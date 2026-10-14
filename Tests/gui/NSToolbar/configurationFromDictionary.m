/* -setConfigurationFromDictionary: replaces the toolbar's items with those
   the dictionary names, in order.  The removal loop stopped half way, and
   each removal saved the toolbar's state over the configuration being
   applied, so the toolbar ended up with leftovers, and the saved
   configuration that later toolbars with the same identifier are built
   from was left with no items.  The display mode and visibility are
   applied through the toolbar, so they show.  The toolbar builds its
   items through the delegate and lays them out with the theme and font
   backend, so the set is skipped when the backend is unavailable. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSString.h>
#include <Foundation/NSValue.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSToolbar.h>
#include <AppKit/NSToolbarItem.h>

@interface ConfigDelegate : NSObject
@end

@implementation ConfigDelegate
- (NSToolbarItem *) toolbar: (NSToolbar *)tb
      itemForItemIdentifier: (NSString *)ident
  willBeInsertedIntoToolbar: (BOOL)flag
{
  return AUTORELEASE([[NSToolbarItem alloc] initWithItemIdentifier: ident]);
}
- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *)tb
{
  return [NSArray arrayWithObjects: @"alpha", @"beta", @"gamma", nil];
}
- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *)tb
{
  return [NSArray arrayWithObjects: @"alpha", @"gamma", nil];
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  ConfigDelegate *del;
  NSToolbar *tb;
  NSArray *wanted;
  NSDictionary *config;

  START_SET("NSToolbar setConfigurationFromDictionary:")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  del = AUTORELEASE([[ConfigDelegate alloc] init]);
  tb = AUTORELEASE([[NSToolbar alloc]
    initWithIdentifier: @"GSTestToolbarConfiguration"]);
  [tb setDelegate: del];
  while ([[tb items] count] > 0)
    {
      [tb removeItemAtIndex: 0];
    }
  [tb insertItemWithItemIdentifier: @"alpha" atIndex: 0];
  [tb insertItemWithItemIdentifier: @"gamma" atIndex: 1];

  wanted = [NSArray arrayWithObjects: @"gamma", @"beta", @"alpha", nil];
  config = [NSDictionary dictionaryWithObjectsAndKeys:
    wanted, @"items",
    [NSNumber numberWithBool: NO], @"isVisible",
    [NSNumber numberWithInt: NSToolbarDisplayModeIconOnly], @"displayMode",
    nil];
  [tb setConfigurationFromDictionary: config];

  PASS_EQUAL([[tb items] valueForKey: @"itemIdentifier"], wanted,
    "the toolbar holds the configured items in order");
  PASS([tb displayMode] == NSToolbarDisplayModeIconOnly,
    "the toolbar takes the configured display mode");
  PASS([tb configurationDictionary] == config,
    "the configuration dictionary is the one applied");
  PASS([tb isVisible] == NO, "the toolbar takes the configured visibility");

  {
    NSToolbar *other = AUTORELEASE([[NSToolbar alloc]
      initWithIdentifier: @"GSTestToolbarConfiguration"]);

    [other setDelegate: del];
    PASS_EQUAL([[other items] valueForKey: @"itemIdentifier"], wanted,
      "a new toolbar with the same identifier gets the configured items");
  }

  END_SET("NSToolbar setConfigurationFromDictionary:")

  [pool release];
  return 0;
}
