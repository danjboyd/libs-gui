/* -beginForDirectory:file:types:modelessDelegate:didEndSelector:contextInfo:
   shows the panel without a modal session and returns; when the panel
   ends, the delegate is sent the did-end selector with the panel, the
   button and the context.  It used to run the panel modally, as a sheet
   without a window, and -ok: never ended a panel shown without a modal
   session.  A timer in the modal run loop mode cancels the panel if a
   modal session runs.  The panel needs the backend, so the
   set is skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSOpenPanel.h>

@interface EndDelegate : NSObject
{
@public
  int ended;
  id panel;
  NSInteger code;
  void *context;
  BOOL modal;
}
@end

@implementation EndDelegate
- (void) panelDidEnd: (NSOpenPanel *)p
          returnCode: (NSInteger)returnCode
         contextInfo: (void *)contextInfo
{
  ended++;
  panel = p;
  code = returnCode;
  context = contextInfo;
}
- (void) fire: (NSTimer *)timer
{
  modal = YES;
  [[NSApp modalWindow] cancel: nil];
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

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];
  static char context;

  START_SET("NSOpenPanel beginForDirectory")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSOpenPanel *p = [NSOpenPanel openPanel];
      EndDelegate *delegate = AUTORELEASE([EndDelegate new]);
      NSArray *types = [NSArray arrayWithObject: @"rtf"];

      NSTimer *timer = [NSTimer timerWithTimeInterval: 0.3
                                               target: delegate
                                             selector: @selector(fire:)
                                             userInfo: nil
                                              repeats: YES];

      [[NSRunLoop currentRunLoop] addTimer: timer
                                   forMode: NSModalPanelRunLoopMode];
      [p beginForDirectory: NSTemporaryDirectory()
                      file: nil
                     types: types
          modelessDelegate: delegate
            didEndSelector: @selector(panelDidEnd:returnCode:contextInfo:)
               contextInfo: &context];
      PASS(delegate->modal == NO && [p isVisible] && delegate->ended == 0,
        "the panel is shown without a modal session");
      PASS([[p allowedFileTypes] isEqual: types], "the file types are set");

      if ([p isVisible])
        {
          [p cancel: nil];
        }
      PASS(delegate->ended == 1 && delegate->panel == p
        && delegate->code == NSCancelButton && delegate->context == &context,
        "the delegate is told when the panel ends");
      PASS([p isVisible] == NO, "the panel is closed when it ends");

      [p setCanChooseDirectories: YES];
      [p beginForDirectory: NSTemporaryDirectory()
                      file: nil
                     types: nil
          modelessDelegate: delegate
            didEndSelector: @selector(panelDidEnd:returnCode:contextInfo:)
               contextInfo: &context];
      if ([p isVisible])
        {
          [p ok: nil];
        }
      PASS(delegate->modal == NO && delegate->ended == 2
        && delegate->code == NSOKButton,
        "the delegate is told when the panel is confirmed");
      [timer invalidate];
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSOpenPanel beginForDirectory")

  DESTROY(arp);
  return 0;
}
