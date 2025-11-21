@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Connection'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Zjm_R_Connection as select from zjmconn

{
 
 key carrier_id as CarrierId,
 key connection_id as ConnectionId,
 airpfrom as Airpfrom,
 cityfrom as Cityfrom,
 airpto as Airpto,
 cityto as Cityto,
 @Semantics.systemDateTime.createdAt: true
 changed_at as ChangedAt,
 loc_changed_at as LocChangedAt
    
}
