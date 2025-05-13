import TransformacionStrategy
import TransformacionExplode
import TransformacionFecha

class TransformacionCompuesta(TransformacionStrategy):
    def transformar(self, transacciones: list):
        transformadorExplode = TransformacionExplode()
        transformadorFecha = TransformacionFecha()

        df = transformadorExplode.transformar(transacciones)
        df = transformadorFecha.transformar(df)

        return df
