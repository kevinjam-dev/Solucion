# Validacion
from estrategias.Validacion.ValidacionEstandar import ValidacionEstandar
from estrategias.Validacion.ValidacionSinNulos import ValidcionSinNulos
from estrategias.Validacion.ValidacionCompuesta import ValidacionCompuesta

# Transformacion
from estrategias.Transformacion.TransformacionExplode import TransformacionExplode
from estrategias.Transformacion.TransformacionFecha import TransformacionFecha
from estrategias.Transformacion.TransformacionCompuesta import TransformacionCompuesta

#ETL
from ETL import ETL


if __name__ == "__main__":

    # Proceso 1
    validador = ValidacionEstandar()
    transformador = TransformacionExplode()

    etl = ETL(validador, transformador)
    etl.ejecutar("archivos/transacciones")

    # Proceso 2
    validador2 = ValidcionSinNulos()
    transformador2 = TransformacionFecha()

    etl2 = ETL(validador2, transformador2)
    etl2.ejecutar("archivos/transacciones")

    # Proceso 3
    validador3 = ValidacionCompuesta()
    transformador3 = TransformacionCompuesta()
    etl3 = ETL()
    etl3.ejecutar("archivos/transacciones")
