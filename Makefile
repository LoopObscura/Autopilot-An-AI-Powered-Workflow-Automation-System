.PHONY: help install setup dev stop logs test lint format clean migrate seed

# Variables
VENV := venv
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip

help:
	@echo "AutoPilot Development Commands"
	@echo "=============================="
	@echo "make install       - Install dependencies"
	@echo "make setup         - Set up development environment"
	@echo "make dev           - Start development environment (Docker Compose)"
	@echo "make stop          - Stop all containers"
	@echo "make logs          - View application logs"
	@echo "make test          - Run tests"
	@echo "make lint          - Lint code"
	@echo "make format        - Format code with black and isort"
	@echo "make clean         - Clean up temporary files"
	@echo "make migrate       - Run database migrations"
	@echo "make seed          - Seed database with sample data"
	@echo "make build         - Build Docker image"

# Install dependencies
install:
	python -m venv $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements-dev.txt

# Set up environment
setup: install
	cp .env.example .env
	@echo "✅ Setup complete! Edit .env with your credentials."

# Start development environment
dev:
	@echo "Starting AutoPilot development environment..."
	docker-compose up -d
	@echo "✅ Services running:"
	@echo "   - API: http://localhost:8000"
	@echo "   - API Docs: http://localhost:8000/docs"
	@echo "   - Jaeger: http://localhost:16686"
	@echo "   - Flower: http://localhost:5555"
	@echo "   - Qdrant: http://localhost:6333"

# Stop containers
stop:
	docker-compose down

# View logs
logs:
	docker-compose logs -f app

# Run tests
test:
	$(PYTHON) -m pytest tests/ -v --cov=app --cov-report=html

# Lint code
lint:
	$(PYTHON) -m pylint app/
	$(PYTHON) -m flake8 app/
	$(PYTHON) -m mypy app/

# Format code
format:
	$(PYTHON) -m black app/ tests/
	$(PYTHON) -m isort app/ tests/

# Clean up
clean:
	find . -type f -name '*.pyc' -delete
	find . -type d -name '__pycache__' -delete
	find . -type d -name '.pytest_cache' -delete
	rm -rf .coverage htmlcov/

# Database migrations
migrate:
	$(PYTHON) scripts/migrate_db.py

# Seed database
seed:
	$(PYTHON) scripts/seed_data.py

# Build Docker image
build:
	docker build -f docker/Dockerfile -t autopilot:latest .

# Run app locally (without Docker)
run:
	$(PYTHON) -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Check health
health:
	curl -f http://localhost:8000/health || echo "Service not running"

# Full reset (dangerous!)
reset: clean stop
	docker-compose down -v
	@echo "⚠️  All containers and volumes removed!"
