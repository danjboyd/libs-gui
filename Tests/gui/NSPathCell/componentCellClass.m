/* An NSPathCell makes its component cells from the class answered by
   +pathComponentCellClass, so an application can set its own, and so does
   an NSPathControl given path items.  The cells used to be
   NSPathComponentCell whatever the class was set to. */
#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSURL.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSPathCell.h>
#import <AppKit/NSPathComponentCell.h>
#import <AppKit/NSPathControl.h>
#import <AppKit/NSPathControlItem.h>

@interface MyComponentCell : NSPathComponentCell
@end

@implementation MyComponentCell
@end

int main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSPathCell *pc;
  NSArray *cells;

  START_SET("NSPathCell pathComponentCellClass")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  PASS([NSPathCell pathComponentCellClass] == [NSPathComponentCell class],
    "the component cell class is NSPathComponentCell by default");

  [NSPathCell setPathComponentCellClass: [MyComponentCell class]];
  PASS([NSPathCell pathComponentCellClass] == [MyComponentCell class],
    "the component cell class can be set");

  pc = AUTORELEASE([[NSPathCell alloc] init]);
  [pc setURL: [NSURL fileURLWithPath: @"/tmp"]];
  cells = [pc pathComponentCells];
  PASS([cells count] > 0
    && [[cells objectAtIndex: 0] isKindOfClass: [MyComponentCell class]],
    "the component cells are made from the class set");

  {
    NSPathControl *control = AUTORELEASE([[NSPathControl alloc]
      initWithFrame: NSMakeRect(0, 0, 200, 24)]);
    NSPathControlItem *item = AUTORELEASE([[NSPathControlItem alloc] init]);

    [item setURL: [NSURL fileURLWithPath: @"/tmp"]];
    [control setPathItems: [NSArray arrayWithObject: item]];
    cells = [[control cell] pathComponentCells];
    PASS([cells count] == 1
      && [[cells objectAtIndex: 0] isKindOfClass: [MyComponentCell class]],
      "a path control makes the cells for its items from the class set");
  }

  [NSPathCell setPathComponentCellClass: [NSPathComponentCell class]];

  END_SET("NSPathCell pathComponentCellClass")

  [pool release];
  return 0;
}
