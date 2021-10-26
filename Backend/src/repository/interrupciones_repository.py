from sqlalchemy.sql import text


class InterrupcionesRepository:
    def __init__(self, db):
        self.db = db

    def get_interrupciones_bd(self, anio, mes, empresa, causa):
        sql = '''
            SELECT CONVERT(EMPRESA.ARE_ESP_NOMBRE, 'US7ASCII', 'EE8MSWIN1250'),
                INTERR.* 
            FROM 
            (
                SELECT 
                    CONVERT(CP.NOMBRE_CENTRO_POBLADO, 'US7ASCII', 'EE8MSWIN1250'),
                    CP.LONGITUD,
                    CP.LATITUD,
                    TO_CHAR(DANE_INTER.COD_DANE),
                    DANE_INTER.IDENTIFICADOR_EMPRESA,
                    DANE_INTER.CAR_CARG_ANO,
                    DANE_INTER.CAR_CARG_MES,
                    ROUND(DANE_INTER.PNEXC/60,2),
                    ROUND(DANE_INTER.NPNEXC/60,2),
                    ROUND(DANE_INTER.REMER/60,2),
                    ROUND(DANE_INTER.STNSTR/60,2),
                    ROUND(DANE_INTER.SEGCIU/60,2),
                    ROUND(DANE_INTER.FNIVEL1/60,2),
                    ROUND(DANE_INTER.CASTNAT/60,2),
                    ROUND(DANE_INTER.TERR/60,2),
                    ROUND(DANE_INTER.CALZESP/60,2),
                    ROUND(DANE_INTER.TSUBEST/60,2),
                    ROUND(DANE_INTER.INFRA/60,2),
                    ROUND(DANE_INTER.SUMI/60,2),
                    ROUND(DANE_INTER.PEXP/60,2),
                    DANE_INTER.TOTAL_INTER 
                FROM 
                (
                    SELECT 
                        INTER.*,
                        ROUND((PNEXC+NPNEXC+REMER+STNSTR+SEGCIU+FNIVEL1+CASTNAT+TERR+CALZESP+TSUBEST+INFRA+SUMI+PEXP)/60,2) AS TOTAL_INTER 
                    FROM 
                    (
                        SELECT 
                            TRAFODANE.COD_DANE,
                            F5.IDENTIFICADOR_EMPRESA,
                            F5.CAR_CARG_ANO,
                            F5.CAR_CARG_MES,
                            CASE WHEN (:PNEXC_ARG = 16) THEN SUM(F5.CAR_T442_MIN_PBEXC) ELSE 0 END AS PNEXC,
                            CASE WHEN (:NPNEXC_ARG = 18) THEN SUM(F5.CAR_T442_MIN_NPNEXC) ELSE 0 END AS NPNEXC,
                            CASE WHEN (:REMER_ARG = 20) THEN SUM(F5.CAR_T442_MIN_REMER) ELSE 0 END AS REMER,
                            CASE WHEN (:STNSTR_ARG = 22) THEN SUM(F5.CAR_T442_MIN_STNSTR) ELSE 0 END AS STNSTR,
                            CASE WHEN (:SEGCIU_ARG = 24) THEN SUM(F5.CAR_T442_MIN_SEG_CIU) ELSE 0 END AS SEGCIU,
                            CASE WHEN (:FNIVEL1_ARG = 26) THEN SUM(F5.CAR_T442_MIN_FNIVEL1) ELSE 0 END AS FNIVEL1,
                            CASE WHEN (:CASTNAT_ARG = 28) THEN SUM(F5.CAR_T442_MIN_CASTNAT) ELSE 0 END AS CASTNAT,
                            CASE WHEN (:TERR_ARG = 30) THEN SUM(F5.CAR_T442_MIN_TERR) ELSE 0 END AS TERR,
                            CASE WHEN (:CALZESP_ARG = 32) THEN SUM(F5.CAR_T442_MIN_CAL_ZESP) ELSE 0 END AS CALZESP,
                            CASE WHEN (:TSUBEST_ARG = 34) THEN SUM(F5.CAR_T442_MIN_TSUBEST) ELSE 0 END AS TSUBEST,
                            CASE WHEN (:INFRA_ARG = 36) THEN SUM(F5.CAR_T442_MIN_INFRA) ELSE 0 END AS INFRA,
                            CASE WHEN (:SUMI_ARG = 38) THEN SUM(F5.CAR_T442_MIN_SUMI) ELSE 0 END AS SUMI,
                            CASE WHEN (:PEXP_ARG = 40) THEN SUM(F5.CAR_T442_MIN_EXP) ELSE 0 END AS PEXP 
                        FROM 
                        (
                            SELECT 
                                * 
                            FROM 
                                CARG_COMERCIAL_E.CAR_T442_FORMATO5 
                            WHERE 
                                CAR_CARG_ANO = :ANIO_ARG
                                AND (IDENTIFICADOR_EMPRESA = :EMPRESA_ARG OR 0 = :EMPRESA_ARG)
                                AND (CAR_CARG_MES = :MES_ARG)
                        ) F5,
                        (SELECT * FROM TRAFO_DANE) TRAFODANE 
                        WHERE 
                            F5.CAR_T442_COD_TRANS = TRAFODANE.COD_TRAFO
                            AND F5.IDENTIFICADOR_EMPRESA = TRAFODANE.IDENTIFICADOR_EMPRESA 
                        GROUP BY 
                            TRAFODANE.COD_DANE,
                            F5.IDENTIFICADOR_EMPRESA,
                            F5.CAR_CARG_ANO,
                            F5.CAR_CARG_MES
                    ) INTER 
                    WHERE PNEXC+NPNEXC+REMER+STNSTR+SEGCIU+FNIVEL1+CASTNAT+TERR+CALZESP+TSUBEST+INFRA+SUMI+PEXP > 0
                ) DANE_INTER,
                (SELECT * FROM JHERRERAA.GIS_CENTRO_POBLADO) CP 
                WHERE DANE_INTER.COD_DANE = CP.CODIGO_CENTRO_POBLADO
            )INTERR,
            (
                SELECT * FROM 
                (
                    SELECT DISTINCT EMP.ARE_ESP_SECUE,
                        EMP.ARE_ESP_NOMBRE,
                        'ENERGIA' SERVICIO 
                    FROM 
                        RUPS.ARE_ESP_EMPRESAS EMP,
                        RUPS.ARE_SEES_SERESP ROM,
                        RUPS.ARE_NESP_NATESP NES,
                        RUPS.ARE_ACES_ACTESP ACT 
                    WHERE 
                        ROM.ARE_ESP_SECUE = EMP.ARE_ESP_SECUE
                        AND ROM.ARE_ESP_SECUE = NES.ARE_ESP_SECUE
                        AND ROM.ARE_ESP_SECUE = ACT.ARE_ESP_SECUE
                        AND EMP.ARE_ESP_SECUE < 99900
                        AND ROM.ARE_SEES_ESTADO = 'O'
                        AND NES.ARE_NESP_ESTADO = 'O'
                        AND ACT.ARE_ACES_ESTADO = 'O'
                        AND EMP.ARE_ESP_ACTUALIZA IS NOT NULL
                        AND EMP.ARE_ESP_ESTACT = 'A'
                        AND EMP.ARE_ESP_SECUE_CREG <> 0 
                    GROUP BY 
                            EMP.ARE_ESP_SECUE,
                            EMP.ARE_ESP_NOMBRE,
                            EMP.ARE_ESP_ACTUALIZA,
                            EMP.ARE_ESP_ESTACT,
                            EMP.ARE_ESP_SECUE_CREG,
                            'ENERGIA' 
                    UNION 
                    SELECT ARE_ESP_SECUE,
                        ARE_ESP_NOMBRE,
                        'ENERGIA' SERVICIO 
                    FROM 
                        RUPS.ARE_ESP_EMPRESAS
                    WHERE ARE_ESP_SECUE = 44278
                )
            )EMPRESA 
            WHERE IDENTIFICADOR_EMPRESA = ARE_ESP_SECUE
        '''
        return self.db.engine.execute(text(sql), ANIO_ARG=2019, MES_ARG=1, EMPRESA_ARG=2103, PNEXC_ARG=16, NPNEXC_ARG=0, REMER_ARG=0, STNSTR_ARG=0, 
        SEGCIU_ARG=0, FNIVEL1_ARG=0, CASTNAT_ARG=0, TERR_ARG=0, CALZESP_ARG=0, TSUBEST_ARG=0, INFRA_ARG=0, SUMI_ARG=0, PEXP_ARG=0).fetchall()