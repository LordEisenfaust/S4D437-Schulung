CLASS zcm_04_messages DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_abap_behv_message.

    DATA customer_ID TYPE /dmo/customer_id.

    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key "OPTIONAL
        !previous LIKE previous OPTIONAL
        !severity type if_abap_behv_message=>t_severity
        i_customer_id TYPE /dmo/customer_id OPTIONAL.

        constants:
          begin of trip_canceld,
            msgid type symsgid value 'Z00',
            msgno type symsgno value '001',
            attr1 type scx_attrname value 'attr1',
            attr2 type scx_attrname value 'attr2',
            attr3 type scx_attrname value 'attr3',
            attr4 type scx_attrname value 'attr4',
          end of trip_canceld.

        constants:
          begin of trip_started,
            msgid type symsgid value 'Z00',
            msgno type symsgno value '002',
            attr1 type scx_attrname value 'attr1',
            attr2 type scx_attrname value 'attr2',
            attr3 type scx_attrname value 'attr3',
            attr4 type scx_attrname value 'attr4',
          end of trip_started.

        constants:
          begin of customer_not_exist,
            msgid type symsgid value 'Z00',
            msgno type symsgno value '003',
            attr1 type scx_attrname value 'attr1',
            attr2 type scx_attrname value 'attr2',
            attr3 type scx_attrname value 'attr3',
            attr4 type scx_attrname value 'attr4',
          end of customer_not_exist.
        constants:
          begin of start_past,
            msgid type symsgid value 'Z00',
            msgno type symsgno value '004',
            attr1 type scx_attrname value 'attr1',
            attr2 type scx_attrname value 'attr2',
            attr3 type scx_attrname value 'attr3',
            attr4 type scx_attrname value 'attr4',
          end of start_past.
        constants:
          begin of start_initial,
            msgid type symsgid value 'Z04',
            msgno type symsgno value '005',
            attr1 type scx_attrname value 'attr1',
            attr2 type scx_attrname value 'attr2',
            attr3 type scx_attrname value 'attr3',
            attr4 type scx_attrname value 'attr4',
          end of start_initial,
          begin of enddate_initial,
            msgid type symsgid value 'Z04',
            msgno type symsgno value '006',
            attr1 type scx_attrname value 'attr1',
            attr2 type scx_attrname value 'attr2',
            attr3 type scx_attrname value 'attr3',
            attr4 type scx_attrname value 'attr4',
          end of enddate_initial,
          begin of enddate_low,
            msgid type symsgid value 'Z04',
            msgno type symsgno value '007',
            attr1 type scx_attrname value 'attr1',
            attr2 type scx_attrname value 'attr2',
            attr3 type scx_attrname value 'attr3',
            attr4 type scx_attrname value 'attr4',
          end of enddate_low.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_04_messages IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(
    previous = previous
    ).
     if_t100_message~t100key = textid.
     if_abap_behv_message~m_severity = severity.


  ENDMETHOD.
ENDCLASS.
