CC = g++ -no-pie
CFLAGS = -m64 -Wall
LDLIBS = -lsfml-graphics -lsfml-window -lsfml-system

all:	main.o polynomial.o
	$(CC) $(CFLAGS) main.o polynomial.o -o polynomial $(LDLIBS)
main.o:	main.cpp
	$(CC) $(CFLAGS) -c -g main.cpp -o main.o
polynomial.o:	polynomial.asm
	nasm -f elf64 -g polynomial.asm

gdb :
	gdb polynomial

clean:
		rm -f *.o
		rm polynomial
		rm polynomial.bmp

debug : all gdb
