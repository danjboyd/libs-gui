/* -colorUsingType: converts a catalog colour to the component based
 * colour its list holds, and answers nil for a conversion that cannot be
 * made.  A catalog colour answered nil for the component based type.
 * The system colour list is made in code, so no backend is needed.
 */
#include "Testing.h"
#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSColor.h>
#include <AppKit/NSColorList.h>
#include <AppKit/NSGraphics.h>

int main(int argc, char **argv)
{
  NSAutoreleasePool	*pool = [NSAutoreleasePool new];
  NSColor		*named;
  NSColor		*real;
  NSColor		*rgb;

  START_SET("NSColor colorUsingType:")
    named = [NSColor colorWithCatalogName: @"System"
                                colorName: @"controlColor"];
    PASS(named != nil && [named type] == NSColorTypeCatalog,
      "a system colour is a catalog colour");

    real = [named colorUsingType: NSColorTypeComponentBased];
    PASS(real != nil && [real type] == NSColorTypeComponentBased,
      "it converts to a component based colour");
    PASS([[real colorUsingColorSpaceName: NSCalibratedRGBColorSpace]
      isEqual: [named colorUsingColorSpaceName: NSCalibratedRGBColorSpace]],
      "the component based colour has the catalog colour's value");
    PASS([named colorUsingType: NSColorTypeCatalog] == named,
      "a catalog colour is its own catalog colour");
    PASS([named colorUsingType: NSColorTypePattern] == nil,
      "a catalog colour does not convert to a pattern");

    rgb = [NSColor colorWithCalibratedRed: 0.2 green: 0.4 blue: 0.6 alpha: 1.0];
    PASS([rgb colorUsingType: NSColorTypeComponentBased] == rgb,
      "a component based colour is its own component based colour");
    PASS([rgb colorUsingType: NSColorTypeCatalog] == nil,
      "a component based colour does not convert to a catalog colour");
  END_SET("NSColor colorUsingType:")

  [pool release];
  return 0;
}
