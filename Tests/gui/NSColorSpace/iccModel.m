/* A colour space made from ICC profile data takes its model from the data
 * colour space field of the profile header.  It used to report an unknown
 * model whatever the profile held.  These are plain value objects and need
 * no backend.
 */
#include "Testing.h"
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSData.h>
#include <AppKit/NSColorSpace.h>
#include <string.h>

static NSColorSpaceModel
modelFor(const char *signature, BOOL valid)
{
  unsigned char	header[128];
  NSData	*data;
  NSColorSpace	*space;

  memset(header, 0, sizeof(header));
  memcpy(header + 16, signature, 4);
  if (valid)
    {
      memcpy(header + 36, "acsp", 4);
    }
  data = [NSData dataWithBytes: header length: sizeof(header)];
  space = AUTORELEASE([[NSColorSpace alloc] initWithICCProfileData: data]);
  return [space colorSpaceModel];
}

int
main(int argc, char **argv)
{
  NSAutoreleasePool	*pool = [NSAutoreleasePool new];

  START_SET("NSColorSpace ICC profile model")
    PASS(modelFor("RGB ", YES) == NSRGBColorSpaceModel,
      "an RGB profile gives an RGB colour space");
    PASS(modelFor("GRAY", YES) == NSGrayColorSpaceModel,
      "a gray profile gives a gray colour space");
    PASS(modelFor("CMYK", YES) == NSCMYKColorSpaceModel,
      "a CMYK profile gives a CMYK colour space");
    PASS(modelFor("Lab ", YES) == NSLABColorSpaceModel,
      "a Lab profile gives a Lab colour space");
    PASS(modelFor("XYZ ", YES) == NSUnknownColorSpaceModel,
      "an XYZ profile gives an unknown model");
    PASS(modelFor("RGB ", NO) == NSUnknownColorSpaceModel,
      "data without the profile signature gives an unknown model");
  END_SET("NSColorSpace ICC profile model")

  [pool release];
  return 0;
}
