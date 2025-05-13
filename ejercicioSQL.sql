
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