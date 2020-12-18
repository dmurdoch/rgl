#include "String.h"
#include "types.h"

using namespace std;

//////////////////////////////////////////////////////////////////////////////
//
// SECTION: Strings
//

//
// CLASS
//   StringArrayImpl
//

namespace rgl {

class StringArrayImpl : public AutoDestroy
{
public:
  StringArrayImpl(int in_ntexts, char** in_texts) 
  {
    int i;

    ntexts = in_ntexts;

    lengths = new unsigned int [ntexts];
    starts = new unsigned int [ntexts];

    int buflen = 0;

    for(i=0;i<ntexts;i++) {
      starts[i] = buflen;
      buflen += 1 + ( lengths[i] = static_cast<int>(strlen(in_texts[i])) );
    }
    
    char* tptr = textbuffer = new char [buflen];

    for(i=0;i<ntexts;i++) {
      int len = lengths[i];
      memcpy(tptr, in_texts[i], 1 + len);
      tptr += 1 + len;
    }
  }

  ~StringArrayImpl()
  {
    delete [] lengths;
    delete [] starts;
    delete [] textbuffer;
  }
  int   ntexts;
  char* textbuffer;
  unsigned int*  lengths;
  unsigned int*  starts;
};

}

using namespace rgl;

//
// CLASS
//   StringArray
//

StringArray::StringArray()
{
  impl = NULL;
}

StringArray::StringArray(int in_ntexts, char** in_texts)
{
  if (in_ntexts > 0) {
    impl = new StringArrayImpl(in_ntexts, in_texts);
    impl->ref();
  }
  else
    impl = NULL;
}

StringArray::StringArray(StringArray& from)
{
  impl = from.impl;

  if (impl)
    impl->ref();
}

StringArray::~StringArray()
{
  if (impl)
    impl->unref();
}

String StringArray::operator[](int index)
{
  if (impl && index < impl->ntexts)
    return String(impl->lengths[index], impl->textbuffer + impl->starts[index]);
  else
    return String(0, NULL);
}

int StringArray::size()
{
  if (impl) return impl->ntexts;
  else return 0;
}

//
// CLASS
//   StringArrayIterator
//

StringArrayIterator::StringArrayIterator(StringArray* in_array)
{
  array = in_array;
}

void StringArrayIterator::first()
{
  cnt = 0;
  if (array->impl)
    textptr = array->impl->textbuffer;
  else
    textptr = NULL;
}

void StringArrayIterator::next()
{
  if ( (textptr) && (cnt < array->impl->ntexts) )
    textptr += 1 + array->impl->lengths[cnt++];
}

String StringArrayIterator::getCurrent()
{
  return String(array->impl->lengths[cnt], textptr );
}

bool StringArrayIterator::isDone() const 
{
  if (array->impl)
    return (cnt == array->impl->ntexts) ? true : false;
  else
    return true;
}
