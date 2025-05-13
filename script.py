import os
import json
import pandas as pd


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

def validarFormato(listaTransacciones):
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

def guardarArchivo(df, nombreArchivo):
    df.to_csv(nombreArchivo, index=False)

def guardarTransaccionesIncorrectas(transaccionesIncorrectas):
    df = pd.DataFrame(transaccionesIncorrectas)
    guardarArchivo(df, "errores.csv")

def transformarTransacciones(transaccionesCorrectas):
    df = pd.DataFrame(transaccionesCorrectas)
    dfTransformado = df.explode("products").reset_index(drop=True)
    return dfTransformado


def main():
    rutaPrincipal = "archivos/transacciones"
    listaTransacciones = cargarArchivos(rutaPrincipal)

    transaccionesCorrectas, transaccionesIncorrectas = validarFormato(listaTransacciones)

    if transaccionesIncorrectas:
        guardarTransaccionesIncorrectas(transaccionesIncorrectas)
    
    dfTransformado = transformarTransacciones(transaccionesCorrectas)

    guardarArchivo(dfTransformado, "transacciones_limpias.csv")

if __name__ == "__main__":
    main()
