/* +imageNamed: is declared to answer an NSImage, as in Cocoa (Swift then
   has NSImage(named:)).  Its answer is used as an NSImage without a cast,
   also when sent to a subclass, and a missing name gives nil.  Needs the
   backend for the named images, so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/NSString.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSImage.h>

@interface ImageNamedSubclass : NSImage
@end
@implementation ImageNamedSubclass
@end

int main()
{
  START_SET("NSImage imageNamed type")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  {
    NSImage	*image = [NSImage imageNamed: @"GNUstep"];
    NSImage	*fromSubclass = [ImageNamedSubclass imageNamed: @"GNUstep"];

    PASS(image != nil && [image isKindOfClass: [NSImage class]],
      "a named image is an NSImage");
    PASS(fromSubclass == image, "a subclass answers the same named image");
    PASS([NSImage imageNamed: @"NoSuchImageAnywhereAtAll"] == nil,
      "a missing name gives nil");
  }

  END_SET("NSImage imageNamed type")
  return 0;
}
