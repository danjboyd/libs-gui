/* A constraint answers anchors for its first and second item and
   attribute, so a constraint built from two anchors answers anchors of the
   same items and attributes.  Both used to answer nil.  Views and anchors
   are plain objects here and need no backend. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSLayoutAnchor.h>
#import <AppKit/NSLayoutConstraint.h>
#import <AppKit/NSView.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSView *a;
  NSView *b;
  NSLayoutConstraint *c;

  START_SET("NSLayoutConstraint anchors")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  a = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(0, 0, 10, 10)]);
  b = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(0, 0, 10, 10)]);

  c = [[a leadingAnchor] constraintEqualToAnchor: [b trailingAnchor]];
  PASS([[c firstAnchor] item] == a
    && [[c firstAnchor] isKindOfClass: [NSLayoutXAxisAnchor class]],
    "the first anchor is the leading anchor's item and kind");
  PASS([[c secondAnchor] item] == b,
    "the second anchor is the trailing anchor's item");

  c = [[a widthAnchor] constraintEqualToConstant: 20];
  PASS([[c firstAnchor] isKindOfClass: [NSLayoutDimension class]],
    "the first anchor of a width constraint is a dimension");
  PASS([c secondAnchor] == nil,
    "a constraint to a constant has no second anchor");

  END_SET("NSLayoutConstraint anchors")

  [pool release];
  return 0;
}
