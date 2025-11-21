@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'value help'
@Metadata.ignorePropagatedAnnotations: false //Annotationen von /DMO/I_CUSTOMER mit verwenden
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z02_I_Customer_Vh as select from /DMO/I_Customer
{
  key CustomerID,
      LastName,
      PostalCode,
      City
}
