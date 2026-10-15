#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSDataLinkPanel.h>
#import <AppKit/NSView.h>

/* The data link panel keeps the accessory view it is given.  The setter
   was a stub and the getter answered nil.  The panel is loaded from its
   resource and needs the backend, so the set is skipped without it. */

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSDataLinkPanel *panel = nil;
  NSView *view;

  START_SET("NSDataLinkPanel accessory view")

  NS_DURING
    {
      [NSApplication sharedApplication];
      panel = [NSDataLinkPanel sharedDataLinkPanel];
    }
  NS_HANDLER
    {
      panel = nil;
    }
  NS_ENDHANDLER
  if (panel == nil)
    {
      SKIP("the backend or the panel resource is not available")
    }

  view = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(0, 0, 50, 20)]);
  [panel setAccessoryView: view];
  PASS([panel accessoryView] == view, "the accessory view is kept");
  [panel setAccessoryView: nil];
  PASS([panel accessoryView] == nil, "the accessory view can be removed");

  END_SET("NSDataLinkPanel accessory view")

  [pool release];
  return 0;
}
