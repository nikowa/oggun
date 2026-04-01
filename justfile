
set shell := ["powershell.exe", "-c"]

default: run

build:
	odin build . -out:main.exe -subsystem:console -debug -max-error-count:8

run:
	odin run . -out:main.exe -subsystem:console -debug -max-error-count:8 -extra-linker-flags:"/ignore:4099"

release:
	make -C ./build
	./build.exe -release

test:
	odin test engine/tests -all-packages -define:ODIN_TEST_THREADS=1 -define:ODIN_TEST_TRACK_MEMORY=false

doc:
	mdbook serve engine\doc
