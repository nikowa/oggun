
set shell := ["powershell.exe", "-c"]

default: run

build:
	odin build . -out:main.exe -subsystem:console -debug -max-error-count:8

run:
	odin run . -out:main.exe -subsystem:console -debug -max-error-count:8 -extra-linker-flags:"/ignore:4099"

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
	odin build shared/willow -out:willow.exe -subsystem:console -debug -max-error-count:8
	./willow.exe install

example_input:
	odin run examples/input -debug

example_gui:
	odin run examples/gui -debug
