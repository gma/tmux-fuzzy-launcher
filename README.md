tmux-fuzzy-launcher
===================

Do you like to edit code in a terminal, in [tmux]?

If so, this is for you.

While watching one of [ThePrimeagen's videos], I saw him do something like this:

[TODO: Animated Screenshot]

Prime used [fzf] to search through his local repositories, hitting return to launch Vim in a tmux session. Genius!

Prime's implementation is embedded in his bash config, so I wrote my own (standalone) version. And then I extended it a bit.

Install
-------

To run `tm` you need `tmux` and `fzf` installed. If you don't already have it, go do that now (`apt instal fzf` or `brew install fzf`, or whatever works for you).

`tm` is just a single shell script, so all you need to do is make sure it's exectuable and copied to somewhere in your `PATH`.

    $ git clone https://github.com/gma/tm.git
    $ cd tm
    $ ./install.sh       # creates symlink in ~/.local/bin, if it exists

Alternatively, once you've checked it out:

    $ sudo ./install.sh  # creates symlink in /usr/local/bin

In future you can update to the latest version with `git pull`.

If you don't fancy any of that git stuff, this manual approach will do it:

    curl -O https://raw.githubusercontent.com/gma/tmux-fuzzy-launcher/main/tm
    chmod +x tm
    mv tm ~/.local/bin/  # or to wherever you like

Usage
-----

Set the `TM_ROOT` environment variable to the name of the folder where you keep your code.

The default path is `~/Code`, but mine lives in `~/Projects`. So I've added this line to my `.bashrc` file:

    export TM_ROOT=~/Projects

Now run `tm` in your terminal. You'll be able to choose from any of the directories within `$TM_ROOT` that contain a `.git` folder.

Customisation
-------------

If the default behaviour doesn't work for how your repos are layed out, you can tweak it with the following environment variables. Define them in your shell's config. In Bash, you'd do it by setting the variable in your `~/.bashrc` file. Like this:

    export TM_EDITOR=nano

### TM_ROOT

Default: `~/Code`

The directory where you checkout your Git repositories.

### TM_DEPTH

Default: 3

`tm` runs `find` in order to find directories that live beneath your `$TM_ROOT` directory. By default any directory that contains a `.git` folder will be considered a project that you might want to open, so `tm` runs a command like this to discover them:

    find $TM_ROOT -type d -name .git

If you've got thousands of directories beneath `$TM_ROOT`, this could take a while. So we use the `-maxdepth` option to tell `find` not to look so deep in your directory structure.

If your directory structure is totally flat (with all repos living directly inside `$TM_ROOT`) you could set `TM_DEPTH` to 1. If you've got some nesting, you might want to increase it.

Most people will be able to leave this as is. Decrease it if you've got lots of big projects in a flat directory structure and `tm` isn't loading up as fast as you'd like (on my vintage laptop, it's essentially instant).

### TM_FILTER

Default: `cat`

There might be times when you want to prevent `tm` from listing some of the repositories on your machine. Perhaps you do live coding online, or at talks, and have some repositories that you don't want to show on screen. You could just avoid running `tm`, but once these tools get into your muscle memory... yeah, good luck with that.

Imagine you kept all your repositories in `~/Code`, and stored all the sensitive code in `~/Code/clients`. You can prevent `tm` from listing any repositories within `clients` by setting `TM_FILTER` to `grep` them out. But if you do that, how do you launch all that client work?

Let's hide the client projects by default, and make a separate command for opening client work:

    alias tm="TM_FILTER='grep -v clients/' tm"
    alias tmc="TM_FILTER='grep clients/' command tm"

Note the use of `command tm` in the second alias; `command` will call the `tm` script directly, rather than calling the `tm` alias (those two grep commands would combine to filter *everything* out).

### TM_PROJECT_CONTAINS

Default: `.git`

What if you don't use Git? `tm` won't be able to find any `.git` directories inside your projects. Use `TM_PROJECT_CONTAINS` to change the name of the directory that it's looking for. 

If you want to identify projects by searching for a file instead of a subdirectory, also set `TM_CRITERIA`.

### TM_CRITERIA

Default: `-type d -name $TM_PROJECT_CONTAINS`

Use `TM_CRITERIA` if you need to teach `tm` a new way of identifying your projects. The string that you set this variable to will be used to build up a `find` command, so they need to be legal options from `find(1)`.

If you only wanted to search through projects that contain a `README`, you could add this to your `~/.bashrc`:

    export TM_PROJECT_CONTAINS=README
    export TM_CRITERIA="-type f -name $TM_PROJECT_CONTAINS"

`fzf` will now be passed a list of paths to the directories that contain a `README` file.

### TM_EDITOR

Default: `$EDITOR` (or `vi` if `EDITOR` not set)

This is the command that will be run inside new tmux sessions.

[tmux]: https://github.com/tmux/tmux/wiki
[fzf]: https://github.com/junegunn/fzf
[ThePrimeagen's videos]: https://www.youtube.com/channel/UC8ENHE5xdFSwx71u3fDH5Xw
