/* The input manager inserts typed text into a client that adopts
   NSTextInputClient with -insertText:replacementRange:, giving no range to
   replace, and into any other client with -insertText:.  The input manager
   needs the backend, so the set is skipped without it. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSEvent.h>
#include <AppKit/NSInputManager.h>
#include <AppKit/NSTextInputClient.h>

/* A client that records how text is inserted into it.  */
@interface InputClient : NSObject <NSTextInputClient>
{
@public
  NSMutableString *text;
  NSRange replacementRange;
  int plainInserts;
}
@end
@implementation InputClient
- (BOOL) hasMarkedText { return NO; }
- (NSRange) markedRange { return NSMakeRange(NSNotFound, 0); }
- (NSRange) selectedRange { return NSMakeRange([text length], 0); }
- (void) setMarkedText: (id)string
         selectedRange: (NSRange)selectedRange
      replacementRange: (NSRange)range {}
- (void) unmarkText {}
- (NSArray *) validAttributesForMarkedText { return [NSArray array]; }
- (NSAttributedString *) attributedSubstringForProposedRange: (NSRange)range
  actualRange: (NSRangePointer)actualRange { return nil; }
- (void) insertText: (id)string replacementRange: (NSRange)range
{
  [text appendString: string];
  replacementRange = range;
}
- (void) insertText: (id)string
{
  plainInserts++;
}
- (NSUInteger) characterIndexForPoint: (NSPoint)point { return 0; }
- (NSRect) firstRectForCharacterRange: (NSRange)range
                          actualRange: (NSRangePointer)actualRange
{
  return NSZeroRect;
}
- (void) doCommandBySelector: (SEL)selector {}
@end

/* A client that only knows -insertText:.  */
@interface PlainClient : NSObject
{
@public
  NSMutableString *text;
}
@end
@implementation PlainClient
- (void) insertText: (id)string
{
  [text appendString: string];
}
- (void) doCommandBySelector: (SEL)selector {}
@end

static NSEvent *
keyEvent(NSString *characters)
{
  return [NSEvent keyEventWithType: NSKeyDown
			  location: NSZeroPoint
		     modifierFlags: 0
			 timestamp: 0
		      windowNumber: 0
			   context: nil
			characters: characters
       charactersIgnoringModifiers: characters
			 isARepeat: NO
			   keyCode: 0];
}

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSInputManager *manager;
  InputClient *client;
  PlainClient *plain;

  START_SET("NSInputManager NSTextInputClient")

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

  manager = [NSInputManager currentInputManager];

  client = AUTORELEASE([InputClient new]);
  client->text = [NSMutableString string];
  client->replacementRange = NSMakeRange(0, 0);
  [manager handleKeyboardEvents: [NSArray arrayWithObject: keyEvent(@"b")]
			 client: client];
  PASS_EQUAL(client->text, @"b",
    "a text input client is sent -insertText:replacementRange:");
  PASS(client->replacementRange.location == NSNotFound
    && client->plainInserts == 0,
    "no replacement range is given and -insertText: is not sent");

  plain = AUTORELEASE([PlainClient new]);
  plain->text = [NSMutableString string];
  [manager handleKeyboardEvents: [NSArray arrayWithObject: keyEvent(@"c")]
			 client: plain];
  PASS_EQUAL(plain->text, @"c", "any other client is sent -insertText:");

  END_SET("NSInputManager NSTextInputClient")

  DESTROY(pool);
  return 0;
}
