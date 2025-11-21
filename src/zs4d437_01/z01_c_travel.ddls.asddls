@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Flight Travel (Consumption)'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define root view entity Z01_C_TRAVEL
  provider contract transactional_query
  as projection on Z01_R_TRAVEL
{
  key AgencyId,
  key TravelId,
      Description,
      CustomerId,
      BeginDate,
      EndDate,
      Duration,
      Status,
      ChangedAt,
      LocChangedAt,
      ChangedBy,
      _TravelItem : redirected to composition child Z01_C_TRAVELITEM
}
