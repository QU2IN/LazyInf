-------------------------------------------------------------------------------
------------------------Общие атрибуты ценных бумаг----------------------------
select
    ISS.HK  as SEC_HK,                 --Идентификатор ценной бумаги на источнике
	IDBR.FI_KEY as SEC_ID_BR_CD,           --ID BR ценной бумаги
    INST.INSTR_NM as SEC_NM,                  --Наименование ценной бумаги
    nvl(SPR_TP_CB_V.MDM_ENTITY_CLUSTER_ID,-1) as SEC_TP_CLUSTER_SQN,    --Ссылка на тип ценной бумаги
	FI_TP.FI_TYPE_NM as SEC_TP_NM,       --Вид ценной бумаги
	FI_ISS.ISIN_CD as SEC_ISIN_CD,        --Международный идентификационный код ценной бумаги (ISIN)
	FI_ISS.CFI_CD as SEC_CFI_CD,           --Международный код классификации финансовых инструментов (CFI)
	nvl(FI_ISS.REG_NUM_CD,UNIT_HS.REG_NUM_CD) as SEC_REG_CD	,	--Государственный регистрационный код ценной бумаги
	max(FI_INS_SBJ_L.SUBJECT_HK) as SEC_SBJ_HK,				 --Идентификатор субъекта на источнике
	CUR.ISO_LAT_CD as CCY_TP_CD	,	--	Код валюты номинала
	nvl(OKV_V.MDM_ENTITY_CLUSTER_ID,-1) as CCY_CLUSTER_SQN	,	--	Ссылка на вид валюты
	COALESCE(BOND_HS.ISSUE_REG_DT,ACT_HS.ISSUE_REG_DT,RDR_HS.ISSUE_REG_DT,UNIT_HS.ISSUE_REG_DT) as REG_DT	,	--	Дата внесения записи в реестр
    COALESCE(BOND_HS.PLACEMENT_START_DT,ACT_HS.PLACEMENT_START_DT,RDR_HS.PLACEMENT_START_DT,MORTGAGE_HS.PLACEMENT_START_DT,UNIT_HS.PLACEMENT_START_DT, CLEARING_HS.PLACEMENT_START_DT) as POST_START_DT	,	--	Дата начала размещения
    COALESCE(BOND_HS.PLACEMENT_END_DT,ACT_HS.PLACEMENT_END_DT,RDR_HS.PLACEMENT_END_DT,MORTGAGE_HS.PLACEMENT_END_DT, UNIT_HS.PLACEMENT_END_DT, CLEARING_HS.PLACEMENT_END_DT) as POST_END_DT	,	--	Дата окончания размещения
	BOND_HS.MATURITY_DT as REPAY_DT	,	--	Дата (срок) погашения
	PROSP.HK as ISSUE_CD	,	--	Идентификатор проспекта выпуска
	COALESCE(BOND_HS.PAR_VALUE_CNT,BOND_HS.PAR_VALUE_EUROBOND_CNT,ACT_HS.PAR_VALUE_CNT,MORTGAGE_HS.PAR_VALUE_CNT,CLEARING_HS.PAR_VALUE_CNT) as SEC_COST_NVAL	,	--	Номинальная стоимость ценной бумаги
	COALESCE(BOND_HS.FOR_PLACEMENT_CNT,ACT_HS.FOR_PLACEMENT_CNT) as ISSUE_VOLUME_CNT	,	--	Объем выпуска, шт.
	COALESCE(BOND_HS.MIN_LOT_CNT,ACT_HS.MIN_LOT_CNT,MORTGAGE_HS.MIN_LOT_CNT,CLEARING_HS.MIN_LOT_CNT) as ISSUE_SIZE_NVAL	,	--	Размер лота
	COALESCE(BOND_HS.PLACED_ISS_CNT/BOND_HS.PAR_VALUE_CNT/BOND_HS.MIN_LOT_CNT,ACT_HS.FOR_PLACEMENT_CNT,RDR_HS.QUARTER_QUANTITY_SECURITY) as ISSUE_SIZE_POST_NVAL	,	--	Размещённый объем выпуска, шт.
	IDBR.FI_KEY as ISSUE_SEC_ID_BR_CD	,	--	ID BR выпуска ценной бумаги
	PLACE.FI_PLACEMENT_NM as POST_TP_NM	,	--	Вид размещения
    nvl(SPR_ISSUE_TP_V.MDM_ENTITY_CLUSTER_ID,-1) as ISSUE_TP_CLUSTER_SQN	,	--	Ссылка на тип выпуска ценных бумаг
	FI_ISS.ISSUE_NUM_CD as ISSUE_NUM_CD	,	--	Номер выпуска
    ISS.SRC_SYS_ID as SEC_SRC_SYS_ID,  --Система-источник
    INST.START_DTTM as START_DTTM,             --Дата начала действия записи
    INST.END_DTTM as END_DTTM             --Дата окончания действия записи

