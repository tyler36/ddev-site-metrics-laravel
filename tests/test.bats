#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # Override this variable for your add-on:
  export GITHUB_REPO=tyler36/ddev-site-metrics-laravel

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p ~/tmp
  export TESTDIR=$(mktemp -d ~/tmp/${PROJNAME}.XXXXXX)
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"

  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
}

health_checks() {
  # Confirm PHP module is installed
  ddev php --ri opentelemetry | grep "opentelemetry hooks => enabled"

  # Environmental variables are set
  run ddev dotenv get .ddev/.env.web --otel-php-autoload-enabled
  assert_output true

  # It writes traces
  run curl -sfI https://${PROJNAME}.ddev.site
  assert_output --partial "HTTP/2 200"
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

install_laravel() {
  ddev config --project-type=laravel --docroot=public
  ddev start
  ddev composer create "laravel/laravel"
  ddev artisan key:generate
  ddev artisan migrate:fresh
}

@test "install from directory" {
  set -eu -o pipefail

  install_laravel

  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success

  run ddev restart -y
  assert_success
  health_checks
}

@test "it can collect traces" {
  set -eu -o pipefail

  install_laravel

  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success

  run ddev dotenv set .ddev/.env.web --otel-traces-exporter=console
  assert_success

  run ddev restart -y
  assert_success

  # Ensure traces appear in logs
  run curl -sfI https://${PROJNAME}.ddev.site
  assert_output --partial "HTTP/2 200"
  # Service name is set in `.ddev/.env` in `OTEL_SERVICE_NAME`
  ddev logs -s web | \grep --color=auto '"service.name": "laravel"'
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}
