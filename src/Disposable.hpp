#ifndef RGL_DISPOSABLE_HPP
#define RGL_DISPOSABLE_HPP

#include <vector>

// forward declaration
class Disposable;

/**
 * Dispose Listener Interface.
 **/
struct IDisposeListener
{
  virtual void notifyDisposed(Disposable* disposing) = 0;
};

/**
 * Disposable objects can be disposed autonomous while
 * they might be managed by a different Subject.
 * They allow for registering listeners that will be notified when
 * the object becomes disposed.
 **/ 
class Disposable
{
public:
  /**
   * register listener. It is not allowed to add the listener
   * if it is already registered.
   * 
   * @arg l listener to be added to list
   **/
  void addDisposeListener(IDisposeListener* l);
  /**
   * unregister listener.
   * @arg l listener to be removed
   **/
  void removeDisposeListener(IDisposeListener* l);
  /**
   * dispose object. 
   * Default implementatin will fire NotifyDisposed.
   **/
  void dispose();
protected:
  /**
   * fires 'notifyDisposed' on all registered listeners.
   * It is save to call add/remove during 'notifyDisposed'.
   **/
  void fireNotifyDisposed();
private:
  typedef std::vector<IDisposeListener*> Container;
  Container disposeListeners;
};

#endif // RGL_DISPOSABLE_HPP

