/* -pathComponentCellAtPoint:withFrame:inView: finds the component under a
   point within the frame, wherever the frame lies, and answers nil outside
   it.  It used to ignore the frame origin, so it found the wrong component
   in an offset frame and raised past the last one. */
#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSPathCell.h>
#import <AppKit/NSPathComponentCell.h>

int main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSRect frame = NSMakeRect(180, 80, 260, 28);
  NSPathCell *pc;
  NSPathComponentCell *a;
  NSPathComponentCell *b;
  NSRect r;

  START_SET("NSPathCell hit testing")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  pc = AUTORELEASE([[NSPathCell alloc] init]);
  a = AUTORELEASE([[NSPathComponentCell alloc] init]);
  b = AUTORELEASE([[NSPathComponentCell alloc] init]);
  [pc setPathComponentCells: [NSArray arrayWithObjects: a, b, nil]];

  r = [pc rectOfPathComponentCell: a withFrame: frame inView: nil];
  PASS([pc pathComponentCellAtPoint: NSMakePoint(NSMidX(r), NSMidY(r))
                          withFrame: frame
                             inView: nil] == a,
    "the middle of the first component finds the first component");
  r = [pc rectOfPathComponentCell: b withFrame: frame inView: nil];
  PASS([pc pathComponentCellAtPoint: NSMakePoint(NSMidX(r), NSMidY(r))
                          withFrame: frame
                             inView: nil] == b,
    "the middle of the last component finds the last component");
  PASS([pc pathComponentCellAtPoint: NSMakePoint(NSMaxX(frame) + 10, 90)
                          withFrame: frame
                             inView: nil] == nil,
    "a point past the frame finds no component");

  END_SET("NSPathCell hit testing")

  [pool release];
  return 0;
}
