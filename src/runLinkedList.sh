#!/bin/sh
time scala -classpath . openmodbat-3.1-dev.jar \
	-s=5 \
	-n=1000 \
	--abort-probability=0.02 \
	model.LinkedListModel
