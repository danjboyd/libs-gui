/* The NSTableRowView drawing methods paint the row's background colour, its
 * selection, a separator along its bottom edge and the frame of a drop
 * target.  They used to draw nothing.  The pixels are read back, so the set
 * skips when the backend cannot draw offscreen.
 */
#import <Foundation/NSObject.h>
#import "Testing.h"
#import "../GSDrawTest.h"

#import <AppKit/AppKit.h>
#import <AppKit/NSTableRowView.h>

static BOOL
isWhite(NSBitmapImageRep *rep, int x, int y)
{
  return rep != nil && GSPixelIs(rep, x, y, 255, 255, 255);
}

int
main(int argc, const char **argv)
{
  START_SET("NSTableRowView drawing")

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

  int w = 20, h = 10;
  NSRect all = NSMakeRect(0, 0, w, h);
  NSTableRowView *row;
  NSImage *img;
  NSBitmapImageRep *rep;

  row = AUTORELEASE([[NSTableRowView alloc] initWithFrame: all]);

  img = GSDrawBeginWhite(w, h);
  [row drawBackgroundInRect: all];
  [row drawSelectionInRect: all];
  [row drawDraggingDestinationFeedbackInRect: all];
  rep = GSDrawEnd(img, w, h);
  PASS(isWhite(rep, 10, 5),
    "a plain row draws no background, selection or drop feedback");

  [row setBackgroundColor:
    [NSColor colorWithDeviceRed: 0.0 green: 0.0 blue: 1.0 alpha: 1.0]];
  img = GSDrawBeginWhite(w, h);
  [row drawBackgroundInRect: all];
  rep = GSDrawEnd(img, w, h);
  PASS(rep != nil && GSPixelIs(rep, 10, 5, 0, 0, 255),
    "the background is filled with the background colour");

  [row setSelected: YES];
  [row setEmphasized: YES];
  img = GSDrawBeginWhite(w, h);
  [row drawSelectionInRect: all];
  rep = GSDrawEnd(img, w, h);
  PASS(!isWhite(rep, 10, 5), "a selected row draws its selection");

  img = GSDrawBeginWhite(w, h);
  [row drawSeparatorInRect: all];
  rep = GSDrawEnd(img, w, h);
  PASS(!isWhite(rep, 10, h - 1) && isWhite(rep, 10, 5),
    "the separator is drawn along the bottom edge only");

  [row setTargetForDropOperation: YES];
  img = GSDrawBeginWhite(w, h);
  [row drawDraggingDestinationFeedbackInRect: all];
  rep = GSDrawEnd(img, w, h);
  PASS(!isWhite(rep, 0, 5) && isWhite(rep, 10, 5),
    "a drop target is framed");

  END_SET("NSTableRowView drawing")
  return 0;
}