from DEV_CBRSPB_RDV.FI_INSTRUMENT_H@khd FI_INST_H -- Финансовые инструменты

inner join DEV_CBRSPB_RDV.FI_INSTRUMENT_HS@khd INST --Спутник узла Финансовые инструменты
on INST.HK = FI_INST_H.HK and INST.SRC_SYS_ID = FI_INST_H.SRC_SYS_ID
and INST.START_DTTM<=SYSDATE --параметр
and INST.END_DTTM>=SYSDATE --параметр
and INST.LOAD_END_DTTM>=SYSDATE --не параметр

-----Определение вида ценной бумаги
left join DEV_CBRSPB_NSI.FI_TYPE_R@khd FI_TP --Тип финансового инструмента (акция, облигация, итд)
on FI_TP.HK = INST.TYPE_HK and FI_TP.SRC_SYS_ID=43--параметр
-----Справочник МДМ типов ценных бумаг
left join MDM_DATA.SPR_TP_CB_V SPR_TP_CB_V
on FI_TP.FI_TYPE_NM=SPR_TP_CB_V.TYPE_NM
and SPR_TP_CB_V.EFFECTIVE_FROM_DT<=SYSDATE --параметр
and SPR_TP_CB_V.EFFECTIVE_TO_DT>=SYSDATE --параметр

-----Опредление Международных кодов ISIN и CFI
inner join DEV_CBRSPB_RDV.FI_INSTRUMENT_ISSUE_L@khd FI_INS_L --Линк Финансовые инструменты - Выпуски ценных бумаг
on FI_INS_L.FI_SEC_HK = FI_INST_H.HK and FI_INS_L.SRC_SYS_ID = FI_INST_H.SRC_SYS_ID

inner join DEV_CBRSPB_RDV.FI_ISSUE_H@khd ISS --Выпуски ценных бумаг
on ISS.HK = FI_INS_L.FI_ISS_HK and ISS.SRC_SYS_ID = FI_INS_L.SRC_SYS_ID

inner join DEV_CBRSPB_RDV.FI_ISSUE_HS@khd FI_ISS -- Спутник узла Выпуски ценных бумаг - Общие атрибуты
on FI_ISS.HK = ISS.HK and FI_ISS.SRC_SYS_ID = ISS.SRC_SYS_ID
and FI_ISS.START_DTTM<=SYSDATE --параметр
and FI_ISS.END_DTTM>=SYSDATE --параметр
and FI_ISS.LOAD_END_DTTM>=SYSDATE --не параметр

-----Определение субъекта
left join DEV_CBRSPB_RDV.FI_INSTRUMENT_SUBJECT_L@khd FI_INS_SBJ_L --Линк Финансовые инструменты - Организации
on FI_INST_H.HK=FI_INS_SBJ_L.FI_HK and FI_INST_H.SRC_SYS_ID=FI_INS_SBJ_L.SRC_SYS_ID

-----Определение ID BR ценной бумаги
left join SIT_DM_NFO_OUT.V_RP_PURCB_RATE_2_1 IDBR
on FI_ISS.ISIN_CD=IDBR.ISIN
--когда появятся нормальные данные, возможно начнёт тормозить из-за OR
or (FI_ISS.REG_NUM_CD=IDBR.REG_NUM and IDBR.REPORT_DATE>=INST.START_DTTM and IDBR.REPORT_DATE<=INST.END_DTTM)

--привязка характеристик различных типов ценных бумаг
left join DEV_CBRSPB_RDV.FI_SHARE_ISSUE_HS@khd ACT_HS --Спутник узла Выпуски ценных бумаг - Выпуски акций
on ISS.HK=ACT_HS.HK and ISS.SRC_SYS_ID=ACT_HS.SRC_SYS_ID
and ACT_HS.START_DTTM<=SYSDATE --параметр
and ACT_HS.END_DTTM>=SYSDATE --параметр
and ACT_HS.LOAD_END_DTTM>=SYSDATE --не параметр

