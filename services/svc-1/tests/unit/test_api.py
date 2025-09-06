from fastapi.testclient import TestClient
from svc_1.contracts.hello import HelloQuery
from svc_1.main import app
from svc_1.services.greeting import make_greeting

client = TestClient(app)


def test_healthz() -> None:
    resp = client.get("/healthz")
    assert resp.status_code == 200
    assert resp.json() == {"ok": True}


def test_hello_default() -> None:
    resp = client.get("/hello")
    assert resp.status_code == 200
    assert resp.json() == {"message": "hello world"}


def test_hello_with_name() -> None:
    resp = client.get("/hello", params={"name": "llmworks"})
    assert resp.status_code == 200
    assert resp.json() == {"message": "hello llmworks"}


def test_service_make_greeting_unit() -> None:
    # pure service test (no FastAPI involved)
    out = make_greeting(HelloQuery(name="Unit Test"))
    assert out.message == "hello Unit Test"
