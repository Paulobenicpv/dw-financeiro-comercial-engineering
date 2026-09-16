.PHONY: install bootstrap run prefect test lint demo
install:
	pip install -r requirements.txt
bootstrap:
	PYTHONPATH=src python scripts/bootstrap.py
run:
	PYTHONPATH=src python scripts/run_pipeline.py
prefect:
	PYTHONPATH=src python orchestration/prefect_flow.py
test:
	PYTHONPATH=src pytest -q
lint:
	PYTHONPATH=src python -m compileall -q src orchestration scripts tests
demo:
	docker compose up --build
