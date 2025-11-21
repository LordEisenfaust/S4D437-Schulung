CLASS zcm_09_messages DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_abap_behv_message.

    DATA customer_id TYPE string.

    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key
        !previous LIKE previous OPTIONAL
        severity  TYPE if_abap_behv_message=>t_severity
        customer  TYPE /dmo/customer_id OPTIONAL.

    CONSTANTS:
      BEGIN OF trip_cancelled,
        msgid TYPE symsgid VALUE 'Z09',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF trip_cancelled,
      BEGIN OF trip_started,
        msgid TYPE symsgid VALUE 'Z09',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF trip_started,
      BEGIN OF no_customer,
        msgid TYPE symsgid VALUE 'Z09',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'CUSTOMER_ID',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF no_customer,
      BEGIN OF start_past,
        msgid TYPE symsgid VALUE 'Z09',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF start_past,
      BEGIN OF end_past,
        msgid TYPE symsgid VALUE 'Z09',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF end_past,
      BEGIN OF wrong_sequence,
        msgid TYPE symsgid VALUE 'Z09',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF wrong_sequence,
            BEGIN OF flight_date_past,
        msgid TYPE symsgid VALUE 'Z09',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF FLIGHT_DATE_PAST.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_09_messages IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(
    previous = previous
    ).

    if_t100_message~t100key         = textid.
    if_abap_behv_message~m_severity = severity.
    customer_id = |{ customer ALPHA = OUT }|.

  ENDMETHOD.
ENDCLASS.
