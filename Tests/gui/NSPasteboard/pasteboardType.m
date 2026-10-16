/* NSPasteboardType is a typed extensible string enumeration, as in Cocoa,
   so Swift can import it as NSPasteboard.PasteboardType with the
   NSPasteboardType... constants as its members.  The constants, including
   Cocoa's NSPasteboardTypeURL and NSPasteboardTypeFileURL, are declared
   with the type, and a view registers dragged types given as an array of
   them. */
#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSPasteboard.h>
#import <AppKit/NSView.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  NSPasteboardType	type = NSPasteboardTypeFileURL;
  NSArray		*types;
  NSView		*view;

  START_SET("NSPasteboardType")

  PASS([NSPasteboardTypeString isEqual: NSStringPboardType],
    "NSPasteboardTypeString is the string type");
  PASS([NSPasteboardTypeURL isEqual: NSURLPboardType],
    "NSPasteboardTypeURL is the URL type");
  PASS([type length] > 0 && ![type isEqual: NSPasteboardTypeURL]
    && ![type isEqual: NSFilenamesPboardType],
    "NSPasteboardTypeFileURL is a type of its own");

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  types = [NSArray arrayWithObjects: NSPasteboardTypeFileURL,
    NSPasteboardTypeString, nil];
  view = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(0, 0, 10, 10)]);
  [view registerForDraggedTypes: types];
  PASS([[view registeredDraggedTypes] containsObject: NSPasteboardTypeFileURL]
    && [[view registeredDraggedTypes] containsObject: NSPasteboardTypeString],
    "a view registers NSPasteboardType dragged types");

  END_SET("NSPasteboardType")

  [arp release];
  return 0;
}
