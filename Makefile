PROJECT_TYPE := scala
PYTHON_DIR := 
SCALA_DIR := sc_test


DATABRICKS_PROFILE ?= dev-public
DATABRICKS_TEMPLATE ?= default-python


SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c


.PHONY: setup build test validate deploy databricks-init ci help


# Setup

setup:
ifeq ($(PROJECT_TYPE),python)
	@echo "Setting up Python environment..."
	cd $(PYTHON_DIR) && python3 -m venv .venv
endif

ifeq ($(PROJECT_TYPE),scala)
	@echo "Resolving Scala dependencies..."
	cd $(SCALA_DIR) && sbt update
endif

ifeq ($(PROJECT_TYPE),hybrid)
	@echo "Setting up Hybrid project..."
	cd $(PYTHON_DIR) && python3 -m venv .venv
	cd $(SCALA_DIR) && sbt update
endif


# Build


build:
ifeq ($(PROJECT_TYPE),python)
	@echo "Building Python project..."
	cd $(PYTHON_DIR) && python3 -m compileall src
endif

ifeq ($(PROJECT_TYPE),scala)
	@echo "Building Scala project..."
	cd $(SCALA_DIR) && sbt compile
endif

ifeq ($(PROJECT_TYPE),hybrid)
	@echo "Building Hybrid project..."
	cd $(PYTHON_DIR) && python3 -m compileall src
	cd $(SCALA_DIR) && sbt compile
endif


# Test


test:
ifeq ($(PROJECT_TYPE),python)
	@echo "Running Python tests..."
	cd $(PYTHON_DIR) && pytest
endif

ifeq ($(PROJECT_TYPE),scala)
	@echo "Running Scala tests..."
	cd $(SCALA_DIR) && sbt test
endif

ifeq ($(PROJECT_TYPE),hybrid)
	@echo "Running Hybrid tests..."
	cd $(PYTHON_DIR) && pytest
	cd $(SCALA_DIR) && sbt test
endif



# Databricks Bundle Init


databricks-init:
	@echo "Initializing Databricks bundle..."

	@if [ ! -f databricks.yml ]; then \
		databricks bundle init $(DATABRICKS_TEMPLATE) \
			--profile $(DATABRICKS_PROFILE) \
			--output-dir . \
			--force; \
	else \
		echo "databricks.yml already exists. Skipping init."; \
	fi


# Databricks Validate


validate:
	@echo "Validating Databricks bundle..."

	@if [ ! -f databricks.yml ]; then \
		echo "ERROR: databricks.yml not found."; \
		echo "Run: make databricks-init"; \
		exit 1; \
	fi

	databricks bundle validate -p $(DATABRICKS_PROFILE)

deploy:
	@echo "Deploying Databricks bundle..."
	databricks bundle deploy -p $(DATABRICKS_PROFILE)


# Full CI Flow



ci: build test validate



# Help


help:
	@echo ""
	@echo "Available commands:"
	@echo ""
	@echo "  make setup"
	@echo "  make build"
	@echo "  make test"

	@echo "  make databricks-init"
	@echo "  make validate"
	@echo "  make deploy"

	@echo "  make ci"
	@echo ""