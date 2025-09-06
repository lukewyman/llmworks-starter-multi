from fastapi import FastAPI, Query

from svc_1.contracts.hello import HealthOut, HelloOut, HelloQuery
from svc_1.services.greeting import make_greeting

app = FastAPI()


@app.get("/healthz", response_model=HealthOut)
def healthz() -> HealthOut:
    return HealthOut(ok=True)


@app.get("/hello", response_model=HelloOut)
def hello(name: str = Query("world", min_length=1, max_length=100)) -> HelloOut:
    return make_greeting(HelloQuery(name=name))
