/* Constants declared in the AppKit headers are defined: the accessibility
   exception name, the font collection change notification and its user
   info keys, and the icon and token sizes.  They were declared but never
   defined, so code using them did not link.  They need no backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSString.h>
#include <AppKit/AppKitDefines.h>
#include <AppKit/NSErrors.h>
#include <AppKit/NSFontCollection.h>
#include <AppKit/NSWindow.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];

  START_SET("AppKit constant exports")

  PASS_EQUAL(NSAccessibilityException, @"NSAccessibilityException",
    "NSAccessibilityException is defined");
  PASS_EQUAL(NSFontCollectionDidChangeNotification,
    @"NSFontCollectionDidChangeNotification",
    "NSFontCollectionDidChangeNotification is defined");
  PASS(NSFontCollectionActionKey != nil && NSFontCollectionNameKey != nil
    && NSFontCollectionOldNameKey != nil
    && NSFontCollectionVisibilityKey != nil,
    "the font collection notification keys are defined");
  PASS(NSIconSize.width == 48 && NSIconSize.height == 48,
    "NSIconSize is 48 by 48");
  PASS(NSTokenSize.width == 64 && NSTokenSize.height == 64,
    "NSTokenSize is 64 by 64");

  END_SET("AppKit constant exports")

  [pool release];
  return 0;
}
