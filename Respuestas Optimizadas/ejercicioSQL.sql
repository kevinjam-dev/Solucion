/*
 Una empresa de comercio electrónico desea identificar patrones de comportamiento entre sus usuarios para detectar posibles fraudes. 
 Para esto, tienes acceso a las siguientes tablas en su base de datos SQL:
 
usuarios (id_usuario, nombre, fecha_creacion, pais)
transacciones (id_transaccion, id_usuario, monto, fecha_transaccion, metodo_pago, ip)
alertas_fraude (id_alerta, id_transaccion, tipo_alerta, fecha_alerta)

Se desea obtener un informe que contenga la siguiente información: 
Usuarios con más de 3 alertas de fraude en los últimos 6 meses. 
Para cada uno, listar el total de transacciones, monto total transaccionado, país y el último método de pago utilizado. 
Incluir solamente usuarios cuya primera transacción ocurrió hace más de un año.

*/

CREATE DATABASE BACDB
USE BACDB


-- Create -
CREATE TABLE usuarios (
	id_usuario INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	nombre NVARCHAR NOT NULL,
	fecha_creacion DATE NOT NULL,
	pais NVARCHAR NOT NULL
);


CREATE TABLE transacciones (
	id_transaccion INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	id_usuario INT NOT NULL,
	monto DECIMAL (5,2) NOT NULL,
	fecha_transaccion DATE NOT NULL,
	metodo_pago NVARCHAR NOT NULL,
	ip NVARCHAR NOT NULL
);

CREATE TABLE alertas_fraude (
	id_alerta INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	id_transaccion INT NOT NULL,
	tipo_alerta NVARCHAR NOT NULL,
	fecha_alerta DATE NOT NULL
)
-------------------------------------

-- FK --
ALTER TABLE transacciones 
ADD CONSTRAINT FK_Usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario)

ALTER TABLE alertas_fraude
ADD CONSTRAINT FK_Transaccion FOREIGN KEY (id_transaccion) REFERENCES transacciones (id_transaccion)


ALTER TABLE usuarios
ALTER COLUMN nombre NVARCHAR(255)

ALTER TABLE usuarios
ALTER COLUMN pais NVARCHAR(255)

ALTER TABLE alertas_fraude
ALTER COLUMN tipo_alerta NVARCHAR(255)
-------------------------------------

-- Contar --
SELECT 
	COUNT(*)
FROM usuarios

SELECT 
	COUNT(*)
FROM transacciones
-------------------------------------

ALTER TABLE transacciones
ALTER COLUMN metodo_pago NVARCHAR(255)

ALTER TABLE transacciones
ALTER COLUMN monto DECIMAL(7, 2)

ALTER TABLE transacciones
ALTER COLUMN ip NVARCHAR(255)

-- Truncate --
TRUNCATE TABLE usuarios

TRUNCATE TABLE transacciones
-------------------------------------


-- Respuesta -- 
SELECT 
	U.id_usuario,
	U.nombre,
	U.pais,
	T.cantidadTransacciones,
	T.montoTotal,
	(
        SELECT 
			TOP 1 
			T2.metodo_pago
        FROM transacciones AS T2
        WHERE T2.id_usuario = U.id_usuario
        ORDER BY T2.fecha_transaccion DESC
    ) AS ultimoMetodoDePago
FROM usuarios AS U
INNER JOIN (
	SELECT
		T.id_usuario,
		COUNT(*) AS cantidadTransacciones,
        SUM(t.monto) AS montoTotal,
        MIN(t.fecha_transaccion) AS primerTransaccion
	FROM transacciones AS T
	GROUP BY T.id_usuario
) AS T
ON U.id_usuario = T.id_usuario
INNER JOIN (
	SELECT 
		T3.id_usuario
	FROM alertas_fraude AS A
	INNER JOIN transacciones AS T3 
	ON A.id_transaccion = T3.id_transaccion
	WHERE A.fecha_alerta >= DATEADD(MONTH, -6, GETDATE())
	GROUP BY T3.id_usuario
	HAVING COUNT(*) > 3
) AS AI
ON AI.id_usuario = U.id_usuario 
WHERE T.primerTransaccion <= DATEADD(YEAR, -1, GETDATE())
-------------------------------------


-- Consulta Preliminar --
SELECT 
    u.id_usuario,
    u.nombre,
    tinfo.total_transacciones,
    tinfo.monto_total,
    tinfo.ultimo_metodo_pago
FROM usuarios u
INNER JOIN (
    SELECT 
        t.id_usuario,
        COUNT(*) AS total_transacciones,
        SUM(t.monto) AS monto_total,
        MAX(t.metodo_pago) AS ultimo_metodo_pago,
        MIN(t.fecha_transaccion) AS primera_fecha
    FROM transacciones t
    GROUP BY t.id_usuario
) AS tinfo ON u.id_usuario = tinfo.id_usuario
WHERE 
    tinfo.primera_fecha <= DATEADD(YEAR, -1, GETDATE()) -- Usuarios con primera transacción hace más de 1 año
    AND u.id_usuario IN (
        SELECT t.id_usuario
        FROM alertas_fraude af
        INNER JOIN transacciones t ON af.id_transaccion = t.id_transaccion
        WHERE af.fecha_alerta >= DATEADD(MONTH, -6, GETDATE())
        GROUP BY t.id_usuario
        HAVING COUNT(*) > 3 -- Más de 3 alertas de fraude en los últimos 6 meses
    );
