#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${TCLENV_TEST_DIR}/myproject"
  cd "${TCLENV_TEST_DIR}/myproject"
  echo "1.2.3" > .tcl-version
  mkdir -p "${TCLENV_ROOT}/versions/1.2.3"
  run tclenv-prefix
  assert_success "${TCLENV_ROOT}/versions/1.2.3"
}

@test "prefix for invalid version" {
  TCLENV_VERSION="1.2.3" run tclenv-prefix
  assert_failure "tclenv: version \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${TCLENV_TEST_DIR}/bin"
  touch "${TCLENV_TEST_DIR}/bin/tcl"
  chmod +x "${TCLENV_TEST_DIR}/bin/tcl"
  TCLENV_VERSION="system" run tclenv-prefix
  assert_success "$TCLENV_TEST_DIR"
}

@test "prefix for invalid system" {
  PATH="$(path_without tcl)" run tclenv-prefix system
  assert_failure "tclenv: system version not found in PATH"
}
