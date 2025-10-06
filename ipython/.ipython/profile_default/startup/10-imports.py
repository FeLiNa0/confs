from __future__ import print_function

import importlib
import sys
import time

_preimport_start_time = time.time()

_preimported_modules = {}
_failed_preimported_modules = []
_preimported_modules_not_loaded = []

_preimport_implementation = getattr(sys, "implementation", None)


def imp(module_name, third_party=False, not2=False, not_pypy=False):
    try:
        if (
            not_pypy and getattr(_preimport_implementation, "name", None) == "pypy"
        ) or (not2 and sys.version_info.major < 3):
            _preimported_modules_not_loaded.append(module_name)
            return

        if module_name not in sys.modules:
            module_start_time = time.time()
            importlib.import_module(module_name)
            _preimported_modules[module_name] = (time.time() - module_start_time) * 1000
        return importlib.import_module(module_name)

    except Exception as exc:  # pylint: disable=broad-except
        _failed_preimported_modules.append(module_name)
        if not third_party:
            print("%s %s" % (__file__, exc))
    return


ast = imp("ast")
binascii = imp("binascii")
collections = imp("collections")
copy = imp("copy")
datetime = imp("datetime")
getpass = imp("getpass")
decimal = imp("decimal")
Decimal = decimal.Decimal
fileinput = imp("fileinput")
functools = imp("functools")
importlib = imp("importlib")
itertools = imp("itertools")
json = imp("json")
# slow
# logging = imp("logging")
math = imp("math")
os = imp("os")
# slow
# pdb = imp("pdb")
# slow
# pickle = imp("pickle")
# slow
# platform = imp("platform")
glob = imp("glob")
pprint = imp("pprint")
random = imp("random")
re = imp("re")
socket = imp("socket")
string = imp("string")
subprocess = imp("subprocess")
sys = imp("sys")
threading = imp("threading")
# time = imp("time")
traceback = imp("traceback")
subprocess = imp("subprocess")


# Third party
requests = imp("requests", True)
# slow
# np = numpy = imp("numpy", True)
progressbar = imp("progressbar", True)
pydantic = imp("pydantic", True)
yaml = imp("yaml", True)

# Built-in libraries not present in Python 2
asyncio = imp("asyncio", not2=True, not_pypy=True)
enum = imp("enum", not2=True)
statistics = imp("statistics", not2=True)
typing = imp("typing", not2=True)

_failed_preimported_modules_str = " ".join(
    sorted(_preimported_modules_not_loaded + _failed_preimported_modules)
)

duration = time.time() - _preimport_start_time

if len(_preimported_modules) > 0:
    print()
    print(sys.version, _preimport_implementation)
    print("sys.path:", "    ".join(sys.path))
    print()

    print(
        "import",
        len(_preimported_modules),
        "in",
        f"{duration:.3}sec",
        " ".join(sorted(_preimported_modules)),
    )

    if _failed_preimported_modules_str:
        print("failed:", _failed_preimported_modules_str)

try:
    def paste_from_clipboard(as_bytes: bool=False) -> str | bytes:
        import subprocess
        result = subprocess.run("vis-clipboard --paste".split(), stdout=subprocess.PIPE)
        result = result.stdout
        return result if as_bytes else result.decode()
    def copy_to_clipboard(contents: str | bytes, encoding="utf-8"):
        import subprocess
        contents = contents.encode(encoding=encoding) if isinstance(contents, str) else contents
        result = subprocess.run("vis-clipboard --copy".split(), stdout=subprocess.PIPE, input=contents)
        return result
    vp = paste_from_clipboard
    vc = copy_to_clipboard

except Exception:
    pass # boo hoo
