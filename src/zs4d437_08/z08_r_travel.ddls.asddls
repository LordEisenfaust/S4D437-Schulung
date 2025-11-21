@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Travel (Data Model)'

define root view entity Z08_R_TRAVEL
  as select from z08_travel
  composition [0..*] of Z08_R_TRAVELITEM as _Item
  {
//  Old name to new JavaScript name
    key agency_id   as AgencyId,
    key travel_id   as TravelId,
        description as Description,
        customer_id as CustomerId,
        begin_date  as BeginDate,
        end_date    as EndDate,
        @EndUserText.label: 'Duration (days)'
//         dats_days_between( begin_date , dats_add_days( end_date, 1,'FAIL'   ) ) as Duration,
        dats_days_between( begin_date ,  end_date ) + 1 as Duration,
        status      as Status,
        @Semantics.systemDateTime.lastChangedAt: true
        changed_at  as ChangedAt,
        @Semantics.user.lastChangedBy: true
        changed_by  as ChangedBy,
        @Semantics.systemDateTime.localInstanceLastChangedAt: true
        loc_change_at as LocChangeAt,
        
        _Item
  }
