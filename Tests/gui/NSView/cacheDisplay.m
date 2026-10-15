/* -cacheDisplayInRect:toBitmapImageRep: draws the view and its subviews
   into the bitmap with -drawRect:, as Cocoa does, whether or not the
   window has been displayed and whether or not the view is in a window.
   It used to copy what the window showed, so a view that had not been
   displayed came back as background and -drawRect: was never called. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

/* Fills its bounds with one colour, and a 10x10 square at the bounds
   origin with another, counting its -drawRect: calls. */
@interface Swatch : NSView
{
@public
  NSColor	*fill;
  NSColor	*corner;
  BOOL		flipped;
  int		drawCalls;
}
@end

@implementation Swatch
- (BOOL) isFlipped
{
  return flipped;
}
- (void) drawRect: (NSRect)r
{
  drawCalls++;
  [fill set];
  NSRectFill([self bounds]);
  if (corner != nil)
    {
      [corner set];
      NSRectFill(NSMakeRect(0, 0, 10, 10));
    }
}
@end

static Swatch *
swatch(NSRect frame, NSColor *fill, NSColor *corner)
{
  Swatch	*v = AUTORELEASE([[Swatch alloc] initWithFrame: frame]);

  v->fill = fill;
  v->corner = corner;
  return v;
}

/* Is the pixel at x, y (from the top left) close to the colour? */
static BOOL
pixelIs(NSBitmapImageRep *rep, NSInteger x, NSInteger y, NSColor *want)
{
  NSColor	*c = [[rep colorAtX: x y: y]
    colorUsingColorSpaceName: NSCalibratedRGBColorSpace];

  want = [want colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
  return c != nil && [c alphaComponent] > 0.9
    && fabs([c redComponent] - [want redComponent]) < 0.1
    && fabs([c greenComponent] - [want greenComponent]) < 0.1
    && fabs([c blueComponent] - [want blueComponent]) < 0.1;
}

int main(int argc, const char **argv)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSWindow		*w = nil;

  START_SET("NSView cacheDisplayInRect:toBitmapImageRep:")

  NS_DURING
    {
      [NSApplication sharedApplication];
      w = AUTORELEASE([[NSWindow alloc]
        initWithContentRect: NSMakeRect(0, 0, 100, 100)
                  styleMask: NSBorderlessWindowMask
                    backing: NSBackingStoreBuffered
                      defer: NO]);
    }
  NS_HANDLER
    SKIP("No backend or display available to draw with")
  NS_ENDHANDLER

  NSColor		*red = [NSColor redColor];
  NSColor		*green = [NSColor greenColor];
  NSColor		*blue = [NSColor blueColor];
  NSBitmapImageRep	*rep;
  Swatch		*v;
  Swatch		*sub;

  /* A view in a window that has never been displayed. */
  v = swatch(NSMakeRect(0, 0, 40, 40), red, blue);
  [[w contentView] addSubview: v];
  rep = [v bitmapImageRepForCachingDisplayInRect: [v bounds]];
  PASS(rep != nil && [rep pixelsWide] == 40 && [rep pixelsHigh] == 40,
    "the caching bitmap has the size of the rectangle");
  [v cacheDisplayInRect: [v bounds] toBitmapImageRep: rep];
  PASS(v->drawCalls >= 1, "caching the display calls -drawRect:");
  PASS(pixelIs(rep, 30, 5, red), "the view's fill is in the bitmap");
  PASS(pixelIs(rep, 2, 37, blue),
    "an unflipped view's origin is at the bottom left of the bitmap");

  /* A flipped view puts its origin at the top left. */
  v->flipped = YES;
  rep = [v bitmapImageRepForCachingDisplayInRect: [v bounds]];
  [v cacheDisplayInRect: [v bounds] toBitmapImageRep: rep];
  PASS(pixelIs(rep, 2, 2, blue) && pixelIs(rep, 2, 37, red),
    "a flipped view's origin is at the top left of the bitmap");
  v->flipped = NO;

  /* Subviews are drawn over the view, where they are. */
  sub = swatch(NSMakeRect(20, 20, 20, 20), green, nil);
  [v addSubview: sub];
  rep = [v bitmapImageRepForCachingDisplayInRect: [v bounds]];
  [v cacheDisplayInRect: [v bounds] toBitmapImageRep: rep];
  PASS(sub->drawCalls >= 1 && pixelIs(rep, 30, 5, green)
    && pixelIs(rep, 15, 30, red), "subviews are drawn into the bitmap");

  [sub setHidden: YES];
  rep = [v bitmapImageRepForCachingDisplayInRect: [v bounds]];
  [v cacheDisplayInRect: [v bounds] toBitmapImageRep: rep];
  PASS(pixelIs(rep, 30, 5, red), "hidden subviews are not drawn");
  [sub setHidden: NO];

  /* Part of a view fills the bitmap. */
  rep = [v bitmapImageRepForCachingDisplayInRect: NSMakeRect(0, 0, 20, 20)];
  [v cacheDisplayInRect: NSMakeRect(0, 0, 20, 20) toBitmapImageRep: rep];
  PASS([rep pixelsWide] == 20 && pixelIs(rep, 2, 17, blue)
    && pixelIs(rep, 17, 2, red), "a part of the view fills the bitmap");

  /* A view outside any window. */
  [v removeFromSuperview];
  v->drawCalls = 0;
  sub->drawCalls = 0;
  rep = [v bitmapImageRepForCachingDisplayInRect: [v bounds]];
  [v cacheDisplayInRect: [v bounds] toBitmapImageRep: rep];
  PASS(v->drawCalls >= 1 && sub->drawCalls >= 1
    && pixelIs(rep, 15, 30, red) && pixelIs(rep, 30, 5, green),
    "a view outside a window is drawn");

  END_SET("NSView cacheDisplayInRect:toBitmapImageRep:")

  [arp release];
  return 0;
}
