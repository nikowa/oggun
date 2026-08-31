
set shell := ["powershell.exe", "-c"]

default: current

audit package: lib
	oggun audit {{package}}.odin

current: example_sprites
	examples/sprites.exe

flags := "-subsystem:console -debug -max-error-count:8 -extra-linker-flags:\"/ignore:4099\" -ignore-unknown-attributes"

check_flags := "-max-error-count:4 -ignore-unknown-attributes"

release:
	make -C ./build
	./build.exe -release

check: lib
	cls
	odin check shared/oggun {{check_flags}}
	odin check examples/input {{check_flags}}
	odin check examples/gui {{check_flags}}
	odin check examples/neon {{check_flags}}
	odin check examples/sprites {{check_flags}}
	odin check examples/sync {{check_flags}}
	odin check examples/graph {{check_flags}}
	odin check examples/prop {{check_flags}}
	odin check examples/modes {{check_flags}}
	odin check examples/graph {{check_flags}}

test: lib
	cls
	odin test tests -all-packages -define:ODIN_TEST_THREADS=1 -define:ODIN_TEST_TRACK_MEMORY=false -ignore-unknown-attributes -debug

doc:
	mkdocs serve

lib:
	cls
	odin build shared/oggun -out:oggun.exe {{flags}} -ignore-warnings -define:OGGUN_EXE=true
	./oggun.exe install

example_input: lib
	odin build examples/input -out:examples/input.exe {{flags}}

example_gui: lib
	odin build examples/gui -out:examples/gui.exe {{flags}}

example_neon: lib
	odin build examples/neon -out:examples/neon.exe {{flags}}

example_sprites: lib
	odin build examples/sprites -out:examples/sprites.exe {{flags}}

example_sync: lib
	odin build examples/sync -out:examples/sync.exe {{flags}}

example_graph: lib
	oggun build examples/graph -out:examples/graph.exe {{flags}}
#	odin build examples/graph -out:examples/graph.exe {{flags}}

example_prop: lib
	odin build examples/prop -out:examples/prop.exe {{flags}}

example_modes: lib
	odin build examples/modes -out:examples/modes.exe {{flags}}

example_collage: lib
	odin build examples/collage -out:examples/collage.exe {{flags}}

examples: example_input example_gui example_neon example_sprites example_sync example_graph example_collage
