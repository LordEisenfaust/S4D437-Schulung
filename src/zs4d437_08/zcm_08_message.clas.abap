CLASS zcm_08_message DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_abap_behv_message.

    DATA mv_customerid TYPE /dmo/customer_id.
    CONSTANTS:
      BEGIN OF is_canceled,
        msgid TYPE symsgid VALUE 'Z08',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF is_canceled,
      BEGIN OF is_running,
        msgid TYPE symsgid VALUE 'Z08',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF is_running,
      BEGIN OF is_blank,
        msgid TYPE symsgid VALUE 'Z08',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF is_blank,
      BEGIN OF no_customer,
        msgid TYPE symsgid VALUE 'Z08',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'MV_CUSTOMERID',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF no_customer,
      BEGIN OF false_date,
        msgid TYPE symsgid VALUE 'Z08',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF false_date,
      BEGIN OF end_before_Start,
        msgid TYPE symsgid VALUE 'Z08',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'attr1',
        attr2 TYPE scx_attrname VALUE 'attr2',
        attr3 TYPE scx_attrname VALUE 'attr3',
        attr4 TYPE scx_attrname VALUE 'attr4',
      END OF end_before_Start.

    METHODS constructor
      IMPORTING
        !textid    LIKE if_t100_message=>t100key
        !previous  LIKE previous OPTIONAL
        severety   TYPE if_abap_behv_message=>t_severity
        i_customer TYPE /dmo/customer_id OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_08_message IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(
    previous = previous
    ).
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
    if_abap_behv_message~m_severity = severety.
    mv_customerid = i_customer.
  ENDMETHOD.
ENDCLASS.
