from operators.dto import ConnectorStatus, EnabledLabelValues


class TestEnabledLabelValues:
    def test_str(self):
        value = str(EnabledLabelValues.enabled)
        assert isinstance(value, str)
        assert value == 'enabled'


class TestConnectorStatus:
    def test_label_is_enabled(self):
        status = ConnectorStatus()
        assert isinstance(status.label_is_enabled, str)
        assert status.label_is_enabled == EnabledLabelValues.undefined.value

    def test_label_is_enabled_true(self):
        status = ConnectorStatus(is_enabled=True)
        assert isinstance(status.label_is_enabled, str)
        assert status.label_is_enabled == EnabledLabelValues.enabled.value

    def test_label_is_enabled_false(self):
        status = ConnectorStatus(is_enabled=False)
        assert isinstance(status.label_is_enabled, str)
        assert status.label_is_enabled == EnabledLabelValues.disabled.value
