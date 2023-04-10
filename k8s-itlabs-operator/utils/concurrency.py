from threading import Condition
from typing import List


class ConnectorSourceLock:
    _lock = Condition()
    _lock_sources: List[str] = []

    def __init__(self, source_hash: str):
        self.source_hash = source_hash

    def __enter__(self):
        with self._lock:
            self._lock.wait_for(self.is_source_unlocked)
            self._lock_sources.append(self.source_hash)

    def __exit__(self, exc_type, exc_val, exc_tb):
        with self._lock:
            self._lock_sources.remove(self.source_hash)
            self._lock.notify()

    def is_source_unlocked(self):
        return self.source_hash not in self._lock_sources
