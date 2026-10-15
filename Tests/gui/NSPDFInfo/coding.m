/* An NSPDFInfo keeps its settings through a keyed and an unkeyed archive.
   -initWithCoder: answered nil, so an archived PDF info could not be read
   back.  NSPDFInfo is a plain model object, but -init reads the shared
   print info's paper size, as the other NSPDFInfo tests do. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSPrintInfo.h>
#import <AppKit/NSPDFInfo.h>

int main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSPDFInfo *info;
  NSPDFInfo *keyed;
  NSPDFInfo *unkeyed;

  START_SET("NSPDFInfo coding")

  info = AUTORELEASE([[NSPDFInfo alloc] init]);
  [info setFileExtensionHidden: NO];
  [info setOrientation: NSPaperOrientationLandscape];
  [info setPaperSize: NSMakeSize(100, 200)];
  [[info attributes] setObject: @"Report" forKey: @"Title"];

  keyed = [NSKeyedUnarchiver unarchiveObjectWithData:
    [NSKeyedArchiver archivedDataWithRootObject: info]];
  PASS(keyed != nil, "a keyed archive reads back");
  PASS([keyed isFileExtensionHidden] == NO
    && [keyed orientation] == NSPaperOrientationLandscape
    && NSEqualSizes([keyed paperSize], NSMakeSize(100, 200)),
    "the settings survive a keyed archive");
  PASS_EQUAL([[keyed attributes] objectForKey: @"Title"], @"Report",
    "the attributes survive a keyed archive");

  unkeyed = [NSUnarchiver unarchiveObjectWithData:
    [NSArchiver archivedDataWithRootObject: info]];
  PASS(unkeyed != nil, "an unkeyed archive reads back");
  PASS([unkeyed isFileExtensionHidden] == NO
    && [unkeyed orientation] == NSPaperOrientationLandscape
    && NSEqualSizes([unkeyed paperSize], NSMakeSize(100, 200)),
    "the settings survive an unkeyed archive");
  PASS_EQUAL([[unkeyed attributes] objectForKey: @"Title"], @"Report",
    "the attributes survive an unkeyed archive");

  END_SET("NSPDFInfo coding")

  [pool release];
  return 0;
}
