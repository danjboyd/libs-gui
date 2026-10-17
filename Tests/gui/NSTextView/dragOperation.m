/* -[NSTextView dragOperationForDraggingInfo:type:] answers no operation
   for a text view that cannot be edited, moves text dragged within the
   view, and copies anything else, within the operations the source
   allows.  It used to answer copy and generic whatever the drag.  The view
   needs the backend, so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSDragging.h>
#import <AppKit/NSPasteboard.h>
#import <AppKit/NSTextView.h>

@interface DragInfo : NSObject
{
@public
  id source;
  NSDragOperation mask;
}
@end

@implementation DragInfo
- (id) draggingSource
{
  return source;
}
- (NSDragOperation) draggingSourceOperationMask
{
  return mask;
}
@end

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSTextView *tv;
  DragInfo *info;
  NSDragOperation op;

  START_SET("NSTextView dragOperationForDraggingInfo:type:")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  tv = AUTORELEASE([[NSTextView alloc] initWithFrame: NSMakeRect(0, 0, 200, 100)]);
  info = AUTORELEASE([DragInfo new]);
  info->mask = NSDragOperationEvery;

  info->source = nil;
  op = [tv dragOperationForDraggingInfo: (id)info type: NSStringPboardType];
  PASS((op & NSDragOperationCopy) && !(op & NSDragOperationMove),
    "text from elsewhere is copied");

  info->source = tv;
  op = [tv dragOperationForDraggingInfo: (id)info type: NSStringPboardType];
  PASS((op & NSDragOperationMove) && !(op & NSDragOperationCopy),
    "text dragged within the view is moved");

  info->source = nil;
  info->mask = NSDragOperationLink;
  op = [tv dragOperationForDraggingInfo: (id)info type: NSStringPboardType];
  PASS(op == NSDragOperationNone,
    "nothing is done that the source does not allow");

  [tv setEditable: NO];
  info->mask = NSDragOperationEvery;
  op = [tv dragOperationForDraggingInfo: (id)info type: NSStringPboardType];
  PASS(op == NSDragOperationNone,
    "nothing can be dropped on a view that cannot be edited");

  END_SET("NSTextView dragOperationForDraggingInfo:type:")

  [pool release];
  return 0;
}
