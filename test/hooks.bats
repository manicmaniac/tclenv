#!/usr/bin/env bats

load test_helper

create_hook() {
  mkdir -p "$1/$2"
  touch "$1/$2/$3"
}

@test "prints usage help given no argument" {
  run tclenv-hooks
  assert_failure "Usage: tclenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${TCLENV_TEST_DIR}/tclenv.d"
  path2="${TCLENV_TEST_DIR}/etc/tclenv_hooks"
  create_hook "$path1" exec "hello.bash"
  create_hook "$path1" exec "ahoy.bash"
  create_hook "$path1" exec "invalid.sh"
  create_hook "$path1" which "boom.bash"
  create_hook "$path2" exec "bueno.bash"

  TCLENV_HOOK_PATH="$path1:$path2" run tclenv-hooks exec
  assert_success
  assert_output <<OUT
${TCLENV_TEST_DIR}/tclenv.d/exec/ahoy.bash
${TCLENV_TEST_DIR}/tclenv.d/exec/hello.bash
${TCLENV_TEST_DIR}/etc/tclenv_hooks/exec/bueno.bash
OUT
}

@test "supports hook paths with spaces" {
  path1="${TCLENV_TEST_DIR}/my hooks/tclenv.d"
  path2="${TCLENV_TEST_DIR}/etc/tclenv hooks"
  create_hook "$path1" exec "hello.bash"
  create_hook "$path2" exec "ahoy.bash"

  TCLENV_HOOK_PATH="$path1:$path2" run tclenv-hooks exec
  assert_success
  assert_output <<OUT
${TCLENV_TEST_DIR}/my hooks/tclenv.d/exec/hello.bash
${TCLENV_TEST_DIR}/etc/tclenv hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  path="${TCLENV_TEST_DIR}/tclenv.d"
  create_hook "$path" exec "hello.bash"
  mkdir -p "$HOME"

  TCLENV_HOOK_PATH="${HOME}/../tclenv.d" run tclenv-hooks exec
  assert_success "${TCLENV_TEST_DIR}/tclenv.d/exec/hello.bash"
}

@test "resolves symlinks" {
  path="${TCLENV_TEST_DIR}/tclenv.d"
  mkdir -p "${path}/exec"
  mkdir -p "$HOME"
  touch "${HOME}/hola.bash"
  ln -s "../../home/hola.bash" "${path}/exec/hello.bash"

  TCLENV_HOOK_PATH="$path" run tclenv-hooks exec
  assert_success "${HOME}/hola.bash"
}
