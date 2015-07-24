# Groom your app’s Tcl environment with tclenv.

Use tclenv to pick a Tcl version for your application and guarantee
that your development environment matches production. Put tclenv to work
with [Bundler](http://bundler.io/) for painless Tcl upgrades and
bulletproof deployments.

**Powerful in development.** Specify your app's Tcl version once,
  in a single file. Keep all your teammates on the same page. No
  headaches running apps on different versions of Tcl. Just Works™
  from the command line and with app servers like [Pow](http://pow.cx).
  Override the Tcl version anytime: just set an environment variable.

**Rock-solid in production.** Your application's executables are its
  interface with ops. With tclenv and [Bundler
  binstubs](https://github.com/manicmaniac/tclenv/wiki/Understanding-binstubs)
  you'll never again need to `cd` in a cron job or Chef recipe to
  ensure you've selected the right runtime. The Tcl version
  dependency lives in one place—your app—so upgrades and rollbacks are
  atomic, even when you switch versions.

**One thing well.** tclenv is concerned solely with switching Tcl
  versions. It's simple and predictable. A rich plugin ecosystem lets
  you tailor it to suit your needs. Compile your own Tcl versions, or
  use the [tcl-build][]
  plugin to automate the process. Specify per-application environment
  variables with [tclenv-vars](https://github.com/manicmaniac/tclenv-vars).
  See more [plugins on the
  wiki](https://github.com/manicmaniac/tclenv/wiki/Plugins).

[**Why choose tclenv over
RVM?**](https://github.com/manicmaniac/tclenv/wiki/Why-tclenv%3F)

## Table of Contents

* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Tcl Version](#choosing-the-tcl-version)
  * [Locating the Tcl Installation](#locating-the-tcl-installation)
* [Installation](#installation)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
  * [Homebrew on Mac OS X](#homebrew-on-mac-os-x)
  * [How tclenv hooks into your shell](#how-tclenv-hooks-into-your-shell)
  * [Installing Tcl Versions](#installing-tcl-versions)
  * [Uninstalling Tcl Versions](#uninstalling-tcl-versions)
  * [Uninstalling tclenv](#uninstalling-tclenv)
* [Command Reference](#command-reference)
  * [tclenv local](#tclenv-local)
  * [tclenv global](#tclenv-global)
  * [tclenv shell](#tclenv-shell)
  * [tclenv versions](#tclenv-versions)
  * [tclenv version](#tclenv-version)
  * [tclenv rehash](#tclenv-rehash)
  * [tclenv which](#tclenv-which)
  * [tclenv whence](#tclenv-whence)
* [Environment variables](#environment-variables)
* [Development](#development)

## How It Works

At a high level, tclenv intercepts Tcl commands using shim
executables injected into your `PATH`, determines which Tcl version
has been specified by your application, and passes your commands along
to the correct Tcl installation.

### Understanding PATH

When you run a command like `tcl` or `rake`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.

### Understanding Shims

tclenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    ~/.tclenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, tclenv maintains shims in that
directory to match every Tcl command across every installed version
of Tcl—`irb`, `gem`, `rake`, `rails`, `tcl`, and so on.

Shims are lightweight executables that simply pass your command along
to tclenv. So with tclenv installed, when you run, say, `rake`, your
operating system will do the following:

* Search your `PATH` for an executable file named `rake`
* Find the tclenv shim named `rake` at the beginning of your `PATH`
* Run the shim named `rake`, which in turn passes the command along to
  tclenv

### Choosing the Tcl Version

When you execute a shim, tclenv determines which Tcl version to use by
reading it from the following sources, in this order:

1. The `tclenv_VERSION` environment variable, if specified. You can use
   the [`tclenv shell`](#tclenv-shell) command to set this environment
   variable in your current shell session.

2. The first `.tcl-version` file found by searching the directory of the
   script you are executing and each of its parent directories until reaching
   the root of your filesystem.

3. The first `.tcl-version` file found by searching the current working
   directory and each of its parent directories until reaching the root of your
   filesystem. You can modify the `.tcl-version` file in the current working
   directory with the [`tclenv local`](#tclenv-local) command.

4. The global `~/.tclenv/version` file. You can modify this file using
   the [`tclenv global`](#tclenv-global) command. If the global version
   file is not present, tclenv assumes you want to use the "system"
   Tcl—i.e. whatever version would be run if tclenv weren't in your
   path.

### Locating the Tcl Installation

Once tclenv has determined which version of Tcl your application has
specified, it passes the command along to the corresponding Tcl
installation.

Each Tcl version is installed into its own directory under
`~/.tclenv/versions`. For example, you might have these versions
installed:

* `~/.tclenv/versions/1.8.7-p371/`
* `~/.tclenv/versions/1.9.3-p327/`
* `~/.tclenv/versions/jtcl-1.7.1/`

Version names to tclenv are simply the names of the directories in
`~/.tclenv/versions`.

## Installation

**Compatibility note**: tclenv is _incompatible_ with RVM. Please make
  sure to fully uninstall RVM and remove any references to it from
  your shell initialization files before installing tclenv.

If you're on Mac OS X, consider
[installing with Homebrew](#homebrew-on-mac-os-x).

### Basic GitHub Checkout

This will get you going with the latest version of tclenv and make it
easy to fork and contribute any changes back upstream.

1. Check out tclenv into `~/.tclenv`.

    ~~~ sh
    $ git clone https://github.com/manicmaniac/tclenv.git ~/.tclenv
    ~~~

2. Add `~/.tclenv/bin` to your `$PATH` for access to the `tclenv`
   command-line utility.

    ~~~ sh
    $ echo 'export PATH="$HOME/.tclenv/bin:$PATH"' >> ~/.bash_profile
    ~~~

    **Ubuntu Desktop note**: Modify your `~/.bashrc` instead of `~/.bash_profile`.

    **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.

3. Add `tclenv init` to your shell to enable shims and autocompletion.

    ~~~ sh
    $ echo 'eval "$(tclenv init -)"' >> ~/.bash_profile
    ~~~

    _Same as in previous step, use `~/.bashrc` on Ubuntu, or `~/.zshrc` for Zsh._

4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.) Now check if tclenv was set up:

    ~~~ sh
    $ type tclenv
    #=> "tclenv is a function"
    ~~~

5. _(Optional)_ Install [tcl-build][], which provides the
   `tclenv install` command that simplifies the process of
   [installing new Tcl versions](#installing-tcl-versions).

#### Upgrading

If you've installed tclenv manually using git, you can upgrade your
installation to the cutting-edge version at any time.

~~~ sh
$ cd ~/.tclenv
$ git pull
~~~

To use a specific release of tclenv, check out the corresponding tag:

~~~ sh
$ cd ~/.tclenv
$ git fetch
$ git checkout v0.3.0
~~~

If you've [installed via Homebrew](#homebrew-on-mac-os-x), then upgrade
via its `brew` command:

~~~ sh
$ brew update
$ brew upgrade tclenv tcl-build
~~~

### Homebrew on Mac OS X

As an alternative to installation via GitHub checkout, you can install
tclenv and [tcl-build][] using the [Homebrew](http://brew.sh) package
manager on Mac OS X:

~~~
$ brew update
$ brew install tclenv tcl-build
~~~

Afterwards you'll still need to add `eval "$(tclenv init -)"` to your
profile as stated in the caveats. You'll only ever have to do this
once.

### How tclenv hooks into your shell

Skip this section unless you must know what every line in your shell
profile is doing.

`tclenv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from RVM, some of you might be
opposed to this idea. Here's what `tclenv init` actually does:

1. Sets up your shims path. This is the only requirement for tclenv to
   function properly. You can do this by hand by prepending
   `~/.tclenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.tclenv/completions/tclenv.bash` will set that
   up. There is also a `~/.tclenv/completions/tclenv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this automatically makes sure everything is up to
   date. You can always run `tclenv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   tclenv and plugins to change variables in your current shell, making
   commands like `tclenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `tclenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `tclenv init -` for yourself to see exactly what happens under the
hood.

### Installing Tcl Versions

The `tclenv install` command doesn't ship with tclenv out of the box, but
is provided by the [tcl-build][] project. If you installed it either
as part of GitHub checkout process outlined above or via Homebrew, you
should be able to:

~~~ sh
# list all available versions:
$ tclenv install -l

# install a Tcl version:
$ tclenv install 2.0.0-p247
~~~

Alternatively to the `install` command, you can download and compile
Tcl manually as a subdirectory of `~/.tclenv/versions/`. An entry in
that directory can also be a symlink to a Tcl version installed
elsewhere on the filesystem. tclenv doesn't care; it will simply treat
any entry in the `versions/` directory as a separate Tcl version.

### Uninstalling Tcl Versions

As time goes on, Tcl versions you install will accumulate in your
`~/.tclenv/versions` directory.

To remove old Tcl versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Tcl version with the `tclenv prefix` command, e.g. `tclenv prefix
1.8.7-p357`.

The [tcl-build][] plugin provides an `tclenv uninstall` command to
automate the removal process.

### Uninstalling tclenv

The simplicity of tclenv makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** tclenv managing your Tcl versions, simply remove the
  `tclenv init` line from your shell startup configuration. This will
  remove tclenv shims directory from PATH, and future invocations like
  `tcl` will execute the system Tcl version, as before tclenv.

  `tclenv` will still be accessible on the command line, but your Tcl
  apps won't be affected by version switching.

2. To completely **uninstall** tclenv, perform step (1) and then remove
   its root directory. This will **delete all Tcl versions** that were
   installed under `` `tclenv root`/versions/ `` directory:

        rm -rf `tclenv root`

   If you've installed tclenv using a package manager, as a final step
   perform the tclenv package removal. For instance, for Homebrew:

        brew uninstall tclenv

## Command Reference

Like `git`, the `tclenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### tclenv local

Sets a local application-specific Tcl version by writing the version
name to a `.tcl-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `tclenv_VERSION` environment variable or with the `tclenv shell`
command.

    $ tclenv local 1.9.3-p327

When run without a version number, `tclenv local` reports the currently
configured local version. You can also unset the local version:

    $ tclenv local --unset

Previous versions of tclenv stored local version specifications in a
file named `.tclenv-version`. For backwards compatibility, tclenv will
read a local version specified in an `.tclenv-version` file, but a
`.tcl-version` file in the same directory will take precedence.

### tclenv global

Sets the global version of Tcl to be used in all shells by writing
the version name to the `~/.tclenv/version` file. This version can be
overridden by an application-specific `.tcl-version` file, or by
setting the `tclenv_VERSION` environment variable.

    $ tclenv global 1.8.7-p352

The special version name `system` tells tclenv to use the system Tcl
(detected by searching your `$PATH`).

When run without a version number, `tclenv global` reports the
currently configured global version.

### tclenv shell

Sets a shell-specific Tcl version by setting the `tclenv_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ tclenv shell jtcl-1.7.1

When run without a version number, `tclenv shell` reports the current
value of `tclenv_VERSION`. You can also unset the shell version:

    $ tclenv shell --unset

Note that you'll need tclenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`tclenv_VERSION` variable yourself:

    $ export tclenv_VERSION=jtcl-1.7.1

### tclenv versions

Lists all Tcl versions known to tclenv, and shows an asterisk next to
the currently active version.

    $ tclenv versions
      1.8.7-p352
      1.9.2-p290
    * 1.9.3-p327 (set by /Users/sam/.tclenv/version)
      jtcl-1.7.1
      rbx-1.2.4
      ree-1.8.7-2011.03

### tclenv version

Displays the currently active Tcl version, along with information on
how it was set.

    $ tclenv version
    1.9.3-p327 (set by /Users/sam/.tclenv/version)

### tclenv rehash

Installs shims for all Tcl executables known to tclenv (i.e.,
`~/.tclenv/versions/*/bin/*`). Run this command after you install a new
version of Tcl, or install a gem that provides commands.

    $ tclenv rehash

### tclenv which

Displays the full path to the executable that tclenv will invoke when
you run the given command.

    $ tclenv which irb
    /Users/sam/.tclenv/versions/1.9.3-p327/bin/irb

### tclenv whence

Lists all Tcl versions with the given command installed.

    $ tclenv whence rackup
    1.9.3-p327
    jtcl-1.7.1
    ree-1.8.7-2011.03

## Environment variables

You can affect how tclenv operates with the following settings:

name | default | description
-----|---------|------------
`tclenv_VERSION` | | Specifies the Tcl version to be used.<br>Also see [`tclenv shell`](#tclenv-shell)
`tclenv_ROOT` | `~/.tclenv` | Defines the directory under which Tcl versions and shims reside.<br>Also see `tclenv root`
`tclenv_DEBUG` | | Outputs debug information.<br>Also as: `tclenv --debug <subcommand>`
`tclenv_HOOK_PATH` | [_see wiki_][hooks] | Colon-separated list of paths searched for tclenv hooks.
`tclenv_DIR` | `$PWD` | Directory to start searching for `.tcl-version` files.

## Development

The tclenv source code is [hosted on
GitHub](https://github.com/manicmaniac/tclenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/manicmaniac/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/manicmaniac/tclenv/issues).


  [tcl-build]: https://github.com/manicmaniac/tcl-build#readme
  [hooks]: https://github.com/manicmaniac/tclenv/wiki/Authoring-plugins#tclenv-hooks
