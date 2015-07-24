#!/usr/bin/env bats

load test_helper

create_executable() {
  name="${1?}"
  shift 1
  bin="${TCLENV_ROOT}/versions/${TCLENV_VERSION}/bin"
  mkdir -p "$bin"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "fails with invalid version" {
  export TCLENV_VERSION="2.0"
  run tclenv-exec tcl -v
  assert_failure "tclenv: version \`2.0' is not installed (set by TCLENV_VERSION environment variable)"
}

@test "completes with names of executables" {
  export TCLENV_VERSION="2.0"
  create_executable "tcl" "#!/bin/sh"
  create_executable "rake" "#!/bin/sh"

  tclenv-rehash
  run tclenv-completions exec
  assert_success
  assert_output <<OUT
rake
tcl
OUT
}

@test "supports hook path with spaces" {
  hook_path="${TCLENV_TEST_DIR}/custom stuff/tclenv hooks"
  mkdir -p "${hook_path}/exec"
  echo "export HELLO='from hook'" > "${hook_path}/exec/hello.bash"

  export TCLENV_VERSION=system
  TCLENV_HOOK_PATH="$hook_path" run tclenv-exec env
  assert_success
  assert_line "HELLO=from hook"
}

@test "carries original IFS within hooks" {
  hook_path="${TCLENV_TEST_DIR}/tclenv.d"
  mkdir -p "${hook_path}/exec"
  cat > "${hook_path}/exec/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export TCLENV_VERSION=system
  TCLENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run tclenv-exec env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "forwards all arguments" {
  export TCLENV_VERSION="2.0"
  create_executable "tcl" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run tclenv-exec tcl -w "/path to/tcl script.rb" -- extra args
  assert_success
  assert_output <<OUT
${TCLENV_ROOT}/versions/2.0/bin/tcl
  -w
  /path to/tcl script.rb
  --
  extra
  args
OUT
}

@test "supports tcl -S <cmd>" {
  export TCLENV_VERSION="2.0"

  # emulate `tcl -S' behavior
  create_executable "tcl" <<SH
#!$BASH
if [[ \$1 == "-S"* ]]; then
  found="\$(PATH="\${TCLPATH:-\$PATH}" which \$2)"
  # assert that the found executable has tcl for shebang
  if head -1 "\$found" | grep tcl >/dev/null; then
    \$BASH "\$found"
  else
    echo "tcl: no Tcl script found in input (LoadError)" >&2
    exit 1
  fi
else
  echo 'tcl 2.0 (tclenv test)'
fi
SH

  create_executable "rake" <<SH
#!/usr/bin/env tcl
echo hello rake
SH

  tclenv-rehash
  run tcl -S rake
  assert_success "hello rake"
}
