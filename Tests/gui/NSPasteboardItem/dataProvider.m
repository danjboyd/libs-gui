/* An NSPasteboardItem asks the data provider of a type for the data the
   first time the type is read, and answers what the provider set.  The
   provider used to be stored and never asked, so the item had no data
   for its types.  NSPasteboardItem is a plain model object and needs no
   backend. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSPasteboardItem.h>

@interface Provider : NSObject <NSPasteboardItemDataProvider>
{
@public
  NSMutableArray *asked;
}
@end

@implementation Provider
- (void) dealloc
{
  RELEASE(asked);
  [super dealloc];
}
- (void) pasteboard: (NSPasteboard *)pasteboard
               item: (NSPasteboardItem *)item
 provideDataForType: (NSString *)type
{
  if (asked == nil)
    {
      asked = [NSMutableArray new];
    }
  [asked addObject: type];
  if ([type isEqualToString: @"provided.string"])
    {
      [item setString: @"provided" forType: type];
    }
  else
    {
      [item setData: [@"bytes" dataUsingEncoding: NSUTF8StringEncoding]
            forType: type];
    }
}
@end

int main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  Provider *provider = AUTORELEASE([Provider new]);
  NSPasteboardItem *item = AUTORELEASE([NSPasteboardItem new]);
  NSArray *types = [NSArray arrayWithObjects:
    @"provided.data", @"provided.string", nil];

  START_SET("NSPasteboardItem data provider")

  PASS([item setDataProvider: provider forTypes: types]
    && [[item types] isEqualToArray: types],
    "the item has the types of its data provider");
  PASS(provider->asked == nil, "the provider is not asked before a read");
  PASS_EQUAL([item dataForType: @"provided.data"],
    [@"bytes" dataUsingEncoding: NSUTF8StringEncoding],
    "dataForType: answers the data the provider set");
  PASS_EQUAL([item stringForType: @"provided.string"], @"provided",
    "stringForType: answers the string the provider set");
  [item dataForType: @"provided.data"];
  PASS_EQUAL(provider->asked, types,
    "the provider is asked once for each type read");
  PASS([item dataForType: @"other"] == nil,
    "a type without a provider still has no data");

  END_SET("NSPasteboardItem data provider")

  [pool release];
  return 0;
}
