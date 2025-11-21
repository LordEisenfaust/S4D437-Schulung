@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable:true
define root view entity z07_c_travel
  provider contract transactional_query as projection on z07_r_travel
{
    key AgencyId,
    key TravelId,
    @Search.defaultSearchElement: true
    Description,
    @Search.defaultSearchElement: true
    @Consumption.valueHelpDefinition: [{ entity: { name:    '/dmo/i_customer_StdVH', 
                                         element:           'CustomerID' }  }]
    CustomerId,
    BeginDate,
    EndDate,
    
    @EndUserText.label: 'Duration (days)'
    Duration,
    
    Status,
    ChangedAt,
    ChangedBy,
    LocChangedAt,
    _TravelItem : redirected to composition child z07_C_TRAVELITEM
}
