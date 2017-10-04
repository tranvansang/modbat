#!/bin/sh
time scala -classpath . openmodbat-3.1-dev.jar \
	-s=9 \
	-n=10 \
	--abort-probability=0.02 \
	model.SimpleListModel
