/* NSView keeps the values an assistive technology would ask for. */
#import "Testing.h"

#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSGeometry.h>

#import <AppKit/NSAccessibilityConstants.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSView.h>

@interface Labelled : NSView
@end

@implementation Labelled
- (NSString *) accessibilityLabel
{
  return @"Swatch";
}
- (BOOL) isAccessibilityElement
{
  return YES;
}
@end

int
main(int argc, char **argv)
{
  START_SET("NSView accessibility properties")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSView *v = AUTORELEASE([[NSView alloc]
        initWithFrame: NSMakeRect(0, 0, 10, 10)]);
      NSView *o = AUTORELEASE([[Labelled alloc]
        initWithFrame: NSMakeRect(0, 0, 10, 10)]);

      PASS([v accessibilityLabel] == nil, "there is no label by default");
      PASS([v isAccessibilityElement] == NO, "a view isn't an element by default");
      PASS_EQUAL([v accessibilityRole], NSAccessibilityUnknownRole,
        "the default role is unknown");

      [v setAccessibilityLabel: @"Save"];
      PASS_EQUAL([v accessibilityLabel], @"Save", "the label round-trips");
      [v setAccessibilityLabel: nil];
      PASS([v accessibilityLabel] == nil, "the label can be cleared");
      [v setAccessibilityRole: NSAccessibilityButtonRole];
      PASS_EQUAL([v accessibilityRole], NSAccessibilityButtonRole,
        "the role round-trips");
      [v setAccessibilityElement: YES];
      PASS([v isAccessibilityElement] == YES, "the element flag round-trips");

      PASS_EQUAL([o accessibilityLabel], @"Swatch", "a subclass can override");
      PASS([o isAccessibilityElement] == YES, "a subclass can be an element");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSView accessibility properties")

  return 0;
}
