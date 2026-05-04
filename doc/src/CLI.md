# CLI

`~/Willow/willow.exe` is a command-line utility which provides some commands that should make it easier to install and use Willow. It is entirely optional.

### Install

The `install` command copies the Willow library from Willow's installation directory to the `shared/` folder in the Odin installation directory on your machine. You need to do this once, before using Willow in your Odin package. Alternatively, you can manually copy `~/Willow/shared/willow` to `~/Odin/shared/willow`.

```
willow install
```

### Init

The `init` command initializes a starter project directory using the Willow engine. It creates a new directory, copies to it the contents of `~/Willow/starter`, and initializes a Git repo in it.

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

The `check` command runs the Willow preprocessor on a given Odin package, to check whether or not Willow's thread synchronization rules are followed.

```
willow check <directory-name> [-r]
```

If the `-r` option is enabled, Willow will also preprocess all imported packages recursively, excluding the ones from the Odin standard library.
