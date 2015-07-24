#!/usr/bin/env bats

load test_helper

@test "commands" {
  run tclenv-commands
  assert_success
  assert_line "init"
  assert_line "rehash"
  assert_line "shell"
  refute_line "sh-shell"
  assert_line "echo"
}

@test "commands --sh" {
  run tclenv-commands --sh
  assert_success
  refute_line "init"
  assert_line "shell"
}

@test "commands in path with spaces" {
  path="${TCLENV_TEST_DIR}/my commands"
  cmd="${path}/tclenv-sh-hello"
  mkdir -p "$path"
  touch "$cmd"
  chmod +x "$cmd"

  PATH="${path}:$PATH" run tclenv-commands --sh
  assert_success
  assert_line "hello"
}

@test "commands --no-sh" {
  run tclenv-commands --no-sh
  assert_success
  assert_line "init"
  refute_line "shell"
}
