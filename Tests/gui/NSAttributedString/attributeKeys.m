/* The AppKit attribute names have the NSAttributedStringKey type, as in
   Cocoa, so Swift imports them as the members of NSAttributedString.Key
   (NSAttributedString.Key.font for NSFontAttributeName).  Their values,
   the strings stored in archives and RTF, are unchanged. */
#import <Foundation/Foundation.h>
#import <AppKit/NSAttributedString.h>
#import "Testing.h"

int main()
{
  NSAutoreleasePool		*arp = [NSAutoreleasePool new];
  NSAttributedStringKey		keys[] = {
    NSAttachmentAttributeName, NSBackgroundColorAttributeName,
    NSBaselineOffsetAttributeName, NSCursorAttributeName,
    NSExpansionAttributeName, NSFontAttributeName,
    NSForegroundColorAttributeName, NSKernAttributeName,
    NSLigatureAttributeName, NSLinkAttributeName,
    NSObliquenessAttributeName, NSParagraphStyleAttributeName,
    NSShadowAttributeName, NSStrikethroughColorAttributeName,
    NSStrikethroughStyleAttributeName, NSStrokeColorAttributeName,
    NSStrokeWidthAttributeName, NSSuperscriptAttributeName,
    NSToolTipAttributeName, NSUnderlineColorAttributeName,
    NSUnderlineStyleAttributeName, NSTextAlternativesAttributeName,
    NSWritingDirectionAttributeName, NSGlyphInfoAttributeName,
    NSCharacterShapeAttributeName, NSSpellingStateAttributeName
  };
  NSUInteger			count = sizeof(keys) / sizeof(keys[0]);
  NSMutableSet			*seen = [NSMutableSet set];
  NSMutableAttributedString	*s;
  NSUInteger			i;

  START_SET("AppKit attribute keys")

  for (i = 0; i < count; i++)
    {
      if (keys[i] != nil)
	{
	  [seen addObject: keys[i]];
	}
    }
  PASS([seen count] == count, "the attribute keys are distinct strings");
  PASS_EQUAL(NSFontAttributeName, @"NSFont",
    "NSFontAttributeName keeps its value");
  PASS_EQUAL(NSForegroundColorAttributeName, @"NSColor",
    "NSForegroundColorAttributeName keeps its value");
  PASS_EQUAL(NSSuperscriptAttributeName, @"NSSuperScript",
    "NSSuperscriptAttributeName keeps its value");

  s = AUTORELEASE([[NSMutableAttributedString alloc] initWithString: @"abc"]);
  [s addAttribute: NSKernAttributeName
	    value: [NSNumber numberWithInt: 2]
	    range: NSMakeRange(0, 3)];
  PASS_EQUAL([s attribute: NSKernAttributeName atIndex: 1 effectiveRange: NULL],
    [NSNumber numberWithInt: 2], "a key names an attribute");
  PASS([[s attributesAtIndex: 0 effectiveRange: NULL]
    objectForKey: @"NSKern"] != nil, "a key is the attribute's string");

  {
    GS_GENERIC_CLASS(NSDictionary, NSAttributedStringKey, id)	*attrs;

    attrs = [s fontAttributesInRange: NSMakeRange(0, 3)];
    PASS_EQUAL([attrs objectForKey: NSKernAttributeName],
      [NSNumber numberWithInt: 2],
      "font attribute dictionaries are keyed by NSAttributedStringKey");
  }

  END_SET("AppKit attribute keys")

  [arp release];
  return 0;
}
