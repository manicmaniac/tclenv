#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin
  if [[ $1 == */* ]]; then bin="$1"
  else bin="${TCLENV_ROOT}/versions/${1}/bin"
  fi
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "outputs path to executable" {
  create_executable "1.8" "tcl"
  create_executable "2.0" "rspec"

  TCLENV_VERSION=1.8 run tclenv-which tcl
  assert_success "${TCLENV_ROOT}/versions/1.8/bin/tcl"

  TCLENV_VERSION=2.0 run tclenv-which rspec
  assert_success "${TCLENV_ROOT}/versions/2.0/bin/rspec"
}

@test "searches PATH for system version" {
  create_executable "${TCLENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${TCLENV_ROOT}/shims" "kill-all-humans"

  TCLENV_VERSION=system run tclenv-which kill-all-humans
  assert_success "${TCLENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims prepended)" {
  create_executable "${TCLENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${TCLENV_ROOT}/shims" "kill-all-humans"

  PATH="${TCLENV_ROOT}/shims:$PATH" TCLENV_VERSION=system run tclenv-which kill-all-humans
  assert_success "${TCLENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims appended)" {
  create_executable "${TCLENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${TCLENV_ROOT}/shims" "kill-all-humans"

  PATH="$PATH:${TCLENV_ROOT}/shims" TCLENV_VERSION=system run tclenv-which kill-all-humans
  assert_success "${TCLENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims spread)" {
  create_executable "${TCLENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${TCLENV_ROOT}/shims" "kill-all-humans"

  PATH="${TCLENV_ROOT}/shims:${TCLENV_ROOT}/shims:/tmp/non-existent:$PATH:${TCLENV_ROOT}/shims" \
    TCLENV_VERSION=system run tclenv-which kill-all-humans
  assert_success "${TCLENV_TEST_DIR}/bin/kill-all-humans"
}

@test "version not installed" {
  create_executable "2.0" "rspec"
  TCLENV_VERSION=1.9 run tclenv-which rspec
  assert_failure "tclenv: version \`1.9' is not installed (set by TCLENV_VERSION environment variable)"
}

@test "no executable found" {
  create_executable "1.8" "rspec"
  TCLENV_VERSION=1.8 run tclenv-which rake
  assert_failure "tclenv: rake: command not found"
}

@test "executable found in other versions" {
  create_executable "1.8" "tcl"
  create_executable "1.9" "rspec"
  create_executable "2.0" "rspec"

  TCLENV_VERSION=1.8 run tclenv-which rspec
  assert_failure
  assert_output <<OUT
tclenv: rspec: command not found

The \`rspec' command exists in these Tcl versions:
  1.9
  2.0
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${TCLENV_TEST_DIR}/tclenv.d"
  mkdir -p "${hook_path}/which"
  cat > "${hook_path}/which/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  TCLENV_HOOK_PATH="$hook_path" IFS=$' \t\n' TCLENV_VERSION=system run tclenv-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "discovers version from tclenv-version-name" {
  mkdir -p "$TCLENV_ROOT"
  cat > "${TCLENV_ROOT}/version" <<<"1.8"
  create_executable "1.8" "tcl"

  mkdir -p "$TCLENV_TEST_DIR"
  cd "$TCLENV_TEST_DIR"

  TCLENV_VERSION= run tclenv-which tcl
  assert_success "${TCLENV_ROOT}/versions/1.8/bin/tcl"
}
