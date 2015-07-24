#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$TCLENV_TEST_DIR"
  cd "$TCLENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run tclenv-version-file-write
  assert_failure "Usage: tclenv version-file-write <file> <version>"
  run tclenv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".tcl-version" ]
  run tclenv-version-file-write ".tcl-version" "1.8.7"
  assert_failure "tclenv: version \`1.8.7' not installed"
  assert [ ! -e ".tcl-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${TCLENV_ROOT}/versions/1.8.7"
  assert [ ! -e "my-version" ]
  run tclenv-version-file-write "${PWD}/my-version" "1.8.7"
  assert_success ""
  assert [ "$(cat my-version)" = "1.8.7" ]
}
