/* A sharing service picker toolbar item keeps its activity items
   configuration and its delegate.  Both setters were stubs and the getters
   answered nil.  Toolbar items need no backend for this. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSSharingServicePickerToolbarItem.h>

@interface SharingDelegate : NSObject <NSSharingServicePickerToolbarItemDelegate>
@end

@implementation SharingDelegate
- (NSArray *) itemsForSharingServicePickerToolbarItem: (NSSharingServicePickerToolbarItem *)items
{
  return [NSArray array];
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSSharingServicePickerToolbarItem *item;
  SharingDelegate *d = AUTORELEASE([SharingDelegate new]);
  id configuration = AUTORELEASE([NSObject new]);

  START_SET("NSSharingServicePickerToolbarItem storage")

  item = AUTORELEASE([[NSSharingServicePickerToolbarItem alloc]
    initWithItemIdentifier: @"share"]);
  [item setActivityItemsConfiguration: configuration];
  [item setDelegate: d];
  PASS([item activityItemsConfiguration] == configuration,
    "the activity items configuration is kept");
  PASS([item delegate] == (id)d, "the delegate is kept");

  END_SET("NSSharingServicePickerToolbarItem storage")

  [pool release];
  return 0;
}
