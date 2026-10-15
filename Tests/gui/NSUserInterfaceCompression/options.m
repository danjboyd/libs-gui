/* NSUserInterfaceCompressionOptions behave as sets of options: the
   standard options combine the four single options, and options can be
   tested, combined, removed, copied and archived.  The class was a stub
   whose constructors answered nil.  Options need no backend. */
#include "Testing.h"

#include <Foundation/NSArchiver.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSKeyedArchiver.h>
#include <Foundation/NSSet.h>
#include <AppKit/NSUserInterfaceCompression.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSUserInterfaceCompressionOptions *images;
  NSUserInterfaceCompressionOptions *text;
  NSUserInterfaceCompressionOptions *both;
  NSUserInterfaceCompressionOptions *standard;
  NSUserInterfaceCompressionOptions *none;
  id decoded;

  START_SET("NSUserInterfaceCompressionOptions")

  images = [NSUserInterfaceCompressionOptions hideImagesOption];
  text = [NSUserInterfaceCompressionOptions hideTextOption];
  standard = [NSUserInterfaceCompressionOptions standardOptions];
  PASS(images != nil && text != nil && standard != nil,
    "the standard options exist");
  PASS(![images isEmpty] && ![images isEqual: text],
    "single options are distinct and not empty");

  both = [images optionsByAddingOptions: text];
  PASS([both containsOptions: images] && [both containsOptions: text],
    "combined options contain both options");
  PASS([both intersectsOptions: images]
    && ![images intersectsOptions: text],
    "options intersect when they share an option");
  PASS([standard containsOptions: both]
    && [standard containsOptions:
      [NSUserInterfaceCompressionOptions reduceMetricsOption]]
    && [standard containsOptions:
      [NSUserInterfaceCompressionOptions breakEqualWidthsOption]],
    "the standard options contain the four single options");

  none = [both optionsByRemovingOptions: both];
  PASS([none isEmpty], "removing all options leaves none");
  {
    NSSet *set = [NSSet setWithObjects: images, text, nil];
    NSUserInterfaceCompressionOptions *made;

    made = AUTORELEASE([[NSUserInterfaceCompressionOptions alloc]
      initWithCompressionOptions: set]);
    PASS([made isEqual: both],
      "options made from a set equal their combination");
  }
  PASS([AUTORELEASE([both copy]) isEqual: both], "a copy is equal");
  PASS([both containsOptions: nil] && ![both intersectsOptions: nil]
    && [[both optionsByAddingOptions: nil] isEqual: both]
    && [[both optionsByRemovingOptions: nil] isEqual: both],
    "nil options act as no options");

  decoded = [NSKeyedUnarchiver unarchiveObjectWithData:
    [NSKeyedArchiver archivedDataWithRootObject: both]];
  PASS([decoded isEqual: both], "keyed archiving keeps the options");
  decoded = [NSUnarchiver unarchiveObjectWithData:
    [NSArchiver archivedDataWithRootObject: both]];
  PASS([decoded isEqual: both], "archiving keeps the options");

  END_SET("NSUserInterfaceCompressionOptions")

  [pool release];
  return 0;
}
