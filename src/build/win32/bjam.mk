rgl.dll: ../build/install/rgl.dll 
	cp $< $@

../build/install/rgl.dll:
	cd .. ; unset BUILD ; bjam install

clean:
	cd .. ; unset BUILD ; bjam clean

