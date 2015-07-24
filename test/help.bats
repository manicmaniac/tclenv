#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run tclenv-help
  assert_success
  assert_line "Usage: tclenv <command> [<args>]"
  assert_line "Some useful tclenv commands are:"
}

@test "invalid command" {
  run tclenv-help hello
  assert_failure "tclenv: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${TCLENV_TEST_DIR}/bin"
  cat > "${TCLENV_TEST_DIR}/bin/tclenv-hello" <<SH
#!shebang
# Usage: tclenv hello <world>
# Summary: Says "hello" to you, from tclenv
# This command is useful for saying hello.
echo hello
SH

  run tclenv-help hello
  assert_success
  assert_output <<SH
Usage: tclenv hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${TCLENV_TEST_DIR}/bin"
  cat > "${TCLENV_TEST_DIR}/bin/tclenv-hello" <<SH
#!shebang
# Usage: tclenv hello <world>
# Summary: Says "hello" to you, from tclenv
echo hello
SH

  run tclenv-help hello
  assert_success
  assert_output <<SH
Usage: tclenv hello <world>

Says "hello" to you, from tclenv
SH
}

@test "extracts only usage" {
  mkdir -p "${TCLENV_TEST_DIR}/bin"
  cat > "${TCLENV_TEST_DIR}/bin/tclenv-hello" <<SH
#!shebang
# Usage: tclenv hello <world>
# Summary: Says "hello" to you, from tclenv
# This extended help won't be shown.
echo hello
SH

  run tclenv-help --usage hello
  assert_success "Usage: tclenv hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${TCLENV_TEST_DIR}/bin"
  cat > "${TCLENV_TEST_DIR}/bin/tclenv-hello" <<SH
#!shebang
# Usage: tclenv hello <world>
#        tclenv hi [everybody]
#        tclenv hola --translate
# Summary: Says "hello" to you, from tclenv
# Help text.
echo hello
SH

  run tclenv-help hello
  assert_success
  assert_output <<SH
Usage: tclenv hello <world>
       tclenv hi [everybody]
       tclenv hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${TCLENV_TEST_DIR}/bin"
  cat > "${TCLENV_TEST_DIR}/bin/tclenv-hello" <<SH
#!shebang
# Usage: tclenv hello <world>
# Summary: Says "hello" to you, from tclenv
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run tclenv-help hello
  assert_success
  assert_output <<SH
Usage: tclenv hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
