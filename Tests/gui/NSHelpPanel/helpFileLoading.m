/* A help file attached to an object with +attachHelpFile:markerName:to:,
   or shown with -showFile:atMarker:, is loaded from its full path: the
   object's context help is the file's text, and showing it runs the help
   panel.  -[NSBundle contextHelpForKey:] looked the path up only below
   the main bundle, so the object had no help and nothing was shown.  A
   timer stops the help panel's modal loop.  The panel needs the backend,
   so the set is skipped without it. */
#include "Testing.h"

#include <Foundation/Foundation.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSAttributedString.h>
#include <AppKit/NSEvent.h>
#include <AppKit/NSHelpManager.h>
#include <AppKit/NSHelpPanel.h>
#include <AppKit/NSWindow.h>

@interface ModalStopper : NSObject
{
@public
  BOOL fired;
}
- (void) fire: (NSTimer *)timer;
@end

@implementation ModalStopper
- (void) fire: (NSTimer *)timer
{
  fired = YES;
  [NSApp stopModal];
  [NSApp postEvent: [NSEvent otherEventWithType: NSApplicationDefined
                                       location: NSZeroPoint
                                  modifierFlags: 0
                                      timestamp: 0
                                   windowNumber: 0
                                        context: nil
                                        subtype: 0
                                          data1: 0
                                          data2: 0]
           atStart: NO];
}
@end

static ModalStopper *
arm(void)
{
  ModalStopper *stopper = AUTORELEASE([ModalStopper new]);

  [[NSRunLoop currentRunLoop]
    addTimer: [NSTimer timerWithTimeInterval: 0.2
                                      target: stopper
                                    selector: @selector(fire:)
                                    userInfo: nil
                                     repeats: NO]
     forMode: NSModalPanelRunLoopMode];
  return stopper;
}

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSHelpPanel *panel = nil;
  NSString *dir;
  NSString *file;
  NSAttributedString *text;
  NSObject *target = AUTORELEASE([NSObject new]);
  ModalStopper *stopper;

  START_SET("NSHelpPanel help file loading")

  NS_DURING
    {
      [NSApplication sharedApplication];
      panel = [NSHelpPanel sharedHelpPanel];
    }
  NS_HANDLER
    {
      panel = nil;
    }
  NS_ENDHANDLER
  if (panel == nil)
    {
      SKIP("the backend is not available")
    }

  dir = [NSTemporaryDirectory() stringByAppendingPathComponent:
    [NSString stringWithFormat: @"help-loading-%d",
      [[NSProcessInfo processInfo] processIdentifier]]];
  [[NSFileManager defaultManager] createDirectoryAtPath: dir
                            withIntermediateDirectories: YES
                                             attributes: nil
                                                  error: NULL];
  file = [dir stringByAppendingPathComponent: @"topic.rtf"];
  text = AUTORELEASE([[NSAttributedString alloc]
    initWithString: @"Help file text."]);
  [[text RTFFromRange: NSMakeRange(0, [text length]) documentAttributes: nil]
    writeToFile: file atomically: YES];

  [NSHelpPanel setHelpDirectory: dir];
  [NSHelpPanel attachHelpFile: @"topic.rtf" markerName: nil to: target];
  PASS_EQUAL([[[NSHelpManager sharedHelpManager] contextHelpForObject: target]
    string], @"Help file text.",
    "an attached help file is the object's context help");

  stopper = arm();
  PASS([panel showHelpAttachedTo: target] && stopper->fired,
    "the attached help is shown");
  [NSHelpPanel detachHelpFrom: target];

  stopper = arm();
  [panel showFile: file atMarker: nil];
  PASS(stopper->fired, "a help file shown with showFile:atMarker: is shown");

  [[NSFileManager defaultManager] removeItemAtPath: dir error: NULL];

  END_SET("NSHelpPanel help file loading")

  [pool release];
  return 0;
}
