/* GSThemeInstallBackendDefaults(): before the display server is created, a
   theme that draws the window decorations itself turns GNUstep-drawn
   decorations on by setting GSBackHandlesWindowDecorations to NO in the
   GSThemeDomain of its Info-gnustep.plist.  The backend reads that default
   when the display server is created, before the theme is loaded, so the
   function installs it from the theme the GSTheme default names, without
   loading the theme, unless the user has set the default (or the older
   GSX11HandlesWindowDecorations) or a theme has already put its domain in
   place.

   The test makes two theme bundles in a temporary directory, one with the
   default in its GSThemeDomain and one without, names them by absolute
   path in GSTheme, and calls the function directly.  It needs no display.
   Defaults are set in the argument domain, for this process only.
*/

#import "Testing.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSUserDefaults.h>
#import <GNUstepGUI/GSTheme.h>

/* Private to the gui library (GSThemePrivate.h). */
extern void GSThemeInstallBackendDefaults(void);

static NSString * const key = @"GSBackHandlesWindowDecorations";

/* Sets a default for this process only, in the argument domain, or
   removes it when value is nil. */
static void
setDefault(id value, NSString *name)
{
  NSUserDefaults	*defs = [NSUserDefaults standardUserDefaults];
  NSMutableDictionary	*args;

  args = [[defs volatileDomainForName: NSArgumentDomain] mutableCopy];
  if (args == nil)
    {
      args = [NSMutableDictionary new];
    }
  if (value == nil)
    {
      [args removeObjectForKey: name];
    }
  else
    {
      [args setObject: value forKey: name];
    }
  [defs removeVolatileDomainForName: NSArgumentDomain];
  [defs setVolatileDomain: args forName: NSArgumentDomain];
  [args release];
}

/* Makes dir/name.theme with that GSThemeDomain (none when nil); answers
   its path. */
static NSString *
makeTheme(NSString *dir, NSString *name, NSDictionary *domain)
{
  NSString		*path;
  NSString		*resources;
  NSMutableDictionary	*info;

  path = [dir stringByAppendingPathComponent:
    [name stringByAppendingPathExtension: @"theme"]];
  resources = [path stringByAppendingPathComponent: @"Resources"];
  [[NSFileManager defaultManager] createDirectoryAtPath: resources
			    withIntermediateDirectories: YES
					     attributes: nil
						  error: NULL];
  info = [NSMutableDictionary dictionaryWithObject: name
					    forKey: @"CFBundleName"];
  if (domain != nil)
    {
      [info setObject: domain forKey: @"GSThemeDomain"];
    }
  [info writeToFile: [resources stringByAppendingPathComponent:
    @"Info-gnustep.plist"] atomically: YES];
  return path;
}

static NSUInteger
occurrences(NSArray *array, id object)
{
  NSUInteger	count = 0;
  NSUInteger	i;

  for (i = 0; i < [array count]; i++)
    {
      if ([[array objectAtIndex: i] isEqual: object])
	{
	  count++;
	}
    }
  return count;
}

int
main(int argc, char **argv)
{
  NSAutoreleasePool	*pool = [NSAutoreleasePool new];
  NSUserDefaults	*defs = [NSUserDefaults standardUserDefaults];
  NSFileManager		*mgr = [NSFileManager defaultManager];
  NSString		*dir;
  NSString		*drawing;
  NSString		*plain;
  NSArray		*searchList;

  START_SET("GSThemeInstallBackendDefaults")

  dir = [NSTemporaryDirectory() stringByAppendingPathComponent:
    [NSString stringWithFormat: @"backendDefaults-%d",
      [[NSProcessInfo processInfo] processIdentifier]]];
  drawing = makeTheme(dir, @"Drawing",
    [NSDictionary dictionaryWithObject: @"NO" forKey: key]);
  plain = makeTheme(dir, @"Plain", nil);

  setDefault(nil, @"GSTheme");
  GSThemeInstallBackendDefaults();
  PASS([defs volatileDomainForName: @"GSThemeDomain"] == nil
    && [defs objectForKey: key] == nil,
    "with no GSTheme nothing is installed");

  setDefault(@"GNUstep", @"GSTheme");
  GSThemeInstallBackendDefaults();
  PASS([defs volatileDomainForName: @"GSThemeDomain"] == nil,
    "the GNUstep theme installs nothing");

  setDefault(drawing, @"GSTheme");
  setDefault(@"YES", key);
  GSThemeInstallBackendDefaults();
  PASS([defs volatileDomainForName: @"GSThemeDomain"] == nil
    && [defs boolForKey: key] == YES,
    "the user's GSBackHandlesWindowDecorations wins over the theme's");
  setDefault(nil, key);

  setDefault(@"YES", @"GSX11HandlesWindowDecorations");
  GSThemeInstallBackendDefaults();
  PASS([defs volatileDomainForName: @"GSThemeDomain"] == nil,
    "the user's GSX11HandlesWindowDecorations wins over the theme's");
  setDefault(nil, @"GSX11HandlesWindowDecorations");

  setDefault(plain, @"GSTheme");
  GSThemeInstallBackendDefaults();
  PASS([defs volatileDomainForName: @"GSThemeDomain"] == nil,
    "a theme without the default installs nothing");

  setDefault([dir stringByAppendingPathComponent: @"Missing.theme"],
    @"GSTheme");
  GSThemeInstallBackendDefaults();
  PASS([defs volatileDomainForName: @"GSThemeDomain"] == nil,
    "a theme that can't be found installs nothing");

  /* A registered default is below the theme's domain. */
  [defs registerDefaults: [NSDictionary dictionaryWithObject: @"YES"
						      forKey: key]];
  setDefault(drawing, @"GSTheme");
  GSThemeInstallBackendDefaults();
  PASS_EQUAL([defs volatileDomainForName: @"GSThemeDomain"],
    [NSDictionary dictionaryWithObject: @"NO" forKey: key],
    "the theme's GSBackHandlesWindowDecorations is installed in"
    " GSThemeDomain, alone");
  PASS([defs objectForKey: key] != nil && [defs boolForKey: key] == NO,
    "the default reads as the theme set it, above the registration domain");
  searchList = [defs searchList];
  PASS(occurrences(searchList, @"GSThemeDomain") == 1
    && [searchList indexOfObject: @"GSThemeDomain"]
      < [searchList indexOfObject: NSRegistrationDomain],
    "GSThemeDomain is in the search list once, before the registration"
    " domain");

  GSThemeInstallBackendDefaults();
  PASS(occurrences([defs searchList], @"GSThemeDomain") == 1,
    "calling it again leaves the search list as it was");

  /* The lookup it shares with +loadThemeNamed:. */
  PASS([GSTheme loadThemeNamed: drawing] != nil,
    "+loadThemeNamed: still finds a theme by its absolute path");

  /* Inside the set: the set has its own autorelease pool. */
  [mgr removeItemAtPath: dir error: NULL];

  END_SET("GSThemeInstallBackendDefaults")

  [pool release];
  return 0;
}
