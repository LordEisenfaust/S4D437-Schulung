@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Flight Class'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z00_I_Class_Vh 
as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: '/LRN/CLASS_ID' )
{
    value_low as ClassId, 
    text
} where language = $session.system_language
