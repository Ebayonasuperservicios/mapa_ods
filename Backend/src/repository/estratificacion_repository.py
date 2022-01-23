from sqlalchemy.sql import text


class EstratificacionRepository:
    def __init__(self, db):
        self.db = db

    def get_estratificacion_bd(self, servicio, anio, mes, empresa, dpto, mpio, cpoblado, opcion):
        if opcion == 1:
            print('OPCION --> ', opcion)
            # Estratos registrados por el prestador iguales a los de la alcaldía
            sql = '''
                SELECT * FROM (
                SELECT TC1.SUM_CON_ANO, TC1.SUM_CON_PERIODO, /*TC1.IDENTIFICADOR_EMPRESA, CONVERT(ESP.ARE_ESP_NOMBRE, 'US7ASCII', 'EE8MSWIN1250') ARE_ESP_NOMBRE,*/ DIVIPOLA.CODIGO_CENTRO_POBLADO
                , CONVERT(DIVIPOLA.NOMBRE_CENTRO_POBLADO, 'US7ASCII', 'EE8MSWIN1250'), DIVIPOLA.LONGITUD, DIVIPOLA.LATITUD, TC1.ESTRATO, TC1.USUARIOS, ALCALDIA.CONTEO, (TC1.USUARIOS - ALCALDIA.CONTEO) AS VALIDACION
                FROM (--CONSOLIDADO COMERCIAL
                    SELECT C.SUM_CON_ANO, C.SUM_CON_PERIODO, /*C.IDENTIFICADOR_EMPRESA,*/ (LPAD(C.SUM_CON_DEPTO,2,'0') || LPAD(C.SUM_CON_MUNICIPIO,3,'0') || LPAD(C.SUM_CON_CNRPBLADO,3,'0')) DANE
                        , (CASE WHEN C.SUM_CON_ESTRATO NOT BETWEEN 1 AND 6 THEN 9 ELSE C.SUM_CON_ESTRATO END) ESTRATO, SUM(C.SUM_CON_NROFACTURAS) USUARIOS
                    FROM SUM_SUI.SUM_CON_CONSOLIDA C        
                    WHERE C.SUM_CON_SERVICIO=:SERVICIO_ARG
                        AND C.SUM_CON_ANO=:ANIO_ARG --ANIO (REMPLAZAR EL 2021 POR LA VARIABLE DEL FRONT)
                        AND C.SUM_CON_PERIODO=:MES_ARG --MES (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
                        AND (C.IDENTIFICADOR_EMPRESA = :EMPRESA_ARG OR 0 = :EMPRESA_ARG) --ID_ESP (REMPLAZAR EL 2103 POR LA VARIABLE DEL FRONT)
                        AND (C.SUM_CON_DEPTO = :DPTO_ARG OR 'TODOS' = :DPTO_ARG) --CODDEPTO (REMPLAZAR EL 8 POR LA VARIABLE DEL FRONT)
                        AND (C.SUM_CON_MUNICIPIO = :MPO_ARG OR 'TODOS' = :MPO_ARG) --CODMPIO (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
                        AND (C.SUM_CON_CNRPBLADO = :CPOBLADO_ARG OR 'TODOS' = :CPOBLADO_ARG) --CODCPOBLADO (REMPLAZAR EL 0 POR LA VARIABLE DEL FRONT)
                    GROUP BY C.SUM_CON_ANO, C.SUM_CON_PERIODO, /*C.IDENTIFICADOR_EMPRESA,*/ (LPAD(C.SUM_CON_DEPTO,2,'0') || LPAD(C.SUM_CON_MUNICIPIO,3,'0') || LPAD(C.SUM_CON_CNRPBLADO,3,'0'))
                        , (CASE WHEN C.SUM_CON_ESTRATO NOT BETWEEN 1 AND 6 THEN 9 ELSE C.SUM_CON_ESTRATO END)
                    ) TC1
                    LEFT JOIN (--ESTRATIFICACION Y COBERTURAS
                                SELECT CAR_CARG_ANO, CAR_CARG_PERIODO, TO_NUMBER(LPAD(CAR_T1549_DANE_DEPTO,2,'0') || LPAD(CAR_T1549_DANE_MPIO,3,'0') || '000') DANE
                                    , ESTRATO, CONTEO FROM
                                    (
                                    SELECT CAR_CARG_ANO, CAR_CARG_PERIODO, CAR_T1549_DANE_DEPTO, CAR_T1549_DANE_MPIO, (CASE WHEN CAR_T1549_ESTRATO_ALCALDIA NOT BETWEEN 1 AND 6 THEN 9 ELSE CAR_T1549_ESTRATO_ALCALDIA END) ESTRATO, COUNT(CAR_T1549_PREDIAL_UTILIZADO) CONTEO
                                    FROM ESTRATIFICACION_2016.CAR_T1549_ESTRATIFICA_COBERT
                                    WHERE CAR_CARG_ANO = :ANIO_ARG
                                    GROUP BY CAR_CARG_ANO, CAR_CARG_PERIODO, CAR_T1549_DANE_DEPTO, CAR_T1549_DANE_MPIO, (CASE WHEN CAR_T1549_ESTRATO_ALCALDIA NOT BETWEEN 1 AND 6 THEN 9 ELSE CAR_T1549_ESTRATO_ALCALDIA END)
                                    )
                                ) ALCALDIA ON TC1.SUM_CON_ANO=ALCALDIA.CAR_CARG_ANO AND (CASE WHEN TC1.SUM_CON_PERIODO BETWEEN 1 AND 12 THEN 1 ELSE TC1.SUM_CON_PERIODO END)=ALCALDIA.CAR_CARG_PERIODO
                                    AND TO_NUMBER(TC1.DANE)=ALCALDIA.DANE AND TC1.ESTRATO=ALCALDIA.ESTRATO
                    LEFT JOIN JHERRERAA.GIS_CENTRO_POBLADO DIVIPOLA ON TC1.DANE = DIVIPOLA.CODIGO_CENTRO_POBLADO
                    --INNER JOIN RUPS.ARE_ESP_EMPRESAS ESP ON TC1.IDENTIFICADOR_EMPRESA=ESP.ARE_ESP_SECUE
                --ORDER BY 1,2,6,9
                WHERE CONTEO IS NOT NULL
                --ORDER BY 1,2,4,7
                )
                WHERE VALIDACION = 0
            '''
        elif opcion == 2:
            # Estratos registrados por el prestador diferentes a los de la alcaldía
            sql = '''
                SELECT * FROM (
                SELECT TC1.SUM_CON_ANO, TC1.SUM_CON_PERIODO, /*TC1.IDENTIFICADOR_EMPRESA, CONVERT(ESP.ARE_ESP_NOMBRE, 'US7ASCII', 'EE8MSWIN1250') ARE_ESP_NOMBRE,*/ DIVIPOLA.CODIGO_CENTRO_POBLADO
                , CONVERT(DIVIPOLA.NOMBRE_CENTRO_POBLADO, 'US7ASCII', 'EE8MSWIN1250'), DIVIPOLA.LONGITUD, DIVIPOLA.LATITUD, TC1.ESTRATO, TC1.USUARIOS, ALCALDIA.CONTEO, (TC1.USUARIOS - ALCALDIA.CONTEO) AS VALIDACION
                FROM (--CONSOLIDADO COMERCIAL
                    SELECT C.SUM_CON_ANO, C.SUM_CON_PERIODO, /*C.IDENTIFICADOR_EMPRESA,*/ (LPAD(C.SUM_CON_DEPTO,2,'0') || LPAD(C.SUM_CON_MUNICIPIO,3,'0') || LPAD(C.SUM_CON_CNRPBLADO,3,'0')) DANE
                        , (CASE WHEN C.SUM_CON_ESTRATO NOT BETWEEN 1 AND 6 THEN 9 ELSE C.SUM_CON_ESTRATO END) ESTRATO, SUM(C.SUM_CON_NROFACTURAS) USUARIOS
                    FROM SUM_SUI.SUM_CON_CONSOLIDA C        
                    WHERE C.SUM_CON_SERVICIO=:SERVICIO_ARG
                        AND C.SUM_CON_ANO=:ANIO_ARG --ANIO (REMPLAZAR EL 2021 POR LA VARIABLE DEL FRONT)
                        AND C.SUM_CON_PERIODO=:MES_ARG --MES (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
                        AND (C.IDENTIFICADOR_EMPRESA = :EMPRESA_ARG OR 0 = :EMPRESA_ARG) --ID_ESP (REMPLAZAR EL 2103 POR LA VARIABLE DEL FRONT)
                        AND (C.SUM_CON_DEPTO = :DPTO_ARG OR 'TODOS' = :DPTO_ARG) --CODDEPTO (REMPLAZAR EL 8 POR LA VARIABLE DEL FRONT)
                        AND (C.SUM_CON_MUNICIPIO = :MPO_ARG OR 'TODOS' = :MPO_ARG) --CODMPIO (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
                        AND (C.SUM_CON_CNRPBLADO = :CPOBLADO_ARG OR 'TODOS' = :CPOBLADO_ARG) --CODCPOBLADO (REMPLAZAR EL 0 POR LA VARIABLE DEL FRONT)
                    GROUP BY C.SUM_CON_ANO, C.SUM_CON_PERIODO, /*C.IDENTIFICADOR_EMPRESA,*/ (LPAD(C.SUM_CON_DEPTO,2,'0') || LPAD(C.SUM_CON_MUNICIPIO,3,'0') || LPAD(C.SUM_CON_CNRPBLADO,3,'0'))
                        , (CASE WHEN C.SUM_CON_ESTRATO NOT BETWEEN 1 AND 6 THEN 9 ELSE C.SUM_CON_ESTRATO END)
                    ) TC1
                    LEFT JOIN (--ESTRATIFICACION Y COBERTURAS
                                SELECT CAR_CARG_ANO, CAR_CARG_PERIODO, TO_NUMBER(LPAD(CAR_T1549_DANE_DEPTO,2,'0') || LPAD(CAR_T1549_DANE_MPIO,3,'0') || '000') DANE
                                    , ESTRATO, CONTEO FROM
                                    (
                                    SELECT CAR_CARG_ANO, CAR_CARG_PERIODO, CAR_T1549_DANE_DEPTO, CAR_T1549_DANE_MPIO, (CASE WHEN CAR_T1549_ESTRATO_ALCALDIA NOT BETWEEN 1 AND 6 THEN 9 ELSE CAR_T1549_ESTRATO_ALCALDIA END) ESTRATO, COUNT(CAR_T1549_PREDIAL_UTILIZADO) CONTEO
                                    FROM ESTRATIFICACION_2016.CAR_T1549_ESTRATIFICA_COBERT
                                    WHERE CAR_CARG_ANO = :ANIO_ARG
                                    GROUP BY CAR_CARG_ANO, CAR_CARG_PERIODO, CAR_T1549_DANE_DEPTO, CAR_T1549_DANE_MPIO, (CASE WHEN CAR_T1549_ESTRATO_ALCALDIA NOT BETWEEN 1 AND 6 THEN 9 ELSE CAR_T1549_ESTRATO_ALCALDIA END)
                                    )
                                ) ALCALDIA ON TC1.SUM_CON_ANO=ALCALDIA.CAR_CARG_ANO AND (CASE WHEN TC1.SUM_CON_PERIODO BETWEEN 1 AND 12 THEN 1 ELSE TC1.SUM_CON_PERIODO END)=ALCALDIA.CAR_CARG_PERIODO
                                    AND TO_NUMBER(TC1.DANE)=ALCALDIA.DANE AND TC1.ESTRATO=ALCALDIA.ESTRATO
                    LEFT JOIN JHERRERAA.GIS_CENTRO_POBLADO DIVIPOLA ON TC1.DANE = DIVIPOLA.CODIGO_CENTRO_POBLADO
                    --INNER JOIN RUPS.ARE_ESP_EMPRESAS ESP ON TC1.IDENTIFICADOR_EMPRESA=ESP.ARE_ESP_SECUE
                --ORDER BY 1,2,6,9
                WHERE CONTEO IS NOT NULL
                --ORDER BY 1,2,4,7
                )
                WHERE VALIDACION <> 0
            '''
        elif opcion == 3:
            # Estratos registrados por el prestador sin registro en alcaldía
            sql = '''
                SELECT TC1.SUM_CON_ANO, TC1.SUM_CON_PERIODO, /*TC1.IDENTIFICADOR_EMPRESA, CONVERT(ESP.ARE_ESP_NOMBRE, 'US7ASCII', 'EE8MSWIN1250') ARE_ESP_NOMBRE,*/ DIVIPOLA.CODIGO_CENTRO_POBLADO
                , CONVERT(DIVIPOLA.NOMBRE_CENTRO_POBLADO, 'US7ASCII', 'EE8MSWIN1250'), DIVIPOLA.LONGITUD, DIVIPOLA.LATITUD, TC1.ESTRATO, TC1.USUARIOS, NVL(ALCALDIA.CONTEO, 0)
                FROM (--CONSOLIDADO COMERCIAL
                    SELECT C.SUM_CON_ANO, C.SUM_CON_PERIODO, /*C.IDENTIFICADOR_EMPRESA,*/ (LPAD(C.SUM_CON_DEPTO,2,'0') || LPAD(C.SUM_CON_MUNICIPIO,3,'0') || LPAD(C.SUM_CON_CNRPBLADO,3,'0')) DANE
                        , (CASE WHEN C.SUM_CON_ESTRATO NOT BETWEEN 1 AND 6 THEN 9 ELSE C.SUM_CON_ESTRATO END) ESTRATO, SUM(C.SUM_CON_NROFACTURAS) USUARIOS
                    FROM SUM_SUI.SUM_CON_CONSOLIDA C        
                    WHERE C.SUM_CON_SERVICIO=:SERVICIO_ARG
                        AND C.SUM_CON_ANO=:ANIO_ARG --ANIO (REMPLAZAR EL 2021 POR LA VARIABLE DEL FRONT)
                        AND C.SUM_CON_PERIODO=:MES_ARG --MES (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
                        AND (C.IDENTIFICADOR_EMPRESA = :EMPRESA_ARG OR 0 = :EMPRESA_ARG) --ID_ESP (REMPLAZAR EL 2103 POR LA VARIABLE DEL FRONT)
                        AND (C.SUM_CON_DEPTO = :DPTO_ARG OR 'TODOS' = :DPTO_ARG) --CODDEPTO (REMPLAZAR EL 8 POR LA VARIABLE DEL FRONT)
                        AND (C.SUM_CON_MUNICIPIO = :MPO_ARG OR 'TODOS' = :MPO_ARG) --CODMPIO (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
                        AND (C.SUM_CON_CNRPBLADO = :CPOBLADO_ARG OR 'TODOS' = :CPOBLADO_ARG) --CODCPOBLADO (REMPLAZAR EL 0 POR LA VARIABLE DEL FRONT)
                    GROUP BY C.SUM_CON_ANO, C.SUM_CON_PERIODO, /*C.IDENTIFICADOR_EMPRESA,*/ (LPAD(C.SUM_CON_DEPTO,2,'0') || LPAD(C.SUM_CON_MUNICIPIO,3,'0') || LPAD(C.SUM_CON_CNRPBLADO,3,'0'))
                        , (CASE WHEN C.SUM_CON_ESTRATO NOT BETWEEN 1 AND 6 THEN 9 ELSE C.SUM_CON_ESTRATO END)
                    ) TC1
                    LEFT JOIN (--ESTRATIFICACION Y COBERTURAS
                                SELECT CAR_CARG_ANO, CAR_CARG_PERIODO, TO_NUMBER(LPAD(CAR_T1549_DANE_DEPTO,2,'0') || LPAD(CAR_T1549_DANE_MPIO,3,'0') || '000') DANE
                                    , (CASE WHEN CAR_T1549_ESTRATO_ALCALDIA NOT BETWEEN 1 AND 6 THEN 9 ELSE CAR_T1549_ESTRATO_ALCALDIA END) ESTRATO, COUNT(CAR_T1549_PREDIAL_UTILIZADO) CONTEO
                                FROM ESTRATIFICACION_2016.CAR_T1549_ESTRATIFICA_COBERT
                                WHERE CAR_CARG_ANO = :ANIO_ARG
                                    --AND CAR_T1549_DANE_DEPTO=5
                                    --AND CAR_T1549_DANE_MPIO=1
                                GROUP BY CAR_CARG_ANO, CAR_CARG_PERIODO, TO_NUMBER(LPAD(CAR_T1549_DANE_DEPTO,2,'0') || LPAD(CAR_T1549_DANE_MPIO,3,'0') || '000'), (CASE WHEN CAR_T1549_ESTRATO_ALCALDIA NOT BETWEEN 1 AND 6 THEN 9 ELSE CAR_T1549_ESTRATO_ALCALDIA END)
                                ) ALCALDIA ON TC1.SUM_CON_ANO=ALCALDIA.CAR_CARG_ANO AND (CASE WHEN TC1.SUM_CON_PERIODO BETWEEN 1 AND 12 THEN 1 ELSE TC1.SUM_CON_PERIODO END)=ALCALDIA.CAR_CARG_PERIODO
                                    AND TO_NUMBER(TC1.DANE)=ALCALDIA.DANE AND TC1.ESTRATO=ALCALDIA.ESTRATO
                    LEFT JOIN JHERRERAA.GIS_CENTRO_POBLADO DIVIPOLA ON TC1.DANE = DIVIPOLA.CODIGO_CENTRO_POBLADO
                    --INNER JOIN RUPS.ARE_ESP_EMPRESAS ESP ON TC1.IDENTIFICADOR_EMPRESA=ESP.ARE_ESP_SECUE
                --ORDER BY 1,2,6,9
                WHERE CONTEO IS NULL
                ORDER BY 1,2,4,7
            '''
        return self.db.engine.execute(text(sql), SERVICIO_ARG=servicio, ANIO_ARG=anio, MES_ARG=mes, EMPRESA_ARG=empresa, DPTO_ARG=dpto, MPO_ARG=mpio, CPOBLADO_ARG=cpoblado).fetchall()
