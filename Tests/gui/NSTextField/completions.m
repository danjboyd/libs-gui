/* A text field editing through a text view passes the text view's request
   for completions on to its delegate's
   control:textView:completions:forPartialWordRange:indexOfSelectedItem:.
   The text view asks its delegate, the text field, for
   textView:completions:forPartialWordRange:indexOfSelectedItem:, which
   NSTextField did not implement, so the control delegate was never asked.
   The text view needs the backend, so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSTextField.h>
#import <AppKit/NSTextView.h>

@interface CompletionDelegate : NSObject
{
@public
  int calls;
  id control;
  NSRange range;
}
@end

@implementation CompletionDelegate
- (NSArray *) control: (NSControl *)c
             textView: (NSTextView *)tv
          completions: (NSArray *)words
  forPartialWordRange: (NSRange)charRange
  indexOfSelectedItem: (int *)index
{
  calls++;
  control = c;
  range = charRange;
  *index = 1;
  return [NSArray arrayWithObjects: @"field", @"fielding", nil];
}
@end

int main()
{
  CREATE_AUTORELEASE_POOL(arp);
  NSTextField *field;
  NSTextView *tv;
  CompletionDelegate *d;
  NSArray *answer;
  NSInteger index = -1;

  START_SET("NSTextField completions")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  field = AUTORELEASE([[NSTextField alloc] initWithFrame: NSMakeRect(0, 0, 100, 22)]);
  d = AUTORELEASE([CompletionDelegate new]);
  [field setDelegate: (id<NSTextFieldDelegate>)d];
  tv = AUTORELEASE([[NSTextView alloc] initWithFrame: NSMakeRect(0, 0, 100, 22)]);
  [tv setString: @"fie"];
  [tv setDelegate: (id<NSTextViewDelegate>)field];

  answer = [tv completionsForPartialWordRange: NSMakeRange(0, 3)
                          indexOfSelectedItem: &index];
  PASS(d->calls == 1 && d->control == field,
       "the control delegate is asked for completions with the field");
  PASS(NSEqualRanges(d->range, NSMakeRange(0, 3)),
       "the delegate gets the partial word range");
  PASS([answer count] == 2 && [[answer objectAtIndex: 1] isEqual: @"fielding"],
       "the text view gets the delegate's completions");
  PASS(index == 1, "the text view gets the delegate's selected index");

  END_SET("NSTextField completions")

  DESTROY(arp);
  return 0;
}
