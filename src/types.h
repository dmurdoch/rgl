#ifndef TYPES_H
#define TYPES_H


// C++ header file
// This file is part of RGL
//
// $Id: types.h,v 1.3 2003/11/27 21:12:23 dadler Exp $


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
  operator bool () { return (ptr); }
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


#endif /* TYPES_H */
