/* NSButton, NSStackView and NSTextField adopt NSUserInterfaceCompression.  They
   can't compress yet, so no option is ever active. */
#import "Testing.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSGeometry.h>

#import <AppKit/NSApplication.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSStackView.h>
#import <AppKit/NSTextField.h>
#import <AppKit/NSUserInterfaceCompression.h>

int
main(int argc, char **argv)
{
  START_SET("NSUserInterfaceCompression adoption")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSRect frame = NSMakeRect(0, 0, 40, 20);
      NSArray *views = [NSArray arrayWithObjects:
        AUTORELEASE([[NSButton alloc] initWithFrame: frame]),
        AUTORELEASE([[NSStackView alloc] initWithFrame: frame]),
        AUTORELEASE([[NSTextField alloc] initWithFrame: frame]), nil];
      NSArray *options = [NSArray arrayWithObject:
        [NSUserInterfaceCompressionOptions hideImagesOption]];
      NSUInteger i;

      for (i = 0; i < [views count]; i++)
        {
          id v = [views objectAtIndex: i];
          NSRect before = [v frame];
          NSSize minimum;

          PASS([v conformsToProtocol: @protocol(NSUserInterfaceCompression)],
            "the view conforms to the protocol");
          PASS([[v activeCompressionOptions] isEmpty], "no option is active");
          minimum = [v minimumSizeWithPrioritizedCompressionOptions: options];
          PASS(minimum.width >= 0 && minimum.height >= 0,
            "the minimum size is usable");
          [v compressWithPrioritizedCompressionOptions: options];
          PASS(NSEqualRects(before, [v frame]) && [[v activeCompressionOptions] isEmpty],
            "compressing changes nothing");
        }
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSUserInterfaceCompression adoption")

  return 0;
}
