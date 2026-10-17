/* The three -[NSFont positionOfGlyph:...struckOver...] methods answer the
 * origin at which a glyph is centred over a rectangle or over another
 * glyph's bounding box, and say the metrics exist.  They used to answer the
 * zero point and say there were no metrics.
 *
 * The glyphs are taken from a layout manager, as in glyphmetrics.m.  The
 * set skips when there is no backend or it reports no metrics.
 */
#import <Foundation/NSObject.h>
#import "Testing.h"

#import <AppKit/AppKit.h>
#include <math.h>

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

static BOOL
nearly(CGFloat a, CGFloat b)
{
  return fabs((double)(a - b)) < 0.01 ? YES : NO;
}

int
main(int argc, char **argv)
{
  START_SET("NSFont struck over glyphs")

  NSFont *f;
  NSGlyph baseGlyph;
  NSGlyph mark;
  NSRect rect = NSMakeRect(10, 20, 30, 40);
  NSRect gb;
  NSRect base;
  NSPoint p;
  BOOL flag;

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

  baseGlyph = glyphInFont(f, @"W.", 0);
  mark = glyphInFont(f, @"W.", 1);
  gb = [f boundingRectForGlyph: mark];

  p = [f positionOfGlyph: mark forCharacter: '.' struckOverRect: rect];
  PASS(nearly(p.x + NSMidX(gb), NSMidX(rect))
    && nearly(p.y + NSMidY(gb), NSMidY(rect)),
    "a glyph struck over a rectangle is centred on it");

  flag = NO;
  p = [f positionOfGlyph: mark struckOverRect: rect metricsExist: &flag];
  PASS(flag && nearly(p.x + NSMidX(gb), NSMidX(rect))
    && nearly(p.y + NSMidY(gb), NSMidY(rect)),
    "positionOfGlyph:struckOverRect:metricsExist: centres the glyph");

  flag = NO;
  base = [f boundingRectForGlyph: baseGlyph];
  p = [f positionOfGlyph: mark struckOverGlyph: baseGlyph metricsExist: &flag];
  PASS(flag && nearly(p.x + NSMidX(gb), NSMidX(base))
    && nearly(p.y + NSMidY(gb), NSMidY(base)),
    "a glyph struck over another is centred on its bounding box");

  END_SET("NSFont struck over glyphs")
  return 0;
}
