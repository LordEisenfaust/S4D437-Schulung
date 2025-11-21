CLASS zcx_01_travel DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA: gv_msgv1 TYPE string.

    INTERFACES if_abap_behv_message .

    CONSTANTS:
      BEGIN OF already_canceled,
        msgid TYPE symsgid VALUE 'Z01_MESSAGE',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF already_canceled.

    CONSTANTS:
      BEGIN OF canceled,
        msgid TYPE symsgid VALUE 'Z01_MESSAGE',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF canceled.

    CONSTANTS:
      BEGIN OF already_started,
        msgid TYPE symsgid VALUE 'Z01_MESSAGE',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF already_started.

    CONSTANTS:
      BEGIN OF descr_missing,
        msgid TYPE symsgid VALUE 'Z01_MESSAGE',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF descr_missing.

    CONSTANTS:
      BEGIN OF customer_invalid,
        msgid TYPE symsgid VALUE 'Z01_MESSAGE',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF customer_invalid.

    CONSTANTS:
      BEGIN OF begin_initial,
        msgid TYPE symsgid VALUE 'Z01_MESSAGE',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF begin_initial.

    CONSTANTS:
      BEGIN OF begin_past,
        msgid TYPE symsgid VALUE 'Z01_MESSAGE',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF begin_past.

    CONSTANTS:
      BEGIN OF end_lower_begin,
        msgid TYPE symsgid VALUE 'Z01_MESSAGE',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF end_lower_begin.

      CONSTANTS:
      BEGIN OF status_ok,
        msgid TYPE symsgid VALUE 'Z01_MESSAGE',
        msgno TYPE symsgno VALUE '009',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF status_ok.

      CONSTANTS:
      BEGIN OF travel_date_chg,
        msgid TYPE symsgid VALUE 'Z01_MESSAGE',
        msgno TYPE symsgno VALUE '010',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF travel_date_chg.


    METHODS constructor
      IMPORTING
        !textid  LIKE if_t100_message=>t100key
        severity LIKE if_abap_behv_message~m_severity OPTIONAL
        iv_msgv1 TYPE any OPTIONAL.
  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.

CLASS zcx_01_travel IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( ).

    if_t100_message~t100key = textid.
    gv_msgv1 = |{ iv_msgv1 ALPHA = OUT }|.

    IF severity IS INITIAL.
      if_abap_behv_message~m_severity  = if_abap_behv_message~severity-error.
    ELSE.
      if_abap_behv_message~m_severity = severity.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
