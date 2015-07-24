#!/usr/bin/env bats

load test_helper

@test "creates shims and versions directories" {
  assert [ ! -d "${TCLENV_ROOT}/shims" ]
  assert [ ! -d "${TCLENV_ROOT}/versions" ]
  run tclenv-init -
  assert_success
  assert [ -d "${TCLENV_ROOT}/shims" ]
  assert [ -d "${TCLENV_ROOT}/versions" ]
}

@test "auto rehash" {
  run tclenv-init -
  assert_success
  assert_line "tclenv rehash 2>/dev/null"
}

@test "setup shell completions" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run tclenv-init - bash
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/tclenv.bash'"
}

@test "detect parent shell" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  SHELL=/bin/false run tclenv-init -
  assert_success
  assert_line "export TCLENV_SHELL=bash"
}

@test "setup shell completions (fish)" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run tclenv-init - fish
  assert_success
  assert_line ". '${root}/test/../libexec/../completions/tclenv.fish'"
}

@test "fish instructions" {
  run tclenv-init fish
  assert [ "$status" -eq 1 ]
  assert_line 'status --is-interactive; and . (tclenv init -|psub)'
}

@test "option to skip rehash" {
  run tclenv-init - --no-rehash
  assert_success
  refute_line "tclenv rehash 2>/dev/null"
}

@test "adds shims to PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run tclenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${TCLENV_ROOT}'/shims:${PATH}"'
}

@test "adds shims to PATH (fish)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run tclenv-init - fish
  assert_success
  assert_line 0 "setenv PATH '${TCLENV_ROOT}/shims' \$PATH"
}

@test "can add shims to PATH more than once" {
  export PATH="${TCLENV_ROOT}/shims:$PATH"
  run tclenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${TCLENV_ROOT}'/shims:${PATH}"'
}

@test "can add shims to PATH more than once (fish)" {
  export PATH="${TCLENV_ROOT}/shims:$PATH"
  run tclenv-init - fish
  assert_success
  assert_line 0 "setenv PATH '${TCLENV_ROOT}/shims' \$PATH"
}

@test "outputs sh-compatible syntax" {
  run tclenv-init - bash
  assert_success
  assert_line '  case "$command" in'

  run tclenv-init - zsh
  assert_success
  assert_line '  case "$command" in'
}

@test "outputs fish-specific syntax (fish)" {
  run tclenv-init - fish
  assert_success
  assert_line '  switch "$command"'
  refute_line '  case "$command" in'
}
