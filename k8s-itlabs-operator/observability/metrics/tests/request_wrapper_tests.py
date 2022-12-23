class TestKopfRequestWrapper:
    def test_try_except_not_fail(self):
        def func(a, b):
            try:
                return a
            finally:
                pass

        res = func(1, 2)
        assert res == 1

    def test_try_except_fail(self):
        def func_fail(a, b):
            try:
                raise Exception(b)
            except Exception:
                raise
            finally:
                pass

        try:
            func_fail('1', '2')
        except Exception as e:
            assert e.args[0] == '2'
