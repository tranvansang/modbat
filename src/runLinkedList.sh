#!/bin/sh
time scala -classpath . openmodbat-3.2.jar \
	-s=5 \
	-n=1000 \
	--abort-probability=0.02 \
	model.complex.LinkedListModel
