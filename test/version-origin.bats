#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$TCLENV_TEST_DIR"
  cd "$TCLENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${TCLENV_ROOT}/version" ]
  run tclenv-version-origin
  assert_success "${TCLENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$TCLENV_ROOT"
  touch "${TCLENV_ROOT}/version"
  run tclenv-version-origin
  assert_success "${TCLENV_ROOT}/version"
}

@test "detects TCLENV_VERSION" {
  TCLENV_VERSION=1 run tclenv-version-origin
  assert_success "TCLENV_VERSION environment variable"
}

@test "detects local file" {
  touch .tcl-version
  run tclenv-version-origin
  assert_success "${PWD}/.tcl-version"
}

@test "detects alternate version file" {
  touch .tclenv-version
  run tclenv-version-origin
  assert_success "${PWD}/.tclenv-version"
}
