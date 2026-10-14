/* An NSPasteboardItem answers nil for a type it does not hold, as AppKit
   does.  -dataForType: used to serialize the missing (nil) value as a
   property list, which raised, and -stringForType: raised with it.
   NSPasteboardItem is a plain model object and needs no backend. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import <AppKit/NSPasteboardItem.h>

int main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSPasteboardItem *item;
  NSData *data = [NSData data];
  NSString *string = @"unset";

  START_SET("NSPasteboardItem missing type")

  item = AUTORELEASE([[NSPasteboardItem alloc] init]);
  [item setString: @"text" forType: @"public.utf8-plain-text"];

  PASS_RUNS(data = [item dataForType: @"public.data"],
    "dataForType: does not raise for a type the item does not hold");
  PASS(data == nil,
    "dataForType: answers nil for a type the item does not hold");
  PASS_RUNS(string = [item stringForType: @"public.data"],
    "stringForType: does not raise for a type the item does not hold");
  PASS(string == nil,
    "stringForType: answers nil for a type the item does not hold");
  PASS_EQUAL([item stringForType: @"public.utf8-plain-text"], @"text",
    "stringForType: still answers a type the item holds");

  END_SET("NSPasteboardItem missing type")

  [pool release];
  return 0;
}
