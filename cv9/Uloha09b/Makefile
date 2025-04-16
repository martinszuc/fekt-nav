# Autor: Martin Szuc, VUTID:231284
# Datum: 16.04.2025
# Makefile pre projekt PC9

ASM = nasm
ASMFLAGS = -fobj
LINKER = alink
LINKFLAGS = -oPE -subsys console

OBJFILES = main.obj MMXsupport.obj blend.obj

all: main.exe detect.dll

main.exe: $(OBJFILES)
	$(LINKER) $(LINKFLAGS) $(OBJFILES)

detect.dll: MMXsupport.obj blend.obj
	$(LINKER) -oPE -subsys gui -dll MMXsupport.obj blend.obj detect.def

main.obj: main.asm
	$(ASM) $(ASMFLAGS) main.asm

MMXsupport.obj: MMXsupport.asm
	$(ASM) $(ASMFLAGS) MMXsupport.asm

blend.obj: blend.asm
	$(ASM) $(ASMFLAGS) blend.asm

clean:
	del *.obj
	del *.exe
	del *.dll