#!/bin/sh
time scala -classpath . openmodbat-3.1-dev.jar \
	-s=10 \
	-n=5 \
	--abort-probability=0.02 \
	model.SimpleListModel
