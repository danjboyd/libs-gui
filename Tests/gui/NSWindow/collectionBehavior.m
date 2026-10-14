/* A window keeps the collection behavior it is given.  The setter used to
   drop it and the getter always answered the default behavior. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSWindow.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *w;
  NSWindowCollectionBehavior b;

  START_SET("NSWindow collectionBehavior")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  w = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 120, 120)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: YES]);
  PASS([w collectionBehavior] == NSWindowCollectionBehaviorDefault,
    "a new window has the default collection behavior");

  [w setCollectionBehavior: NSWindowCollectionBehaviorMoveToActiveSpace];
  PASS([w collectionBehavior] == NSWindowCollectionBehaviorMoveToActiveSpace,
    "a window keeps the collection behavior it is given");

  b = NSWindowCollectionBehaviorManaged
    | NSWindowCollectionBehaviorFullScreenPrimary;
  [w setCollectionBehavior: b];
  PASS([w collectionBehavior] == b,
    "a window keeps a combined collection behavior");

  END_SET("NSWindow collectionBehavior")

  [pool release];
  return 0;
}
