MAKE = $(MAKE) /nologo          # Turn off copyright notice

all: singlewin.exe multiwin.exe multithread.exe

singlewin.exe: 
    @cd singlewin
    @$(MAKE) /$(MAKEFLAGS)
    @cd ..

multiwin.exe: 
    @cd multiwin
    @$(MAKE) /$(MAKEFLAGS)
    @cd ..

multithread.exe: 
    @cd multithread
    @$(MAKE) /$(MAKEFLAGS)
    @cd ..

clean:
    @cd singlewin
    @$(MAKE) /$(MAKEFLAGS) clean
    @cd ..
    @cd multiwin
    @$(MAKE) /$(MAKEFLAGS) clean
    @cd ..
    @cd multithread
    @$(MAKE) /$(MAKEFLAGS) clean
    @cd ..
