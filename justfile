
set shell := ["powershell.exe", "-c"]

default: run

run:
	odin build . -out:main.exe -subsystem:console -debug -max-error-count:8
	odin run . -out:main.exe -subsystem:console -debug -max-error-count:8

release:
	make -C ./build
	./build.exe -release
