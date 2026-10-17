/* A window's delegate is asked where to show a sheet with
   window:willPositionSheet:usingRect:, given by default the zero height
   top edge of the content view, and the sheet appears below the rectangle
   it answers, centred on it.  The delegate was never asked.  The sheet is
   run modally, so a timer reads its frame, ends it and posts an event to
   wake the modal loop.  The windows need the backend, so the set is
   skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSView.h>
#import <AppKit/NSWindow.h>

@interface Positioner : NSObject
{
@public
  NSWindow *sheet;
  NSRect proposed;
  NSRect frame;
  int asked;
}
- (void) fire: (NSTimer *)timer;
@end

@implementation Positioner
- (NSRect) window: (NSWindow *)window
willPositionSheet: (NSWindow *)aSheet
	usingRect: (NSRect)rect
{
  asked++;
  proposed = rect;
  return NSMakeRect(20, 150, 100, 0);
}
- (void) fire: (NSTimer *)timer
{
  frame = [sheet frame];
  [NSApp endSheet: sheet];
  [NSApp postEvent: [NSEvent otherEventWithType: NSApplicationDefined
                                       location: NSZeroPoint
                                  modifierFlags: 0
                                      timestamp: 0
                                   windowNumber: [sheet windowNumber]
                                        context: nil
                                        subtype: 0
                                          data1: 0
                                          data2: 0]
           atStart: NO];
}
@end

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  Positioner *positioner;
  NSTimer *timer;
  NSWindow *w;
  NSWindow *sheet;
  NSRect docFrame;
  NSSize size;

  START_SET("NSWindow window:willPositionSheet:usingRect:")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  w = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(100, 100, 300, 200)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: YES]);
  sheet = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 80, 60)
              styleMask: NSBorderlessWindowMask
                backing: NSBackingStoreBuffered
                  defer: YES]);
  [sheet setReleasedWhenClosed: NO];

  positioner = AUTORELEASE([Positioner new]);
  positioner->sheet = sheet;
  [w setDelegate: (id)positioner];
  timer = [NSTimer timerWithTimeInterval: 0.1
                                  target: positioner
                                selector: @selector(fire:)
                                userInfo: nil
                                 repeats: NO];
  [[NSRunLoop currentRunLoop] addTimer: timer
                               forMode: NSModalPanelRunLoopMode];
  [NSApp beginSheet: sheet
     modalForWindow: w
      modalDelegate: nil
     didEndSelector: NULL
        contextInfo: NULL];

  docFrame = [w frame];
  size = positioner->frame.size;
  PASS(positioner->asked == 1, "the delegate is asked where to put the sheet");
  PASS(NSEqualRects(positioner->proposed,
    NSMakeRect(0, NSMaxY([[w contentView] frame]), NSWidth(docFrame), 0)),
    "the proposed rectangle is the top edge of the content view");
  PASS(NSMaxY(positioner->frame) == NSMinY(docFrame) + 150,
    "the sheet's top is at the rectangle the delegate answers");
  PASS(NSMidX(positioner->frame) == NSMinX(docFrame) + 70,
    "the sheet is centred on the rectangle");

  [w setDelegate: nil];

  END_SET("NSWindow window:willPositionSheet:usingRect:")

  [pool release];
  return 0;
}
