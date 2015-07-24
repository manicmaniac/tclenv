#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${TCLENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$TCLENV_TEST_DIR"
  cd "$TCLENV_TEST_DIR"
}

stub_system_tcl() {
  local stub="${TCLENV_TEST_DIR}/bin/tcl"
  mkdir -p "$(dirname "$stub")"
  touch "$stub" && chmod +x "$stub"
}

@test "no versions installed" {
  stub_system_tcl
  assert [ ! -d "${TCLENV_ROOT}/versions" ]
  run tclenv-versions
  assert_success "* system (set by ${TCLENV_ROOT}/version)"
}

@test "not even system tcl available" {
  PATH="$(path_without tcl)" run tclenv-versions
  assert_failure
  assert_output "Warning: no Tcl detected on the system"
}

@test "bare output no versions installed" {
  assert [ ! -d "${TCLENV_ROOT}/versions" ]
  run tclenv-versions --bare
  assert_success ""
}

@test "single version installed" {
  stub_system_tcl
  create_version "1.9"
  run tclenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${TCLENV_ROOT}/version)
  1.9
OUT
}

@test "single version bare" {
  create_version "1.9"
  run tclenv-versions --bare
  assert_success "1.9"
}

@test "multiple versions" {
  stub_system_tcl
  create_version "1.8.7"
  create_version "1.9.3"
  create_version "2.0.0"
  run tclenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${TCLENV_ROOT}/version)
  1.8.7
  1.9.3
  2.0.0
OUT
}

@test "indicates current version" {
  stub_system_tcl
  create_version "1.9.3"
  create_version "2.0.0"
  TCLENV_VERSION=1.9.3 run tclenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by TCLENV_VERSION environment variable)
  2.0.0
OUT
}

@test "bare doesn't indicate current version" {
  create_version "1.9.3"
  create_version "2.0.0"
  TCLENV_VERSION=1.9.3 run tclenv-versions --bare
  assert_success
  assert_output <<OUT
1.9.3
2.0.0
OUT
}

@test "globally selected version" {
  stub_system_tcl
  create_version "1.9.3"
  create_version "2.0.0"
  cat > "${TCLENV_ROOT}/version" <<<"1.9.3"
  run tclenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by ${TCLENV_ROOT}/version)
  2.0.0
OUT
}

@test "per-project version" {
  stub_system_tcl
  create_version "1.9.3"
  create_version "2.0.0"
  cat > ".tcl-version" <<<"1.9.3"
  run tclenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by ${TCLENV_TEST_DIR}/.tcl-version)
  2.0.0
OUT
}

@test "ignores non-directories under versions" {
  create_version "1.9"
  touch "${TCLENV_ROOT}/versions/hello"

  run tclenv-versions --bare
  assert_success "1.9"
}

@test "lists symlinks under versions" {
  create_version "1.8.7"
  ln -s "1.8.7" "${TCLENV_ROOT}/versions/1.8"

  run tclenv-versions --bare
  assert_success
  assert_output <<OUT
1.8
1.8.7
OUT
}
