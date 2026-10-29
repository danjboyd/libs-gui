/* -[NSCollectionView makeItemWithIdentifier:forIndexPath:] makes an item
   of the class or from the nib registered for the identifier, and
   -makeSupplementaryViewOfKind:withIdentifier:forIndexPath: a view of the
   class registered for the kind and identifier, as on Cocoa.  A data
   source's -collectionView:itemForRepresentedObjectAtIndexPath: calls
   -makeItemWithIdentifier:forIndexPath:, so the collection view asks the
   data source for its items and not the other way round.  The item
   method used to ask the data source and ignore what was registered (and
   so recursed when the data source called it), and the view method
   answered nil.
   The view uses the theme and font backend, so the set is skipped when the
   backend is unavailable.
*/
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSData.h>
#include <Foundation/NSGeometry.h>
#include <Foundation/NSIndexPath.h>
#include <Foundation/NSString.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSCollectionView.h>
#include <AppKit/NSCollectionViewFlowLayout.h>
#include <AppKit/NSCollectionViewItem.h>
#include <AppKit/NSNib.h>
#include <AppKit/NSView.h>

static NSString *itemXib =
  @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  @"<document type=\"com.apple.InterfaceBuilder3.Cocoa.XIB\" version=\"3.0\""
  @" toolsVersion=\"14490.70\" targetRuntime=\"MacOSX.Cocoa\""
  @" propertyAccessControl=\"none\">"
  @"<objects>"
  @"<customObject id=\"-2\" userLabel=\"File's Owner\"/>"
  @"<customObject id=\"-1\" userLabel=\"First Responder\""
  @" customClass=\"FirstResponder\"/>"
  @"<customObject id=\"-3\" userLabel=\"Application\" customClass=\"NSObject\"/>"
  @"<collectionViewItem id=\"item\">"
  @"<connections>"
  @"<outlet property=\"view\" destination=\"item-view\" id=\"item-view-outlet\"/>"
  @"</connections>"
  @"</collectionViewItem>"
  @"<customView id=\"item-view\">"
  @"<rect key=\"frame\" x=\"0.0\" y=\"0.0\" width=\"70\" height=\"25\"/>"
  @"</customView>"
  @"</objects>"
  @"</document>";

@interface RegisteredItem : NSCollectionViewItem
@end
@implementation RegisteredItem
- (void) loadView
{
  NSView *view = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 40, 30)];

  [self setView: view];
  RELEASE(view);
}
@end

@interface RegisteredHeader : NSView
@end
@implementation RegisteredHeader
@end

/* A data source that makes its items as Cocoa data sources do.  */
@interface Source : NSObject <NSCollectionViewDataSource>
{
@public
  NSInteger asked;
}
@end
@implementation Source
- (NSInteger) collectionView: (NSCollectionView *)cv
       numberOfItemsInSection: (NSInteger)section
{
  return 3;
}
- (NSCollectionViewItem *) collectionView: (NSCollectionView *)cv
        itemForRepresentedObjectAtIndexPath: (NSIndexPath *)indexPath
{
  NSCollectionViewItem *item;

  asked++;
  item = [cv makeItemWithIdentifier: @"registered-class"
		       forIndexPath: indexPath];
  [item setRepresentedObject: [NSString stringWithFormat: @"%ld",
    (long)[indexPath item]]];
  return item;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSCollectionView *cv;
  NSCollectionViewItem *item;
  NSIndexPath *path = [NSIndexPath indexPathForItem: 0 inSection: 0];
  NSNib *nib;
  NSView *header;
  Source *source;

  START_SET("NSCollectionView item and view registration")

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

  cv = AUTORELEASE([[NSCollectionView alloc]
    initWithFrame: NSMakeRect(0, 0, 400, 300)]);
  [cv registerClass: [RegisteredItem class]
    forItemWithIdentifier: @"registered-class"];
  item = [cv makeItemWithIdentifier: @"registered-class" forIndexPath: path];
  PASS([item isKindOfClass: [RegisteredItem class]],
    "an item is made of the class registered for its identifier");

  nib = AUTORELEASE([[NSNib alloc]
    initWithNibData: [itemXib dataUsingEncoding: NSUTF8StringEncoding]
	     bundle: nil]);
  [cv registerNib: nib forItemWithIdentifier: @"registered-nib"];
  item = [cv makeItemWithIdentifier: @"registered-nib" forIndexPath: path];
  PASS([item isKindOfClass: [NSCollectionViewItem class]]
    && [item view] != nil && NSWidth([[item view] frame]) == 70.0,
    "an item is loaded from the nib registered for its identifier");

  item = [cv makeItemWithIdentifier: @"unregistered" forIndexPath: path];
  PASS([item isKindOfClass: [NSCollectionViewItem class]] && [item view] != nil,
    "an unregistered identifier makes a plain item with a view");

  [cv registerClass: [RegisteredHeader class]
    forSupplementaryViewOfKind: NSCollectionElementKindSectionHeader
	    withIdentifier: @"registered-header"];
  header = [cv makeSupplementaryViewOfKind: NSCollectionElementKindSectionHeader
			    withIdentifier: @"registered-header"
			      forIndexPath: path];
  PASS([header isKindOfClass: [RegisteredHeader class]],
    "a supplementary view is made of the class registered for its kind");
  PASS([cv makeSupplementaryViewOfKind: NSCollectionElementKindSectionFooter
			withIdentifier: @"registered-header"
			  forIndexPath: path] == nil,
    "a kind with no registration makes no supplementary view");

  /* A registration made with strings and a nib that are released before
     the item or view is made is kept.  */
  {
    NSAutoreleasePool *inner = [NSAutoreleasePool new];
    NSString *kind = [NSString stringWithFormat: @"%@", @"TransientKind"];
    NSString *identifier = [NSString stringWithFormat: @"%@", @"transient"];

    [cv registerClass: [RegisteredHeader class]
      forSupplementaryViewOfKind: kind
	      withIdentifier: identifier];
    [cv registerNib: AUTORELEASE([[NSNib alloc]
      initWithNibData: [itemXib dataUsingEncoding: NSUTF8StringEncoding]
	       bundle: nil])
      forItemWithIdentifier: identifier];
    [inner release];
  }
  header = [cv makeSupplementaryViewOfKind: @"TransientKind"
			    withIdentifier: @"transient"
			      forIndexPath: path];
  PASS([header isKindOfClass: [RegisteredHeader class]],
    "a registration made with a released kind string is kept");
  item = [cv makeItemWithIdentifier: @"transient" forIndexPath: path];
  PASS(NSWidth([[item view] frame]) == 70.0,
    "a registered nib is kept after its creator releases it");

  source = AUTORELEASE([Source new]);
  [cv setCollectionViewLayout:
    AUTORELEASE([[NSCollectionViewFlowLayout alloc] init])];
  [cv setDataSource: source];
  [cv reloadData];
  PASS([[cv visibleItems] count] == 3,
    "a data source that makes its items loads them all");
  PASS([[cv itemAtIndexPath: path] isKindOfClass: [RegisteredItem class]]
    && [[[cv itemAtIndexPath: path] representedObject] isEqual: @"0"],
    "the loaded items are the ones the data source made");

  END_SET("NSCollectionView item and view registration")

  [pool release];
  return 0;
}
