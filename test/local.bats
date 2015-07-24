#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${TCLENV_TEST_DIR}/myproject"
  cd "${TCLENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.tcl-version" ]
  run tclenv-local
  assert_failure "tclenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .tcl-version
  run tclenv-local
  assert_success "1.2.3"
}

@test "supports legacy .tclenv-version file" {
  echo "1.2.3" > .tclenv-version
  run tclenv-local
  assert_success "1.2.3"
}

@test "local .tcl-version has precedence over .tclenv-version" {
  echo "1.8" > .tclenv-version
  echo "2.0" > .tcl-version
  run tclenv-local
  assert_success "2.0"
}

@test "ignores version in parent directory" {
  echo "1.2.3" > .tcl-version
  mkdir -p "subdir" && cd "subdir"
  run tclenv-local
  assert_failure
}

@test "ignores TCLENV_DIR" {
  echo "1.2.3" > .tcl-version
  mkdir -p "$HOME"
  echo "2.0-home" > "${HOME}/.tcl-version"
  TCLENV_DIR="$HOME" run tclenv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${TCLENV_ROOT}/versions/1.2.3"
  run tclenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .tcl-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "1.0-pre" > .tcl-version
  mkdir -p "${TCLENV_ROOT}/versions/1.2.3"
  run tclenv-local
  assert_success "1.0-pre"
  run tclenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .tcl-version)" = "1.2.3" ]
}

@test "renames .tclenv-version to .tcl-version" {
  echo "1.8.7" > .tclenv-version
  mkdir -p "${TCLENV_ROOT}/versions/1.9.3"
  run tclenv-local
  assert_success "1.8.7"
  run tclenv-local "1.9.3"
  assert_success
  assert_output <<OUT
tclenv: removed existing \`.tclenv-version' file and migrated
       local version specification to \`.tcl-version' file
OUT
  assert [ ! -e .tclenv-version ]
  assert [ "$(cat .tcl-version)" = "1.9.3" ]
}

@test "doesn't rename .tclenv-version if changing the version failed" {
  echo "1.8.7" > .tclenv-version
  assert [ ! -e "${TCLENV_ROOT}/versions/1.9.3" ]
  run tclenv-local "1.9.3"
  assert_failure "tclenv: version \`1.9.3' not installed"
  assert [ ! -e .tcl-version ]
  assert [ "$(cat .tclenv-version)" = "1.8.7" ]
}

@test "unsets local version" {
  touch .tcl-version
  run tclenv-local --unset
  assert_success ""
  assert [ ! -e .tclenv-version ]
}

@test "unsets alternate version file" {
  touch .tclenv-version
  run tclenv-local --unset
  assert_success ""
  assert [ ! -e .tclenv-version ]
}
