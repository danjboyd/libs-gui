/* -[NSTableView dragImageForRowsWithIndexes:tableColumns:event:offset:]
   and -dragImageForRows:event:dragImageOffset: answer an image of the
   dragged rows' cells as the table draws them, with the rows between them
   left transparent, and give the image's centre relative to the mouse.
   They used to answer an empty 8 by 8 image.  The table needs the
   backend, so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSBitmapImageRep.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSTableView.h>
#import <AppKit/NSWindow.h>

@interface Source : NSObject
@end
@implementation Source
- (NSInteger) numberOfRowsInTableView: (NSTableView *)tv
{
  return 4;
}
- (id) tableView: (NSTableView *)tv
objectValueForTableColumn: (NSTableColumn *)col
	     row: (NSInteger)row
{
  return [NSString stringWithFormat: @"row %ld", (long)row];
}
@end

/* The alpha of the image's pixel at x, y from the top. */
static unsigned
alphaAt(NSImage *image, NSInteger x, NSInteger y)
{
  NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:
    [image TIFFRepresentation]];
  NSUInteger p[5];

  [rep getPixel: p atX: x y: y];
  return [rep hasAlpha] ? p[[rep samplesPerPixel] - 1] : 255;
}

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *w;
  NSTableView *tv;
  NSTableColumn *a;
  NSTableColumn *b;
  NSMutableIndexSet *rows;
  NSImage *image;
  NSRect first;
  NSRect last;
  NSEvent *event;
  NSPoint offset = NSZeroPoint;
  NSPoint mouse;

  START_SET("NSTableView drag images")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  w = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 200, 150)
	      styleMask: NSBorderlessWindowMask
		backing: NSBackingStoreBuffered
		  defer: NO]);
  tv = AUTORELEASE([[NSTableView alloc]
    initWithFrame: NSMakeRect(0, 0, 200, 150)]);
  a = AUTORELEASE([[NSTableColumn alloc] initWithIdentifier: @"a"]);
  b = AUTORELEASE([[NSTableColumn alloc] initWithIdentifier: @"b"]);
  [a setWidth: 80];
  [b setWidth: 60];
  [tv addTableColumn: a];
  [tv addTableColumn: b];
  [tv setBackgroundColor: [NSColor whiteColor]];
  [tv setDataSource: AUTORELEASE([Source new])];
  [tv reloadData];
  [w setContentView: tv];

  rows = [NSMutableIndexSet indexSetWithIndex: 0];
  [rows addIndex: 2];
  first = [tv rectOfRow: 0];
  last = [tv rectOfRow: 2];

  image = [tv dragImageForRowsWithIndexes: rows
			     tableColumns: [NSArray arrayWithObjects: a, b, nil]
				    event: nil
				   offset: &offset];
  PASS(image != nil && NSHeight(first) > 8
    && [image size].height == NSMaxY(last) - NSMinY(first),
    "the image spans the dragged rows");
  PASS([image size].width == NSWidth(NSUnionRect([tv rectOfColumn: 0],
    [tv rectOfColumn: 1])),
    "the image spans the dragged columns");
  PASS(alphaAt(image, 2, NSHeight(first) / 2) > 0,
    "the first dragged row is drawn");
  PASS(alphaAt(image, 2, NSHeight(first) * 3 / 2) == 0,
    "the row between the dragged rows is left out");

  image = [tv dragImageForRowsWithIndexes: rows
			     tableColumns: [NSArray arrayWithObject: b]
				    event: nil
				   offset: &offset];
  PASS([image size].width == NSWidth([tv rectOfColumn: 1]),
    "only the given columns are drawn");

  mouse = NSMakePoint(10, NSMidY(first));
  event = [NSEvent mouseEventWithType: NSLeftMouseDragged
			     location: [tv convertPoint: mouse toView: nil]
			modifierFlags: 0
			    timestamp: 0
			 windowNumber: [w windowNumber]
			      context: nil
			  eventNumber: 0
			   clickCount: 1
			     pressure: 1.0];
  image = [tv dragImageForRows: [NSArray arrayWithObjects:
    [NSNumber numberWithInt: 0], [NSNumber numberWithInt: 2], nil]
			 event: event
	       dragImageOffset: &offset];
  PASS([image size].height == NSMaxY(last) - NSMinY(first),
    "the older method draws the rows too");
  PASS(fabs(offset.x - (NSMidX(NSUnionRect(first, last)) - mouse.x)) < 0.5
    && fabs(offset.y - (NSMidY(NSUnionRect(first, last)) - mouse.y)) < 0.5,
    "the offset is the image's centre relative to the mouse");

  END_SET("NSTableView drag images")

  [pool release];
  return 0;
}
