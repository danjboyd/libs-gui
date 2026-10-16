/* When the pop-up list of a combo box opens, the cell selects the item
   matching its completed string, asking a data source for its index with
   comboBox:indexOfItemWithStringValue: or
   comboBoxCell:indexOfItemWithStringValue:.  Only the cell form used to be
   asked, so a data source in the NSComboBox form selected nothing.  The
   private -_selectCompleted is what the list sends when it opens.  The
   cell builds a button cell, so the set is skipped when the backend is
   unavailable. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSComboBox.h>
#include <AppKit/NSComboBoxCell.h>

static NSArray *items;

/* A data source in the NSComboBox form. */
@interface ComboSource : NSObject
{
@public
  int indexAsked;
}
@end

@implementation ComboSource
- (NSInteger) numberOfItemsInComboBox: (NSComboBox *)comboBox
{
  return [items count];
}
- (id) comboBox: (NSComboBox *)comboBox objectValueForItemAtIndex: (NSInteger)i
{
  return [items objectAtIndex: i];
}
- (NSString *) comboBox: (NSComboBox *)comboBox
        completedString: (NSString *)string
{
  NSUInteger i;

  for (i = 0; i < [items count]; i++)
    {
      if ([[items objectAtIndex: i] hasPrefix: string])
        return [items objectAtIndex: i];
    }
  return nil;
}
- (NSUInteger) comboBox: (NSComboBox *)comboBox
indexOfItemWithStringValue: (NSString *)string
{
  indexAsked++;
  return [items indexOfObject: string];
}
@end

int
main(int argc, char **argv)
{
  CREATE_AUTORELEASE_POOL(arp);
  NSComboBox *box;
  ComboSource *source;

  START_SET("NSComboBoxCell dataSourceIndex")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  items = [NSArray arrayWithObjects: @"alpha", @"beta", @"gamma", nil];
  box = AUTORELEASE([[NSComboBox alloc] initWithFrame: NSMakeRect(0, 0, 150, 24)]);
  source = AUTORELEASE([ComboSource new]);
  [box setUsesDataSource: YES];
  [box setDataSource: (id<NSComboBoxDataSource>)source];
  [box setStringValue: @"be"];

  [[box cell] performSelector: @selector(_selectCompleted)];
  PASS(source->indexAsked == 1,
       "the data source is asked comboBox:indexOfItemWithStringValue:");
  PASS([box indexOfSelectedItem] == 1,
       "the item the data source answers is selected");

  END_SET("NSComboBoxCell dataSourceIndex")

  DESTROY(arp);
  return 0;
}
