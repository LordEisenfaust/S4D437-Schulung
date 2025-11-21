@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Travel (Data Model)'
define root view entity Z03_R_TRAVEL
  as select from z03_travel
  composition [0..*] of Z03_R_TRAVELITEM as _TravelItem
  {
  
// old ABAP names || New JavaScript suitable names  
  
    key agency_id   as AgencyId,
    key travel_id   as TravelId,
        description as Description,
        customer_id as CustomerId,
        begin_date  as BeginDate,
        end_date    as EndDate,
        status      as Status,
        @Semantics.systemDateTime.lastChangedAt: true
        changed_at  as ChangedAt,
        changed_by  as ChangedBy,
        loc_changed_at as LocChangedAt,
                
        _TravelItem   
  }
