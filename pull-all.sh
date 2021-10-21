#!/bin/bash
START=`pwd`
for r in */.git; do 
	echo "==== `dirname $r`"
	cd `dirname "$r"` && git pull
	cd $START
done
