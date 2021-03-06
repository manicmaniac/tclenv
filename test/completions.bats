#!/usr/bin/env bats

load test_helper

create_command() {
  bin="${TCLENV_TEST_DIR}/bin"
  mkdir -p "$bin"
  echo "$2" > "${bin}/$1"
  chmod +x "${bin}/$1"
}

@test "command with no completion support" {
  create_command "tclenv-hello" "#!$BASH
    echo hello"
  run tclenv-completions hello
  assert_success ""
}

@test "command with completion support" {
  create_command "tclenv-hello" "#!$BASH
# Provide tclenv completions
if [[ \$1 = --complete ]]; then
  echo hello
else
  exit 1
fi"
  run tclenv-completions hello
  assert_success "hello"
}

@test "forwards extra arguments" {
  create_command "tclenv-hello" "#!$BASH
# provide tclenv completions
if [[ \$1 = --complete ]]; then
  shift 1
  for arg; do echo \$arg; done
else
  exit 1
fi"
  run tclenv-completions hello happy world
  assert_success
  assert_output <<OUT
happy
world
OUT
}
