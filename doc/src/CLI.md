# CLI

`~/Oggun/willow.exe` is a command-line utility which provides some commands that should make it easier to install and use Oggun. It is entirely optional.

### Install

The `install` command copies the Oggun library from Oggun's installation directory to the `shared/` folder in the Odin installation directory on your machine. You need to do this once, before using Oggun in your Odin package. Alternatively, you can manually copy `~/Oggun/shared/willow` to `~/Odin/shared/willow`.

```
willow install
```

### Init

The `init` command initializes a starter project directory using the Oggun engine. It creates a new directory, copies to it the contents of `~/Oggun/starter`, and initializes a Git repo in it.

```
willow init <directory-name>
```

Invoking `willow init game` will create the following directory structure:

```
game/
├─ data/
│  ├─ ...
├─ .git
├─ main.odin
├─ README.md
```

### Check

The `check` command runs the Oggun preprocessor on a given Odin package, to check whether or not Oggun's thread synchronization rules are followed.

```
willow check <directory-name> [-r]
```

If the `-r` option is enabled, Oggun will also preprocess all imported packages recursively, excluding the ones from the Odin standard library.
