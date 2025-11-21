@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z03_C_TRAVEL
  provider contract transactional_query
as projection on Z03_R_TRAVEL
{
    key AgencyId,
    key TravelId,
    Description,
    CustomerId,
    BeginDate,
    EndDate,
    Status,
    ChangedAt,
    ChangedBy,
    LocChangedAt,
    _TravelItem : redirected to composition child Z03_C_TRAVELITEM
    
}
