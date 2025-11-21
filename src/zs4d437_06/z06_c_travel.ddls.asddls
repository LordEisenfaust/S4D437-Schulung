@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projektion View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity Z06_C_TRAVEL 
provider contract transactional_query
as projection on Z06_R_TRAVEL
{
    key AgencyId,
    key TravelId,
     @Search.defaultSearchElement: true
    Description,
    @Search.defaultSearchElement: true
    @Consumption.valueHelpDefinition: [ 
    { entity: { name: '/DMO/I_Customer_STdVH', element: 'CustomerID' } }]
    CustomerId,
    BeginDate,
    EndDate,
    @EndUserText.label: 'Duration (days)'
    //Das Feld Duration für den Servie bekannt machen
    Duration,
    Status,
    ChangedAt,
    ChangedBy,
    LocChangedAt,
    _Item : redirected to composition child z06_C_TRAVELITEM
}
