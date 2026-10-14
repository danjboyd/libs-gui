/* After -addFontTrait:, -convertAttributes: adds the trait to the symbolic
 * traits of the attributes, dropping its opposite.  It used to keep only
 * the bits the old traits shared with the trait, so adding italic to plain
 * traits gave no traits at all.  Changing the size stores the new size as
 * a number, as font descriptors do; it used to be stored as a string.  The
 * font manager needs the backend, so the
 * test skips cleanly without one.
 */
#include "Testing.h"
#include <Foundation/Foundation.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSFontDescriptor.h>
#include <AppKit/NSFontManager.h>
#include <AppKit/NSMenuItem.h>

static NSUInteger
traitsAfterAdding(NSFontManager *fm, NSUInteger trait, NSUInteger traits)
{
  NSMenuItem *sender = AUTORELEASE([[NSMenuItem alloc] init]);
  NSDictionary *attributes = [NSDictionary dictionaryWithObject:
    [NSNumber numberWithUnsignedInt: traits] forKey: NSFontSymbolicTrait];

  [sender setTag: trait];
  [fm addFontTrait: sender];
  return [[[fm convertAttributes: attributes]
    objectForKey: NSFontSymbolicTrait] unsignedIntValue];
}

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSFontManager *fm;

  START_SET("convertAttributes: after addFontTrait:")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("It looks like the GNUstep backend is not available")
  NS_ENDHANDLER

  fm = [NSFontManager sharedFontManager];
  PASS(traitsAfterAdding(fm, NSItalicFontMask, 0) == NSItalicFontMask,
    "adding italic to no traits gives italic");
  PASS(traitsAfterAdding(fm, NSItalicFontMask, NSBoldFontMask)
    == (NSBoldFontMask | NSItalicFontMask),
    "adding italic keeps the other traits");
  PASS(traitsAfterAdding(fm, NSBoldFontMask, NSUnboldFontMask)
    == NSBoldFontMask,
    "adding bold drops unbold");

  {
    NSMenuItem *sender = AUTORELEASE([[NSMenuItem alloc] init]);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:
      [NSNumber numberWithFloat: 12.0] forKey: NSFontSizeAttribute];
    id size;

    [sender setTag: NSSizeUpFontAction];
    [fm modifyFont: sender];
    size = [[fm convertAttributes: attributes]
      objectForKey: NSFontSizeAttribute];
    PASS([size isKindOfClass: [NSNumber class]] && [size floatValue] == 13.0,
      "a larger size is stored as a number");
  }

  END_SET("convertAttributes: after addFontTrait:")

  [pool release];
  return 0;
}
