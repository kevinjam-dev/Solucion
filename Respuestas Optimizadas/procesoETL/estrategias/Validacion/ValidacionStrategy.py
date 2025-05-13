from abc import ABC, abstractmethod

class ValidacionStrategy(ABC):
    @abstractmethod
    def validar(self, transacciones: list) -> tuple[list, list]:
        pass
