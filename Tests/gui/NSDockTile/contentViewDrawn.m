/* A dock tile draws its content view, with the view's subviews, instead of
 * the application icon.  The view was only drawn when it could draw in a
 * window, which a dock tile's content view never is, so the tile always
 * showed the application icon.  The pixels are read back, so the set skips
 * when the backend cannot draw offscreen.
 */
#import <Foundation/NSObject.h>
#import "Testing.h"
#import "../GSDrawTest.h"

#import <AppKit/AppKit.h>
#import <AppKit/NSDockTile.h>

@interface NSDockTile (Drawing)
- (void) draw;
@end

@interface FillView : NSView
{
@public
  NSColor *color;
}
@end

@implementation FillView
- (void) drawRect: (NSRect)r
{
  [color set];
  NSRectFill([self bounds]);
}
@end

int
main(int argc, const char **argv)
{
  START_SET("NSDockTile content view drawing")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      SKIP("It looks like GNUstep backend is not yet installed")
    }
  NS_ENDHANDLER

  if (NO == GSCanDrawOffscreen())
    {
      SKIP("the installed backend does not draw offscreen")
    }

  NSDockTile *tile = AUTORELEASE([[NSDockTile alloc] init]);
  NSSize size = [tile size];
  int w = (int)size.width, h = (int)size.height;
  FillView *content;
  FillView *child;
  NSImage *img;
  NSBitmapImageRep *rep;

  content = AUTORELEASE([[FillView alloc]
    initWithFrame: NSMakeRect(0, 0, w, h)]);
  content->color = [NSColor colorWithDeviceRed: 0 green: 0 blue: 1 alpha: 1];
  child = AUTORELEASE([[FillView alloc]
    initWithFrame: NSMakeRect(0, 0, w / 2, h / 2)]);
  child->color = [NSColor colorWithDeviceRed: 1 green: 0 blue: 0 alpha: 1];
  [content addSubview: child];
  [tile setContentView: content];

  img = GSDrawBegin(w, h);
  [tile draw];
  rep = GSDrawEnd(img, w, h);
  PASS(rep != nil && GSPixelIs(rep, w - 2, 1, 0, 0, 255),
    "the content view is drawn");
  PASS(rep != nil && GSPixelIs(rep, 1, h - 2, 255, 0, 0),
    "the content view's subviews are drawn in place");

  END_SET("NSDockTile content view drawing")
  return 0;
}
