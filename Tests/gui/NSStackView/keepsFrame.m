/* Laying out a stack view places its views within it and leaves its own
   frame alone.  The layout pass used to grow the stack view by its spacing
   on every pass, so a stack view was larger than its given frame straight
   out of -initWithFrame:, and grew again with each mutation. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSStackView.h>

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSRect frame = NSMakeRect(0, 0, 220, 80);
  NSStackView *sv;
  NSView *v;

  START_SET("NSStackView keepsFrame")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  sv = AUTORELEASE([[NSStackView alloc] initWithFrame: frame]);
  PASS(NSEqualRects([sv frame], frame),
    "a new stack view keeps the frame it was given");

  [sv setSpacing: 12.0];
  [sv setSpacing: 4.0];
  PASS(NSEqualRects([sv frame], frame),
    "changing the spacing keeps the frame");

  v = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(0, 0, 20, 20)]);
  [sv addArrangedSubview: v];
  PASS(NSEqualRects([sv frame], frame),
    "adding an arranged subview keeps the frame");

  [sv setOrientation: NSUserInterfaceLayoutOrientationVertical];
  PASS(NSEqualRects([sv frame], frame),
    "a vertical layout keeps the frame");
  PASS(NSMaxY([v frame]) == NSHeight(frame),
    "a vertical layout starts at the top of the stack view");

  END_SET("NSStackView keepsFrame")

  [pool release];
  return 0;
}
