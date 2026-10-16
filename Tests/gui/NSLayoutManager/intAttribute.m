/* -setIntAttribute:value:forGlyphAtIndex: stores a glyph attribute and
   -intAttribute:forGlyphAtIndex: answers it.  Both tested the glyph's
   offset in its run the wrong way round, so a glyph in the run was never
   stored or read.  Generating glyphs needs fonts, so the set is skipped
   when the backend is unavailable. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSGlyphGenerator.h>
#include <AppKit/NSLayoutManager.h>
#include <AppKit/NSTextStorage.h>
#include <GNUstepGUI/GSLayoutManager.h>

int main()
{
  CREATE_AUTORELEASE_POOL(arp);
  NSLayoutManager *lm;
  NSTextStorage *ts;

  START_SET("NSLayoutManager intAttribute")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  ts = AUTORELEASE([[NSTextStorage alloc] initWithString: @"abc"]);
  lm = AUTORELEASE([[NSLayoutManager alloc] init]);
  [ts addLayoutManager: lm];
  PASS([lm numberOfGlyphs] == 3, "the text has three glyphs");

  [lm setIntAttribute: NSGlyphAttributeSoft value: 1 forGlyphAtIndex: 1];
  [lm setIntAttribute: NSGlyphAttributeBidiLevel value: 5 forGlyphAtIndex: 2];
  PASS([lm intAttribute: NSGlyphAttributeSoft forGlyphAtIndex: 1] == 1,
       "a glyph keeps the soft attribute it is given");
  PASS([lm intAttribute: NSGlyphAttributeBidiLevel forGlyphAtIndex: 2] == 5,
       "a glyph keeps the bidi level it is given");
  PASS([lm intAttribute: NSGlyphAttributeSoft forGlyphAtIndex: 0] == 0,
       "another glyph keeps its own attribute");

  END_SET("NSLayoutManager intAttribute")

  DESTROY(arp);
  return 0;
}
