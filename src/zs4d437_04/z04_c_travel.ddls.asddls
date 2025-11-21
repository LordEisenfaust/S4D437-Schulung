@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z04_C_TRAVEL
  provider contract transactional_query
as projection on Z04_R_TRAVEL
{
    key AgencyId,
    key TravelId,
    Description,
//    @Consumption.valueHelpDefinition: [{entity:{name: 'Z04_I_CUSTOMER_VH',
//                                                element: 'CustomerID'} }]
    CustomerId,
    BeginDate,
    EndDate,
    Status,
    ChangedAt,
    ChangedBy,
    LocChangedAt,
    Duration,
   _Item: redirected to composition child Z04_C_TRAVELITEM
}
