CC = gcc
CFLAGS = -c -g -Wall -I/usr/include -I..
LIBS = -L/usr/lib -lGL

demo: demo.o glprocs.o
	$(CC) demo.o glprocs.o $(LIBS) -o $@

demo.o: demo.c ../GL/glprocs.h
	$(CC) $(CFLAGS) demo.c

glprocs.o: glprocs.c ../GL/glprocs.h
	$(CC) $(CFLAGS) glprocs.c

glprocs.c:
	ln -s ../GL/glprocs.c .


clean:
	rm -f *.o demo glprocs.c

