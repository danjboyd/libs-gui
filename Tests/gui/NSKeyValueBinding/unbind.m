/* The table of bound objects does not retain the objects it holds, so it
   must forget an object when the object's last binding is removed: the
   object may be deallocated right after -unbind:, and the table would then
   send -hash and -isEqual: to freed memory whenever it looks up or grows.
   The unbound object here stays alive and counts the -hash and -isEqual:
   messages it gets while many other objects are bound, which is enough to
   make the table look up and grow. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSString.h>

#include <AppKit/NSKeyValueBinding.h>

#define	OTHERS	1000

@interface Bound : NSObject
{
  id value;
}
- (id) value;
- (void) setValue: (id)aValue;
@end

@implementation Bound
+ (void) initialize
{
  if (self == [Bound class])
    {
      [self exposeBinding: NSValueBinding];
    }
}
- (id) value
{
  return value;
}
- (void) setValue: (id)aValue
{
  ASSIGN(value, aValue);
}
- (void) dealloc
{
  RELEASE(value);
  [super dealloc];
}
@end

static BOOL counting = NO;
static unsigned messages = 0;

@interface Counted : Bound
@end

@implementation Counted
- (NSUInteger) hash
{
  if (counting)
    {
      messages++;
    }
  return [super hash];
}
- (BOOL) isEqual: (id)other
{
  if (counting)
    {
      messages++;
    }
  return [super isEqual: other];
}
@end

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];
  NSMutableArray *others = [NSMutableArray array];
  Bound *model = AUTORELEASE([Bound new]);
  Counted *unbound = AUTORELEASE([Counted new]);
  NSUInteger i;

  START_SET("NSKeyValueBinding unbind")

  [model setValue: @"model"];
  for (i = 0; i < OTHERS; i++)
    {
      [others addObject: AUTORELEASE([Bound new])];
    }

  [unbound bind: NSValueBinding
       toObject: model
    withKeyPath: @"value"
        options: nil];
  PASS([unbound infoForBinding: NSValueBinding] != nil,
    "a bound object has binding info");
  PASS_EQUAL([unbound value], @"model",
    "binding sets the value from the bound object");

  [unbound unbind: NSValueBinding];
  PASS([unbound infoForBinding: NSValueBinding] == nil,
    "an unbound object has no binding info");

  counting = YES;
  for (i = 0; i < OTHERS; i++)
    {
      [[others objectAtIndex: i] bind: NSValueBinding
			     toObject: model
			  withKeyPath: @"value"
			      options: nil];
    }
  for (i = 0; i < OTHERS; i++)
    {
      [[others objectAtIndex: i] unbind: NSValueBinding];
    }
  counting = NO;
  PASS(messages == 0,
    "the binding table no longer refers to an object once it is unbound");

  END_SET("NSKeyValueBinding unbind")

  DESTROY(arp);
  return 0;
}
