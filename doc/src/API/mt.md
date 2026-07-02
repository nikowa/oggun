# mt

Meta-programming utils.

## core

## generator

## glsl_generator

#### `mt_odin_to_glsl` 🟩

```c
mt_odin_to_glsl :: proc(
	odin_source_path: string) -> (glsl_source: string)
```

Translate all the procedures from a given Odin source file to GLSL.
