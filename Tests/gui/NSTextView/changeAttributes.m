/* -changeAttributes: converts the attributes of the selected text only.  It
   used to set the converted attributes on the whole attribute run holding
   each selected character, so text outside the selection changed too.  The
   text view lays out through the theme and font backend, so the set is
   skipped when the backend is unavailable. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSGeometry.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSTextStorage.h>
#include <AppKit/NSTextView.h>

static NSString *marker = @"GSTestMarker";

@interface Converter : NSObject
- (NSDictionary *) convertAttributes: (NSDictionary *)attributes;
@end

@implementation Converter
- (NSDictionary *) convertAttributes: (NSDictionary *)attributes
{
  NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:
    attributes];

  [d setObject: @"yes" forKey: marker];
  return d;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSTextView *tv;
  NSTextStorage *ts;

  START_SET("NSTextView changeAttributes:")

  NS_DURING
    {
      [NSApplication sharedApplication];
    }
  NS_HANDLER
    {
      if ([[localException name] isEqualToString: NSInternalInconsistencyException])
        SKIP("It looks like GNUstep backend is not yet installed")
    }
  NS_ENDHANDLER

  tv = AUTORELEASE([[NSTextView alloc]
    initWithFrame: NSMakeRect(0, 0, 200, 100)]);
  [tv setEditable: YES];
  [tv setRichText: YES];
  [tv setString: @"abcdef"];
  [tv setSelectedRange: NSMakeRange(2, 2)];

  [tv changeAttributes: AUTORELEASE([Converter new])];

  ts = [tv textStorage];
  PASS([ts attribute: marker atIndex: 2 effectiveRange: NULL] != nil
    && [ts attribute: marker atIndex: 3 effectiveRange: NULL] != nil,
    "the selected text gets the converted attributes");
  PASS([ts attribute: marker atIndex: 1 effectiveRange: NULL] == nil,
    "the text before the selection keeps its attributes");
  PASS([ts attribute: marker atIndex: 4 effectiveRange: NULL] == nil,
    "the text after the selection keeps its attributes");

  END_SET("NSTextView changeAttributes:")

  [pool release];
  return 0;
}
