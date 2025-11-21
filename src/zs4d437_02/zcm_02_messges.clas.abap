CLASS zcm_02_messges DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_abap_behv_message.

    DATA: customer_id TYPE /dmo/customer_id.

    METHODS constructor
      IMPORTING
        !textid       LIKE if_t100_message=>t100key
        !previous     LIKE previous OPTIONAL
        !severity     TYPE if_abap_behv_message=>t_severity
        i_customer_id TYPE /dmo/customer_id OPTIONAL.

    "text eingeben und STRG + Leertaste dann
    CONSTANTS:
      BEGIN OF trip_cancelled,
        msgid TYPE symsgid VALUE 'Z02',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF trip_cancelled.

    CONSTANTS:
      BEGIN OF trip_started,
        msgid TYPE symsgid VALUE 'Z02',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF trip_started.

    CONSTANTS:
      BEGIN OF empty_field,
        msgid TYPE symsgid VALUE 'Z02',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF empty_field.

    CONSTANTS:
      BEGIN OF wrong_CustomerId,
        msgid TYPE symsgid VALUE 'Z02',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'CUSTOMER_ID',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF wrong_CustomerId.

    CONSTANTS:
      BEGIN OF start_past_start,
        msgid TYPE symsgid VALUE 'Z02',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF start_past_start.

    CONSTANTS:
      BEGIN OF start_past_end,
        msgid TYPE symsgid VALUE 'Z02',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF start_past_end.

    CONSTANTS:
      BEGIN OF start_end,
        msgid TYPE symsgid VALUE 'Z02',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF start_end.

    CONSTANTS:
      BEGIN OF flight_outside_trip,
        msgid TYPE symsgid VALUE 'Z02',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF flight_outside_trip.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_02_messges IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(
    previous = previous
    ).
    if_t100_message~t100key = textid.
    if_abap_behv_message~m_severity = severity.
    customer_id = i_customer_id.

  ENDMETHOD.
ENDCLASS.
