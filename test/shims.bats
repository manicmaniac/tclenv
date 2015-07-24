#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run tclenv-shims
  assert_success
  assert [ -z "$output" ]
}

@test "shims" {
  mkdir -p "${TCLENV_ROOT}/shims"
  touch "${TCLENV_ROOT}/shims/tcl"
  touch "${TCLENV_ROOT}/shims/irb"
  run tclenv-shims
  assert_success
  assert_line "${TCLENV_ROOT}/shims/tcl"
  assert_line "${TCLENV_ROOT}/shims/irb"
}

@test "shims --short" {
  mkdir -p "${TCLENV_ROOT}/shims"
  touch "${TCLENV_ROOT}/shims/tcl"
  touch "${TCLENV_ROOT}/shims/irb"
  run tclenv-shims --short
  assert_success
  assert_line "irb"
  assert_line "tcl"
}
