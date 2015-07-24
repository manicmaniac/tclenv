#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${TCLENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "empty rehash" {
  assert [ ! -d "${TCLENV_ROOT}/shims" ]
  run tclenv-rehash
  assert_success ""
  assert [ -d "${TCLENV_ROOT}/shims" ]
  rmdir "${TCLENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${TCLENV_ROOT}/shims"
  chmod -w "${TCLENV_ROOT}/shims"
  run tclenv-rehash
  assert_failure "tclenv: cannot rehash: ${TCLENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  mkdir -p "${TCLENV_ROOT}/shims"
  touch "${TCLENV_ROOT}/shims/.tclenv-shim"
  run tclenv-rehash
  assert_failure "tclenv: cannot rehash: ${TCLENV_ROOT}/shims/.tclenv-shim exists"
}

@test "creates shims" {
  create_executable "1.8" "tcl"
  create_executable "1.8" "rake"
  create_executable "2.0" "tcl"
  create_executable "2.0" "rspec"

  assert [ ! -e "${TCLENV_ROOT}/shims/tcl" ]
  assert [ ! -e "${TCLENV_ROOT}/shims/rake" ]
  assert [ ! -e "${TCLENV_ROOT}/shims/rspec" ]

  run tclenv-rehash
  assert_success ""

  run ls "${TCLENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
rake
rspec
tcl
OUT
}

@test "removes outdated shims" {
  mkdir -p "${TCLENV_ROOT}/shims"
  touch "${TCLENV_ROOT}/shims/oldshim1"
  chmod +x "${TCLENV_ROOT}/shims/oldshim1"

  create_executable "2.0" "rake"
  create_executable "2.0" "tcl"

  run tclenv-rehash
  assert_success ""

  assert [ ! -e "${TCLENV_ROOT}/shims/oldshim1" ]
}

@test "do exact matches when removing stale shims" {
  create_executable "2.0" "unicorn_rails"
  create_executable "2.0" "rspec-core"

  tclenv-rehash

  cp "$TCLENV_ROOT"/shims/{rspec-core,rspec}
  cp "$TCLENV_ROOT"/shims/{rspec-core,rails}
  cp "$TCLENV_ROOT"/shims/{rspec-core,uni}
  chmod +x "$TCLENV_ROOT"/shims/{rspec,rails,uni}

  run tclenv-rehash
  assert_success ""

  assert [ ! -e "${TCLENV_ROOT}/shims/rails" ]
  assert [ ! -e "${TCLENV_ROOT}/shims/rake" ]
  assert [ ! -e "${TCLENV_ROOT}/shims/uni" ]
}

@test "binary install locations containing spaces" {
  create_executable "dirname1 p247" "tcl"
  create_executable "dirname2 preview1" "rspec"

  assert [ ! -e "${TCLENV_ROOT}/shims/tcl" ]
  assert [ ! -e "${TCLENV_ROOT}/shims/rspec" ]

  run tclenv-rehash
  assert_success ""

  run ls "${TCLENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
rspec
tcl
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${TCLENV_TEST_DIR}/tclenv.d"
  mkdir -p "${hook_path}/rehash"
  cat > "${hook_path}/rehash/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  TCLENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run tclenv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "sh-rehash in bash" {
  create_executable "2.0" "tcl"
  TCLENV_SHELL=bash run tclenv-sh-rehash
  assert_success "hash -r 2>/dev/null || true"
  assert [ -x "${TCLENV_ROOT}/shims/tcl" ]
}

@test "sh-rehash in fish" {
  create_executable "2.0" "tcl"
  TCLENV_SHELL=fish run tclenv-sh-rehash
  assert_success ""
  assert [ -x "${TCLENV_ROOT}/shims/tcl" ]
}
