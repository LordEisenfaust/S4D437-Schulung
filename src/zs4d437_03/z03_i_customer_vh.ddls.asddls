define root view entity Z03_I_CUSTOMER_VH
    provider contract transactional_query
    as projection on Z03_R_TRAVEL
{
    key AgencyId,
    key TravelId,
    @Search.defaultSearchElement: true
    Description,
    @Search.defaultSearchElement: true
    @Consumption.valueHelpDefinition: [
    { entity: {name: '/DMO/I_CUSTOMER_StdVH', 
               element: 'CustomerID' } }]
    CustomerId    
}
