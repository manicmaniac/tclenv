#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$TCLENV_TEST_DIR"
  cd "$TCLENV_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  touch "$1"
}

@test "prints global file if no version files exist" {
  assert [ ! -e "${TCLENV_ROOT}/version" ]
  assert [ ! -e ".tcl-version" ]
  run tclenv-version-file
  assert_success "${TCLENV_ROOT}/version"
}

@test "detects 'global' file" {
  create_file "${TCLENV_ROOT}/global"
  run tclenv-version-file
  assert_success "${TCLENV_ROOT}/global"
}

@test "detects 'default' file" {
  create_file "${TCLENV_ROOT}/default"
  run tclenv-version-file
  assert_success "${TCLENV_ROOT}/default"
}

@test "'version' has precedence over 'global' and 'default'" {
  create_file "${TCLENV_ROOT}/version"
  create_file "${TCLENV_ROOT}/global"
  create_file "${TCLENV_ROOT}/default"
  run tclenv-version-file
  assert_success "${TCLENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".tcl-version"
  run tclenv-version-file
  assert_success "${TCLENV_TEST_DIR}/.tcl-version"
}

@test "legacy file in current directory" {
  create_file ".tclenv-version"
  run tclenv-version-file
  assert_success "${TCLENV_TEST_DIR}/.tclenv-version"
}

@test ".tcl-version has precedence over legacy file" {
  create_file ".tcl-version"
  create_file ".tclenv-version"
  run tclenv-version-file
  assert_success "${TCLENV_TEST_DIR}/.tcl-version"
}

@test "in parent directory" {
  create_file ".tcl-version"
  mkdir -p project
  cd project
  run tclenv-version-file
  assert_success "${TCLENV_TEST_DIR}/.tcl-version"
}

@test "topmost file has precedence" {
  create_file ".tcl-version"
  create_file "project/.tcl-version"
  cd project
  run tclenv-version-file
  assert_success "${TCLENV_TEST_DIR}/project/.tcl-version"
}

@test "legacy file has precedence if higher" {
  create_file ".tcl-version"
  create_file "project/.tclenv-version"
  cd project
  run tclenv-version-file
  assert_success "${TCLENV_TEST_DIR}/project/.tclenv-version"
}

@test "TCLENV_DIR has precedence over PWD" {
  create_file "widget/.tcl-version"
  create_file "project/.tcl-version"
  cd project
  TCLENV_DIR="${TCLENV_TEST_DIR}/widget" run tclenv-version-file
  assert_success "${TCLENV_TEST_DIR}/widget/.tcl-version"
}

@test "PWD is searched if TCLENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.tcl-version"
  cd project
  TCLENV_DIR="${TCLENV_TEST_DIR}/widget/blank" run tclenv-version-file
  assert_success "${TCLENV_TEST_DIR}/project/.tcl-version"
}
