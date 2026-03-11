
set shell := ["powershell.exe", "-c"]

default: run

build:
	odin build . -out:main.exe -subsystem:console -debug -max-error-count:8

run:
	odin run . -out:main.exe -subsystem:console -debug -max-error-count:8

release:
	make -C ./build
	./build.exe -release

test:
	odin test engine/tests -all-packages -define:ODIN_TEST_THREADS=1

doc:
	mdbook serve engine\doc

