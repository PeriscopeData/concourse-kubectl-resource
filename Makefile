all: run-tests build push
test: run-tests build pushtest

build:
	docker build -t periscopedata/concourse-kubectl-resource:local .

push:
	docker tag periscopedata/concourse-kubectl-resource:local periscopedata/concourse-kubectl-resource:latest
	docker push periscopedata/concourse-kubectl-resource:latest

pushtest:
	docker tag periscopedata/concourse-kubectl-resource:local periscopedata/concourse-kubectl-resource:test
	docker push periscopedata/concourse-kubectl-resource:test

run-tests:
	./bin/check < test/test_check.json
	./bin/out < test/test_out.json
