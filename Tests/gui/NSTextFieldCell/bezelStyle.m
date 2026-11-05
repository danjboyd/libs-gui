/* A rounded bezel draws differently from a square one, through the theme, and
 * a theme with its own border drawing keeps it.
 */
#import "Testing.h"
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <GNUstepGUI/GSTheme.h>

@interface BorderTheme : GSTheme
{
@public
  unsigned	borders;
}
@end
@implementation BorderTheme
- (void) drawBorderType: (NSBorderType)aType
		  frame: (NSRect)frame
		   view: (NSView*)view
{
  borders++;
}
@end

static NSData *
drawn(NSTextField *field)
{
  NSBitmapImageRep	*rep;

  rep = [field bitmapImageRepForCachingDisplayInRect: [field bounds]];
  [field cacheDisplayInRect: [field bounds] toBitmapImageRep: rep];
  return [rep TIFFRepresentation];
}

int main()
{
  START_SET("NSTextFieldCell bezel style")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  {
    NSTextField	*field = AUTORELEASE([[NSTextField alloc]
      initWithFrame: NSMakeRect(0, 0, 120, 24)]);
    NSData	*square;
    NSData	*rounded;
    NSData	*squareAgain;
    BorderTheme	*theme;
    GSTheme	*old = [GSTheme theme];

    [field setBezeled: YES];
    [field setBezelStyle: NSTextFieldSquareBezel];
    square = drawn(field);
    [field setBezelStyle: NSTextFieldRoundedBezel];
    rounded = drawn(field);
    [field setBezelStyle: NSTextFieldSquareBezel];
    squareAgain = drawn(field);

    PASS(square != nil && rounded != nil, "both styles draw");
    PASS(NO == [square isEqual: rounded], "they draw differently");
    PASS([square isEqual: squareAgain], "going back draws the square one again");

    theme = AUTORELEASE([[BorderTheme alloc] initWithBundle: nil]);
    [GSTheme setTheme: theme];
    [field setBezelStyle: NSTextFieldRoundedBezel];
    theme->borders = 0;
    drawn(field);
    PASS(theme->borders > 0, "a rounded bezel uses a theme's own border drawing");
    [GSTheme setTheme: old];
  }

  END_SET("NSTextFieldCell bezel style")
  return 0;
}
