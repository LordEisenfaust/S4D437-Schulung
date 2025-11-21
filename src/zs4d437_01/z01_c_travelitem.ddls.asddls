@EndUserText.label: 'Flight Travel Item (Projection)'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity Z01_C_TRAVELITEM
  as projection on Z01_R_TRAVELITEM
{
  key ItemUuid,
      AgencyId,
      TravelId,
      CarrierId,
      ConnectionId,
      FlightDate,
      BookingId,
      PassengerFirstName,
      PassengerLastName,
      ChangedAt,
      ChangedBy,
      LocChangedAt,
      _Travel : redirected to parent Z01_C_TRAVEL
}
