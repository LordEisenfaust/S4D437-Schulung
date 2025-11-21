@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fligh Travel'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define root view entity Z08_C_TRAVEL
  provider contract transactional_query
  as projection on Z08_R_TRAVEL
{
  key AgencyId,
  key TravelId,
      Description,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{
                            entity:
                            { name: 'Z08_I_CUSTOMER',
                              element: 'CustomerID' }
                              } ]
      CustomerId,
      BeginDate,
      EndDate,
      Duration,
      Status,
      ChangedAt,
      ChangedBy,
      LocChangeAt,
      
      _Item : redirected to composition child Z08_C_TRAVELITEM
      
}
