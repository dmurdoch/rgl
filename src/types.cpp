// C++ source
// This file is part of RGL.
//
// $Id: types.cpp,v 1.1 2003/03/25 00:13:21 dadler Exp $

#include "types.h"



//////////////////////////////////////////////////////////////////////////////
//
// CLASS IMPLEMENTATION
//   AutoDestroy
//

AutoDestroy::AutoDestroy()
{
  refcount = 1;
}

AutoDestroy::~AutoDestroy()
{
}

void AutoDestroy::ref()
{
  refcount++;
}

void AutoDestroy::unref()
{
  refcount--;
  if (refcount == 0)
    delete this;
}


//////////////////////////////////////////////////////////////////////////////
//
// CLASS IMPLEMENTATION
//   Node
//

Node::Node()
{
  prev = NULL;
  next = NULL;
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS IMPLEMENTATION
//   List
//

List::List()
{
  head = NULL;
  tail = NULL;
}

List::~List()
{
  deleteItems();
}

void List::addTail(Node* node)
{
  if (tail) {
    tail->next = node;
    node->prev = tail;
    tail = node;
  } else {
    head = tail = node;
  }
}

Node* List::remove(Node* inNode)
{

  if (inNode == head)
    head = inNode->next;

  if (inNode == tail)
    tail = inNode->prev;

  if (inNode->prev)
    inNode->prev->next = inNode->next;

  if (inNode->next)
    inNode->next->prev = inNode->prev;

  return inNode;
}

void List::deleteItems()
{

  Node* current = head;

  while(current) {
    
    Node* next = current->next;
    delete current;

    current = next;
  }

  head = NULL;
  tail = NULL;
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS IMPLEMENTATION
//   ListIterator
//

//
// CONSTRUCTOR
//

ListIterator::ListIterator(List* inList) : list(inList) {
  nodePtr = NULL;
}

void ListIterator::operator() (List* inList) {
  list = inList;
  nodePtr = NULL;
}

void ListIterator::first() {
  nodePtr = list->head;
}

void ListIterator::next() {
  nodePtr = (nodePtr) ? nodePtr->next : NULL;
}

bool ListIterator::isDone() {
  return (nodePtr) ? false : true;
}

Node* ListIterator::getCurrent() {
  return nodePtr;
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS IMPLEMENTATION
//   RingIterator
//

RingIterator::RingIterator(List* list) : ListIterator(list)
{
}

void RingIterator::set(Node* node)
{
  nodePtr = node;
}

void RingIterator::next() 
{
  nodePtr = (nodePtr) ? nodePtr->next : NULL;  

  if (!nodePtr)
    nodePtr = list->head;
}
