/* Dragging the header of a column to another place tells the table's
   delegate tableView:didDragTableColumn: with the dragged column, once
   the column has moved; a click on a header does not.  The delegate
   method was never sent.  The header is pressed with queued mouse
   events, through the header view's tracking loop.  The table needs the
   backend, so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSScrollView.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSTableHeaderView.h>
#import <AppKit/NSTableView.h>
#import <AppKit/NSWindow.h>

@interface DragSource : NSObject
{
@public
  NSMutableArray *dragged;
  NSString *firstWhenDragged;
}
@end

@implementation DragSource
- (id) init
{
  if ((self = [super init]) != nil)
    {
      dragged = [NSMutableArray new];
    }
  return self;
}
- (void) dealloc
{
  RELEASE(dragged);
  [super dealloc];
}
- (NSInteger) numberOfRowsInTableView: (NSTableView *)tv
{
  return 2;
}
- (id) tableView: (NSTableView *)tv
  objectValueForTableColumn: (NSTableColumn *)col
	      row: (NSInteger)row
{
  return [col identifier];
}
- (void) tableView: (NSTableView *)tv
didDragTableColumn: (NSTableColumn *)col
{
  [dragged addObject: [col identifier]];
  firstWhenDragged = [[[tv tableColumns] objectAtIndex: 0] identifier];
}
@end

static NSEvent *
mouseEvent(NSWindow *w, NSEventType type, NSPoint point)
{
  return [NSEvent mouseEventWithType: type
                            location: point
                       modifierFlags: 0
                           timestamp: 0
                        windowNumber: [w windowNumber]
                             context: nil
                         eventNumber: 0
                          clickCount: 1
                            pressure: 1.0];
}

/* Presses the header of the column at index, dragging it to x in the
   header view first when drag is YES, and releases it. */
static void
pressHeader(NSTableView *table, NSInteger index, BOOL drag, CGFloat x)
{
  NSTableHeaderView *header = [table headerView];
  NSWindow *w = [table window];
  NSRect rect = [header headerRectOfColumn: index];
  NSPoint down = [header convertPoint: NSMakePoint(NSMidX(rect), NSMidY(rect))
                               toView: nil];
  NSPoint up = down;

  while ([NSApp nextEventMatchingMask: NSAnyEventMask
                            untilDate: [NSDate distantPast]
                               inMode: NSDefaultRunLoopMode
                              dequeue: YES] != nil)
    ;
  if (drag)
    {
      up = [header convertPoint: NSMakePoint(x, NSMidY(rect)) toView: nil];
      [NSApp postEvent: mouseEvent(w, NSLeftMouseDragged, up) atStart: NO];
    }
  [NSApp postEvent: mouseEvent(w, NSLeftMouseUp, up) atStart: NO];
  [w sendEvent: mouseEvent(w, NSLeftMouseDown, down)];
}

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];

  START_SET("NSTableView didDragTableColumn")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  NS_DURING
    {
      NSWindow *w = AUTORELEASE([[NSWindow alloc]
        initWithContentRect: NSMakeRect(100, 100, 320, 220)
                  styleMask: NSTitledWindowMask
                    backing: NSBackingStoreBuffered
                      defer: NO]);
      NSScrollView *scroll = AUTORELEASE([[NSScrollView alloc]
        initWithFrame: NSMakeRect(10, 10, 300, 200)]);
      NSTableView *table = AUTORELEASE([[NSTableView alloc]
        initWithFrame: NSMakeRect(0, 0, 180, 100)]);
      DragSource *source = AUTORELEASE([DragSource new]);
      NSArray *names = [NSArray arrayWithObjects: @"a", @"b", @"c", nil];
      NSUInteger i;

      for (i = 0; i < [names count]; i++)
        {
          NSTableColumn *column = AUTORELEASE([[NSTableColumn alloc]
            initWithIdentifier: [names objectAtIndex: i]]);

          [column setWidth: 60];
          [table addTableColumn: column];
        }
      [table setIntercellSpacing: NSMakeSize(0, 0)];
      [table setAllowsColumnReordering: YES];
      [table setDataSource: source];
      [table setDelegate: source];
      [scroll setDocumentView: table];
      [[w contentView] addSubview: scroll];
      [w makeKeyAndOrderFront: nil];
      [w display];

      pressHeader(table, 1, NO, 0);
      PASS([source->dragged count] == 0,
        "a click on a header is not a drag of its column");

      pressHeader(table, 0, YES, 100);
      PASS([[[[table tableColumns] objectAtIndex: 0] identifier]
        isEqual: @"b"], "dragging a header moves its column");
      PASS([source->dragged isEqual: [NSArray arrayWithObject: @"a"]],
        "the delegate is told of the dragged column");
      PASS([source->firstWhenDragged isEqual: @"b"],
        "the delegate is told once the column has moved");
    }
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException]
      || [[localException name] isEqualToString: @"NSWindowServerCommunicationException"])
      SKIP("No display available")
    else
      [localException raise];
  NS_ENDHANDLER

  END_SET("NSTableView didDragTableColumn")

  DESTROY(arp);
  return 0;
}
