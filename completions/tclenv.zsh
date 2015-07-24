if [[ ! -o interactive ]]; then
    return
fi

compctl -K _tclenv tclenv

_tclenv() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(tclenv commands)"
  else
    completions="$(tclenv completions ${words[2,-2]})"
  fi

  reply=("${(ps:\n:)completions}")
}
