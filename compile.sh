#!/bin/sh
mkdir -p build
scalac -classpath experiment.jar:lib/openmodbat-3.2.jar -sourcepath src -deprecation -verbose -d build src/model/*/*.scala
