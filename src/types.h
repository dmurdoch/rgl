#ifndef TYPES_H
#define TYPES_H

#include "pragma.h"

// C++ header file
// This file is part of RGL
//
// $Id$


#include <cstring>

//
//
// constants
//
//


#ifndef NULL
#define NULL    0UL
#endif



//
//
// fundamental data types
//
//



typedef unsigned char u8;
typedef long          u32;



//
// memory management objects
//


class AutoDestroy
{
public:
  AutoDestroy() { refcount = 0; }
  virtual ~AutoDestroy() { }
  void ref() { refcount++; }
  void unref() { if ( !(--refcount) ) delete this; }
private:
  int refcount;
};

template<class T>
class Ref
{
public:
  Ref() : ptr(NULL) { }
  Ref(T* in_ptr) : ptr(in_ptr) { if (ptr) ptr->ref(); }
  Ref(const Ref& ref) : ptr(ref.ptr) { if (ptr) ptr->ref(); }
  ~Ref() { if (ptr) ptr->unref(); }
  Ref& operator = (T* in_ptr) { if (ptr) ptr->unref(); ptr = in_ptr; if (ptr) ptr->ref(); return *this; }
  T* operator -> () { return ptr; }
  operator bool () { return (ptr) ? true : false; }
private:
  T* ptr;
};

//
// CLASS
//  DestroyHandler
//

class DestroyHandler
{
public:
  virtual void notifyDestroy(void* userdata) = 0;
};

//
//
// Nodes, Containers and Iterators
//
//


//
// CLASS
//   Node
//

class Node;

class Node
{
public:
  Node();
  virtual ~Node() {  }
  
protected:
  Node* prev;
  Node* next;
  friend class List;
  friend class ListIterator;
  friend class RingIterator;

public:
  Node* getNext() { return next; }

};


//
// CLASS
//   List
//

class List
{
public:
  List();
  ~List();
  void addTail(Node* node);
  Node* remove(Node* node);
  void deleteItems(void);
  Node* getTail() { return tail; }
private:
  Node* head;
  Node* tail;
  friend class ListIterator;
  friend class RingIterator;
};


//
// CLASS
//   ListIterator
//

class ListIterator
{
public:
  ListIterator(List* list);
  void operator() (List* list);
  void  first();
  void  next();
  bool  isDone();
  Node* getCurrent();
protected:
  List* list;
  Node* nodePtr;
};

//
// CLASS
//   RingIterator
//

class RingIterator : public ListIterator
{
public:
  RingIterator(List* list);
  void  set(Node* node);
  void  next();
};


//
// TEMPLATE
//   ARRAY
//

template<class T>
struct ARRAY
{
  int _size;
  T*  ptr;
  inline int size()
  { return _size; }
  inline ARRAY(int in_size) : _size(in_size), ptr(new T [_size])
  { }
  template<class SRC>
  inline ARRAY(int in_size, SRC* src) : _size(in_size), ptr(new T [_size])
  { copy(src, ptr,_size); }
  inline ~ARRAY()
  { delete [] ptr; }
  inline T& get(int index)
  { return ptr[index]; }
  inline T& getRecycled(int index)
  { return ptr[index%_size]; };
};

//
// mem copy
//

template<class A, class B>
inline void copy(A* from, B* to, int size)
{
  memcpy( (void*) to, (const void*) from, size*sizeof(A) );
}

//
// cast-copy doubles to floats
//

template<>
inline void copy(double* from, float* to, int size)
{
  while(size--) {
    *to = (float) *from;
    from++; to++;
  }
}

/**
 * get most significant bit
 * @param x unsigned value
 * @return bit position between 1..32 or 0 if value was 0
 **/
inline int msb(unsigned int x) {
  if (x) {
    int bit = sizeof(int)*8;
    unsigned int mask = 1<<((sizeof(int)*8)-1);
    while ( !(x & mask) ) {
      --bit; mask >>= 1;
    }
    return bit;
  } else
    return 0;
}


// template<class T> T getMax(T a, T b) { return (a > b) ? a : b; }
// template<class T> T getMin(T a, T b) { return (a < b) ? a : b; }

inline int   getMin(int a, int b)     { return (a <= b) ? a : b; }
inline float getMin(float a, float b) { return (a <= b) ? a : b; }
inline int   getMax(int a, int b)     { return (a >= b) ? a : b; }
inline float getMax(float a, float b) { return (a >= b) ? a : b; }
inline float clamp(float v, float floor, float ceil) { return (v<floor) ? floor : ( (v>ceil) ? ceil : v ); }
inline int   clamp(int   v, int   floor, int   ceil) { return (v<floor) ? floor : ( (v>ceil) ? ceil : v ); }

/**
 * Listener utility
 **/
#if 0
#include <vector>

template<class ListenerT>
class ListenerList
{
public:
  typedef ListenerT::EventT EventT;
  typedef void (ListenerT::* MemberPtrT) (const EventT&);
  void add(ListenerT* l)
  {
    listeners.push_back(l);
  }
  void remove(ListenerT* l)
  {
    std::vector<ListenerT*>::iterator iter = std::find( listeners.begin() , listeners.end() , l);
    if ( iter != listeners.end() )
      listeners.erase(iter);
  }
  void fire(MemberPtrT ptr, const EventT& event) 
  {
    std::vector<ListenerT*>::iterator iter;
    for (iter = listeners.begin() ; iter != listeners.end() ; ++ iter ) {
      ListenerT* l = *iter;
      (l->*ptr)(event);
    }
  }
private:
  std::vector<ListenerT*> listeners;
};
#endif

#endif /* TYPES_H */
