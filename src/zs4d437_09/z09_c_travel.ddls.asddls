@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ProjectionView'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z09_C_Travel
  provider contract transactional_query
  as projection on Z09_R_TRAVEL

{
  key AgencyId,
  key TravelId,
      Description,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'Z09_I_CUSTOMER_VH', element: 'CustomerID' } }]
      CustomerId,
      BeginDate,
      EndDate,
      @EndUserText.label: 'Duration'
      Duration,
      Status,
      ChangedAt,
      ChangedBy,
      LocChangedAt,
      _Item : redirected to composition child Z09_C_TRAVELITEM
}
