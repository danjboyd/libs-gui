/* NSTableView writes a tracked cell's value to the data source only when
   tracking changed it.  A popup's object value is an index, so a data source
   that answers with something else, such as a title, never compares equal to
   it, and tracking that ended without a pick used to write the index. */
#import "Testing.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSValue.h>

#import <AppKit/NSApplication.h>
#import <AppKit/NSButtonCell.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSPopUpButtonCell.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSTableView.h>

@interface NSTableView (Tracking)
- (void) _trackCellAtColumn: (NSInteger)column
                        row: (NSInteger)row
                  withEvent: (NSEvent *)ev;
@end

/* Stands in for the user: tracking ends with a pick, or with none (-1). */
@interface ScriptedPopUpCell : NSPopUpButtonCell
{
@public
  NSInteger pick;
}
@end

@implementation ScriptedPopUpCell
- (BOOL) trackMouse: (NSEvent *)ev
             inRect: (NSRect)frame
             ofView: (NSView *)view
       untilMouseUp: (BOOL)flag
{
  if (pick >= 0)
    {
      [self selectItemAtIndex: pick];
    }
  return YES;
}
@end

@interface ToggledButtonCell : NSButtonCell
@end

@implementation ToggledButtonCell
- (BOOL) trackMouse: (NSEvent *)ev
             inRect: (NSRect)frame
             ofView: (NSView *)view
       untilMouseUp: (BOOL)flag
{
  [self setState: [self state] == NSOnState ? NSOffState : NSOnState];
  return YES;
}
@end

@interface Source : NSObject
{
@public
  id value;
  id written;
  int writes;
}
@end

@implementation Source
- (NSInteger) numberOfRowsInTableView: (NSTableView *)tv
{
  return 1;
}
- (id) tableView: (NSTableView *)tv
  objectValueForTableColumn: (NSTableColumn *)col
             row: (NSInteger)row
{
  return value;
}
- (void) tableView: (NSTableView *)tv
    setObjectValue: (id)obj
    forTableColumn: (NSTableColumn *)col
               row: (NSInteger)row
{
  writes++;
  written = obj;
}
@end

int
main(int argc, const char **argv)
{
  START_SET("NSTableView tracked cell value")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      Source *ds = AUTORELEASE([Source new]);
      NSTableView *tv;
      NSTableColumn *col;
      ScriptedPopUpCell *popUp;
      ToggledButtonCell *button;

      tv = AUTORELEASE([[NSTableView alloc]
        initWithFrame: NSMakeRect(0, 0, 200, 100)]);
      col = AUTORELEASE([[NSTableColumn alloc] initWithIdentifier: @"c"]);
      [col setEditable: YES];
      [tv addTableColumn: col];
      [tv setDataSource: ds];

      popUp = AUTORELEASE([[ScriptedPopUpCell alloc]
        initTextCell: @"" pullsDown: NO]);
      [popUp addItemsWithTitles:
        [NSArray arrayWithObjects: @"Zero", @"One", @"Two", nil]];
      [col setDataCell: popUp];

      ds->value = @"One";
      popUp->pick = -1;
      [tv _trackCellAtColumn: 0 row: 0 withEvent: nil];
      PASS(ds->writes == 0,
        "no pick, title value: nothing is written to the data source");

      popUp->pick = 2;
      [tv _trackCellAtColumn: 0 row: 0 withEvent: nil];
      PASS(ds->writes == 1 && [ds->written isEqual: [NSNumber numberWithInt: 2]],
        "a pick, title value: the picked index is written");

      ds->writes = 0;
      ds->value = [NSNumber numberWithInt: 1];
      popUp->pick = -1;
      [tv _trackCellAtColumn: 0 row: 0 withEvent: nil];
      PASS(ds->writes == 0, "no pick, index value: nothing is written");

      popUp->pick = 1;
      [tv _trackCellAtColumn: 0 row: 0 withEvent: nil];
      PASS(ds->writes == 0, "picking the current index writes nothing");

      popUp->pick = 2;
      [tv _trackCellAtColumn: 0 row: 0 withEvent: nil];
      PASS(ds->writes == 1 && [ds->written isEqual: [NSNumber numberWithInt: 2]],
        "a pick, index value: the picked index is written");

      /* Other cells keep working, including with a value of nil. */
      button = AUTORELEASE([[ToggledButtonCell alloc] initTextCell: @""]);
      [button setButtonType: NSSwitchButton];
      [col setDataCell: button];
      ds->writes = 0;
      ds->value = nil;
      [tv _trackCellAtColumn: 0 row: 0 withEvent: nil];
      PASS(ds->writes == 1 && [ds->written intValue] == NSOnState,
        "a toggled check box is written");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSTableView tracked cell value")

  return 0;
}
