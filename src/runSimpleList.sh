#!/bin/sh
time scala -classpath . openmodbat-3.2.jar \
	-s=10 \
	-n=5 \
	--abort-probability=0.02 \
	model.simple.SimpleListModel
