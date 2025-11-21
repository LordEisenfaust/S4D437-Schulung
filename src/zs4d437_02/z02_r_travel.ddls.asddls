@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Travel (Data Model)'
define root view entity Z02_R_TRAVEL
  as select from z02_travel
  composition [0..*] of Z02_R_TRAVELITEM as _Item
{

      // old ABAP names || New JavaScript suitable names

  key agency_id                                 as AgencyId,
  key travel_id                                 as TravelId,
      description                               as Description,
      customer_id                               as CustomerId,
      begin_date                                as BeginDate,
      dats_days_between( begin_date, end_date ) as Duration,
      end_date                                  as EndDate,
      status                                    as Status,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at                                as ChangedAt,
      @Semantics.user.lastChangedBy: true
      changed_by                                as ChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      localchanged_at                           as LocChangedAt,
      _Item
}
