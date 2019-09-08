ifeq (${PYTHON}, )
override PYTHON=3.6
endif

DOCKER=docker run -p 8888:8888 -v ${PWD}:/ntc_dummies ntc_dummies-${PYTHON}:latest

YANG_VENDORED_BASE_PATH=ntc_dummies/yang

OPENCONFIG_REPO=https://github.com/networktocode/openconfig.git
OPENCONFIG_BRANCH=7edf3c8
OPENCONFIG_FOLDER=openconfig

NTC_YANG_REPO=https://github.com/networktocode/ntc-yang-models.git
NTC_YANG_BRANCH=3afc611
NTC_YANG_FOLDER=ntc-yang-models

.PHONY: build_test_container
build_test_container:
	docker build \
		--tag ntc_dummies-${PYTHON}:latest \
		--build-arg PYTHON=${PYTHON} \
		-f Dockerfile .

.PHONY: enter-container
enter-container:
	${DOCKER} \
		bash

.PHONY: pytest
pytest:
	${DOCKER} \
		pytest --cov=ntc_dummies --cov-report=term-missing -vs ${ARGS}

.PHONY: black
black:
	${DOCKER} \
		black --check .

.PHONY: pylama
pylama:
	${DOCKER} \
		pylama .

.PHONY: mypy
mypy:
	${DOCKER} \
		mypy .

.PHONY: jupyter
jupyter:
	${DOCKER} \
		jupyter notebook --allow-root --ip=0.0.0.0 --NotebookApp.token=''

.PHONY: tests
tests: build_test_container black pylama mypy lint
	make pytest PYTHON=3.6

.PHONY: lint
lint:
	${DOCKER} \
		poetry run ntc_dummies lint -i W001 -m openconfig ntc_dummies/parsers/openconfig ntc_dummies/translators/openconfig
	${DOCKER} \
		poetry run ntc_dummies lint -i W001 -m ntc ntc_dummies/parsers/ntc ntc_dummies/translators/ntc

.PHONY: vendor
vendor:
	rm -rf $(YANG_VENDORED_BASE_PATH)/$(OPENCONFIG_FOLDER)
	git clone $(OPENCONFIG_REPO) $(YANG_VENDORED_BASE_PATH)/$(OPENCONFIG_FOLDER)
	cd $(YANG_VENDORED_BASE_PATH)/$(OPENCONFIG_FOLDER) && git checkout $(OPENCONFIG_BRANCH)
	rm -rf $(YANG_VENDORED_BASE_PATH)/$(OPENCONFIG_FOLDER)/.git

	rm -rf $(YANG_VENDORED_BASE_PATH)/$(NTC_YANG_FOLDER)
	git clone $(NTC_YANG_REPO) $(YANG_VENDORED_BASE_PATH)/$(NTC_YANG_FOLDER)
	cd $(YANG_VENDORED_BASE_PATH)/$(NTC_YANG_FOLDER) && git checkout $(NTC_YANG_BRANCH)
	rm -rf $(YANG_VENDORED_BASE_PATH)/$(NTC_YANG_FOLDER)/.git
