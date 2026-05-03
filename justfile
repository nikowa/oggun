
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
	odin test shared/willow/tests -all-packages -define:ODIN_TEST_THREADS=1 -define:ODIN_TEST_TRACK_MEMORY=false

doc:
	mdbook serve shared/willow\doc

lib:
	odin build shared/willow -out:willow.exe -subsystem:console -debug -max-error-count:8
	./willow.exe install
