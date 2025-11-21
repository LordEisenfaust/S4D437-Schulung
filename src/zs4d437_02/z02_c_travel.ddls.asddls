@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projektions-View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z02_C_TRAVEL provider contract transactional_query as projection on Z02_R_TRAVEL
{
    key AgencyId,
    key TravelId,
    @Search.defaultSearchElement: true
    Description,
    @Search.defaultSearchElement: true
    @Consumption.valueHelpDefinition: [{ entity: { name: 'Z02_I_CUSTOMER_VH', element: 'CustomerID' } }]
    CustomerId,
    BeginDate,
    Duration,
    EndDate,
    Status,
    ChangedAt,
    ChangedBy,
    LocChangedAt,
    _Item : redirected to composition child Z02_C_TRAVELITEM    
}
