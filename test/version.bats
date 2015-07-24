#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${TCLENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$TCLENV_TEST_DIR"
  cd "$TCLENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${TCLENV_ROOT}/versions" ]
  run tclenv-version
  assert_success "system (set by ${TCLENV_ROOT}/version)"
}

@test "set by TCLENV_VERSION" {
  create_version "1.9.3"
  TCLENV_VERSION=1.9.3 run tclenv-version
  assert_success "1.9.3 (set by TCLENV_VERSION environment variable)"
}

@test "set by local file" {
  create_version "1.9.3"
  cat > ".tcl-version" <<<"1.9.3"
  run tclenv-version
  assert_success "1.9.3 (set by ${PWD}/.tcl-version)"
}

@test "set by global file" {
  create_version "1.9.3"
  cat > "${TCLENV_ROOT}/version" <<<"1.9.3"
  run tclenv-version
  assert_success "1.9.3 (set by ${TCLENV_ROOT}/version)"
}
