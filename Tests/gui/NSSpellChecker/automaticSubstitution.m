/* The automatic text replacement, dash and quote substitution settings of
   NSSpellChecker follow the user's defaults, and are off when unset.  They
   were always off.  The defaults are set in the argument domain, so
   nothing is written to the user's defaults.  They need no backend or
   spell server. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSUserDefaults.h>
#include <AppKit/AppKitDefines.h>
#include <AppKit/NSSpellChecker.h>

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

static void
setAll(id value)
{
  setArgument(@"NSAutomaticTextReplacementEnabled", value);
  setArgument(@"NSAutomaticDashSubstitutionEnabled", value);
  setArgument(@"NSAutomaticQuoteSubstitutionEnabled", value);
}

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];

  START_SET("NSSpellChecker automatic substitution settings")

  setAll(@"NO");
  PASS(![NSSpellChecker isAutomaticTextReplacementEnabled]
    && ![NSSpellChecker isAutomaticDashSubstitutionEnabled]
    && ![NSSpellChecker isAutomaticQuoteSubstitutionEnabled],
    "the substitutions are off when the defaults say so");

  setAll(@"YES");
  PASS([NSSpellChecker isAutomaticTextReplacementEnabled]
    && [NSSpellChecker isAutomaticDashSubstitutionEnabled]
    && [NSSpellChecker isAutomaticQuoteSubstitutionEnabled],
    "the substitutions follow the user's defaults");

  setAll(nil);

  END_SET("NSSpellChecker automatic substitution settings")

  [pool release];
  return 0;
}
