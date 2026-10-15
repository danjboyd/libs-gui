#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSGeometry.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSControl.h>
#import <AppKit/NSActionCell.h>

/* -[NSControl sizeThatFits:] answers the size its cell computes for a
   rectangle of the proposed size.  It answered the proposed size.  The
   cell here records the bounds it is given and answers a fixed size, so
   no font is measured.  Views need the usual backend guard. */

@interface FixedSizeCell : NSActionCell
{
@public
  NSRect bounds;
}
@end

@implementation FixedSizeCell
- (NSSize) cellSizeForBounds: (NSRect)aRect
{
  bounds = aRect;
  return NSMakeSize(42, 17);
}
@end

int
main(int argc, const char **argv)
{
  START_SET("NSControl sizeThatFits:")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSControl *c = AUTORELEASE([[NSControl alloc]
        initWithFrame: NSMakeRect(0, 0, 100, 20)]);
      FixedSizeCell *cell = AUTORELEASE([[FixedSizeCell alloc] init]);
      NSSize s;

      [c setCell: cell];
      s = [c sizeThatFits: NSMakeSize(300, 50)];
      PASS(NSEqualSizes(s, NSMakeSize(42, 17)),
        "the size comes from the cell");
      PASS(NSEqualRects(cell->bounds, NSMakeRect(0, 0, 300, 50)),
        "the cell is asked about the proposed size");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
  NS_ENDHANDLER

  END_SET("NSControl sizeThatFits:")
  return 0;
}
