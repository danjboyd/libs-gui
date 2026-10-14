/* A sound written to a pasteboard can be read back from it: the sound's
   data is written, which -initWithPasteboard: reads.  An archive of the
   sound object used to be written instead, which no sound plug-in reads.
   The set needs the sound plug-ins and the gpbs server, and is skipped
   without them. */
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSException.h>
#include <AppKit/NSPasteboard.h>
#include <AppKit/NSSound.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSSound *sound;
  NSSound *copy = nil;
  NSPasteboard *pb = nil;

  START_SET("NSSound pasteboard round trip")

  sound = [NSSound soundNamed: @"Pop"];
  if (sound == nil)
    {
      SKIP("the sound plug-ins are not available")
    }
  NS_DURING
    {
      pb = [NSPasteboard pasteboardWithUniqueName];
      [sound writeToPasteboard: pb];
    }
  NS_HANDLER
    {
      pb = nil;
    }
  NS_ENDHANDLER
  if (pb == nil)
    {
      SKIP("the pasteboard server is not available")
    }

  copy = AUTORELEASE([[NSSound alloc] initWithPasteboard: pb]);
  PASS(copy != nil, "a sound can be read from the pasteboard it was written to");
  PASS(copy != nil && [copy duration] == [sound duration],
    "the sound read back has the same duration");

  [pb releaseGlobally];

  END_SET("NSSound pasteboard round trip")

  [pool release];
  return 0;
}
