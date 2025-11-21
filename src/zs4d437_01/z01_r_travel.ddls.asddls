@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Flight Travel (Data Model)'
define root view entity Z01_R_TRAVEL
  as select from z01_travel
  composition [0..*] of Z01_R_TRAVELITEM as _TravelItem
{
  key agency_id   as AgencyId,
  key travel_id   as TravelId,
      description as Description,
      customer_id as CustomerId,
      begin_date  as BeginDate,
      end_date    as EndDate,
      dats_days_between($projection.BeginDate, $projection.EndDate) as Duration,
      status      as Status,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at  as ChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      loc_changed_at as LocChangedAt,
      @Semantics.user.lastChangedBy: true
      changed_by  as ChangedBy,
      _TravelItem
}
