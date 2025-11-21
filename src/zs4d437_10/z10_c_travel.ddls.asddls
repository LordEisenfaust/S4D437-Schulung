@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root  view entity Z10_C_TRAVEL
  provider contract transactional_query 
as projection on Z10_R_TRAVEL
{
    key AgencyId,
    key TravelId,
        @Search.defaultSearchElement: true
    Description,
        @Search.defaultSearchElement: true
        @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer_StdVH', element: 'CustomerID' }  }]
    CustomerId,
    BeginDate,
    EndDate,
    @EndUserText.label: 'Duration (days)'
    Duration,

    Status,
    
    ChangedAt,
    ChangedBy,
    LocChangedAt,
    _Item : redirected to composition child Z10_C_TRAVELITEM
}
