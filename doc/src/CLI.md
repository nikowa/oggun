# CLI

`~/Oggun/oggun.exe` is a command-line utility which provides some commands that should make it easier to install and use oggun. It is entirely optional.

### Install

The `install` command copies the oggun library from oggun's installation directory to the `shared/` folder in the odin installation directory on your machine. You need to do this once, before using oggun in your odin package. Alternatively, you can manually copy `~/Oggun/shared/oggun` to `~/Odin/shared/oggun`.

```
oggun install
```

### Init

The `init` command initializes a starter project directory using the oggun engine. It creates a new directory, copies to it the contents of `~/Oggun/starter`, and initializes a Git repo in it.

```
oggun init <directory-name>
```

Invoking `oggun init game` will create the following directory structure:

```
game/
├─ data/
│  ├─ ...
├─ .git
├─ main.odin
├─ README.md
```

### Check

The `check` command runs the oggun preprocessor on a given odin package, which will check whether oggun's synchronization rules are followed and warn you if you're using untested or unstable procedures.

```
oggun check <directory-name> [-r]
```

If the `-r` option is enabled, oggun will also preprocess all imported packages recursively, excluding the ones from the odin standard library.
