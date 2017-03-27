kernel := $(shell sh -c 'uname -s 2>/dev/null || echo not')

ifeq ($(kernel),Linux)
    CLANG_ARGS = -lGL -lGLU -lglut
endif
ifeq ($(kernel),Darwin)
    CLANG_ARGS = -framework GLUT -framework OpenGL -Wno-deprecated
endif

all: native asm wasm hybrid

build:
	mkdir build

native: build
	/usr/bin/clang $(CLANG_ARGS) Cube.c -o Cube

asm: build
	emcc -O3 -s LEGACY_GL_EMULATION=1 --separate-asm -o build/asmjs.html Cube.c

wasm: build
	emcc -O3 -s LEGACY_GL_EMULATION=1 -s WASM=1 -o build/webassembly.html Cube.c

hybrid: build
	emcc -O3 -s LEGACY_GL_EMULATION=1 --separate-asm -s WASM=1 -s 'BINARYEN_METHOD="native-wasm,asmjs"' -o build/hybrid.html Cube.c

clean:
	rm -rf Cube build
