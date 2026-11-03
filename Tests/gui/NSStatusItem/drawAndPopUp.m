/* -[NSStatusItem drawStatusBarBackgroundInRect:withHighlight:] fills the
   rectangle with the selected menu item colour when highlighted (white in
   the default theme, so the canvas starts black), and
   -popUpStatusItemMenu: updates the menu, which asks its delegate, before
   popping it up.  Both were empty.  Drawing uses the backend, so the set
   is skipped when the backend is unavailable. */
#include "Testing.h"

#include <math.h>

#include <Foundation/NSAutoreleasePool.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSBitmapImageRep.h>
#include <AppKit/NSColor.h>
#include <AppKit/NSGraphics.h>
#include <AppKit/NSImage.h>
#include <AppKit/NSMenu.h>
#include <AppKit/NSStatusBar.h>
#include <AppKit/NSStatusItem.h>
#include <AppKit/NSView.h>

@interface MenuDelegate : NSObject <NSMenuDelegate>
{
@public
  int needsUpdate;
}
@end
@implementation MenuDelegate
- (void) menuNeedsUpdate: (NSMenu *)menu
{
  needsUpdate++;
}
@end

/* Whether the middle of IMAGE has the colour of EXPECTED.  */
static BOOL
hasColor(NSImage *image, NSColor *expected)
{
  NSBitmapImageRep *rep;
  NSColor *color;

  [image lockFocus];
  rep = AUTORELEASE([[NSBitmapImageRep alloc]
    initWithFocusedViewRect: NSMakeRect(0, 0, 16, 16)]);
  [image unlockFocus];
  if (rep == nil)
    {
      return NO;
    }
  color = [[rep colorAtX: 8 y: 8]
    colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
  expected = [expected colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
  return fabs([color redComponent] - [expected redComponent]) < 0.02
    && fabs([color greenComponent] - [expected greenComponent]) < 0.02
    && fabs([color blueComponent] - [expected blueComponent]) < 0.02;
}

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSStatusBar *bar;
  NSStatusItem *item;
  NSImage *canvas;
  NSMenu *menu;
  MenuDelegate *delegate;

  START_SET("NSStatusItem drawing and menu")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      if ([[localException name] isEqualToString: NSInternalInconsistencyException])
        SKIP("It looks like GNUstep backend is not yet installed")
    }
  NS_ENDHANDLER

  bar = AUTORELEASE([[NSStatusBar alloc] init]);
  item = [bar statusItemWithLength: 88.0];

  canvas = AUTORELEASE([[NSImage alloc] initWithSize: NSMakeSize(16, 16)]);
  [canvas lockFocus];
  [[NSColor blackColor] set];
  NSRectFill(NSMakeRect(0, 0, 16, 16));
  [item drawStatusBarBackgroundInRect: NSMakeRect(0, 0, 16, 16)
			 withHighlight: NO];
  [canvas unlockFocus];
  PASS(hasColor(canvas, [NSColor blackColor]),
    "an unhighlighted background leaves the bar showing");

  [canvas lockFocus];
  [item drawStatusBarBackgroundInRect: NSMakeRect(0, 0, 16, 16)
			 withHighlight: YES];
  [canvas unlockFocus];
  PASS(hasColor(canvas, [NSColor selectedMenuItemColor]),
    "a highlighted background is drawn in the selected menu item colour");

  menu = AUTORELEASE([[NSMenu alloc] initWithTitle: @"Status"]);
  delegate = AUTORELEASE([MenuDelegate new]);
  [menu setDelegate: delegate];
  [item popUpStatusItemMenu: menu];
  PASS(delegate->needsUpdate > 0,
    "popping up the menu asks its delegate to update it");

  END_SET("NSStatusItem drawing and menu")

  [pool release];
  return 0;
}
