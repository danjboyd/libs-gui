#import "Testing.h"
#import <AppKit/NSApplication.h>
#import <AppKit/NSFontPanel.h>
#import <AppKit/NSTextField.h>
#import <AppKit/NSView.h>
#import <AppKit/NSWindow.h>

/* Ordering the font panel in asks the responder chain which modes the panel
   should offer, and the size controls follow the answer.  */

@interface ModesView : NSView
{
@public
  int calls;
  unsigned int modes;
}
@end

@implementation ModesView
- (BOOL) acceptsFirstResponder
{
  return YES;
}

- (unsigned int) validModesForFontPanel: (NSFontPanel *)fontPanel
{
  calls++;
  return modes;
}
@end

int
main(int argc, const char **argv)
{
  START_SET("NSFontPanel validModes")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSWindow *window;
      ModesView *view;
      NSFontPanel *fp;
      NSTextField *sizeField;
      int i;

      /* The application tracks its key window once it has launched.  */
      [NSApp finishLaunching];
      window = [[NSWindow alloc] initWithContentRect: NSMakeRect(0, 0, 200, 200)
                                           styleMask: NSTitledWindowMask
                                             backing: NSBackingStoreBuffered
                                               defer: NO];
      view = [[ModesView alloc] initWithFrame: NSMakeRect(0, 0, 50, 50)];
      view->modes = NSFontPanelFaceModeMask;
      [[window contentView] addSubview: view];
      [window makeKeyAndOrderFront: nil];
      [window makeFirstResponder: view];
      /* The window server makes the window key.  */
      for (i = 0; i < 10 && [NSApp keyWindow] != window; i++)
        {
          [[NSRunLoop currentRunLoop] runUntilDate:
            [NSDate dateWithTimeIntervalSinceNow: 0.05]];
        }

      fp = [NSFontPanel sharedFontPanel];
      sizeField = [[fp contentView] viewWithTag: NSFPSizeField];
      [fp orderFront: nil];
      PASS(view->calls >= 1,
        "ordering the font panel in asks the responder chain for its modes");
      PASS([sizeField isEnabled] == NO,
        "the size field is disabled when the size mode is not valid");

      [fp orderOut: nil];
      view->modes = NSFontPanelStandardModesMask;
      [fp orderFront: nil];
      PASS([sizeField isEnabled] == YES,
        "the size field is enabled again when the size mode is valid");
      [fp orderOut: nil];
    }
  NS_HANDLER
    {
      if ([[localException name] isEqualToString: NSInternalInconsistencyException])
        SKIP("It looks like GNUstep backend is not yet installed")
      else
        [localException raise];
    }
  NS_ENDHANDLER

  END_SET("NSFontPanel validModes")

  return 0;
}
