from svc_1.contracts.common import AppError


def test_app_error_shape() -> None:
    e = AppError(code="INVALID_INPUT", message="bad")
    assert e.code == "INVALID_INPUT" and e.message == "bad"
