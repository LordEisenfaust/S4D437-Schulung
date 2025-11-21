@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z01_I_CUSTOMER_VH
  as select from /DMO/I_Customer_StdVH
{
  @ObjectModel.text.element: ['FullName']
  key CustomerID,
      FirstName,
      LastName,
      concat_with_space( FirstName, LastName, 1 ) as FullName,
      Title,
      Street,
      PostalCode,
      City,
      CountryCode,
      CountryCodeText,
      PhoneNumber,
      EMailAddress
}
