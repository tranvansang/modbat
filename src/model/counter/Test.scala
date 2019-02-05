package model.counter

import modbat.dsl._

class Counter {
  private var n = 0
  def inc = n += 1
  def dec = n -= 1
  def get = n
  def reset = n = 0
}

class Test extends Model {
  val counter = new Counter()
  var model : Int = 0
  "init" -> "init" := {
    counter.inc
    model += 1
  } label "inc"
  "init" -> "init" := {
    counter.dec
    model -= 1
  } label "dec"
  "init" -> "init" := {
    counter.reset
    model = 0
  } label "reset"
  "init" -> "init" := {
    assert (counter.get == model)
  } label "get"
  "init" -> "end" := {
  } label "end"
}
