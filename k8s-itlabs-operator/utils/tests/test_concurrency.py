import asyncio
import time

import pytest
from utils.concurrency import ConnectorSourceLock


@pytest.mark.unit
class TestConnectorSourceLock:
    is_thread_1_done = False
    is_thread_2_done = False
    is_thread_3_done = False

    thread_sleep_time = 0.2

    def run_thread_1_for_common_resource(self):
        with ConnectorSourceLock("common-resource"):
            while not self.is_thread_1_done:
                time.sleep(self.thread_sleep_time)

    def run_thread_2_for_common_resource(self):
        with ConnectorSourceLock("common-resource"):
            while not self.is_thread_2_done:
                time.sleep(self.thread_sleep_time)

    def run_thread_3_for_other_resource(self):
        with ConnectorSourceLock("other-resource"):
            while not self.is_thread_3_done:
                time.sleep(self.thread_sleep_time)

    @pytest.mark.asyncio
    async def test_connector_source_lock(self):
        loop = asyncio.get_running_loop()

        thread_1_task = loop.run_in_executor(
            None, self.run_thread_1_for_common_resource
        )
        await asyncio.sleep(0)

        thread_2_task = loop.run_in_executor(
            None, self.run_thread_2_for_common_resource
        )
        await asyncio.sleep(0)

        thread_3_task = loop.run_in_executor(
            None, self.run_thread_3_for_other_resource
        )
        await asyncio.sleep(self.thread_sleep_time)

        assert thread_1_task.done() is False
        assert thread_2_task.done() is False
        assert thread_3_task.done() is False

        self.is_thread_2_done = True
        await asyncio.sleep(self.thread_sleep_time)
        # thread_2 waiting while thread_1 has unlocked common-resource
        assert thread_2_task.done() is False

        self.is_thread_3_done = True
        await asyncio.sleep(self.thread_sleep_time)
        # thread_3 was done, because it's not used common-resource
        assert thread_3_task.done() is True

        self.is_thread_1_done = True
        await asyncio.sleep(self.thread_sleep_time)
        assert thread_1_task.done() is True
        assert thread_2_task.done() is True
