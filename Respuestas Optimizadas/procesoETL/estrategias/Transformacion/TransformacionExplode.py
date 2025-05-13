import TransformacionStrategy
import pandas as pd

class TransformacionExplode(TransformacionStrategy):
    def transformar(self, transacciones: list) -> pd.DataFrame:
        df = pd.DataFrame(transacciones)
        df_transformado = df.explode("products").reset_index(drop=True)
        return df_transformado
