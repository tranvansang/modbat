# Modbat tutorial #

This repository contains introductory exercises for using Modbat, a model-based tester.
The tool is included in the repository.

## Requirements ##

* Scala 2.11.X; tested with Java 8.
* Modbat version 3.2 (provided).

## Overview of examples ##

1. src/model/simple: A simple model of a LinkedList.
1. src/model/complex: A more complex model that includes the usage of iterators.

## How to compile and run ##

* Compilation: ./compile.sh
* Simple example: ./runSimpleList.sh
* Complex example: ./runLinkedList.sh

## Explanation of examples ##

Both examples are intended to show failing test cases.
In this case, the Java collection classes are correct, so each model has a flaw.
The problems in the models can be fixed with one or a few lines of code.

### Test using the simple model ###

	./runSimpleList.sh 
	[INFO] 5 tests executed, 0 ok, 5 failed.
	[INFO] 2 types of test failures:
	[INFO] 1) java.lang.AssertionError: assertion failed:
	          Predicted size: 0, actual size: 1 at size:
	[INFO]    ba471c1085a01750 2251f4042ff65867 89a677f51847fa26 …
	[INFO] 2) java.lang.AssertionError: assertion failed:
	          Predicted size: 1, actual size: 2 at size:
	[INFO]    fd53cd70667aea0
	[INFO] 1 states covered (100 % out of 1),
	[INFO] 4 transitions covered (100 % out of 4).
	[INFO] Random seed for next test would be: 4f9dd7062e2f7ae4

	real	0m0.493s
	user	0m0.505s
	sys 	0m0.078s
	
This output shows that all five test sequences fail. Two identical types
of assertion errors with slightly different messages are generated.
The failure also shows the random seeds of each failing test.

A test can be replayed as follows:

	scala -classpath . openmodbat-3.2.jar \
	  -s=89a677f51847fa26 -n=1 model.simple.SimpleListModel

Each failed test also produces a trace file, e. g., 89a677f51847fa26.err.

### Analysis of the trace file ###

	[WARNING] java.lang.AssertionError:assertion failed:
	          Predicted size: 0, actual size: 1 occurred, aborting.
	[ERROR] java.lang.AssertionError:assertion failed:
	        Predicted size: 0, actual size: 1
	[ERROR] 	at scala.Predef$.assert(Predef.scala:170)
	[ERROR] 	at modbat.dsl.Model$class.assert(Model.scala:82)
	[ERROR] 	at model.simple.SimpleListModel.assert(SimpleListModel.scala:6)
	[ERROR] 	at model.simple.SimpleListModel.size(SimpleListModel.scala:30)
	        	...
	[WARNING] Error found, model trace:
	[WARNING] model/simple/SimpleListModel.scala:35: add; choices = (1)
	[WARNING] model/simple/SimpleListModel.scala:36: size
	[WARNING] model/simple/SimpleListModel.scala:38: remove; choices = (4)
	[WARNING] model/simple/SimpleListModel.scala:36: size

Sequence leading to failure: add(1), check size, remove(4), check size.