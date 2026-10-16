/* NSUnregisterServicesProvider(), the Cocoa spelling, and
   NSUnRegisterServicesProvider(), the spelling NSApplication.h used to
   declare without a definition, both remove the port a services provider
   was registered under. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSPortNameServer.h>
#include <Foundation/NSProcessInfo.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>

@interface Provider : NSObject
@end
@implementation Provider
@end

int main()
{
  CREATE_AUTORELEASE_POOL(arp);
  NSPortNameServer *ns;
  NSString *name;
  Provider *provider;

  START_SET("NSApplication unregisterServicesProvider")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  /* A process may register its own name without an NSServices entry. */
  name = [[NSProcessInfo processInfo] processName];
  ns = [NSPortNameServer systemDefaultPortNameServer];
  provider = AUTORELEASE([Provider new]);

  NSRegisterServicesProvider(provider, name);
  PASS([ns portForName: name] != nil, "the provider's port is registered");
  NSUnregisterServicesProvider(name);
  PASS([ns portForName: name] == nil,
       "NSUnregisterServicesProvider() removes the port");

  NSRegisterServicesProvider(provider, name);
  PASS([ns portForName: name] != nil, "the provider's port is registered again");
  NSUnRegisterServicesProvider(name);
  PASS([ns portForName: name] == nil,
       "NSUnRegisterServicesProvider() removes the port");

  END_SET("NSApplication unregisterServicesProvider")

  DESTROY(arp);
  return 0;
}
