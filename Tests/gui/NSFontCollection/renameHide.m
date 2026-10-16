/* +renameFontCollectionWithName:visibility:toName:error: saves a shown
   collection under the new name, and +hideFontCollectionWithName:
   visibility:error: removes it.  Both raised, because removing the
   collection's file stored a nil file name in a dictionary; renaming
   raised before saving under the new name, so the collection was lost.
   Removing the file also removes the collection from the list of
   available collections, so both methods must keep a collection that
   only the list holds until they are done with it.  The collections are
   saved in the user's Library. */
#include "Testing.h"
#include <objc/runtime.h>
#include <Foundation/Foundation.h>
#include <Foundation/NSDebug.h>
#include <AppKit/NSFontCollection.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSString *suffix = [NSString stringWithFormat: @"%d",
    [[NSProcessInfo processInfo] processIdentifier]];
  NSString *oldName = [@"GSTestRenameFrom" stringByAppendingString: suffix];
  NSString *newName = [@"GSTestRenameTo" stringByAppendingString: suffix];
  NSString *onlyName = [@"GSTestOnlyFrom" stringByAppendingString: suffix];
  NSString *onlyNewName = [@"GSTestOnlyTo" stringByAppendingString: suffix];
  NSAutoreleasePool *inner;
  NSFontCollection *fc;
  BOOL ok;

  START_SET("NSFontCollection rename and hide")

  fc = [NSFontCollection fontCollectionWithDescriptors: [NSArray array]];
  ok = [NSFontCollection showFontCollection: fc
                                   withName: oldName
                                 visibility: NSFontCollectionVisibilityUser
                                      error: NULL];
  PASS(ok && [NSFontCollection fontCollectionWithName: oldName] != nil,
       "a shown collection is found under its name");

  ok = NO;
  NS_DURING
    ok = [NSFontCollection renameFontCollectionWithName: oldName
                                             visibility: NSFontCollectionVisibilityUser
                                                 toName: newName
                                                  error: NULL];
  NS_HANDLER
    NSLog(@"rename raised %@", localException);
  NS_ENDHANDLER
  PASS(ok, "renaming a collection succeeds");
  PASS([NSFontCollection fontCollectionWithName: oldName] == nil,
       "the collection is no longer found under the old name");
  PASS([NSFontCollection fontCollectionWithName: newName] != nil,
       "the collection is found under the new name");

  ok = NO;
  NS_DURING
    ok = [NSFontCollection hideFontCollectionWithName: newName
                                           visibility: NSFontCollectionVisibilityUser
                                                error: NULL];
  NS_HANDLER
    NSLog(@"hide raised %@", localException);
  NS_ENDHANDLER
  PASS(ok, "hiding a collection succeeds");
  PASS([NSFontCollection fontCollectionWithName: newName] == nil,
       "a hidden collection is no longer found");

  /* Show a collection in a pool of its own, so that once the pool is
   * gone the list of available collections holds the only reference.
   * With zombies enabled, a collection that renaming or hiding
   * deallocates before it is done with it is a zombie when the method
   * returns, instead of a crash.
   */
  inner = [NSAutoreleasePool new];
  fc = [NSFontCollection fontCollectionWithDescriptors: [NSArray array]];
  ok = [NSFontCollection showFontCollection: fc
                                   withName: onlyName
                                 visibility: NSFontCollectionVisibilityUser
                                      error: NULL];
  [inner release];
  PASS(ok && [fc retainCount] == 1,
       "the list of available collections holds the only reference");

  NSZombieEnabled = YES;

  inner = [NSAutoreleasePool new];
  ok = NO;
  NS_DURING
    ok = [NSFontCollection renameFontCollectionWithName: onlyName
                                             visibility: NSFontCollectionVisibilityUser
                                                 toName: onlyNewName
                                                  error: NULL];
  NS_HANDLER
    NSLog(@"rename raised %@", localException);
  NS_ENDHANDLER
  PASS(ok, "renaming a collection held only by that list succeeds");
  PASS(object_getClass(fc) == [NSFontCollection class],
       "renaming keeps the collection until it is done with it");
  [inner release];
  PASS(object_getClass(fc) == [NSFontCollection class]
    && [NSFontCollection fontCollectionWithName: onlyNewName] == fc,
       "the renamed collection is found under the new name");

  inner = [NSAutoreleasePool new];
  ok = NO;
  NS_DURING
    ok = [NSFontCollection hideFontCollectionWithName: onlyNewName
                                           visibility: NSFontCollectionVisibilityUser
                                                error: NULL];
  NS_HANDLER
    NSLog(@"hide raised %@", localException);
  NS_ENDHANDLER
  PASS(ok, "hiding a collection held only by that list succeeds");
  PASS(object_getClass(fc) == [NSFontCollection class],
       "hiding keeps the collection until it is done with it");
  [inner release];

  NSZombieEnabled = NO;
  PASS([NSFontCollection fontCollectionWithName: onlyNewName] == nil,
       "the hidden collection is no longer found");

  END_SET("NSFontCollection rename and hide")

  [pool release];
  return 0;
}
