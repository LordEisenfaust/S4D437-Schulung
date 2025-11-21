CLASS zjm_unmanaged_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES rt_carriers TYPE RANGE OF /dmo/flight-carrier_id.

    TYPES: BEGIN OF t_recordx,
             carrier_id    TYPE abap_bool,
             connection_id TYPE abap_bool,
             airpfrom      TYPE abap_bool,
             cityfrom      TYPE abap_bool,
             airpto        TYPE abap_bool,
             cityto        TYPE abap_bool,
           END OF t_recordx.

    TYPES: BEGIN OF rt_key,
             carrier_id    TYPE zjmconn-carrier_id,
             connection_Id TYPE zjmconn-connection_id,
           END OF rt_key.

    TYPES t_zjmconn TYPE STANDARD TABLE OF zjmconn WITH NON-UNIQUE KEY
    carrier_id connection_id.

    CLASS-METHODS read_flights IMPORTING carriers TYPE rt_carriers
                               EXPORTING flights  TYPE t_zjmconn.
    CLASS-METHODS update_flight IMPORTING  is_record   TYPE zjmconn
                                           is_record_x TYPE t_recordx
                                EXCEPTIONS update_failed.
    CLASS-METHODS create_flight IMPORTING  is_record TYPE zjmconn
                                EXCEPTIONS create_failed.
    CLASS-METHODS delete_flight IMPORTING  is_record TYPE rt_key
                                EXCEPTIONS delete_failed.
    CLASS-METHODS save EXCEPTIONS save_failed.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA create_buffer TYPE t_zjmconn.

ENDCLASS.



CLASS zjm_unmanaged_model IMPLEMENTATION.
  METHOD create_flight.
    IF is_Record-carrier_Id IS INITIAL OR is_record-connection_id IS INITIAL.
      RAISE create_failed.
    ENDIF.
    APPEND is_Record TO create_buffer.
  ENDMETHOD.

  METHOD delete_flight.

  ENDMETHOD.

  METHOD read_flights.
    SELECT FROM zjmconn
    FIELDS *
    WHERE carrier_Id IN @carriers
    INTO TABLE @flights.

  ENDMETHOD.

  METHOD update_flight.

  ENDMETHOD.

  METHOD save.
    IF create_buffer IS NOT INITIAL.
      INSERT zjmconn FROM TABLE @create_buffer ACCEPTING DUPLICATE KEYS.
      IF sy-subrc = 0.
        CLEAR create_buffer.
      ELSE.
        RAISE save_failed.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