-------------------------------------

-- Consulta Nueva --
/*
 Una empresa de comercio electrónico desea identificar patrones de comportamiento entre sus usuarios para detectar posibles fraudes. 
 Para esto, tienes acceso a las siguientes tablas en su base de datos SQL:
 
usuarios (id_usuario, nombre, fecha_creacion, pais)
transacciones (id_transaccion, id_usuario, monto, fecha_transaccion, metodo_pago, ip)
alertas_fraude (id_alerta, id_transaccion, tipo_alerta, fecha_alerta)

Se desea obtener un informe que contenga la siguiente información: 
Usuarios con más de 3 alertas de fraude en los últimos 6 meses. 
Para cada uno, listar el total de transacciones, monto total transaccionado, país y el último método de pago utilizado. 
Incluir solamente usuarios cuya primera transacción ocurrió hace más de un año.
*/
/*
WITH alertasFraude AS (
	SELECT
		U.id_usuario
	FROM usuarios AS U
	INNER JOIN transacciones AS T
	ON U.id_usuario = T.id_usuario
	INNER JOIN alertas_fraude AS AF
	ON T.id_transaccion = AF.id_transaccion
	WHERE AF.fecha_alerta >= DATEADD(MONTH, -6, GETDATE())
	GROUP BY U.id_usuario
	HAVING COUNT(AF.id_alerta) > 3
), ultimoMetodoPago AS (
	SELECT 
		U.id_usuario,
		T.metodo_pago,
		ROW_NUMBER() OVER (PARTITION BY U.id_usuario ORDER BY T.fecha_transaccion DESC) AS PosReciente
	FROM usuarios AS U
	INNER JOIN transacciones AS T
	ON U.id_usuario = T.id_usuario
), primeraTransaccion AS (
	SELECT
		U.id_usuario,
		MIN(T.fecha_transaccion) AS FechaPrimeraTransaccion
	FROM usuarios AS U
	INNER JOIN transacciones AS T
	ON U.id_usuario = T.id_usuario
	GROUP BY U.id_usuario
), infoInforme AS (
	SELECT 
		U.id_usuario AS ID,
		U.nombre AS Nombre,
		U.pais AS Pais,
		UMP.metodo_pago AS UltimoMetodoPago,
		COUNT(T.id_usuario) AS TotalTransacciones,
		SUM(T.monto) AS MontoTotal
	FROM usuarios AS U
	INNER JOIN transacciones AS T
	ON U.id_usuario = T.id_usuario
	INNER JOIN ultimoMetodoPago AS UMP
	ON UMP.id_usuario = U.id_usuario
	INNER JOIN primeraTransaccion AS PT
	ON U.id_usuario = PT.id_usuario
	INNER JOIN alertasFraude AS AF
	ON U.id_usuario = AF.UsuarioID
	WHERE UMP.PosReciente = 1
		AND PT.FechaPrimeraTransaccion <= DATEADD(YEAR, -1, GETDATE())
	GROUP BY u.id_usuario, U.nombre, U.pais, UMP.metodo_pago
)

SELECT
	*
FROM infoInforme
ORDER BY ID ASC
*/

WITH alertasFraude AS (
	SELECT
		U.id_usuario
	FROM usuarios AS U
	INNER JOIN transacciones AS T
	ON U.id_usuario = T.id_usuario
	INNER JOIN alertas_fraude AS AF
	ON T.id_transaccion = AF.id_transaccion
	WHERE AF.fecha_alerta >= DATEADD(MONTH, -6, GETDATE())
	GROUP BY U.id_usuario
	HAVING COUNT(AF.id_alerta) > 3
), ultimoMetodoPago AS (
	SELECT 
		U.id_usuario,
		T.metodo_pago,
		ROW_NUMBER() OVER (PARTITION BY U.id_usuario ORDER BY T.fecha_transaccion DESC) AS PosReciente
	FROM usuarios AS U
	INNER JOIN transacciones AS T
	ON U.id_usuario = T.id_usuario
), primeraTransaccion AS (
	SELECT
		U.id_usuario,
		MIN(T.fecha_transaccion) AS FechaPrimeraTransaccion
	FROM usuarios AS U
	INNER JOIN transacciones AS T
	ON U.id_usuario = T.id_usuario
	GROUP BY U.id_usuario
), infoInforme AS (
	SELECT 
		U.id_usuario AS ID,
		U.nombre AS Nombre,
		U.pais AS Pais,
		UMP.metodo_pago AS UltimoMetodoPago,
		COUNT(T.id_transaccion) AS TotalTransacciones,
		SUM(T.monto) AS MontoTotal
	FROM usuarios AS U
	INNER JOIN transacciones AS T
	ON U.id_usuario = T.id_usuario
	INNER JOIN ultimoMetodoPago AS UMP
	ON UMP.id_usuario = U.id_usuario
	INNER JOIN primeraTransaccion AS PT
	ON U.id_usuario = PT.id_usuario
	INNER JOIN alertasFraude AS AF
	ON U.id_usuario = AF.id_usuario
	WHERE UMP.PosReciente = 1
		AND PT.FechaPrimeraTransaccion <= DATEADD(YEAR, -1, GETDATE())
	GROUP BY U.id_usuario, U.nombre, U.pais, UMP.metodo_pago
)
SELECT
	ID,
	Nombre,
	Pais,
	UltimoMetodoPago,
	TotalTransacciones,
	MontoTotal
FROM infoInforme
ORDER BY ID ASC

