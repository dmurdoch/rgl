#!/bin/sh

case $1 in
	default)
		rm -f src/Makefile
		;;
	bjam)
		echo "include build/unix/bjam.mk" >src/Makefile
		;;
	*)

cat <<EOT
Select 'unix' build-tool.

$0 <build-tool>

  build-tool :

    "default"   -  GNUmake
    "bjam"      -  Boost jam v1

EOT
		;;
esac

