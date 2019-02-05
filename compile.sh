#!/bin/sh
scalac -classpath experiment.jar:lib/openmodbat-3.2.jar -sourcepath src -deprecation src/model/*/*.scala
