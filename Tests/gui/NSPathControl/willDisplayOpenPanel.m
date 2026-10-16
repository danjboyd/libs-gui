/* Choosing a path from a path control's menu sends
   pathControl:willDisplayOpenPanel: to a control delegate and
   pathCell:willDisplayOpenPanel: to a cell delegate that implement them,
   before the open panel runs.  Both used to be sent only to a delegate that
   answered pathCell:willPopUpMenu:.  The panel runs modally, so a timer
   stops it.  It needs a backend, so the set is skipped when the backend is
   unavailable. */
#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSURL.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSOpenPanel.h>
#import <AppKit/NSPathCell.h>
#import <AppKit/NSPathControl.h>

/* Answers only the open panel method of each delegate protocol. */
@interface PanelDelegate : NSObject
{
@public
  int controlPanels;
  int cellPanels;
}
@end

@implementation PanelDelegate
- (void) pathControl: (NSPathControl *)control
willDisplayOpenPanel: (NSOpenPanel *)panel
{
  controlPanels++;
}
- (void) pathCell: (NSPathCell *)cell
willDisplayOpenPanel: (NSOpenPanel *)panel
{
  cellPanels++;
}
@end

@interface Stopper : NSObject
@end

@implementation Stopper
- (void) stop: (id)ignored
{
  [NSApp stopModalWithCode: NSCancelButton];
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

int main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSPathControl *control;
  PanelDelegate *delegate;
  Stopper *stopper;
  NSTimer *timer;

  START_SET("NSPathControl willDisplayOpenPanel")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  control = AUTORELEASE([[NSPathControl alloc]
    initWithFrame: NSMakeRect(0, 0, 300, 22)]);
  [control setURL: [NSURL fileURLWithPath: @"/"]];
  delegate = AUTORELEASE([PanelDelegate new]);
  [control setDelegate: (id<NSPathControlDelegate>)delegate];
  [[control cell] setDelegate: (id<NSPathCellDelegate>)delegate];

  stopper = AUTORELEASE([Stopper new]);
  timer = [NSTimer timerWithTimeInterval: 0.2
                                  target: stopper
                                selector: @selector(stop:)
                                userInfo: nil
                                 repeats: YES];
  [[NSRunLoop currentRunLoop] addTimer: timer
                               forMode: NSModalPanelRunLoopMode];
  [control performSelector: @selector(_doChooseMenuAction:) withObject: nil];
  [timer invalidate];

  PASS(delegate->controlPanels == 1,
       "the control delegate is sent pathControl:willDisplayOpenPanel:");
  PASS(delegate->cellPanels == 1,
       "the cell delegate is sent pathCell:willDisplayOpenPanel:");

  END_SET("NSPathControl willDisplayOpenPanel")

  [pool release];
  return 0;
}
