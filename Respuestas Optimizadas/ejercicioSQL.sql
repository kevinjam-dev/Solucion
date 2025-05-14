-------------------------------------

-- Consulta Nueva --
/*
 Una empresa de comercio electr�nico desea identificar patrones de comportamiento entre sus usuarios para detectar posibles fraudes. 
 Para esto, tienes acceso a las siguientes tablas en su base de datos SQL:
 
usuarios (id_usuario, nombre, fecha_creacion, pais)
transacciones (id_transaccion, id_usuario, monto, fecha_transaccion, metodo_pago, ip)
alertas_fraude (id_alerta, id_transaccion, tipo_alerta, fecha_alerta)

Se desea obtener un informe que contenga la siguiente informaci�n: 
Usuarios con m�s de 3 alertas de fraude en los �ltimos 6 meses. 
Para cada uno, listar el total de transacciones, monto total transaccionado, pa�s y el �ltimo m�todo de pago utilizado. 
Incluir solamente usuarios cuya primera transacci�n ocurri� hace m�s de un a�o.
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

