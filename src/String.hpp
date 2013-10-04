#ifndef STRING_HPP
#define STRING_HPP

namespace rgl {

//
// CLASS
//   StringArray
//

struct String
{
  String(int in_length, char* in_text) {
    length = in_length;
    text   = in_text;
  }
  int   length;
  char* text;
};

class StringArrayImpl;

class StringArray
{
public:
  StringArray();
  StringArray(int ntexts, char** in_texts);
  StringArray(StringArray& from);
  ~StringArray();
  String operator[](int index);
  int size();

private:
  StringArrayImpl* impl;
  friend class StringArrayIterator;
};

class StringArrayIterator
{
public:
  StringArrayIterator(StringArray* array);
  void first();
  void next();
  String getCurrent();
  bool isDone() const;
private:
  StringArray* array;
  int   cnt;
  char* textptr;
};

} // namespace rgl

#endif // STRING_HPP
