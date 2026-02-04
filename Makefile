DBT_CORE_VERSION ?= 1.8.0
DBT_SNOWFLAKE_VERSION ?= 1.8.0

BASE_TAG = dbt-runtime-base:local
CORE_TAG = dbt-runtime-core:local
SNOW_TAG = dbt-runtime-snowflake:local

build-base:
	docker build -f docker/base/Dockerfile -t $(BASE_TAG) .

build-core: build-base
	docker build -f docker/core/Dockerfile \
		--build-arg BASE_IMAGE=$(BASE_TAG) \
		--build-arg DBT_CORE_VERSION=$(DBT_CORE_VERSION) \
		-t $(CORE_TAG) .

build-snowflake: build-core
	docker build -f docker/adapters/snowflake/Dockerfile \
		--build-arg CORE_IMAGE=$(CORE_TAG) \
		--build-arg DBT_SNOWFLAKE_VERSION=$(DBT_SNOWFLAKE_VERSION) \
		-t $(SNOW_TAG) .

test-core: build-core
	docker run --rm $(CORE_TAG) --version

test-snowflake: build-snowflake
	docker run --rm --entrypoint bash $(SNOW_TAG) -lc 'python -c "import dbt.adapters.snowflake; print(\"ok\")"'

all: test-core test-snowflake
