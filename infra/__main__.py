from importlib import import_module

from pulumi import get_stack

# Load the per-env program dynamically, e.g. stacks/dev/__main__.py
stack = get_stack()  # "dev", "stg", "prod"
import_module(f"stacks.{stack}.__main__")
