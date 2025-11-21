@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Travel (Data Model)'
define root view entity Z06_R_TRAVEL
  as select from z06_travel
  composition[0..*] of z06_R_TRAVELITEM as _Item   //Bezug zu den Positionen 0 zu n
  {
  
  // old AbAP nAME   -- nEW jAVEsCRIPT name
    key agency_id   as AgencyId,
    key travel_id   as TravelId,
        description as Description,
        customer_id as CustomerId,
        begin_date  as BeginDate,
        end_date    as EndDate,
        //Hier nehmen wir das neue Feld Duration auf, wir benötigen es aber nicht 
        //in der DB-Tabelle, da wir es dynmaisch immer neu berechnen
        //Die automatische Berechnung erfolgt hier nur für aktive Sätze in der DB
        //und nicht für Drafts, da diese in der DB-Tabelle Ztabelle _d 
   dats_days_between( begin_date, end_date ) as Duration,
        status      as Status,
        @Semantics.systemDateTime.lastChangedAt: true  //optimis. Sperre
        changed_at  as ChangedAt,
        @Semantics.user.lastChangedBy: true
        changed_by  as ChangedBy,
        @Semantics.systemDateTime.localInstanceLastChangedAt: true
        loc_changed_at as LocChangedAt,
        
        _Item       // auch wieder die Pos aufnehmen
  }
