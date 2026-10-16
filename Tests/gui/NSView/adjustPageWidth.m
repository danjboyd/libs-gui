/* -adjustPageWidthNew:left:right:limit: asks each subview to adjust the
   page width, with the edges converted to the subview's coordinates, and
   answers the right edge the subview chose.  It used to ask the subviews
   -adjustPageHeightNew:top:bottom:limit: instead. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSView.h>

@interface PaginatingView : NSView
{
@public
  int widthCalls;
  int heightCalls;
  CGFloat left;
  CGFloat right;
}
@end

@implementation PaginatingView
- (void) adjustPageWidthNew: (CGFloat *)newRight
                       left: (CGFloat)oldLeft
                      right: (CGFloat)oldRight
                      limit: (CGFloat)rightLimit
{
  widthCalls++;
  left = oldLeft;
  right = oldRight;
  *newRight = oldRight - 10;
}

- (void) adjustPageHeightNew: (CGFloat *)newBottom
                         top: (CGFloat)oldTop
                      bottom: (CGFloat)oldBottom
                       limit: (CGFloat)bottomLimit
{
  heightCalls++;
  *newBottom = oldBottom;
}
@end

int main(int argc, char **argv)
{
  CREATE_AUTORELEASE_POOL(arp);
  NSView *outer;
  PaginatingView *inner;
  CGFloat newRight = 0;

  START_SET("NSView adjustPageWidth")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  outer = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(0, 0, 400, 400)]);
  inner = AUTORELEASE([[PaginatingView alloc]
    initWithFrame: NSMakeRect(50, 0, 300, 400)]);
  [outer addSubview: inner];

  [outer adjustPageWidthNew: &newRight left: 100 right: 200 limit: 150];

  PASS(inner->widthCalls == 1 && inner->heightCalls == 0,
       "the subview is asked to adjust the page width");
  PASS(inner->left == 50 && inner->right == 150,
       "the subview gets the edges in its own coordinates");
  PASS(newRight == 190, "the answer is the subview's right edge");

  END_SET("NSView adjustPageWidth")

  DESTROY(arp);
  return 0;
}
