/* A percentage value of an NSTextBlock is a share, out of 100, of the
   enclosing rectangle.  The layer widths used to be scaled by the value
   type instead of the value, so every percentage padding, border or margin
   added the whole enclosing size, and the block dimensions were scaled by
   the value without dividing it by 100. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSTextTable.h>

int
main(int argc, char **argv)
{
  CREATE_AUTORELEASE_POOL(arp);
  NSTextBlock *block;
  NSRect r;

  START_SET("NSTextBlock percentage")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  block = AUTORELEASE([[NSTextBlock alloc] init]);
  [block setWidth: 10.0 type: NSTextBlockPercentageValueType
         forLayer: NSTextBlockPadding];
  r = [block boundsRectForContentRect: NSMakeRect(50, 30, 100, 40)
                               inRect: NSMakeRect(0, 0, 200, 100)
                        textContainer: nil
                       characterRange: NSMakeRange(0, 0)];
  PASS(NSEqualRects(r, NSMakeRect(30, 20, 140, 60)),
       "a 10%% padding adds a tenth of the enclosing width and height");

  block = AUTORELEASE([[NSTextBlock alloc] init]);
  [block setValue: 50.0 type: NSTextBlockPercentageValueType
     forDimension: NSTextBlockWidth];
  [block setValue: 20.0 type: NSTextBlockPercentageValueType
     forDimension: NSTextBlockHeight];
  [block setValue: 100.0 type: NSTextBlockPercentageValueType
     forDimension: NSTextBlockMaximumWidth];
  [block setValue: 100.0 type: NSTextBlockPercentageValueType
     forDimension: NSTextBlockMaximumHeight];
  r = [block rectForLayoutAtPoint: NSMakePoint(0, 0)
                           inRect: NSMakeRect(0, 0, 200, 100)
                    textContainer: nil
                   characterRange: NSMakeRange(0, 0)];
  PASS(NSEqualRects(r, NSMakeRect(0, 0, 100, 20)),
       "percentage dimensions are shares of the enclosing size");

  END_SET("NSTextBlock percentage")

  DESTROY(arp);
  return 0;
}
