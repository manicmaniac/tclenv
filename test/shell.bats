#!/usr/bin/env bats

load test_helper

@test "no shell version" {
  mkdir -p "${TCLENV_TEST_DIR}/myproject"
  cd "${TCLENV_TEST_DIR}/myproject"
  echo "1.2.3" > .tcl-version
  TCLENV_VERSION="" run tclenv-sh-shell
  assert_failure "tclenv: no shell-specific version configured"
}

@test "shell version" {
  TCLENV_SHELL=bash TCLENV_VERSION="1.2.3" run tclenv-sh-shell
  assert_success 'echo "$TCLENV_VERSION"'
}

@test "shell version (fish)" {
  TCLENV_SHELL=fish TCLENV_VERSION="1.2.3" run tclenv-sh-shell
  assert_success 'echo "$TCLENV_VERSION"'
}

@test "shell unset" {
  TCLENV_SHELL=bash run tclenv-sh-shell --unset
  assert_success "unset TCLENV_VERSION"
}

@test "shell unset (fish)" {
  TCLENV_SHELL=fish run tclenv-sh-shell --unset
  assert_success "set -e TCLENV_VERSION"
}

@test "shell change invalid version" {
  run tclenv-sh-shell 1.2.3
  assert_failure
  assert_output <<SH
tclenv: version \`1.2.3' not installed
false
SH
}

@test "shell change version" {
  mkdir -p "${TCLENV_ROOT}/versions/1.2.3"
  TCLENV_SHELL=bash run tclenv-sh-shell 1.2.3
  assert_success 'export TCLENV_VERSION="1.2.3"'
}

@test "shell change version (fish)" {
  mkdir -p "${TCLENV_ROOT}/versions/1.2.3"
  TCLENV_SHELL=fish run tclenv-sh-shell 1.2.3
  assert_success 'setenv TCLENV_VERSION "1.2.3"'
}
