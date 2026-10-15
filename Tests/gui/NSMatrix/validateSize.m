/* -setValidateSize: NO makes a matrix compute its cell size again from its
   cells, and resize to it; YES keeps the cell size.  It did nothing.  The
   cells here answer a fixed size, so no font is measured, but building
   the matrix keeps the usual backend skip guard. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSActionCell.h>
#include <AppKit/NSMatrix.h>

@interface FixedSizeCell : NSActionCell
@end

@implementation FixedSizeCell
- (NSSize) cellSize
{
  return NSMakeSize(70, 30);
}
@end

int
main(int argc, const char **argv)
{
  NSMatrix *m;

  START_SET("NSMatrix setValidateSize:")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      m = AUTORELEASE([[NSMatrix alloc]
        initWithFrame: NSMakeRect(0, 0, 100, 100)
                 mode: NSRadioModeMatrix
            prototype: AUTORELEASE([[FixedSizeCell alloc] initTextCell: @""])
         numberOfRows: 2
      numberOfColumns: 2]);
      [m setIntercellSpacing: NSMakeSize(2, 4)];
      [m setCellSize: NSMakeSize(10, 10)];

      [m setValidateSize: YES];
      PASS(NSEqualSizes([m cellSize], NSMakeSize(10, 10)),
        "validating the size keeps the cell size");

      [m setValidateSize: NO];
      PASS(NSEqualSizes([m cellSize], NSMakeSize(70, 30)),
        "not validating the size computes it from the cells");
      PASS(NSEqualSizes([m frame].size, NSMakeSize(142, 64)),
        "and resizes the matrix to it");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
  NS_ENDHANDLER

  END_SET("NSMatrix setValidateSize:")
  return 0;
}
