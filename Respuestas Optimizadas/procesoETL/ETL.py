import os
import json
import pandas as pd

from estrategias.Validacion import ValidacionStrategy
from estrategias.Transformacion import TransformacionStrategy

class ETL:
    def __init__(self, validador: ValidacionStrategy, transformador: TransformacionStrategy):
        self.validador = validador
        self.transformador = transformador
    
    def guardarArchivo(df, nombreArchivo):
        df.to_csv(nombreArchivo, index=False)

    def cargarArchivos(rutaPrincipal):
        listaTransacciones = []
        for archivo in os.listdir(rutaPrincipal):
            if archivo.endswith('.json'):
                rutaArchivo = os.path.join(rutaPrincipal, archivo)
                try:
                    with open(rutaArchivo, 'r', encoding='utf-8') as contenido:
                        datos = json.load(contenido)
                        listaTransacciones.extend(datos)
                except:
                    print(f"Se dio un error al cargar los datos del archivo: {archivo}")
        return listaTransacciones
    
    def ejecutar(self, rutaPrincipal):
        listaTransacciones = self.cargarArchivos(rutaPrincipal)

        transaccionesCorrectas, transaccionesIncorrectas = self.validador.validar(listaTransacciones)

        if transaccionesIncorrectas:
            dfErrores = pd.DataFrame(transaccionesIncorrectas)
            self.guardarArchivo(dfErrores, "errores.csv")

        dfTransformado = self.transformador.transformar(transaccionesCorrectas)
        self.guardarArchivo(dfTransformado, "transacciones_limpias.csv")