left join DEV_CBRSPB_RDV.FI_BOND_ISSUE_HS@khd BOND_HS --Спутник узла Выпуски ценных бумаг - Выпуски облигаций
on ISS.HK=BOND_HS.HK and ISS.SRC_SYS_ID=BOND_HS.SRC_SYS_ID
and BOND_HS.START_DTTM<=SYSDATE --параметр
and BOND_HS.END_DTTM>=SYSDATE --параметр
and BOND_HS.LOAD_END_DTTM>=SYSDATE --не параметр

left join DEV_CBRSPB_RDV.FI_RDR_ISSUE_HS@khd RDR_HS --Спутник узла Выпуски ценных бумаг -  Депозитарные расписки
on ISS.HK=RDR_HS.HK and ISS.SRC_SYS_ID=RDR_HS.SRC_SYS_ID
and RDR_HS.START_DTTM<=SYSDATE --параметр
and RDR_HS.END_DTTM>=SYSDATE --параметр
and RDR_HS.LOAD_END_DTTM>=SYSDATE --не параметр

left join DEV_CBRSPB_RDV.FI_UNIT_ISSUE_HS@khd UNIT_HS --Спутник узла Выпуск ценной бумаги - Инвестиционные паи
on ISS.HK=UNIT_HS.HK and ISS.SRC_SYS_ID=UNIT_HS.SRC_SYS_ID
and UNIT_HS.START_DTTM<=SYSDATE --параметр
and UNIT_HS.END_DTTM>=SYSDATE --параметр
and UNIT_HS.LOAD_END_DTTM>=SYSDATE --не параметр

left join DEV_CBRSPB_RDV.FI_MORTGAGE_INSTRUMENT_HS@khd MORTGAGE_HS --Ипотечные сертификаты участия (ИСУ)
on ISS.HK=MORTGAGE_HS.HK and ISS.SRC_SYS_ID=MORTGAGE_HS.SRC_SYS_ID
and MORTGAGE_HS.START_DTTM<=SYSDATE --параметр
and MORTGAGE_HS.END_DTTM>=SYSDATE --параметр
and MORTGAGE_HS.LOAD_END_DTTM>=SYSDATE --не параметр

left join DEV_CBRSPB_RDV.FI_CLEARING_INSTRUMENT_HS@khd CLEARING_HS --КСУ
on ISS.HK=CLEARING_HS.HK and ISS.SRC_SYS_ID=CLEARING_HS.SRC_SYS_ID
and CLEARING_HS.START_DTTM<=SYSDATE --параметр
and CLEARING_HS.END_DTTM>=SYSDATE --параметр
and CLEARING_HS.LOAD_END_DTTM>=SYSDATE --не параметр

--определение валюты номинала
left join DEV_CBRSPB_NSI.OKV_RS@khd CUR
on INST.OKV_HK=CUR.HK and INST.SRC_SYS_ID=CUR.SRC_SYS_ID
and CUR.START_DTTM<=SYSDATE --параметр
and CUR.END_DTTM>=SYSDATE --параметр

--связь со справочником ОКВ
left join MDM_DATA.OKV_V OKV_V
on CUR.ISO_LAT_CD=OKV_V.ISO_LAT3
and OKV_V.EFFECTIVE_FROM_DT<=SYSDATE --параметр
and OKV_V.EFFECTIVE_TO_DT>=SYSDATE --параметр

left join DEV_CBRSPB_RDV.FI_ISSUE_PROSPECTUS_HS@khd PROSP --Спутник узла Выпуски ценных бумаг - Проспект выпуска ценной бумаги
on ISS.HK=PROSP.HK and ISS.SRC_SYS_ID=PROSP.SRC_SYS_ID
and PROSP.START_DTTM<=SYSDATE --параметр
and PROSP.END_DTTM>=SYSDATE --параметр
and PROSP.LOAD_END_DTTM>=SYSDATE --не параметр

left join DEV_CBRSPB_NSI.FI_PLACEMENT_RS@khd PLACE
on BOND_HS.FI_PLACEMENT_HK=PLACE.HK	and BOND_HS.SRC_SYS_ID=PLACE.SRC_SYS_ID
and PLACE.START_DTTM<=SYSDATE --параметр
and PLACE.END_DTTM>=SYSDATE --параметр
and PLACE.LOAD_END_DTTM>=SYSDATE --не параметр

