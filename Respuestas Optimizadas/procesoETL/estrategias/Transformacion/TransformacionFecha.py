import TransformacionStrategy
import pandas as pd

class TransformacionFecha(TransformacionStrategy):
    def transformar(self, transacciones: list[dict]) -> pd.DataFrame:
        df = pd.DataFrame(transacciones)
        df["date"] = pd.to_datetime(df["date"], errors="coerce")
        df["año"] = df["date"].dt.year
        df["mes"] = df["date"].dt.month
        return df