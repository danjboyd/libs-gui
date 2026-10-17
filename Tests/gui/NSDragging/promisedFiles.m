/* -[NSView dragPromisedFilesOfTypes:fromRect:source:slideBack:event:]
   drags the icon of the first file type, with the types on the drag
   pasteboard as promised files.  It used to have no image to drag
   ("FIXME: Where to get the image from?"), so it always answered NO.  The
   view here records the drag instead of running it.  The views need the
   backend, so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSDragging.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSPasteboard.h>
#import <AppKit/NSView.h>
#import <AppKit/NSWorkspace.h>

@interface RecordingView : NSView
{
@public
  NSImage *image;
  NSPoint origin;
  NSPasteboard *pasteboard;
  id source;
}
@end

@implementation RecordingView
- (void) dragImage: (NSImage *)anImage
		at: (NSPoint)viewLocation
	    offset: (NSSize)initialOffset
	     event: (NSEvent *)event
	pasteboard: (NSPasteboard *)pboard
	    source: (id)sourceObject
	 slideBack: (BOOL)slideFlag
{
  image = anImage;
  origin = viewLocation;
  pasteboard = pboard;
  source = sourceObject;
}
@end

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  RecordingView *view;
  NSArray *types = [NSArray arrayWithObjects: @"txt", @"rtf", nil];
  BOOL ok;

  START_SET("NSView dragPromisedFilesOfTypes:fromRect:source:slideBack:event:")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  view = AUTORELEASE([[RecordingView alloc]
    initWithFrame: NSMakeRect(0, 0, 100, 100)]);

  NS_DURING
    {
      ok = [view dragPromisedFilesOfTypes: types
				 fromRect: NSMakeRect(10, 20, 32, 32)
				   source: view
				slideBack: YES
				    event: nil];
      PASS(ok, "the promised files are dragged");
      PASS(view->image != nil, "an image is dragged");
      PASS(view->image == [[NSWorkspace sharedWorkspace] iconForFileType: @"txt"],
	"the image is the icon of the first file type");
      PASS(NSEqualPoints(view->origin, NSMakePoint(10, 20)),
	"the image is dragged from the rectangle's origin");
      PASS(view->source == view, "the drag has the source");
      PASS_EQUAL([view->pasteboard propertyListForType: NSFilesPromisePboardType],
	types, "the drag pasteboard promises the file types");
    }
  NS_HANDLER
    PASS(NO, "dragging promised files raises %s",
      [[localException reason] UTF8String]);
  NS_ENDHANDLER

  PASS([view dragPromisedFilesOfTypes: [NSArray array]
			     fromRect: NSMakeRect(10, 20, 32, 32)
			       source: view
			    slideBack: YES
				event: nil] == NO,
    "no file types drag nothing");

  END_SET("NSView dragPromisedFilesOfTypes:fromRect:source:slideBack:event:")

  [pool release];
  return 0;
}
