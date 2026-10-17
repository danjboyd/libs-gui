#import "Testing.h"
#import <Foundation/NSKeyValueObserving.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSView.h>
#import <AppKit/NSTabView.h>
#import <AppKit/NSTabViewItem.h>
#import <AppKit/NSTabViewController.h>

/* When its tab view selects an item, however that happens, the controller
   is told with -tabView:willSelectTabViewItem: and
   -tabView:didSelectTabViewItem:; it tells observers of
   selectedTabViewItemIndex and propagates the item's label as its title.
   Both methods were empty, so selecting an item through the tab view left
   the title alone and observers of the index were never told.  Needs a
   window server, so the set skips cleanly without one. */

@interface Observer : NSObject
{
@public
  int prior;
  int changes;
  NSInteger seen;
}
@end

@implementation Observer
- (void) observeValueForKeyPath: (NSString *)keyPath
		       ofObject: (id)object
			 change: (NSDictionary *)change
			context: (void *)context
{
  if ([[change objectForKey: NSKeyValueChangeNotificationIsPriorKey] boolValue])
    {
      prior++;
    }
  else
    {
      changes++;
      seen = [[change objectForKey: NSKeyValueChangeNewKey] integerValue];
    }
}
@end

static NSTabViewItem *
makeItem(NSString *label)
{
  NSTabViewItem *item = AUTORELEASE([[NSTabViewItem alloc]
    initWithIdentifier: label]);

  [item setView: AUTORELEASE([[NSView alloc]
    initWithFrame: NSMakeRect(0, 0, 100, 80)])];
  [item setLabel: label];
  return item;
}

int
main(int argc, const char **argv)
{
  START_SET("NSTabViewController tab view selection")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSTabViewController *tc = AUTORELEASE([[NSTabViewController alloc] init]);
      NSTabView *tv = AUTORELEASE([[NSTabView alloc]
        initWithFrame: NSMakeRect(0, 0, 220, 160)]);
      Observer *o = AUTORELEASE([Observer new]);

      [tc setTabView: tv];
      [tc addTabViewItem: makeItem(@"Alpha")];
      [tc addTabViewItem: makeItem(@"Beta")];
      [tc setSelectedTabViewItemIndex: 0];
      [tc addObserver: o
	   forKeyPath: @"selectedTabViewItemIndex"
	      options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior
	      context: NULL];

      [tv selectTabViewItemAtIndex: 1];
      PASS_EQUAL([tc title], @"Beta",
	"selecting through the tab view propagates the label as the title");
      PASS(o->prior == 1 && o->changes == 1,
	"observers of the selected index are told once before and once after");
      PASS(o->seen == 1, "observers are told the new index");

      [tc setSelectedTabViewItemIndex: 0];
      PASS_EQUAL([tc title], @"Alpha",
	"selecting through the controller propagates the label");
      PASS(o->prior == 2 && o->changes == 2 && o->seen == 0,
	"selecting through the controller tells observers once");

      [tc setCanPropagateSelectedChildViewControllerTitle: NO];
      [tv selectTabViewItemAtIndex: 1];
      PASS_EQUAL([tc title], @"Alpha",
	"the title is left alone when propagation is off");

      [tc removeObserver: o forKeyPath: @"selectedTabViewItemIndex"];
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
  NS_ENDHANDLER

  END_SET("NSTabViewController tab view selection")
  return 0;
}
