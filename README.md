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

Both examples are intended to show failing test cases.
In this case, the Java collection classes are correct, so each model has a flaw.
The problems in the models can be fixed with one or a few lines of code.

## A simple model: Java collections ##

The first model tests four operations on a Java LinkedList: add, remove, clear, and size.

```scala
class SimpleListModel extends Model {
  val N = 10 // range of integers to choose from
  val collection = new LinkedList[Integer] // the "system under test"
  var n = 0 // Number of elements in the collection

  def add {
    val element = new Integer(choose(0, N))
    val ret = collection.add(element)   
    n += 1
    assert(ret)
  }

  def clear {
    collection.clear
    n = 0
  }

  def remove {
    val obj = new Integer(choose(0, N))
    val res = collection.remove(obj)
    n = n - 1
  }

  def size {
    assert (collection.size == n,
	    "Predicted size: " + n +
	    ", actual size: " + collection.size)
  }

  "main" -> "main" := add
  "main" -> "main" := size
  "main" -> "main" := clear
  "main" -> "main" := remove
}
```

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

## Complex model: Java collections and iterators ##

* A _collection_ holds a number of data items.
* An _iterator_ can access these data items sequentially.
* An iterator is _valid_ as long as the underlying collection has not been modified.
* _hasNext_ queries if an iterator has more elements available.
* If an iterator goes beyond the last element, NoSuchElementException is thrown.
* If the collection has been modified, ConcurrentModificationException is thrown.

### How to orchestrate multiple models ###

	abstract class CollectionModel extends Model {
	  val collection: Collection[Integer] // the "system under test" 
	  def iterator {
	    val it = collection.iterator()
	    val modelIt = new IteratorModel(this, it)
	    launch(modelIt)	
	  }

* _launch_ activates a new model instance.
* In this example, the instance is initialized with a reference to the current model and the iterator.

### Iterator model ###

	class IteratorModel(val dataModel: CollectionModel,
	                    val it: Iterator[Integer]) extends Model {
	
	  var pos = 0
	  val version = dataModel.version
	  	
	  def valid = (version == dataModel.version)
	
	  def actualSize = dataModel.collection.size
	
	  def hasNext {
	    if (valid) {
	      assert ((pos < actualSize) == it.hasNext)
	    } else {
	      it.hasNext
	    } 
	  }
	
	  def next {
	    require (valid)
	    require (pos < actualSize)
	    it.next 
	    pos += 1 
	  }

	  def failingNext { // throws NoSuchElementException
	    require (valid)
	    require (pos >= actualSize)
	    it.next
	  } 
	
	  def concNext { // throws ConcurrentModificationException
	    require(!valid)
	    it.next
	  }
	
	  "main" -> "main" := hasNext 
	  "main" -> "main" := next
	  "main" -> "main" := failingNext throws "NoSuchElementException"
	  "main" -> "main" := concNext throws "ConcurrentModificationException"
	}

* Preconditions determine when a given transition function is enabled.

* In this case, the preconditions distinguish normal behavior from exceptions.

### Test case generation with the example model ###

	[INFO] 1000 tests executed, 997 ok, 3 failed.
	[INFO] 2 types of test failures:
	[INFO] 1) java.util.ConcurrentModificationException at failingNext:
	[INFO]    6e8ddf360994ae26 36ae40ee3f8301d6
	[INFO] 2) java.util.ConcurrentModificationException at next:
	[INFO]    6929277733240995

* Interpretation: ConcurrentModificationException is thrown by Java's iterator, but model does not expect it.
* Only 3 out of 1000 tests fail; only particular combinations of actions.
* Can you see a pattern and find the flaw in the model?
* Hint: You need to consider both the base model (CollectionModel) and the iterator model.