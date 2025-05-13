import ValidacionStrategy
import ValidacionFormato
import ValidacionNulos

class ValidacionCompuesta(ValidacionStrategy):
    def validar(self, listaTransacciones) -> tuple[list, list]:
        
        validadorFormato = ValidacionFormato()
        validadorNulos = ValidacionNulos()

        transaccionesCorrectas, transaccionesIncorrectas = validadorFormato.validar(listaTransacciones)
        transaccionesCorrectas, transaccionesNulos = validadorNulos.validar(transaccionesCorrectas)

        transaccionesIncorrectas.extend(transaccionesNulos)
        return transaccionesCorrectas, transaccionesIncorrectas
