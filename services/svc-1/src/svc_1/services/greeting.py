from svc_1.contracts.hello import HelloOut, HelloQuery


def make_greeting(q: HelloQuery) -> HelloOut:
    name = q.name.strip()
    return HelloOut(message=f"hello {name}")
