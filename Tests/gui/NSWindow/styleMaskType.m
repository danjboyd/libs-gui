/* NSWindowStyleMask is an NS_OPTIONS type, as in Cocoa, so Swift imports it
   as the option set NSWindow.StyleMask.  It was an NSUInteger typedef
   beside an anonymous enumeration.  The older names of the flags remain
   integer constants with the same values. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSWindow.h>

/* The older names must stay usable where C needs a constant. */
static const NSUInteger standardStyle
  = NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask;

static BOOL
isTitled(NSUInteger style)
{
  switch (style & NSTitledWindowMask)
    {
      case NSTitledWindowMask:
	return YES;
      default:
	return NO;
    }
}

int
main(int argc, const char **argv)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSWindowStyleMask	style;

  START_SET("NSWindowStyleMask")

  PASS(sizeof(NSWindowStyleMask) == sizeof(NSUInteger),
    "NSWindowStyleMask has the size of NSUInteger");
  PASS(NSWindowStyleMaskBorderless == 0
    && NSWindowStyleMaskTitled == 1
    && NSWindowStyleMaskClosable == 2
    && NSWindowStyleMaskMiniaturizable == 4
    && NSWindowStyleMaskResizable == 8
    && NSWindowStyleMaskUtilityWindow == 16
    && NSWindowStyleMaskTexturedBackground == 256
    && NSWindowStyleMaskUnifiedTitleAndToolbar == 4096
    && NSWindowStyleMaskHUDWindow == 8192
    && NSWindowStyleMaskFullScreen == 16384
    && NSWindowStyleMaskFullSizeContentView == 32768,
    "the style flags have Cocoa's values");
  PASS(NSBorderlessWindowMask == NSWindowStyleMaskBorderless
    && NSTitledWindowMask == NSWindowStyleMaskTitled
    && NSClosableWindowMask == NSWindowStyleMaskClosable
    && NSMiniaturizableWindowMask == NSWindowStyleMaskMiniaturizable
    && NSResizableWindowMask == NSWindowStyleMaskResizable
    && NSTexturedBackgroundWindowMask == NSWindowStyleMaskTexturedBackground
    && NSFullScreenWindowMask == NSWindowStyleMaskFullScreen,
    "the older names have the same values");

  /* Known clash, pinned so that a fix shows here: Cocoa's values for
     these two flags are the bits GNUstep uses for its icon and mini
     windows, and NSPanel.h gives NSDocModalWindowMask another value. */
  PASS(NSWindowStyleMaskDocModalWindow == 64
    && NSWindowStyleMaskDocModalWindow == NSIconWindowMask
    && NSWindowStyleMaskNonactivatingPanel == 128
    && NSWindowStyleMaskNonactivatingPanel == NSMiniWindowMask,
    "known clash: the doc modal and nonactivating panel flags are"
    " NSIconWindowMask and NSMiniWindowMask");

  style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;
  PASS((style & NSClosableWindowMask) && !(style & NSResizableWindowMask),
    "flags combine into a style mask");
  PASS(isTitled(standardStyle) && !isTitled(NSBorderlessWindowMask),
    "the older names are integer constant expressions");

  END_SET("NSWindowStyleMask")

  [arp release];
  return 0;
}
