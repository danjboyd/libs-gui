/* An NSOpenGLView's drawable must follow the view.
 *
 * The backends draw an OpenGL view into a native child window placed over
 * the view; the context's -update places it (shows, hides, moves and clips
 * it).  These check that the view asks for that whenever it should:
 *  - when an ancestor is hidden or unhidden (viewDidHide/viewDidUnhide);
 *  - when an ancestor moves, once per batch of changes;
 *  - when the view leaves its window, the context lets go of its drawable
 *    (-_viewWillMoveToWindow: used to compare the window after super had
 *    already set it, so -clearDrawable never ran and the child window
 *    stayed on screen);
 *  - and when the view comes back, drawing attaches the context again.
 *
 * Needs a display with OpenGL; the set skips cleanly without one.
 */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSException.h>
#import <Foundation/NSRunLoop.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSOpenGL.h>
#import <AppKit/NSOpenGLView.h>
#import <AppKit/NSView.h>
#import <AppKit/NSWindow.h>

@interface UpdateRecorder : NSOpenGLView
{
@public
  int updates;
}
@end

@implementation UpdateRecorder
- (void) update
{
  updates++;
  [super update];
}
@end

/* Lets the run loop deliver the view's coalesced update request.  */
static void
spin(void)
{
  [[NSRunLoop currentRunLoop]
    runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.2]];
}

static void
checkVisibility(void)
{
  NSWindow *window;
  NSView *container;
  UpdateRecorder *view;

  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(100, 100, 300, 300)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: NO]);
  [window setReleasedWhenClosed: NO];
  container = AUTORELEASE([[NSView alloc]
    initWithFrame: NSMakeRect(20, 20, 200, 200)]);
  view = AUTORELEASE([[UpdateRecorder alloc]
    initWithFrame: NSMakeRect(10, 10, 100, 100)]);
  [[window contentView] addSubview: container];
  [container addSubview: view];
  [window orderFront: nil];
  [window display];
  spin();

  PASS([[view openGLContext] view] == view,
    "drawing the view attaches its context to it");

  view->updates = 0;
  [container setHidden: YES];
  PASS(view->updates > 0, "hiding an ancestor updates the context");

  view->updates = 0;
  [container setHidden: NO];
  PASS(view->updates > 0, "unhiding the ancestor updates the context");

  spin();
  view->updates = 0;
  [container setFrameOrigin: NSMakePoint(30, 25)];
  [container setFrameOrigin: NSMakePoint(40, 30)];
  [[window contentView] setBoundsOrigin: NSMakePoint(0, 5)];
  spin();
  PASS(view->updates == 1,
    "moving ancestors updates the context once per batch of changes "
    "(got %d)", view->updates);

  RETAIN(view);
  [view removeFromSuperview];
  PASS([[view openGLContext] view] == nil,
    "removing the view from its window detaches its context");

  /* Hiding, moving and running the loop with no drawable must be safe.  */
  [view setHidden: YES];
  [view setHidden: NO];
  spin();

  [container addSubview: view];
  RELEASE(view);
  [window display];
  spin();
  PASS([[view openGLContext] view] == view,
    "drawing the view again in a window reattaches its context");

  [window close];
}

int
main(int argc, char **argv)
{
  CREATE_AUTORELEASE_POOL(arp);

  START_SET("NSOpenGLView visibility")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: @"SkipSet"])
      [localException raise];
    else if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      {
        SKIP("It looks like GNUstep backend is not yet installed")
      }
    else
      {
        PASS(NO, "the application starts without an unexpected exception, "
          "but %s was raised", [[localException name] UTF8String]);
      }
  NS_ENDHANDLER

  NS_DURING
    {
      if ([NSOpenGLView defaultPixelFormat] == nil)
        {
          SKIP("No OpenGL pixel format available on this display")
        }
      checkVisibility();
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: @"SkipSet"])
      [localException raise];
    else if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      {
        SKIP("No display available")
      }
    else
      {
        PASS(NO, "showing an OpenGL view raises no unexpected exception, "
          "but %s was raised", [[localException name] UTF8String]);
      }
  NS_ENDHANDLER

  END_SET("NSOpenGLView visibility")

  DESTROY(arp);
  return 0;
}
