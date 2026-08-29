# **mt/testing**

## Overview

The main content of this are helper functions for generating test data.

## Procedures

### `expect`

```odin
expect :: proc(
	cond: bool,
	loc := #caller_location)
```

Wrapper for `testing.expect`. Passes `context.user_ptr` as first argument.

### `mt_test_coverage`

```odin
mt_test_coverage :: proc(
	directory_path: string,
	files: []string={},
	silent: bool=false) -> (tested, untested: []string)
```

Scans a package directory and determines which of the Oggun procedures used within it are covered by the Oggun tests.

<div style="height: 100vh;"></div>
