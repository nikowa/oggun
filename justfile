
set shell := ["powershell.exe", "-c"]

default: current

current: example_graph
	examples/graph.exe

flags := "-subsystem:console -debug -max-error-count:8 -extra-linker-flags:\"/ignore:4099\""

cli:
	odin build . -out:main.exe {{flags}}

release:
	make -C ./build
	./build.exe -release

check:
	cls
	odin check shared/willow -no-entry-point -max-error-count:8

test:
	cls
	odin test tests -all-packages -define:ODIN_TEST_THREADS=1 -define:ODIN_TEST_TRACK_MEMORY=false

doc:
	mdbook serve doc

lib:
	cls
	odin build shared/willow -out:willow.exe  {{flags}}
	./willow.exe install

example_input: lib
	odin build examples/input -out:examples/input.exe {{flags}}

example_gui: lib
	odin build examples/gui -out:examples/gui.exe {{flags}}

example_sprites: lib
	odin build examples/sprites -out:examples/sprites.exe {{flags}}

example_sync: lib
	odin build examples/sync -out:examples/sync.exe {{flags}}

example_graph: lib
	odin build examples/graph -out:examples/graph.exe {{flags}}

examples: example_input example_gui example_sprites example_sync example_graph
