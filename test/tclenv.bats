#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run tclenv
  assert_success
  assert [ "${lines[0]}" = "tclenv 0.0.1" ]
}

@test "invalid command" {
  run tclenv does-not-exist
  assert_failure
  assert_output "tclenv: no such command \`does-not-exist'"
}

@test "default TCLENV_ROOT" {
  TCLENV_ROOT="" HOME=/home/mislav run tclenv root
  assert_success
  assert_output "/home/mislav/.tclenv"
}

@test "inherited TCLENV_ROOT" {
  TCLENV_ROOT=/opt/tclenv run tclenv root
  assert_success
  assert_output "/opt/tclenv"
}

@test "default TCLENV_DIR" {
  run tclenv echo TCLENV_DIR
  assert_output "$(pwd)"
}

@test "inherited TCLENV_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  TCLENV_DIR="$dir" run tclenv echo TCLENV_DIR
  assert_output "$dir"
}

@test "invalid TCLENV_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  TCLENV_DIR="$dir" run tclenv echo TCLENV_DIR
  assert_failure
  assert_output "tclenv: cannot change working directory to \`$dir'"
}

@test "adds its own libexec to PATH" {
  run tclenv echo "PATH"
  assert_success "${BATS_TEST_DIRNAME%/*}/libexec:$PATH"
}

@test "adds plugin bin dirs to PATH" {
  mkdir -p "$TCLENV_ROOT"/plugins/tcl-build/bin
  mkdir -p "$TCLENV_ROOT"/plugins/tclenv-each/bin
  run tclenv echo -F: "PATH"
  assert_success
  assert_line 0 "${BATS_TEST_DIRNAME%/*}/libexec"
  assert_line 1 "${TCLENV_ROOT}/plugins/tclenv-each/bin"
  assert_line 2 "${TCLENV_ROOT}/plugins/tcl-build/bin"
}

@test "TCLENV_HOOK_PATH preserves value from environment" {
  TCLENV_HOOK_PATH=/my/hook/path:/other/hooks run tclenv echo -F: "TCLENV_HOOK_PATH"
  assert_success
  assert_line 0 "/my/hook/path"
  assert_line 1 "/other/hooks"
  assert_line 2 "${TCLENV_ROOT}/tclenv.d"
}

@test "TCLENV_HOOK_PATH includes tclenv built-in plugins" {
  run tclenv echo "TCLENV_HOOK_PATH"
  assert_success ":${TCLENV_ROOT}/tclenv.d:${BATS_TEST_DIRNAME%/*}/tclenv.d:/usr/local/etc/tclenv.d:/etc/tclenv.d:/usr/lib/tclenv/hooks"
}
