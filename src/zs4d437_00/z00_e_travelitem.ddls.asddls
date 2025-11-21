@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Extension View for Travel Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED

}
@AbapCatalog.extensibility: {
    extensible: true,
    elementSuffix: 'Z00',
    dataSources: [ 'Item' ],
    allowNewDatasources: false
}    
define view entity Z00_E_TRAVELITEM as select from Z00_R_TRAVELITEM
as Item
{
    key ItemUuid
   
}
