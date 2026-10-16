/* -searchString:inUserInterfaceItemString:searchRange:foundRange: finds
   the search string in the given range of the item string, ignoring
   case, and answers the range where it found it.  It used to answer NO
   for every string. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSString.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSUserInterfaceItemSearching.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];
  NSApplication *app;
  NSRange found;
  BOOL ok;

  START_SET("NSApplication searchString")

  NS_DURING
    app = [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  found = NSMakeRange(0, 0);
  ok = [app searchString: @"pha"
    inUserInterfaceItemString: @"alpha"
                  searchRange: NSMakeRange(0, 5)
                   foundRange: &found];
  PASS(ok && found.location == 2 && found.length == 3,
    "a string in the item string is found with its range");

  found = NSMakeRange(0, 0);
  ok = [app searchString: @"SAVE"
    inUserInterfaceItemString: @"Save As..."
                  searchRange: NSMakeRange(0, 10)
                   foundRange: &found];
  PASS(ok && found.location == 0 && found.length == 4,
    "the search ignores case");

  ok = [app searchString: @"open"
    inUserInterfaceItemString: @"Open Recent"
                  searchRange: NSMakeRange(4, 7)
                   foundRange: &found];
  PASS(ok == NO, "only the search range is searched");

  ok = [app searchString: @"print"
    inUserInterfaceItemString: @"Page Setup"
                  searchRange: NSMakeRange(0, 10)
                   foundRange: &found];
  PASS(ok == NO, "a string that is not there is not found");

  END_SET("NSApplication searchString")

  DESTROY(arp);
  return 0;
}
