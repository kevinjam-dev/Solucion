import ValidacionStrategy

class ValidacionEstandar(ValidacionStrategy):
    def validar(listaTransacciones)-> tuple[list, list]:
        formato = {"transaction_id", "amount", "date", "customer_id", "products"}

        transaccionesCorrectas = []
        transaccionesIncorrectas = []

        for transaccion in listaTransacciones:
            valido = True

            for columna in formato:
                if columna not in transaccion or transaccion[columna] is None: 
                    valido =  False
                    break
            
            if valido and not isinstance(transaccion["products"], list):
                valido = False

            if valido:
                transaccionesCorrectas.append(transaccion)
            else:
                transaccionesIncorrectas.append(transaccion)
        
        return transaccionesCorrectas, transaccionesIncorrectas