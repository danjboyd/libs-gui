/* NSAccessibilityCustomRotor and NSAccessibilityCustomRotorItemResult keep
   what they are made with and given.  Both were stubs whose initializers
   answered nil.  They are plain model objects and need no backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSString.h>
#include <AppKit/NSAccessibilityCustomRotor.h>

@interface RotorDelegate : NSObject <NSAccessibilityCustomRotorItemSearchDelegate>
@end

@implementation RotorDelegate
- (NSAccessibilityCustomRotorItemResult *) rotor: (NSAccessibilityCustomRotor *)rotor
                       resultForSearchParameters: (NSAccessibilityCustomRotorSearchParameters *)parameters
{
  return nil;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  RotorDelegate *d = AUTORELEASE([RotorDelegate new]);
  NSAccessibilityCustomRotor *rotor;
  NSAccessibilityCustomRotorItemResult *result;
  id element = AUTORELEASE([NSObject new]);

  START_SET("NSAccessibilityCustomRotor storage")

  rotor = AUTORELEASE([[NSAccessibilityCustomRotor alloc]
    initWithLabel: @"Headings" itemSearchDelegate: d]);
  PASS(rotor != nil, "a rotor is made with a label");
  PASS_EQUAL([rotor label], @"Headings", "the rotor keeps its label");
  PASS([rotor type] == NSAccessibilityCustomRotorTypeCustom,
    "a rotor made with a label is a custom rotor");
  PASS([rotor itemSearchDelegate] == d, "the rotor keeps its search delegate");

  rotor = AUTORELEASE([[NSAccessibilityCustomRotor alloc]
    initWithRotorType: NSAccessibilityCustomRotorTypeLink
   itemSearchDelegate: d]);
  PASS([rotor type] == NSAccessibilityCustomRotorTypeLink,
    "a rotor made with a type keeps it");
  [rotor setType: NSAccessibilityCustomRotorTypeHeading];
  [rotor setLabel: @"Other"];
  PASS([rotor type] == NSAccessibilityCustomRotorTypeHeading
    && [[rotor label] isEqual: @"Other"],
    "the type and label can be changed");

  result = AUTORELEASE([[NSAccessibilityCustomRotorItemResult alloc]
    initWithTargetElement: element]);
  PASS(result != nil && [result targetElement] == element,
    "a result keeps its target element");
  result = AUTORELEASE([[NSAccessibilityCustomRotorItemResult alloc]
    initWithItemLoadingToken: element customLabel: @"Label"]);
  PASS(result != nil && [result itemLoadingToken] == element
    && [[result customLabel] isEqual: @"Label"],
    "a result keeps its loading token and label");

  END_SET("NSAccessibilityCustomRotor storage")

  [pool release];
  return 0;
}
