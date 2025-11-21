@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z00_C_Travel
  provider contract transactional_query 
as projection on Z00_R_TRAVEL
{
    key AgencyId,
    key TravelId,
    Description,
   @Consumption.valueHelpDefinition: [{ entity: { name: 'Z00_I_CUSTOMER_VH', element: 'CustomerID' } }]
    CustomerId,
    BeginDate,
    EndDate,
    Duration, 
    Status,
    ChangedAt,
    ChangedBy,
    LocChangedAt,
    _Item : redirected to composition child z00_c_travelitem
}
