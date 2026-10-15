#import "Testing.h"
#import <AppKit/NSApplication.h>
#import <AppKit/NSView.h>
#import <AppKit/NSViewController.h>
#import <AppKit/NSTabView.h>
#import <AppKit/NSTabViewItem.h>
#import <AppKit/NSTabViewController.h>
#import <AppKit/NSToolbarItem.h>

/* As the delegate of a toolbar, NSTabViewController offers one item per
   tab view item, with its identifier and label, and the item selects the
   tab.  Tabs without a distinct string identifier, such as those made with
   +tabViewItemWithViewController:, get one made for them.  The identifier
   lists were empty and no item was made.  Needs a
   window server, so the set skips cleanly without one. */

static NSTabViewItem *
anItem(NSString *ident)
{
  NSTabViewItem *item = AUTORELEASE([[NSTabViewItem alloc]
    initWithIdentifier: ident]);
  NSViewController *vc = AUTORELEASE([[NSViewController alloc] init]);

  [vc setView: AUTORELEASE([[NSView alloc]
    initWithFrame: NSMakeRect(0, 0, 100, 80)])];
  [item setViewController: vc];
  [item setLabel: [ident uppercaseString]];
  return item;
}

int
main(int argc, const char **argv)
{
  START_SET("NSTabViewController toolbar items")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSTabViewController *tc = AUTORELEASE([[NSTabViewController alloc] init]);
      NSArray *expected = [NSArray arrayWithObjects: @"one", @"two", nil];
      NSToolbarItem *item;

      [tc addTabViewItem: anItem(@"one")];
      [tc addTabViewItem: anItem(@"two")];

      PASS_EQUAL([tc toolbarAllowedItemIdentifiers: nil], expected,
        "the allowed identifiers are the tab identifiers");
      PASS_EQUAL([tc toolbarSelectableItemIdentifiers: nil], expected,
        "the selectable identifiers are the tab identifiers");

      item = [tc toolbar: nil itemForItemIdentifier: @"two"
        willBeInsertedIntoToolbar: YES];
      PASS(item != nil && [[item itemIdentifier] isEqual: @"two"]
        && [[item label] isEqual: @"TWO"],
        "a toolbar item is made for a tab, with its label");
      PASS([tc toolbar: nil itemForItemIdentifier: @"three"
        willBeInsertedIntoToolbar: YES] == nil,
        "no toolbar item is made for an unknown identifier");

      [[item target] performSelector: [item action] withObject: item];
      PASS([tc selectedTabViewItemIndex] == 1,
        "the toolbar item selects its tab");
      {
        NSTabViewController *vc = AUTORELEASE([[NSTabViewController alloc] init]);
        NSTabViewItem *numbered = anItem(@"three");
        NSArray *ids;
        NSUInteger i;

        [vc addTabViewItem: [NSTabViewItem tabViewItemWithViewController:
          [anItem(@"a") viewController]]];
        [vc addTabViewItem: [NSTabViewItem tabViewItemWithViewController:
          [anItem(@"b") viewController]]];
        [numbered setIdentifier: [NSNumber numberWithInt: 3]];
        [vc addTabViewItem: numbered];

        ids = [vc toolbarAllowedItemIdentifiers: nil];
        PASS([ids count] == 3, "every tab has a toolbar identifier");
        PASS([[NSSet setWithArray: ids] count] == 3,
          "tabs without distinct identifiers get distinct toolbar identifiers");
        for (i = 0; i < [ids count]; i++)
          {
            PASS([[ids objectAtIndex: i] isKindOfClass: [NSString class]],
              "toolbar identifier %lu is a string", (unsigned long)i);
          }

        for (i = 0; i < [ids count]; i++)
          {
            item = [vc toolbar: nil
              itemForItemIdentifier: [ids objectAtIndex: i]
              willBeInsertedIntoToolbar: YES];
            [[item target] performSelector: [item action] withObject: item];
            PASS([vc selectedTabViewItemIndex] == (NSInteger)i,
              "the toolbar item made for tab %lu selects it", (unsigned long)i);
          }
      }
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
  NS_ENDHANDLER

  END_SET("NSTabViewController toolbar items")
  return 0;
}
