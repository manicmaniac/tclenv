function __fish_tclenv_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'tclenv' ]
    return 0
  end
  return 1
end

function __fish_tclenv_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c tclenv -n '__fish_tclenv_needs_command' -a '(tclenv commands)'
for cmd in (tclenv commands)
  complete -f -c tclenv -n "__fish_tclenv_using_command $cmd" -a "(tclenv completions $cmd)"
end
