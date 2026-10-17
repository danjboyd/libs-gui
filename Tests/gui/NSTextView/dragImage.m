/* -[NSTextView dragImageForSelectionWithEvent:origin:] answers an image of
   the selected text and its lower left corner in the view, and nil when
   nothing is selected.  It used to answer nil always.  The view needs the
   backend, so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSBitmapImageRep.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSLayoutManager.h>
#import <AppKit/NSTextContainer.h>
#import <AppKit/NSTextView.h>

static BOOL
hasInk(NSImage *image)
{
  NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:
    [image TIFFRepresentation]];
  NSInteger x, y;

  for (y = 0; y < [rep pixelsHigh]; y++)
    {
      for (x = 0; x < [rep pixelsWide]; x++)
	{
	  if ([[rep colorAtX: x y: y] alphaComponent] > 0.5)
	    {
	      return YES;
	    }
	}
    }
  return NO;
}

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSTextView *tv;
  NSImage *image;
  NSPoint origin = NSMakePoint(-1, -1);
  NSRect rect;
  NSPoint o;

  START_SET("NSTextView dragImageForSelectionWithEvent:origin:")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  tv = AUTORELEASE([[NSTextView alloc] initWithFrame: NSMakeRect(0, 0, 300, 100)]);
  [tv setString: @"Hello world"];

  [tv setSelectedRange: NSMakeRange(0, 0)];
  PASS([tv dragImageForSelectionWithEvent: nil origin: &origin] == nil,
    "there is no image without a selection");

  [tv setSelectedRange: NSMakeRange(0, 5)];
  image = [tv dragImageForSelectionWithEvent: nil origin: &origin];
  rect = [[tv layoutManager] boundingRectForGlyphRange: NSMakeRange(0, 5)
				       inTextContainer: [tv textContainer]];
  o = [tv textContainerOrigin];
  rect = NSIntegralRect(NSOffsetRect(rect, o.x, o.y));
  PASS(image != nil, "the selection has an image");
  PASS(NSEqualSizes([image size], rect.size),
    "the image is the size of the selected glyphs");
  PASS(NSEqualPoints(origin, NSMakePoint(NSMinX(rect), NSMaxY(rect))),
    "the origin is the image's lower left corner in the view");
  PASS(hasInk(image), "the selected text is drawn");

  END_SET("NSTextView dragImageForSelectionWithEvent:origin:")

  [pool release];
  return 0;
}
