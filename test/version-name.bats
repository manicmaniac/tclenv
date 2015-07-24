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
  run tclenv-version-name
  assert_success "system"
}

@test "system version is not checked for existance" {
  TCLENV_VERSION=system run tclenv-version-name
  assert_success "system"
}

@test "TCLENV_VERSION has precedence over local" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > ".tcl-version" <<<"1.8.7"
  run tclenv-version-name
  assert_success "1.8.7"

  TCLENV_VERSION=1.9.3 run tclenv-version-name
  assert_success "1.9.3"
}

@test "local file has precedence over global" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > "${TCLENV_ROOT}/version" <<<"1.8.7"
  run tclenv-version-name
  assert_success "1.8.7"

  cat > ".tcl-version" <<<"1.9.3"
  run tclenv-version-name
  assert_success "1.9.3"
}

@test "missing version" {
  TCLENV_VERSION=1.2 run tclenv-version-name
  assert_failure "tclenv: version \`1.2' is not installed (set by TCLENV_VERSION environment variable)"
}

@test "version with prefix in name" {
  create_version "1.8.7"
  cat > ".tcl-version" <<<"tcl-1.8.7"
  run tclenv-version-name
  assert_success
  assert_output "1.8.7"
}
