import ValidacionStrategy

class ValidcionSinNulos(ValidacionStrategy):
    def validar(listaTransacciones) -> tuple[list, list]:
        transaccionesCorrectas = []
        transaccionesIncorrectas = []

        for transaccion in listaTransacciones:
            valido = True

            for clave, valor in transaccion.items():
                if valor is None:
                    valido = False
                    break

            if valido:
                transaccionesCorrectas.append(transaccion)
            else:
                transaccionesIncorrectas.append(transaccion)
        
        return transaccionesCorrectas, transaccionesIncorrectas
