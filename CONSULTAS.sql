-- CALIDAD DEL SERVICIO 
SELECT 
AVG(CAR_T1729_DIU),
AVG(CAR_T1729_DIUM),
AVG(CAR_T1729_FIU),
AVG(CAR_T1729_FIUM),
CAR_CARG_MES,
CAR_CARG_ANO 
FROM ENERGIA_CREG_015.CAR_T1729_CS2_DIU_FIU
WHERE CAR_CARG_MES = 1
AND CAR_CARG_ANO = 2021
GROUP BY 
CAR_CARG_MES,
CAR_CARG_ANO;

SELECT AVG(CAR_T1729_DIU), AVG(CAR_T1729_FIU), USUARIOS.CAR_T1732_DANE_NIU, DIUFIU.IDENTIFICADOR_EMPRESA, DIUFIU.CAR_CARG_MES, DIUFIU.CAR_CARG_ANO FROM 
(
SELECT CAR_T1729_NIU,
CAR_T1729_DIU,
CAR_T1729_DIUM,
CAR_T1729_FIU,
CAR_T1729_FIUM,
IDENTIFICADOR_EMPRESA,
CAR_CARG_MES,
CAR_CARG_ANO 
FROM ENERGIA_CREG_015.CAR_T1729_CS2_DIU_FIU
WHERE CAR_CARG_MES = 1
AND CAR_CARG_ANO = 2021
AND IDENTIFICADOR_EMPRESA = 2103
) DIUFIU
LEFT JOIN
ENERGIA_CREG_015.CAR_T1732_TC1_INV_USUARIOS USUARIOS
ON 
DIUFIU.CAR_T1729_NIU = USUARIOS.CAR_T1732_NIU
AND DIUFIU.CAR_CARG_MES = USUARIOS.CAR_CARG_PERIODO
AND DIUFIU.CAR_CARG_ANO = USUARIOS.CAR_CARG_ANO
AND DIUFIU.IDENTIFICADOR_EMPRESA = USUARIOS.IDENTIFICADOR_EMPRESA
WHERE CAR_T1732_NIU IS NOT NULL
GROUP BY USUARIOS.CAR_T1732_DANE_NIU, DIUFIU.IDENTIFICADOR_EMPRESA, DIUFIU.CAR_CARG_MES, DIUFIU.CAR_CARG_ANO;

-- ESTRATIFICACION VERSION 1.0

SELECT TC1.SUM_CON_ANO, TC1.SUM_CON_PERIODO, /*TC1.IDENTIFICADOR_EMPRESA, CONVERT(ESP.ARE_ESP_NOMBRE, 'US7ASCII', 'EE8MSWIN1250') ARE_ESP_NOMBRE,*/ DIVIPOLA.CODIGO_CENTRO_POBLADO
  , DIVIPOLA.NOMBRE_CENTRO_POBLADO, DIVIPOLA.LONGITUD, DIVIPOLA.LATITUD, TC1.ESTRATO, TC1.USUARIOS, ALCALDIA.CONTEO
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
;

AND (CASE WHEN C.SUM_CON_ESTRATO NOT BETWEEN 1 AND 6 THEN 9 ELSE C.SUM_CON_ESTRATO END = :ESTRATO_ARG OR 0 =:ESTRATO_ARG)

