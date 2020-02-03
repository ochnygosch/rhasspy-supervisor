SOURCE = rhasspysupervisor
PYTHON_FILES = $(SOURCE)/*.py *.py
SHELL_FILES = bin/*

.PHONY: reformat check test venv dist pyinstaller

version := $(shell cat VERSION)
architecture := $(shell dpkg-architecture | grep DEB_BUILD_ARCH= | sed 's/[^=]\+=//')

reformat:
	black .
	isort $(PYTHON_FILES)

check:
	flake8 $(PYTHON_FILES)
	pylint $(PYTHON_FILES)
	mypy $(PYTHON_FILES)
	black --check .
	isort --check-only $(PYTHON_FILES)
	bashate $(SHELL_FILES)
	yamllint .
	pip list --outdated

venv:
	scripts/create-venv.sh

dist:
	python3 setup.py sdist

pyinstaller:
	mkdir -p dist
	pyinstaller -y --workpath pyinstaller/build --distpath pyinstaller/dist rhasspysupervisor.spec
	tar -C pyinstaller/dist -czf dist/rhasspy-supervisor_$(version)_$(architecture).tar.gz rhasspysupervisor/
