PIP := pip install -r
DATABASE_PASS := postgres

PROJECT_NAME := raffa-studio
PYTHON_VERSION := 3.8.5
VENV_NAME := $(PROJECT_NAME)-$(PYTHON_VERSION)

.pip:
	pip install --upgrade pip

.install_dependencies:
	-apk --update --upgrade add libmagic
	-sudo apt-get install libmagic

.create-venv:
	pyenv install -s $(PYTHON_VERSION)
	pyenv uninstall -f $(VENV_NAME)
	pyenv virtualenv $(PYTHON_VERSION) $(VENV_NAME)
	pyenv local $(VENV_NAME)

run-postgres:
	docker start $(PROJECT_NAME)-postgres 2>/dev/null || docker run --name $(PROJECT_NAME)-postgres -p 5433:5432 -e POSTGRES_PASSWORD='$(DATABASE_PASS)' -d postgres:13.7-alpine

setup-dev: .pip .install_dependencies
	$(PIP) requirements.txt

create-venv: .create-venv setup-dev

run:
	DJANGO_READ_DOT_ENV_FILE=on DJANGO_DEBUG=True python manage.py runserver 0.0.0.0:8000

migrate:
	python manage.py migrate