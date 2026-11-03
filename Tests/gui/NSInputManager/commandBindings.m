/* Key bindings can name the Command modifier.  A binding file entry such
   as "Command-LeftArrow" is parsed (it used to be dropped as an unknown
   modifier) and matched (the input manager used to clear Command from the
   keystroke, so Command-LeftArrow was looked up as LeftArrow).  A Command
   keystroke with no binding of its own still falls back to its binding
   without Command, and a menu key equivalent still takes a Command
   keystroke before the key bindings see it.  Key events and menus need
   the backend, so the set is skipped without it. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSFileManager.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSEvent.h>
#include <AppKit/NSInputManager.h>
#include <AppKit/NSMenu.h>
#include <AppKit/NSMenuItem.h>
#include <AppKit/NSWindow.h>

/* A client that records the commands the input manager sends it.  */
@interface Client : NSObject
{
@public
  NSMutableArray *commands;
}
@end
@implementation Client
- (void) doCommandBySelector: (SEL)aSelector
{
  [commands addObject: NSStringFromSelector(aSelector)];
}
- (void) insertText: (id)aString
{
  [commands addObject: @"insertText:"];
}
@end

@interface MenuTarget : NSObject
{
@public
  int fired;
}
- (void) copyAction: (id)sender;
@end
@implementation MenuTarget
- (void) copyAction: (id)sender
{
  fired++;
}
@end

static NSEvent *
keyEvent(unichar character, NSUInteger modifiers, NSInteger windowNumber)
{
  NSString *string = [NSString stringWithCharacters: &character length: 1];

  return [NSEvent keyEventWithType: NSKeyDown
			  location: NSZeroPoint
		     modifierFlags: modifiers
			 timestamp: 0
		      windowNumber: windowNumber
			   context: nil
			characters: string
       charactersIgnoringModifiers: string
			 isARepeat: NO
			   keyCode: 0];
}

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSInputManager *manager;
  NSString *path;
  Client *client;
  NSWindow *window;
  NSMenu *menu;
  MenuTarget *target;
  NSUInteger arrow = NSFunctionKeyMask;

  START_SET("NSInputManager Command key bindings")

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

  PASS([NSInputManager parseKey: @"Command-LeftArrow"
		  intoCharacter: NULL
		   andModifiers: NULL],
    "a key with the Command modifier is parsed");

  path = [NSTemporaryDirectory() stringByAppendingPathComponent:
    @"CommandWordMoves-test.dict"];
  [[NSDictionary dictionaryWithObjectsAndKeys:
    @"moveWordLeft:", @"Command-LeftArrow",
    @"moveRight:", @"RightArrow",
    @"selectAll:", @"Command-c",
    nil] writeToFile: path atomically: YES];
  manager = [NSInputManager currentInputManager];
  [manager loadBindingsFromFile: path];
  [[NSFileManager defaultManager] removeFileAtPath: path handler: nil];

  client = AUTORELEASE([Client new]);
  client->commands = [NSMutableArray array];
  [manager handleKeyboardEvents:
    [NSArray arrayWithObject: keyEvent(NSLeftArrowFunctionKey,
      arrow | NSCommandKeyMask, 0)] client: client];
  PASS_EQUAL(client->commands, [NSArray arrayWithObject: @"moveWordLeft:"],
    "a Command-LeftArrow binding fires");

  [client->commands removeAllObjects];
  [manager handleKeyboardEvents:
    [NSArray arrayWithObject: keyEvent(NSRightArrowFunctionKey,
      arrow | NSCommandKeyMask, 0)] client: client];
  PASS_EQUAL(client->commands, [NSArray arrayWithObject: @"moveRight:"],
    "an unbound Command keystroke falls back to its binding without Command");

  /* A menu key equivalent takes a Command keystroke first.  */
  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(100, 100, 200, 100)
	      styleMask: NSTitledWindowMask
		backing: NSBackingStoreBuffered
		  defer: NO]);
  [window setReleasedWhenClosed: NO];
  [window makeKeyAndOrderFront: nil];
  target = AUTORELEASE([MenuTarget new]);
  menu = AUTORELEASE([[NSMenu alloc] initWithTitle: @"Main"]);
  [[menu addItemWithTitle: @"Copy"
		   action: @selector(copyAction:)
	    keyEquivalent: @"c"] setTarget: target];
  [NSApp setMainMenu: menu];
  [client->commands removeAllObjects];
  [NSApp sendEvent: keyEvent('c', NSCommandKeyMask, [window windowNumber])];
  PASS(target->fired == 1 && [client->commands count] == 0,
    "a menu key equivalent takes a Command keystroke before the bindings");

  END_SET("NSInputManager Command key bindings")

  [pool release];
  return 0;
}
