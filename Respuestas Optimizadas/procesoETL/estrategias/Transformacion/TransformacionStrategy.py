from abc import ABC, abstractmethod
import pandas as pd

class TransformacionStrategy(ABC):
    @abstractmethod
    def transformar(self, transacciones: list) -> pd.DataFrame:
        pass
