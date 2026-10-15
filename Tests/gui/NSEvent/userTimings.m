/* NSEvent answers the double click interval from the GSDoubleClickTime
   default, as the backend reads it (300 ms when unset or under 200 ms),
   and the X server's usual key repeat delay and interval.  All three
   answered 0.  The defaults are set in the argument domain, so nothing is
   written to the user's defaults.  They need no backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSUserDefaults.h>
#include <AppKit/NSEvent.h>

static void
setArgument(NSString *key, id value)
{
  NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
  NSMutableDictionary *args = [NSMutableDictionary dictionaryWithDictionary:
    [defs volatileDomainForName: NSArgumentDomain]];

  if (value != nil)
    [args setObject: value forKey: key];
  else
    [args removeObjectForKey: key];
  [defs removeVolatileDomainForName: NSArgumentDomain];
  [defs setVolatileDomain: args forName: NSArgumentDomain];
}

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];

  START_SET("NSEvent user timings")

  setArgument(@"GSDoubleClickTime", @"100");
  PASS([NSEvent doubleClickInterval] == 0.3,
    "a double click time under 200 ms gives 300 ms");
  setArgument(@"GSDoubleClickTime", @"500");
  PASS([NSEvent doubleClickInterval] == 0.5,
    "the double click interval follows GSDoubleClickTime");
  setArgument(@"GSDoubleClickTime", nil);

  PASS([NSEvent keyRepeatDelay] == 0.66 && [NSEvent keyRepeatInterval] == 0.04,
    "the key repeat delay and interval are the X server's usual ones");

  END_SET("NSEvent user timings")

  [pool release];
  return 0;
}
