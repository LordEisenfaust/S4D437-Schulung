@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Extension'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@AbapCatalog.extensibility: {
    extensible: true,
    elementSuffix: 'Z02',
    dataSources: [ 'Item' ],
    allowNewDatasources: false
}
define view entity Z02_E_TRAVELITEM as select from Z02_R_TRAVELITEM as Item
{
    key ItemUuid
}