---------------------------------------------------------------
-- ESTRATIFICACIÓN
---------------------------------------------------------------
-- CUANDO EL ESTRATO ES IGUAL
SELECT TC2.CAR_CARG_ANO, TC2.CAR_CARG_PERIODO, TC2.IDENTIFICADOR_EMPRESA, CONVERT(ESP.ARE_ESP_NOMBRE, 'US7ASCII', 'EE8MSWIN1250') ARE_ESP_NOMBRE, CODIGO_CENTRO_POBLADO, NOMBRE_CENTRO_POBLADO, LONGITUD, LATITUD, COUNT(*) AS CANTIDAD_ESTRATOS FROM 
(
SELECT CAR_T1732_DANE_NIU, CAR_T1743_INFO_PRED_UTIL, TC2.CAR_T1743_CEDULA_CAT_NPN, TC1.CAR_T1732_DIRECCION, TC1.CAR_T1732_ESTRATO_SECTOR, TC1.CAR_T1732_NIU, TC1.CAR_T1732_ID_MERCADO, TC2.CAR_CARG_PERIODO, TC2.CAR_CARG_ANO, TC2.IDENTIFICADOR_EMPRESA FROM ENERGIA_CREG_015.CAR_T1743_TC2FACTURACION_USU TC2, ENERGIA_CREG_015.CAR_T1732_TC1_INV_USUARIOS TC1
WHERE TC2.CAR_CARG_ANO = TC1.CAR_CARG_ANO
AND TC2.CAR_CARG_PERIODO = TC1.CAR_CARG_PERIODO
AND TC2.IDENTIFICADOR_EMPRESA = TC1.IDENTIFICADOR_EMPRESA
AND TO_NUMBER(SUBSTR(CAR_T1743_MERCADO_NIU, 1, INSTR(CAR_T1743_MERCADO_NIU, '-')-1)) = TC1.CAR_T1732_ID_MERCADO
AND SUBSTR(CAR_T1743_MERCADO_NIU, INSTR(CAR_T1743_MERCADO_NIU, '-')+1) = TC1.CAR_T1732_NIU
AND TC2.CAR_CARG_ANO = :ANIO_ARG --ANIO (REMPLAZAR EL 2021 POR LA VARIABLE DEL FRONT)
AND TC2.CAR_CARG_PERIODO = :MES_ARG --MES (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
AND (TC2.IDENTIFICADOR_EMPRESA = :EMPRESA_ARG OR 0 = :EMPRESA_ARG) --ID_ESP (REMPLAZAR EL 2103 POR LA VARIABLE DEL FRONT)
AND (SUBSTR(TC1.CAR_T1732_DANE_NIU,1,2)=LPAD(:DPTO_ARG,2,'0') OR 'TODOS' = :DPTO_ARG) --CODDEPTO (REMPLAZAR EL 8 POR LA VARIABLE DEL FRONT)
AND (SUBSTR(TC1.CAR_T1732_DANE_NIU,3,3)=LPAD(:MPO_ARG,3,'0') OR 'TODOS' = :MPO_ARG) --CODMPIO (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
AND (SUBSTR(TC1.CAR_T1732_DANE_NIU,6,3)=LPAD(:CPOBLADO_ARG,3,'0') OR 'TODOS' = :CPOBLADO_ARG) --CODCPOBLADO (REMPLAZAR EL 0 POR LA VARIABLE DEL FRONT)
) TC2,
(
SELECT CAR_T1549_DANE_DEPTO, CAR_T1549_DANE_MPIO, CAR_T1549_ESTRATO_ALCALDIA, CAR_T1549_PREDIAL_UTILIZADO, CAR_T1549_NPN_INFO_PRED_CAT, CAR_T1549_DIRECCION_CAT, CAR_CARG_ANO FROM ESTRATIFICACION_2016.CAR_T1549_ESTRATIFICA_COBERT
WHERE CAR_CARG_ANO = :ANIO_ARG
) ALCALDIA,
JHERRERAA.GIS_CENTRO_POBLADO DIVIPOLA,
RUPS.ARE_ESP_EMPRESAS ESP
WHERE 
1 = :ESTRATO_SELECT
AND TC2.CAR_CARG_ANO = ALCALDIA.CAR_CARG_ANO
AND TC2.CAR_T1743_CEDULA_CAT_NPN = ALCALDIA.CAR_T1549_NPN_INFO_PRED_CAT
AND TC2.CAR_T1743_INFO_PRED_UTIL = ALCALDIA.CAR_T1549_PREDIAL_UTILIZADO
AND TC2.CAR_T1732_ESTRATO_SECTOR = ALCALDIA.CAR_T1549_ESTRATO_ALCALDIA -- CUANDO EL ESTRATO ES IGUAL
AND TC2.CAR_T1732_DANE_NIU = DIVIPOLA.CODIGO_CENTRO_POBLADO
AND TC2.IDENTIFICADOR_EMPRESA = ESP.ARE_ESP_SECUE
GROUP BY TC2.CAR_CARG_ANO, TC2.CAR_CARG_PERIODO, TC2.IDENTIFICADOR_EMPRESA, CONVERT(ESP.ARE_ESP_NOMBRE, 'US7ASCII', 'EE8MSWIN1250'), CODIGO_CENTRO_POBLADO, NOMBRE_CENTRO_POBLADO, LONGITUD, LATITUD
UNION -- CUANDO LOS ESTRATOS SON DIFERENTES A LOS REGISTRADOS POR LA ALCALDIA
SELECT TC2.CAR_CARG_ANO, TC2.CAR_CARG_PERIODO, TC2.IDENTIFICADOR_EMPRESA, CONVERT(ESP.ARE_ESP_NOMBRE, 'US7ASCII', 'EE8MSWIN1250') ARE_ESP_NOMBRE, CODIGO_CENTRO_POBLADO, NOMBRE_CENTRO_POBLADO, LONGITUD, LATITUD, COUNT(*) AS CANTIDAD_ESTRATOS FROM 
(
SELECT CAR_T1732_DANE_NIU, CAR_T1743_INFO_PRED_UTIL, TC2.CAR_T1743_CEDULA_CAT_NPN, TC1.CAR_T1732_DIRECCION, TC1.CAR_T1732_ESTRATO_SECTOR, TC1.CAR_T1732_NIU, TC1.CAR_T1732_ID_MERCADO, TC2.CAR_CARG_PERIODO, TC2.CAR_CARG_ANO, TC2.IDENTIFICADOR_EMPRESA FROM ENERGIA_CREG_015.CAR_T1743_TC2FACTURACION_USU TC2, ENERGIA_CREG_015.CAR_T1732_TC1_INV_USUARIOS TC1
WHERE TC2.CAR_CARG_ANO = TC1.CAR_CARG_ANO
AND TC2.CAR_CARG_PERIODO = TC1.CAR_CARG_PERIODO
AND TC2.IDENTIFICADOR_EMPRESA = TC1.IDENTIFICADOR_EMPRESA
AND TO_NUMBER(SUBSTR(CAR_T1743_MERCADO_NIU, 1, INSTR(CAR_T1743_MERCADO_NIU, '-')-1)) = TC1.CAR_T1732_ID_MERCADO
AND SUBSTR(CAR_T1743_MERCADO_NIU, INSTR(CAR_T1743_MERCADO_NIU, '-')+1) = TC1.CAR_T1732_NIU
AND TC2.CAR_CARG_ANO = :ANIO_ARG --ANIO (REMPLAZAR EL 2021 POR LA VARIABLE DEL FRONT)
AND TC2.CAR_CARG_PERIODO = :MES_ARG --MES (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
AND (TC2.IDENTIFICADOR_EMPRESA = :EMPRESA_ARG OR 0 = :EMPRESA_ARG) --ID_ESP (REMPLAZAR EL 2103 POR LA VARIABLE DEL FRONT)
AND (SUBSTR(TC1.CAR_T1732_DANE_NIU,1,2)=LPAD(:DPTO_ARG,2,'0') OR 'TODOS' = :DPTO_ARG) --CODDEPTO (REMPLAZAR EL 8 POR LA VARIABLE DEL FRONT)
AND (SUBSTR(TC1.CAR_T1732_DANE_NIU,3,3)=LPAD(:MPO_ARG,3,'0') OR 'TODOS' = :MPO_ARG) --CODMPIO (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
AND (SUBSTR(TC1.CAR_T1732_DANE_NIU,6,3)=LPAD(:CPOBLADO_ARG,3,'0') OR 'TODOS' = :CPOBLADO_ARG) --CODCPOBLADO (REMPLAZAR EL 0 POR LA VARIABLE DEL FRONT)
) TC2,
(
SELECT CAR_T1549_DANE_DEPTO, CAR_T1549_DANE_MPIO, CAR_T1549_ESTRATO_ALCALDIA, CAR_T1549_PREDIAL_UTILIZADO, CAR_T1549_NPN_INFO_PRED_CAT, CAR_T1549_DIRECCION_CAT, CAR_CARG_ANO FROM ESTRATIFICACION_2016.CAR_T1549_ESTRATIFICA_COBERT
WHERE CAR_CARG_ANO = :ANIO_ARG
) ALCALDIA,
JHERRERAA.GIS_CENTRO_POBLADO DIVIPOLA,
RUPS.ARE_ESP_EMPRESAS ESP
WHERE
TC2.CAR_CARG_ANO = ALCALDIA.CAR_CARG_ANO
AND 2 = :ESTRATO_SELECT
AND TC2.CAR_T1743_CEDULA_CAT_NPN = ALCALDIA.CAR_T1549_NPN_INFO_PRED_CAT
AND TC2.CAR_T1743_INFO_PRED_UTIL = ALCALDIA.CAR_T1549_PREDIAL_UTILIZADO
AND TC2.CAR_T1732_ESTRATO_SECTOR <> ALCALDIA.CAR_T1549_ESTRATO_ALCALDIA -- CUANDO LOS ESTRATOS SON DIFERENTES A LOS REGISTRADOS POR LA ALCALDIA
AND TC2.CAR_T1732_DANE_NIU = DIVIPOLA.CODIGO_CENTRO_POBLADO
AND TC2.IDENTIFICADOR_EMPRESA = ESP.ARE_ESP_SECUE
GROUP BY TC2.CAR_CARG_ANO, TC2.CAR_CARG_PERIODO, TC2.IDENTIFICADOR_EMPRESA, CONVERT(ESP.ARE_ESP_NOMBRE, 'US7ASCII', 'EE8MSWIN1250'), CODIGO_CENTRO_POBLADO, NOMBRE_CENTRO_POBLADO, LONGITUD, LATITUD
UNION -- CUANDO NO HAY INFORMACION DE ESTRATOS REGISTRADOS EN LA ALCALDIA
SELECT ESTRATOS.CAR_CARG_ANO, ESTRATOS.CAR_CARG_PERIODO, ESTRATOS.IDENTIFICADOR_EMPRESA, CONVERT(ESP.ARE_ESP_NOMBRE, 'US7ASCII', 'EE8MSWIN1250') ARE_ESP_NOMBRE, CODIGO_CENTRO_POBLADO, NOMBRE_CENTRO_POBLADO, LONGITUD, LATITUD, COUNT(*) AS CANTIDAD_ESTRATOS FROM 
(
SELECT * FROM 
(
SELECT TC2.CAR_CARG_ANO, TC2.CAR_CARG_PERIODO, TC2.IDENTIFICADOR_EMPRESA, CAR_T1732_DANE_NIU, CAR_T1743_INFO_PRED_UTIL, TC2.CAR_T1743_CEDULA_CAT_NPN, TC1.CAR_T1732_DIRECCION, TC1.CAR_T1732_ESTRATO_SECTOR, TC1.CAR_T1732_NIU, TC1.CAR_T1732_ID_MERCADO FROM ENERGIA_CREG_015.CAR_T1743_TC2FACTURACION_USU TC2, ENERGIA_CREG_015.CAR_T1732_TC1_INV_USUARIOS TC1
WHERE TC2.CAR_CARG_ANO = TC1.CAR_CARG_ANO
AND TC2.CAR_CARG_PERIODO = TC1.CAR_CARG_PERIODO
AND TC2.IDENTIFICADOR_EMPRESA = TC1.IDENTIFICADOR_EMPRESA
AND TO_NUMBER(SUBSTR(CAR_T1743_MERCADO_NIU, 1, INSTR(CAR_T1743_MERCADO_NIU, '-')-1)) = TC1.CAR_T1732_ID_MERCADO
AND SUBSTR(CAR_T1743_MERCADO_NIU, INSTR(CAR_T1743_MERCADO_NIU, '-')+1) = TC1.CAR_T1732_NIU
AND TC2.CAR_CARG_ANO = :ANIO_ARG --ANIO (REMPLAZAR EL 2021 POR LA VARIABLE DEL FRONT)
AND TC2.CAR_CARG_PERIODO = :MES_ARG --MES (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
AND (TC2.IDENTIFICADOR_EMPRESA = :EMPRESA_ARG OR 0 = :EMPRESA_ARG) --ID_ESP (REMPLAZAR EL 2103 POR LA VARIABLE DEL FRONT)
AND (SUBSTR(TC1.CAR_T1732_DANE_NIU,1,2)=LPAD(:DPTO_ARG,2,'0') OR 'TODOS' = :DPTO_ARG) --CODDEPTO (REMPLAZAR EL 8 POR LA VARIABLE DEL FRONT)
AND (SUBSTR(TC1.CAR_T1732_DANE_NIU,3,3)=LPAD(:MPO_ARG,3,'0') OR 'TODOS' = :MPO_ARG) --CODMPIO (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
AND (SUBSTR(TC1.CAR_T1732_DANE_NIU,6,3)=LPAD(:CPOBLADO_ARG,3,'0') OR 'TODOS' = :CPOBLADO_ARG) --CODCPOBLADO (REMPLAZAR EL 0 POR LA VARIABLE DEL FRONT)
) TC2
LEFT JOIN
(
SELECT CAR_T1549_DANE_DEPTO, CAR_T1549_DANE_MPIO, CAR_T1549_ESTRATO_ALCALDIA, CAR_T1549_PREDIAL_UTILIZADO, CAR_T1549_NPN_INFO_PRED_CAT, CAR_T1549_DIRECCION_CAT, CAR_CARG_ANO ANO_ALCALDIA FROM ESTRATIFICACION_2016.CAR_T1549_ESTRATIFICA_COBERT
WHERE CAR_CARG_ANO = :ANIO_ARG
) ALCALDIA
ON
TC2.CAR_CARG_ANO = ALCALDIA.ANO_ALCALDIA
AND TC2.CAR_T1743_CEDULA_CAT_NPN = ALCALDIA.CAR_T1549_NPN_INFO_PRED_CAT
AND TC2.CAR_T1743_INFO_PRED_UTIL = ALCALDIA.CAR_T1549_PREDIAL_UTILIZADO
WHERE CAR_T1549_PREDIAL_UTILIZADO IS NULL -- CUANDO NO HAY INFORMACION DE ESTRATOS REGISTRADOS EN LA ALCALDIA
) ESTRATOS,
JHERRERAA.GIS_CENTRO_POBLADO DIVIPOLA,
RUPS.ARE_ESP_EMPRESAS ESP
WHERE
3 = :ESTRATO_SELECT
AND ESTRATOS.CAR_T1732_DANE_NIU = DIVIPOLA.CODIGO_CENTRO_POBLADO
AND ESTRATOS.IDENTIFICADOR_EMPRESA = ESP.ARE_ESP_SECUE
GROUP BY ESTRATOS.CAR_CARG_ANO, ESTRATOS.CAR_CARG_PERIODO, ESTRATOS.IDENTIFICADOR_EMPRESA, CONVERT(ESP.ARE_ESP_NOMBRE, 'US7ASCII', 'EE8MSWIN1250'), CODIGO_CENTRO_POBLADO, NOMBRE_CENTRO_POBLADO, LONGITUD, LATITUD;

---------------------------------------------------------------
-- FORMATO TC2
---------------------------------------------------------------
SELECT STC1.CAR_CARG_ANO, STC1.CAR_CARG_PERIODO, STC1.ID_COMER,
STC1.RES_NORES, --USO
STC1.CAR_T1732_DANE_NIU COD_DANE,
SUM(STC2.CONSUMO) CONSUMO,
SUM(STC2.FACXCON) FACXCON
FROM 
( SELECT DISTINCT TC1.CAR_CARG_ANO, TC1.CAR_CARG_PERIODO, TC1.IDENTIFICADOR_EMPRESA ID_OR, TC1.CAR_T1732_ID_COMER ID_COMER, TC1.CAR_T1732_DANE_NIU,
DECODE(TC1.CAR_T1732_ESTRATO_SECTOR,1,1,2,2,3,3,4,4,5,5,6,6,7,10,8,11,9,12,10,16,11,17) ESTRATO,
(CASE WHEN TC1.CAR_T1732_ESTRATO_SECTOR BETWEEN 1 AND 6 THEN 1 ELSE 2 END) RES_NORES, --USO
TC1.CAR_T1732_ID_MERCADO || '-' || TC1.CAR_T1732_NIU MERCADO_NIU, TC1.CAR_T1732_ID_MERCADO
FROM ENERGIA_CREG_015.CAR_T1732_TC1_INV_USUARIOS TC1
WHERE 
TC1.CAR_CARG_ANO = :ANIO_ARG --ANIO (REMPLAZAR EL 2021 POR LA VARIABLE DEL FRONT)
AND TC1.CAR_CARG_PERIODO = :MES_ARG --MES (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
AND TC1.CAR_T1732_ID_COMER = :IDEMPRESA_ARG --ID_ESP (REMPLAZAR EL 2103 POR LA VARIABLE DEL FRONT)
AND (CASE WHEN TC1.CAR_T1732_ESTRATO_SECTOR BETWEEN 1 AND 6 THEN 1 ELSE 2 END) = :SECTOR --1= RESIDENCIAL; 2=NO RESIDENCIAL; (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
) STC1
INNER JOIN ( SELECT TC2.CAR_CARG_ANO, TC2.CAR_CARG_PERIODO, TC2.IDENTIFICADOR_EMPRESA
, (CASE WHEN INSTR(TC2.CAR_T1743_MERCADO_NIU,'-',1,1) > 0 THEN TC2.CAR_T1743_MERCADO_NIU ELSE TC2.CAR_T1743_ID_MERCADO || '-' || TC2.CAR_T1743_MERCADO_NIU END) MERCADO_NIU
, SUM(CASE WHEN TC2.CAR_T1743_TIPO_FACT=1 AND TC2.CAR_T1743_VAL_RFT_CU >= 0 THEN TC2.CAR_T1743_CONS_USUARIO + TC2.CAR_T1743_RFT_CU
WHEN TC2.CAR_T1743_TIPO_FACT=1 AND TC2.CAR_T1743_VAL_RFT_CU < 0 THEN TC2.CAR_T1743_CONS_USUARIO - TC2.CAR_T1743_RFT_CU
WHEN TC2.CAR_T1743_TIPO_FACT<>1 THEN 0 END) CONSUMO
, SUM(TC2.CAR_T1743_VAL_FACT_CU + TC2.CAR_T1743_VAL_RFT_CU) FACXCON
FROM ENERGIA_CREG_015.CAR_T1743_TC2FACTURACION_USU TC2
WHERE 
TC2.CAR_CARG_ANO = :ANIO_ARG --ANIO (REMPLAZAR EL 2021 POR LA VARIABLE DEL FRONT)
AND TC2.CAR_CARG_PERIODO = :MES_ARG --MES (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
AND TC2.IDENTIFICADOR_EMPRESA = :IDEMPRESA_ARG --ID_ESP (REMPLAZAR EL 2103 POR LA VARIABLE DEL FRONT)
GROUP BY TC2.CAR_CARG_ANO, TC2.CAR_CARG_PERIODO, TC2.IDENTIFICADOR_EMPRESA
, (CASE WHEN INSTR(TC2.CAR_T1743_MERCADO_NIU,'-',1,1) > 0 THEN TC2.CAR_T1743_MERCADO_NIU ELSE TC2.CAR_T1743_ID_MERCADO || '-' || TC2.CAR_T1743_MERCADO_NIU END)
) STC2 ON STC1.CAR_CARG_ANO=STC2.CAR_CARG_ANO AND STC1.CAR_CARG_PERIODO=STC2.CAR_CARG_PERIODO AND STC1.ID_COMER=STC2.IDENTIFICADOR_EMPRESA AND STC1.MERCADO_NIU=STC2.MERCADO_NIU
GROUP BY STC1.CAR_CARG_ANO, STC1.CAR_CARG_PERIODO, STC1.ID_COMER, STC1.RES_NORES, STC1.CAR_T1732_DANE_NIU

---------------------------------------------------------------
-- FORMATO2
---------------------------------------------------------------
SELECT 
F2.CAR_CARG_ANO, F2.CAR_CARG_MES,
F2.IDENTIFICADOR_EMPRESA,
1 RES_NORES, --USO
F2.CAR_T439_DANE,
SUM(CASE WHEN F2.CAR_T439_TIPO='I' THEN F2.CAR_T439_CONSUMO ELSE 0 END) CONSUMO,
SUM(F2.CAR_T439_FACT_CONS) + SUM(F2.CAR_T439_VALOR_RECFAC) FACXCON
FROM CARG_COMERCIAL_E.CAR_T439_FORMATO2 F2
WHERE
F2.CAR_CARG_ANO = :ANIO_ARG --ANIO (REMPLAZAR EL 2021 POR LA VARIABLE DEL FRONT)
AND F2.CAR_CARG_MES = :MES_ARG --MES (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
AND F2.IDENTIFICADOR_EMPRESA = :IDEMPRESA_ARG -- (REMPLAZAR EL 2103 POR LA VARIABLE DEL FRONT)
AND 1 = :SECTOR --FILTRO RESIDENCIAL (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
GROUP BY F2.CAR_CARG_ANO, F2.CAR_CARG_MES, F2.IDENTIFICADOR_EMPRESA, 1, F2.CAR_T439_DANE

---------------------------------------------------------------
-- FORMATO3
---------------------------------------------------------------
SELECT F3.CAR_CARG_ANO, F3.CAR_CARG_MES, F3.IDENTIFICADOR_EMPRESA,
2 RES_NORES, --USO,
F3.CAR_T440_DANE,
SUM(CASE WHEN F3.CAR_T440_TIPO_FACT='I' THEN F3.CAR_T440_CONSUMO ELSE 0 END) CONSUMO,
SUM(F3.CAR_T440_FACT_CONS) + SUM(F3.CAR_T440_VALOR_RECFAC) FACXCON
FROM CARG_COMERCIAL_E.CAR_T440_FORMATO3 F3
WHERE
F3.CAR_CARG_ANO = :ANIO_ARG --ANIO (REMPLAZAR EL 2021 POR LA VARIABLE DEL FRONT)
AND F3.CAR_CARG_MES = :MES_ARG --MES (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
AND F3.IDENTIFICADOR_EMPRESA = :IDEMPRESA_ARG --ID_ESP (REMPLAZAR EL 2103 POR LA VARIABLE DEL FRONT)
AND 2 = :SECTOR --FILTRO NO RESIDENCIAL (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
GROUP BY F3.CAR_CARG_ANO, F3.CAR_CARG_MES, F3.IDENTIFICADOR_EMPRESA, 2, F3.CAR_T440_DANE

--- CONSULTA FINAL

SELECT 
    T.CAR_CARG_ANO,
    T.CAR_CARG_PERIODO,
    T.COD_DANE,
    T.ID_COMER,
    ESP.ARE_ESP_NOMBRE,
    T.RES_NORES, --USO
    GIS.DANE_NOM_DPTO,
    GIS.DANE_NOM_MPIO,
    GIS.DANE_NOM_POBLAD,
    GIS.LONGITUD,
    GIS.LATITUD,
    T.CONSUMO CONSUMO,
    T.FACXCON FACXCON
FROM(--cXm(F2)
    SELECT 
    F2.CAR_CARG_ANO, F2.CAR_CARG_MES AS CAR_CARG_PERIODO,
    F2.IDENTIFICADOR_EMPRESA AS ID_COMER,
    1 RES_NORES, --USO
    F2.CAR_T439_DANE AS COD_DANE,
    SUM(CASE WHEN F2.CAR_T439_TIPO='I' THEN F2.CAR_T439_CONSUMO ELSE 0 END) CONSUMO,
    SUM(F2.CAR_T439_FACT_CONS) + SUM(F2.CAR_T439_VALOR_RECFAC) FACXCON
    FROM CARG_COMERCIAL_E.CAR_T439_FORMATO2 F2
    WHERE
    F2.IDENTIFICADOR_EMPRESA < 99800
    AND F2.CAR_CARG_ANO = :ANIO_ARG --ANIO (REMPLAZAR EL 2021 POR LA VARIABLE DEL FRONT)
    AND F2.CAR_CARG_MES = :MES_ARG --MES (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
    AND (F2.IDENTIFICADOR_EMPRESA = :EMPRESA_ARG OR 0 = :EMPRESA_ARG) -- (REMPLAZAR EL 2103 POR LA VARIABLE DEL FRONT)
    AND 1 = :SECTOR_ARG --FILTRO RESIDENCIAL (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
    AND (SUBSTR(F2.CAR_T439_DANE,1,2)=LPAD(:DPTO_ARG,2,'0') OR 'TODOS' = :DPTO_ARG) --CODDEPTO (REMPLAZAR EL 8 POR LA VARIABLE DEL FRONT)
    AND (SUBSTR(F2.CAR_T439_DANE,3,3)=LPAD(:MPO_ARG,3,'0') OR 'TODOS' = :MPO_ARG) --CODMPIO (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
    AND (SUBSTR(F2.CAR_T439_DANE,6,3)=LPAD(:CPOBLADO_ARG,3,'0') OR 'TODOS' = :CPOBLADO_ARG) --CODCPOBLADO (REMPLAZAR EL 0 POR LA VARIABLE DEL FRONT)
    GROUP BY F2.CAR_CARG_ANO, F2.CAR_CARG_MES, F2.IDENTIFICADOR_EMPRESA, 1, F2.CAR_T439_DANE
UNION
--CXM (F3)
    SELECT F3.CAR_CARG_ANO, F3.CAR_CARG_MES AS CAR_CARG_PERIODO, F3.IDENTIFICADOR_EMPRESA AS ID_COMER,
    2 RES_NORES, --USO,
    F3.CAR_T440_DANE AS COD_DANE,
    SUM(CASE WHEN F3.CAR_T440_TIPO_FACT='I' THEN F3.CAR_T440_CONSUMO ELSE 0 END) CONSUMO,
    SUM(F3.CAR_T440_FACT_CONS) + SUM(F3.CAR_T440_VALOR_RECFAC) FACXCON
    FROM CARG_COMERCIAL_E.CAR_T440_FORMATO3 F3
    WHERE
    F3.IDENTIFICADOR_EMPRESA < 99800
    AND F3.CAR_CARG_ANO = :ANIO_ARG --ANIO (REMPLAZAR EL 2021 POR LA VARIABLE DEL FRONT)
    AND F3.CAR_CARG_MES = :MES_ARG --MES (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
    AND (F3.IDENTIFICADOR_EMPRESA = :EMPRESA_ARG OR 0 = :EMPRESA_ARG) --ID_ESP (REMPLAZAR EL 2103 POR LA VARIABLE DEL FRONT)
    AND 2 = :SECTOR_ARG --FILTRO NO RESIDENCIAL (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
    AND (SUBSTR(F3.CAR_T440_DANE,1,2)=LPAD(:DPTO_ARG,2,'0') OR 'TODOS' = :DPTO_ARG) --CODDEPTO (REMPLAZAR EL 8 POR LA VARIABLE DEL FRONT)
    AND (SUBSTR(F3.CAR_T440_DANE,3,3)=LPAD(:MPO_ARG,3,'0') OR 'TODOS' = :MPO_ARG) --CODMPIO (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
    AND (SUBSTR(F3.CAR_T440_DANE,6,3)=LPAD(:CPOBLADO_ARG,3,'0') OR 'TODOS' = :CPOBLADO_ARG) --CODCPOBLADO (REMPLAZAR EL 0 POR LA VARIABLE DEL FRONT)
    GROUP BY F3.CAR_CARG_ANO, F3.CAR_CARG_MES, F3.IDENTIFICADOR_EMPRESA, 2, F3.CAR_T440_DANE
UNION
--CREG 015 (RES 20155 Y 12515)
    SELECT STC1.CAR_CARG_ANO, STC1.CAR_CARG_PERIODO, STC1.ID_COMER
    , STC1.RES_NORES --USO
    , STC1.CAR_T1732_DANE_NIU COD_DANE
    , SUM(STC2.CONSUMO) CONSUMO
    , SUM(STC2.FACXCON) FACXCON
    FROM ( SELECT DISTINCT TC1.CAR_CARG_ANO, TC1.CAR_CARG_PERIODO, TC1.IDENTIFICADOR_EMPRESA ID_OR, TC1.CAR_T1732_ID_COMER ID_COMER, TC1.CAR_T1732_DANE_NIU
        , DECODE(TC1.CAR_T1732_ESTRATO_SECTOR,1,1,2,2,3,3,4,4,5,5,6,6,7,10,8,11,9,12,10,16,11,17) ESTRATO
        , (CASE WHEN TC1.CAR_T1732_ESTRATO_SECTOR BETWEEN 1 AND 6 THEN 1 ELSE 2 END) RES_NORES --USO
        , TC1.CAR_T1732_ID_MERCADO || '-' || TC1.CAR_T1732_NIU MERCADO_NIU, TC1.CAR_T1732_ID_MERCADO
        FROM ENERGIA_CREG_015.CAR_T1732_TC1_INV_USUARIOS TC1
        WHERE TC1.IDENTIFICADOR_EMPRESA < 99800
        AND TC1.CAR_CARG_ANO = :ANIO_ARG --ANIO (REMPLAZAR EL 2021 POR LA VARIABLE DEL FRONT)
        AND TC1.CAR_CARG_PERIODO = :MES_ARG --MES (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
        AND (TC1.CAR_T1732_ID_COMER = :EMPRESA_ARG OR 0 = :EMPRESA_ARG) --ID_ESP (REMPLAZAR EL 2103 POR LA VARIABLE DEL FRONT)
        AND (SUBSTR(TC1.CAR_T1732_DANE_NIU,1,2)=LPAD(:DPTO_ARG,2,'0') OR 'TODOS' = :DPTO_ARG) --CODDEPTO (REMPLAZAR EL 8 POR LA VARIABLE DEL FRONT)
        AND (SUBSTR(TC1.CAR_T1732_DANE_NIU,3,3)=LPAD(:MPO_ARG,3,'0') OR 'TODOS' = :MPO_ARG) --CODMPIO (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
        AND (SUBSTR(TC1.CAR_T1732_DANE_NIU,6,3)=LPAD(:CPOBLADO_ARG,3,'0') OR 'TODOS' = :CPOBLADO_ARG) --CODCPOBLADO (REMPLAZAR EL 0 POR LA VARIABLE DEL FRONT)
        AND (CASE WHEN TC1.CAR_T1732_ESTRATO_SECTOR BETWEEN 1 AND 6 THEN 1 ELSE 2 END) = :SECTOR_ARG --1= RESIDENCIAL; 2=NO RESIDENCIAL; (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
        ) STC1
        INNER JOIN ( SELECT TC2.CAR_CARG_ANO, TC2.CAR_CARG_PERIODO, TC2.IDENTIFICADOR_EMPRESA
                    , (CASE WHEN INSTR(TC2.CAR_T1743_MERCADO_NIU,'-',1,1) > 0 THEN TC2.CAR_T1743_MERCADO_NIU ELSE TC2.CAR_T1743_ID_MERCADO || '-' || TC2.CAR_T1743_MERCADO_NIU END) MERCADO_NIU
                    , SUM(CASE WHEN TC2.CAR_T1743_TIPO_FACT=1 AND TC2.CAR_T1743_VAL_RFT_CU >= 0 THEN TC2.CAR_T1743_CONS_USUARIO + TC2.CAR_T1743_RFT_CU
                            WHEN TC2.CAR_T1743_TIPO_FACT=1 AND TC2.CAR_T1743_VAL_RFT_CU < 0 THEN TC2.CAR_T1743_CONS_USUARIO - TC2.CAR_T1743_RFT_CU
                            WHEN TC2.CAR_T1743_TIPO_FACT<>1 THEN 0 END) CONSUMO
                    , SUM(TC2.CAR_T1743_VAL_FACT_CU + TC2.CAR_T1743_VAL_RFT_CU) FACXCON
                    FROM ENERGIA_CREG_015.CAR_T1743_TC2FACTURACION_USU TC2
                    WHERE TC2.IDENTIFICADOR_EMPRESA < 99800
                    AND TC2.CAR_CARG_ANO = :ANIO_ARG --ANIO (REMPLAZAR EL 2021 POR LA VARIABLE DEL FRONT)
                    AND TC2.CAR_CARG_PERIODO = :MES_ARG --MES (REMPLAZAR EL 1 POR LA VARIABLE DEL FRONT)
                    AND (TC2.IDENTIFICADOR_EMPRESA = :EMPRESA_ARG OR 0 = :EMPRESA_ARG) --ID_ESP (REMPLAZAR EL 2103 POR LA VARIABLE DEL FRONT)
                    GROUP BY TC2.CAR_CARG_ANO, TC2.CAR_CARG_PERIODO, TC2.IDENTIFICADOR_EMPRESA
                    , (CASE WHEN INSTR(TC2.CAR_T1743_MERCADO_NIU,'-',1,1) > 0 THEN TC2.CAR_T1743_MERCADO_NIU ELSE TC2.CAR_T1743_ID_MERCADO || '-' || TC2.CAR_T1743_MERCADO_NIU END)
                    ) STC2 ON STC1.CAR_CARG_ANO=STC2.CAR_CARG_ANO AND STC1.CAR_CARG_PERIODO=STC2.CAR_CARG_PERIODO AND STC1.ID_COMER=STC2.IDENTIFICADOR_EMPRESA AND STC1.MERCADO_NIU=STC2.MERCADO_NIU
    GROUP BY STC1.CAR_CARG_ANO, STC1.CAR_CARG_PERIODO, STC1.ID_COMER, STC1.RES_NORES, STC1.CAR_T1732_DANE_NIU
) T,
(SELECT * FROM RUPS.ARE_ESP_EMPRESAS) ESP,
(SELECT D.DANE_COD_DEPTO, D.DANE_NOM_DPTO, D.DANE_COD_MPIO, D.DANE_NOM_MPIO, D.DANE_COD_CTP, D.DANE_NOM_POBLAD, D.DANE_DIVIPOLA, G.LATITUD, G.LONGITUD
FROM CARG_ARCH.DANE_DIVIPOLA D
LEFT JOIN JHERRERAA.GIS_CENTRO_POBLADO G ON TO_NUMBER(D.DANE_DIVIPOLA)=G.CODIGO_CENTRO_POBLADO) GIS
WHERE T.ID_COMER = ESP.ARE_ESP_SECUE
AND T.COD_DANE=GIS.DANE_DIVIPOLA;