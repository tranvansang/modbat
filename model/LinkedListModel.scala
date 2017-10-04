package model

import modbat.dsl._

class LinkedListModel extends CollectionModel {
  override val testData = new java.util.LinkedList[Integer]
}
