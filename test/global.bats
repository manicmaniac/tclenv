#!/usr/bin/env bats

load test_helper

@test "default" {
  run tclenv global
  assert_success
  assert_output "system"
}

@test "read TCLENV_ROOT/version" {
  mkdir -p "$TCLENV_ROOT"
  echo "1.2.3" > "$TCLENV_ROOT/version"
  run tclenv-global
  assert_success
  assert_output "1.2.3"
}

@test "set TCLENV_ROOT/version" {
  mkdir -p "$TCLENV_ROOT/versions/1.2.3"
  run tclenv-global "1.2.3"
  assert_success
  run tclenv global
  assert_success "1.2.3"
}

@test "fail setting invalid TCLENV_ROOT/version" {
  mkdir -p "$TCLENV_ROOT"
  run tclenv-global "1.2.3"
  assert_failure "tclenv: version \`1.2.3' not installed"
}