-----Справочник МДМ типов выпусков ценных бумаг
left join MDM_DATA.SPR_ISSUE_TP_V SPR_ISSUE_TP_V
on FI_ISS.MAIN_ADD_IND=decode(SPR_ISSUE_TP_V.TYPE_NM,'Основной','M','Дополнительный','A')
and SPR_ISSUE_TP_V.EFFECTIVE_FROM_DT<=SYSDATE --параметр
and SPR_ISSUE_TP_V.EFFECTIVE_TO_DT>=SYSDATE --параметр

group by     ISS.HK  ,                 --Идентификатор ценной бумаги на источнике
	IDBR.FI_KEY ,           --ID BR ценной бумаги
    INST.INSTR_NM ,                  --Наименование ценной бумаги
    nvl(SPR_TP_CB_V.MDM_ENTITY_CLUSTER_ID,-1),    --Ссылка на тип ценной бумаги
	FI_TP.FI_TYPE_NM ,       --Вид ценной бумаги
	FI_ISS.ISIN_CD ,        --Международный идентификационный код ценной бумаги (ISIN)
	FI_ISS.CFI_CD,           --Международный код классификации финансовых инструментов (CFI)
	nvl(FI_ISS.REG_NUM_CD,UNIT_HS.REG_NUM_CD) 	,	--Государственный регистрационный код ценной бумаги
	CUR.ISO_LAT_CD 	,	--	Код валюты номинала
	nvl(OKV_V.MDM_ENTITY_CLUSTER_ID,-1) 	,	--	Ссылка на вид валюты
	COALESCE(BOND_HS.ISSUE_REG_DT,ACT_HS.ISSUE_REG_DT,RDR_HS.ISSUE_REG_DT,UNIT_HS.ISSUE_REG_DT) 	,	--	Дата внесения записи в реестр
    COALESCE(BOND_HS.PLACEMENT_START_DT,ACT_HS.PLACEMENT_START_DT,RDR_HS.PLACEMENT_START_DT,MORTGAGE_HS.PLACEMENT_START_DT,UNIT_HS.PLACEMENT_START_DT, CLEARING_HS.PLACEMENT_START_DT) 	,	--	Дата начала размещения
    COALESCE(BOND_HS.PLACEMENT_END_DT,ACT_HS.PLACEMENT_END_DT,RDR_HS.PLACEMENT_END_DT,MORTGAGE_HS.PLACEMENT_END_DT, UNIT_HS.PLACEMENT_END_DT, CLEARING_HS.PLACEMENT_END_DT) 	,	--	Дата окончания размещения
	BOND_HS.MATURITY_DT 	,	--	Дата (срок) погашения
	PROSP.HK 	,	--	Идентификатор проспекта выпуска
	COALESCE(BOND_HS.PAR_VALUE_CNT,BOND_HS.PAR_VALUE_EUROBOND_CNT,ACT_HS.PAR_VALUE_CNT,MORTGAGE_HS.PAR_VALUE_CNT,CLEARING_HS.PAR_VALUE_CNT) 	,	--	Номинальная стоимость ценной бумаги
	COALESCE(BOND_HS.FOR_PLACEMENT_CNT,ACT_HS.FOR_PLACEMENT_CNT) 	,	--	Объем выпуска, шт.
	COALESCE(BOND_HS.MIN_LOT_CNT,ACT_HS.MIN_LOT_CNT,MORTGAGE_HS.MIN_LOT_CNT,CLEARING_HS.MIN_LOT_CNT) 	,	--	Размер лота
	COALESCE(BOND_HS.PLACED_ISS_CNT/BOND_HS.PAR_VALUE_CNT/BOND_HS.MIN_LOT_CNT,ACT_HS.FOR_PLACEMENT_CNT,RDR_HS.QUARTER_QUANTITY_SECURITY) 	,	--	Размещённый объем выпуска, шт.
	IDBR.FI_KEY 	,	--	ID BR выпуска ценной бумаги
	PLACE.FI_PLACEMENT_NM 	,	--	Вид размещения
    nvl(SPR_ISSUE_TP_V.MDM_ENTITY_CLUSTER_ID,-1)	,	--	Ссылка на тип выпуска ценных бумаг
	FI_ISS.ISSUE_NUM_CD ,	--	Номер выпуска
    ISS.SRC_SYS_ID ,  --Система-источник
    INST.START_DTTM ,             --Дата начала действия записи
    INST.END_DTTM             --Дата окончания действия записи
;