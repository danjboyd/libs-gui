/* NSUserInterfaceItemIdentifier is still an NSString * for Objective-C
   (Swift sees a structure wrapping the string), declared once for the
   views, layout guides, collection and table views that use it. */
#import "Testing.h"
#import <Foundation/NSString.h>
#import <AppKit/NSCollectionView.h>
#import <AppKit/NSLayoutGuide.h>
#import <AppKit/NSTableView.h>
#import <AppKit/NSUserInterfaceItemIdentification.h>

int main(int argc, const char **argv)
{
  START_SET("NSUserInterfaceItemIdentifier type")

  NSLayoutGuide			*g = AUTORELEASE([[NSLayoutGuide alloc] init]);
  NSUserInterfaceItemIdentifier	ident = @"ContentGuideIdentifier";
  NSString			*plain;

  [g setIdentifier: ident];
  plain = [g identifier];
  PASS([plain isEqualToString: @"ContentGuideIdentifier"],
    "an identifier is used as a string");
  PASS([[g identifier] length] == [ident length],
    "an identifier answers string methods");

  END_SET("NSUserInterfaceItemIdentifier type")
  return 0;
}
