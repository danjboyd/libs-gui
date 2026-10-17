/* +[NSWindow minFrameWidthWithTitle:styleMask:] answers a width that holds
   the window's title and decorations.  When the window manager draws the
   decorations (GSBackendWindowDecorationView), it used to answer 0 whatever
   the title; it now guesses from the frame offsets and the title's width,
   as the decorations GNUstep draws itself do.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSStringDrawing.h>
#include <AppKit/NSWindow.h>
#include <GNUstepGUI/GSWindowDecorationView.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSString *title = @"A window title of some length";
  NSUInteger titled = NSTitledWindowMask | NSClosableWindowMask;
  CGFloat titleWidth;
  /* The decorator methods are class methods of the GSWindowDecorator
     protocol. */
  id<GSWindowDecorator> backend
    = (id<GSWindowDecorator>)[GSBackendWindowDecorationView class];

  START_SET("NSWindow minFrameWidthWithTitle:styleMask:")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  titleWidth = [title sizeWithAttributes: nil].width;

  PASS([backend minFrameWidthWithTitle: title
						   styleMask: titled]
    >= titleWidth,
    "with window manager decorations, a titled window holds its title");
  PASS([backend minFrameWidthWithTitle: title
						   styleMask: titled]
    > [backend minFrameWidthWithTitle: @""
						  styleMask: titled],
    "with window manager decorations, a longer title needs a wider frame");
  PASS([backend minFrameWidthWithTitle: title
						   styleMask: NSBorderlessWindowMask]
    < titleWidth,
    "with window manager decorations, an untitled window ignores the title");

  PASS([NSWindow minFrameWidthWithTitle: title styleMask: titled]
    >= titleWidth,
    "a titled window holds its title");

  END_SET("NSWindow minFrameWidthWithTitle:styleMask:")

  [pool release];
  return 0;
}
