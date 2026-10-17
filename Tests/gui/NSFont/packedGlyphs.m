/* -[NSFont getAdvancements:forPackedGlyphs:count:] answers the
 * advancements of glyphs packed by NSConvertGlyphsToPackedGlyphs() in the
 * font's packing.  It used to leave the array alone.
 *
 * The glyphs are taken from a layout manager, as in glyphmetrics.m.  The
 * set skips when there is no backend or it reports no metrics.
 */
#import <Foundation/NSObject.h>
#import "Testing.h"

#import <AppKit/AppKit.h>

static NSGlyph
glyphInFont(NSFont *font, NSString *string, unsigned index)
{
  NSTextStorage *storage;
  NSLayoutManager *layout;
  NSTextContainer *container;
  NSGlyph glyph;

  storage = [[NSTextStorage alloc] initWithString: string];
  [storage addAttribute: NSFontAttributeName
                  value: font
                  range: NSMakeRange(0, [string length])];
  layout = [[NSLayoutManager alloc] init];
  container = [[NSTextContainer alloc]
    initWithContainerSize: NSMakeSize(1000, 1000)];
  [layout addTextContainer: container];
  [storage addLayoutManager: layout];

  glyph = ([layout numberOfGlyphs] > index)
    ? [layout glyphAtIndex: index] : NSNullGlyph;

  RELEASE(container);
  RELEASE(layout);
  RELEASE(storage);
  return glyph;
}

int
main(int argc, char **argv)
{
  START_SET("NSFont packed glyphs")

  NSFont *f;
  NSGlyph glyphs[3];
  char packed[1 + 3 * 4];
  NSSize advancements[3];
  int i;

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      SKIP("It looks like GNUstep backend is not yet installed")
    }
  NS_ENDHANDLER

  f = [NSFont systemFontOfSize: 14];
  if (nil == f)
    {
      SKIP("the installed backend builds no font")
    }
  if ([f maximumAdvancement].width <= 0.0)
    {
      SKIP("the installed backend reports no font metrics")
    }

  glyphs[0] = glyphInFont(f, @"Wi.", 0);
  glyphs[1] = glyphInFont(f, @"Wi.", 1);
  glyphs[2] = glyphInFont(f, @"Wi.", 2);
  NSConvertGlyphsToPackedGlyphs(glyphs, 3, [f glyphPacking], packed);
  for (i = 0; i < 3; i++)
    {
      advancements[i] = NSMakeSize(-1, -1);
    }
  [f getAdvancements: advancements forPackedGlyphs: packed count: 3];
  PASS(NSEqualSizes(advancements[0], [f advancementForGlyph: glyphs[0]])
    && NSEqualSizes(advancements[1], [f advancementForGlyph: glyphs[1]])
    && NSEqualSizes(advancements[2], [f advancementForGlyph: glyphs[2]]),
    "the advancements of packed glyphs are those of the glyphs");
  PASS(advancements[0].width > advancements[1].width,
    "the packed glyphs are read in order");

  END_SET("NSFont packed glyphs")
  return 0;
}
