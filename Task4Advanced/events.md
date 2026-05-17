# Каталог доменных событий

События именуются в прошедшем времени (**fact**). Указаны **источник bounded context**, краткая **семантика** и **минимальный контракт** (поля концептуально; фактическая схема — в Schema Registry).

Политика: в топики для **Mart / внешних подписчиков** не попадают PHI и детали медицинских исследований — только разрешённые атрибуты и обобщения.

---

## Клиники

| Событие | Источник (BC) | Семантика | Минимальный контракт | Основные подписчики |
|---------|----------------|-----------|----------------------|---------------------|
| `PatientRegistered` | Patient Identity | заведена учётная запись пациента для обслуживания в сети клиник | `patientId`, `registeredAt`, `clinicOrgId`; без диагнозов | CRM/уведомления, Mart (демография по политике) |
| `VisitScheduled` | Visit Management | забронирован приём | `visitId`, `patientId`, `slotStart`, `departmentId` | напоминания, операционная аналитика |
| `VisitCompleted` | Visit Management | приём завершён | `visitId`, `completedAt`, `visitTypeCode` | биллинг (ACL), Mart (потоки без PHI) |
| `ClinicalOrderPlaced` | Clinical Documentation | заказана услуга/исследование в рамках случая | `orderId`, `encounterId`, `serviceCode`, `orderedAt`; **без результатов и заключений** | логистика, Mart (объёмы услуг) |

---

## Финтех

| Событие | Источник (BC) | Семантика | Минимальный контракт | Основные подписчики |
|---------|----------------|-----------|----------------------|---------------------|
| `AccountOpened` | Accounts & Ledger | открыт счёт | `accountId`, `partyId`, `productCode`, `openedAt` | Mart, AML/мониторинг |
| `PaymentCaptured` | Payments | успешное списание/зачисление | `paymentId`, `amount`, `currency`, `capturedAt`, `accountId` | бухгалтерия, Mart, fraud |
| `PaymentFailed` | Payments | отказ платежа | `paymentId`, `reasonCode`, `failedAt` | retry/коллекшн, Mart |
| `CreditAgreementCreated` | Lending | создан кредитный договор (пакет условий) | `agreementId`, `partyId`, `principal`, `createdAt`, `status=DRAFT` | скоринг-аудит, Mart |
| `CreditAgreementActivated` | Lending | договор вступил в силу | `agreementId`, `activatedAt` | начисления, риск-витрины |

---

## ИИ

| Событие | Источник (BC) | Семантика | Минимальный контракт | Основные подписчики |
|---------|----------------|-----------|----------------------|---------------------|
| `AISessionRequested` | Inference Session | запрошена сессия поддержки решения | `sessionId`, `requestedAt`, `modelReleaseId`; **без сырья исследований в payload** | оркестрация GPU, аудит нагрузки |
| `AIDiagnosticHypothesisRecorded` | Inference Session | зафиксирован вывод модели (в клиническом контуре) | `sessionId`, `hypothesisCode` (обобщённо), `recordedAt`, `modelReleaseId` | клинический UI (sync), обучение с **отдельным гейтом** на данные |
| `AIModelInferenceAudited` | Inference Session | тех. аудит инференса | `sessionId`, `latencyMs`, `outcomeClass` | SRE, качество сервиса |
| `MlModelPromotedToProduction` | Model Lifecycle | модель допущена в прод | `modelReleaseId`, `promotedAt`, `performanceMetricsRef` | Inference, каталог возможностей |

---

## Партнёры

| Событие | Источник (BC) | Семантика | Минимальный контракт | Основные подписчики |
|---------|----------------|-----------|----------------------|---------------------|
| `PrescriptionFulfillmentSubmitted` | Pharma Integration | партнёр сообщил об отгрузке/исполнении | `partnerRxRef`, `sku`, `quantity`, `submittedAt`; связь с внутренним заказом через ACL map | склад/комплаенс, Mart |
| `DeviceObservationReceived` | Device Telemetry | поток наблюдений с оборудования | `deviceId`, `observationType`, `timestamp`, `valueRange`; без пациента в открытом топике при необходимости псевдонима | мониторинг парка устройств, исследовательские витрины |

---

## Платформа данных

| Событие | Источник (BC) | Семантика | Минимальный контракт | Основные подписчики |
|---------|----------------|-----------|----------------------|---------------------|
| `DataContractPublished` | Integration Contracts | опубликована новая версия схемы события | `schemaId`, `version`, `topic`, `compatMode` | все домены-публикаторы, CI контрактных тестов |

---

### Замечание по именованию топиков

Рекомендуется префиксация по домену: `clinical.visit`, `fintech.payment`, `ai.session`, `partner.pharma` — упрощает ACL, ACL-кэши и правила доступа на уровне брокера.
