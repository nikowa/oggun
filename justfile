
set shell := ["powershell.exe", "-c"]

default: run

flags := "-subsystem:console -debug -max-error-count:8 -extra-linker-flags:\"/ignore:4099\""

build:
	odin build . -out:main.exe {{flags}}

run:
	odin run . -out:main.exe {{flags}}

release:
	make -C ./build
	./build.exe -release

check:
	odin check shared/willow/input_sys -no-entry-point
	odin check shared/willow/graphics -no-entry-point
	odin check shared/willow
	odin check shared/willow/asset_manager -no-entry-point
	odin check shared/willow/base -no-entry-point
	odin check shared/willow/container/micro_pair -no-entry-point
	odin check shared/willow/container/ordered_mutex -no-entry-point
	odin check shared/willow/container/rect -no-entry-point
	odin check shared/willow/container/sdf -no-entry-point
	odin check shared/willow/container/two_stack -no-entry-point
	odin check shared/willow/dll -no-entry-point

test:
	odin test shared/willow/tests -all-packages -define:ODIN_TEST_THREADS=1 -define:ODIN_TEST_TRACK_MEMORY=false

doc:
	mdbook serve doc

lib:
	cls
	odin build shared/willow -out:willow.exe  {{flags}}
	./willow.exe install

example_input:
	odin build examples/input -out:examples/input/input.exe {{flags}}
	examples/input/input.exe

example_gui:
	odin build examples/gui -out:examples/gui/gui.exe {{flags}}
	examples/gui/gui.exe

example_sprites:
	odin build examples/sprites -out:examples/sprites/sprites.exe {{flags}}
	examples/sprites/sprites.exe

example_sync:
	odin build examples/sync -out:examples/sync/sync.exe {{flags}}
	examples/sync/sync.exe
