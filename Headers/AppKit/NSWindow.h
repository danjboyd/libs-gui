/*
   NSWindow.h

   The window class

   Copyright (C) 1996,1999,2004 Free Software Foundation, Inc.

   Author:  Scott Christley <scottc@net-community.com>
   Date: 1996
   Modified:  Felipe A. Rodriguez <far@ix.netcom.com>
   Date: June 1998
   Modified:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Date:  1998,1999
   Author:  Quentin Mathe <qmathe@club-internet.fr>
   Date: January 2004

   This file is part of the GNUstep GUI Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; see the file COPYING.LIB.
   If not, see <http://www.gnu.org/licenses/> or write to the 
   Free Software Foundation, 51 Franklin Street, Fifth Floor, 
   Boston, MA 02110-1301, USA.
*/

#ifndef _GNUstep_H_NSWindow
#define _GNUstep_H_NSWindow
#import <AppKit/AppKitDefines.h>

#import <AppKit/NSGraphicsContext.h>
#import <AppKit/NSPasteboard.h>
#import <AppKit/NSResponder.h>

@class NSArray;
@class NSData;
@class NSDate;
@class NSDictionary;
@class NSMutableArray;
@class NSNotification;
@class NSString;
@class NSUndoManager;

@class NSButton;
@class NSButtonCell;
@class NSColor;
@class NSEvent;
@class NSImage;
@class NSMenu;
@class NSPasteboard;
@class NSScreen;
@class NSText;
@class NSToolbar; 
@class NSView;
@class NSWindowController;
@class NSCachedImageRep;
@class NSViewController;

@class GSWindowDecorationView;
@class GSAutoLayoutEngine;

/*
 * Window levels are taken from MacOS-X
 * NSDesktopWindowLevel is copied from Window maker and is intended to be
 * the level at which things on the desktop sit ... so you should be able
 * to put a desktop background just below it.
 * FIXME: The hardcoded values here don't match the ones in Cocoa. 
 * But we cannot change them easily as the have to match the ones in Window maker.
 */
enum {
  NSDesktopWindowLevel = -1000,	/* GNUstep addition	*/ // 2
  NSNormalWindowLevel = 0, // 3
  NSFloatingWindowLevel = 2, // 4
  NSSubmenuWindowLevel = 3, // 5
  NSTornOffMenuWindowLevel = 3, // 5
  NSMainMenuWindowLevel = 20, // 7
  NSDockWindowLevel = 21,	/* Deprecated - use NSStatusWindowLevel */ // 6
  NSStatusWindowLevel = 21, // 8
  NSModalPanelWindowLevel = 100, // 9
  NSPopUpMenuWindowLevel = 101,  // 10
  NSScreenSaverWindowLevel = 1000  // 12
};

#if OS_API_VERSION(MAC_OS_X_VERSION_10_9, GS_API_LATEST)
/** The code a modal session or sheet ends with.  As in Cocoa, it is a
 * typed extensible enumeration, which Swift imports as
 * NSApplication.ModalResponse with the constants below as its members
 * (.OK, .cancel, .alertFirstButtonReturn and so on).<br />
 * For Clang the constants are static constants of the type, as in Cocoa,
 * since Swift makes only those members of the type; Clang accepts them
 * as case labels (GNU constant folding, which -pedantic warns about).
 * Other compilers get an enumeration, so the constants stay integer
 * constant expressions.  The constants are NSInteger with Clang and int
 * otherwise, so print them with %ld and a cast to long.
 */
#ifndef NS_TYPED_EXTENSIBLE_ENUM
/* Defined by gnustep-base from the version that declares
 * NSAttributedStringKey with it. */
#define NS_TYPED_EXTENSIBLE_ENUM
#endif
typedef NSInteger NSModalResponse NS_TYPED_EXTENSIBLE_ENUM
  NS_SWIFT_NAME(NSApplication.ModalResponse);
#if __has_attribute(swift_wrapper)
static const NSModalResponse NSModalResponseOK = 1;
static const NSModalResponse NSModalResponseCancel = 0;
static const NSModalResponse NSModalResponseStop = -1000;
static const NSModalResponse NSModalResponseAbort = -1001;
static const NSModalResponse NSModalResponseContinue = -1002;
static const NSModalResponse NSAlertFirstButtonReturn
  NS_SWIFT_NAME(alertFirstButtonReturn) = 1000;
static const NSModalResponse NSAlertSecondButtonReturn
  NS_SWIFT_NAME(alertSecondButtonReturn) = 1001;
static const NSModalResponse NSAlertThirdButtonReturn
  NS_SWIFT_NAME(alertThirdButtonReturn) = 1002;
#else
enum {
  NSModalResponseOK = 1,
  NSModalResponseCancel = 0,
  NSModalResponseStop = -1000,
  NSModalResponseAbort = -1001,
  NSModalResponseContinue = -1002,
  NSAlertFirstButtonReturn = 1000,
  NSAlertSecondButtonReturn = 1001,
  NSAlertThirdButtonReturn = 1002
};
#endif
DEFINE_BLOCK_TYPE(GSNSWindowDidEndSheetCallbackBlock, void, NSModalResponse returnCode);
#endif

/**
 * The style of a window, a combination of these flags: whether it has a
 * title bar, which buttons the title bar shows, whether it can be resized,
 * and so on.  It is an NS_OPTIONS type, as in Cocoa, so Swift imports it
 * as an option set.
 */
typedef NS_OPTIONS(NSUInteger, NSWindowStyleMask)
{
  NSWindowStyleMaskBorderless = 0,
  NSWindowStyleMaskTitled = 1 << 0,
  NSWindowStyleMaskClosable = 1 << 1,
  NSWindowStyleMaskMiniaturizable = 1 << 2,
  NSWindowStyleMaskResizable = 1 << 3,
  NSWindowStyleMaskUtilityWindow = 1 << 4,
  /* Known clash: this is Cocoa's value, but GNUstep uses the same bit
   * for NSIconWindowMask (64), and NSPanel.h gives NSDocModalWindowMask
   * the value 32.  libs-gui and the backends treat a window with this
   * bit as an application icon window.
   */
  NSWindowStyleMaskDocModalWindow = 1 << 6,
  /* Specifies a panel that does not activate the owning application.
   * Known clash: this is Cocoa's value, but GNUstep uses the same bit for
   * NSMiniWindowMask (128), and libs-gui and the backends treat a window
   * with this bit as a miniwindow.
   */
  NSWindowStyleMaskNonactivatingPanel = 1 << 7,
  NSWindowStyleMaskTexturedBackground = 1 << 8,
  NSWindowStyleMaskUnifiedTitleAndToolbar = 1 << 12,
  NSWindowStyleMaskHUDWindow = 1 << 13,
  NSWindowStyleMaskFullScreen = 1 << 14,
  NSWindowStyleMaskFullSizeContentView = 1 << 15
};

/* The older names of the window style flags.  They are constants of an
 * anonymous enumeration, so they remain integer constant expressions.
 */
enum {
  NSBorderlessWindowMask = NSWindowStyleMaskBorderless,
  NSTitledWindowMask = NSWindowStyleMaskTitled,
  NSClosableWindowMask = NSWindowStyleMaskClosable,
  NSMiniaturizableWindowMask = NSWindowStyleMaskMiniaturizable,
  NSResizableWindowMask = NSWindowStyleMaskResizable,
#if OS_API_VERSION(MAC_OS_X_VERSION_10_2, GS_API_LATEST)
  NSTexturedBackgroundWindowMask = NSWindowStyleMaskTexturedBackground,
#endif 
#if OS_API_VERSION(MAC_OS_X_VERSION_10_4, GS_API_LATEST)
  NSUnscaledWindowMask = 1 << 11,
  NSUnifiedTitleAndToolbarWindowMask = NSWindowStyleMaskUnifiedTitleAndToolbar,
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_7, GS_API_LATEST)
  NSFullScreenWindowMask = NSWindowStyleMaskFullScreen,
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_10, GS_API_LATEST)
  NSFullSizeContentViewWindowMask = NSWindowStyleMaskFullSizeContentView,
#endif
  NSIconWindowMask = 64,	/* GNUstep extension - app icon window	*/
  NSMiniWindowMask = 128	/* GNUstep extension - miniwindows	*/
};

#if OS_API_VERSION(MAC_OS_X_VERSION_10_5, GS_API_LATEST)
enum {
  NSWindowCollectionBehaviorDefault = 0,
  NSWindowCollectionBehaviorCanJoinAllSpaces = 1 << 0,
  NSWindowCollectionBehaviorMoveToActiveSpace = 1 << 1
};
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_6, GS_API_LATEST)
enum {
  NSWindowCollectionBehaviorManaged = 1 << 2,
  NSWindowCollectionBehaviorTransient = 1 << 3,
  NSWindowCollectionBehaviorStationary = 1 << 4,
};
enum {
  NSWindowCollectionBehaviorParticipatesInCycle = 1 << 5,
  NSWindowCollectionBehaviorIgnoresCycle = 1 << 6
};
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_7, GS_API_LATEST)
enum {
  NSWindowCollectionBehaviorFullScreenPrimary = 1 << 7,
  NSWindowCollectionBehaviorFullScreenAuxiliary = 1 << 8
};
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_11, GS_API_LATEST)
enum
{
  NSWindowCollectionBehaviorFullScreenAllowsTiling = 1 << 11,
  NSWindowCollectionBehaviorFullScreenDisallowsTiling = 1 << 12
};
#endif
typedef NSUInteger NSWindowCollectionBehavior;

enum _NSSelectionDirection {
  NSDirectSelection,
  NSSelectingNext,
  NSSelectingPrevious
};
typedef NSUInteger NSSelectionDirection;

#if OS_API_VERSION(MAC_OS_X_VERSION_10_2, GS_API_LATEST)
enum _NSWindowButton
{
  NSWindowCloseButton = 0,
  NSWindowMiniaturizeButton,
  NSWindowZoomButton,
  NSWindowToolbarButton,
  NSWindowDocumentIconButton
};
typedef NSUInteger NSWindowButton;
#endif

APPKIT_EXPORT NSSize NSIconSize;
APPKIT_EXPORT NSSize NSTokenSize;

/**
 * <p>An NSWindow instance represents a window, panel or menu on the
 * screen.<br />
 * Each window has a style, which determines how the window is decorated:
 * ie whether it has a border, a title bar, a resize bar, minimise and
 * close buttons.
 * </p>
 * <p>A window has a <em>frame</em>. This is the frame of the <em>entire</em>
 * window on the screen, including all decorations and borders.  The origin
 * of the frame represents its bottom left corner and the frame is expressed
 * in screen coordinates (see [NSScreen]).
 * </p>
 * <p>When a window is created, it has a <em>private</em> [NSView] instance
 * which fills the entire window frame and whose coordinate system is the
 * same as the base coordinate system of the window (ie zero x and
 * y coordinates are at the bottom left corner of the window, with increasing
 * x and y corresponding to points to the right and above the origin).<br />
 * This view may be used by the library internals (and theme engines) to
 * draw window decorations if the backend library is not handling the
 * window decorations.
 * </p>
 * <p>A window always contains a <em>content view</em> which is the highest
 * level view available for public (application) use.  This view fills the
 * area of the window inside any decoration/border.<br />
 * This is the only part of the window that application programmers are
 * allowed to draw in directly.
 * </p>
 * <p>You can convert between view coordinates and window base coordinates
 * using the [NSView-convertPoint:fromView:], [NSView-convertPoint:toView:],
 * [NSView-convertRect:fromView:], and [NSView-convertRect:toView:]
 * methods with a nil view argument.<br />
 * You can convert between window and screen coordinates using the
 * -convertBaseToScreen: and -convertScreenToBase: methods.
 * </p>
 */
APPKIT_EXPORT_CLASS
@interface NSWindow : NSResponder <NSCoding>
{
  NSRect        _frame;
  NSSize        _minimumSize;
  NSSize        _maximumSize;
  NSSize        _increments;
  NSSize        _aspectRatio;
  NSString	*_autosaveName;
  GSWindowDecorationView *_wv;
  id            _contentView;
  id            _firstResponder;
  id            _futureFirstResponder;
  NSView        *_initialFirstResponder;
  GSAutoLayoutEngine *_layoutEngine;
PACKAGE_SCOPE
  id            _delegate;
@protected
  id            _fieldEditor;
  id            _lastLeftMouseDownView;
  id            _lastRightMouseDownView;
  id            _lastOtherMouseDownView;
  id            _lastDragView;
  NSInteger     _lastDragOperationMask;
  NSInteger     _windowNum;
  NSInteger     _gstate;
  id            _defaultButtonCell;
  NSGraphicsContext *_context;

  NSScreen      *_screen;
  NSColor       *_backgroundColor;
  NSString      *_representedFilename;
  NSString      *_miniaturizedTitle;
  NSImage       *_miniaturizedImage;
  NSString      *_windowTitle;
PACKAGE_SCOPE
  NSPoint       _lastPoint;
@protected
  NSBackingStoreType _backingType;
  NSUInteger    _styleMask;
  NSInteger     _windowLevel;
PACKAGE_SCOPE
  NSRect        _rectNeedingFlush;
  NSMutableArray *_rectsBeingDrawn;
@protected
  unsigned	_disableFlushWindow;
  
  NSWindowDepth _depthLimit;
  NSWindowController *_windowController;
  NSInteger     _counterpart;
  CGFloat       _alphaValue;
  
  NSMutableArray *_children;
  NSWindow       *_parent;
  NSCachedImageRep *_cachedImage;
  NSPoint        _cachedImageOrigin;
  NSWindow       *_attachedSheet;

PACKAGE_SCOPE
  struct GSWindowFlagsType {
    unsigned	accepts_drag:1;
    unsigned	is_one_shot:1;
    unsigned	needs_flush:1;
    unsigned	is_autodisplay:1;
    unsigned	optimize_drawing:1;
    unsigned	dynamic_depth_limit:1;
    unsigned	cursor_rects_enabled:1;
    unsigned	cursor_rects_valid:1;
    unsigned	visible:1;
    unsigned	is_key:1;
    unsigned	is_main:1;
    unsigned	is_edited:1;
    unsigned	is_released_when_closed:1;
    unsigned	is_miniaturized:1;
    unsigned	menu_exclude:1;
    unsigned	hides_on_deactivate:1;
    unsigned	accepts_mouse_moved:1;
    unsigned	has_opened:1;
    unsigned	has_closed:1;
    unsigned	default_button_cell_key_disabled:1;
    unsigned	can_hide:1;
    unsigned	has_shadow:1;
    unsigned	is_opaque:1;
    unsigned	views_need_display:1;
    // 3 bits reserved for subclass use
    unsigned subclass_bool_one: 1;
    unsigned subclass_bool_two: 1;
    unsigned subclass_bool_three: 1;

    unsigned selectionDirection: 2;
    unsigned displays_when_screen_profile_changes: 1;
    unsigned is_movable_by_window_background: 1;
    unsigned allows_tooltips_when_inactive: 1;

    // 5 used 27 available
    unsigned shows_toolbar_button: 1;
    unsigned autorecalculates_keyview_loop: 1;
    unsigned ignores_mouse_events: 1;
    unsigned preserves_content_during_live_resize: 1;
    unsigned hides_resize_indicator: 1;
  } _f;
@protected 
  NSToolbar     *_toolbar;
  void          *_reserved_1;
  NSWindowCollectionBehavior _collectionBehavior;
  NSSize _contentAspectRatio;
}

#if GS_HAS_DECLARED_PROPERTIES
/*
 * Declared properties for accessors that are also declared as methods
 * below.  Clients compiled without declared property support use the
 * method declarations; property syntax (and Swift) use these.
 */
@property (readonly) NSRect frame;
@property NSSize minSize;
@property NSSize maxSize;
@property (readonly) NSString *frameAutosaveName;
@property (readonly, getter=isVisible) BOOL visible;
@property NSInteger level;
@property (readonly) BOOL canBecomeKeyWindow;
@property (readonly) BOOL canBecomeMainWindow;
@property (readonly, getter=isKeyWindow) BOOL keyWindow;
@property (readonly, getter=isMainWindow) BOOL mainWindow;
@property (getter=isAutodisplay) BOOL autodisplay;
@property BOOL viewsNeedDisplay;
@property (readonly, getter=isFlushWindowDisabled) BOOL flushWindowDisabled;
@property (readonly) NSInteger windowNumber;
@property (readonly) NSDictionary *deviceDescription;
@property NSBackingStoreType backingType;
@property (getter=isOneShot) BOOL oneShot;
@property (readonly) BOOL canStoreColor;
@property NSWindowDepth depthLimit;
@property (readonly) NSScreen *deepestScreen;
@property (readonly) NSScreen *screen;
@property (readonly) NSResponder *firstResponder;
@property (readonly) NSEvent *currentEvent;
@property BOOL acceptsMouseMovedEvents;
@property (copy) NSString *representedFilename;
@property (copy) NSString *title;
@property (getter=isDocumentEdited) BOOL documentEdited;
@property (getter=isReleasedWhenClosed) BOOL releasedWhenClosed;
@property (readonly, getter=isMiniaturized) BOOL miniaturized;
@property (retain) NSImage *miniwindowImage;
@property (copy) NSString *miniwindowTitle;
@property (getter=isExcludedFromWindowsMenu) BOOL excludedFromWindowsMenu;
@property (readonly) BOOL areCursorRectsEnabled;
@property BOOL hidesOnDeactivate;
@property (readonly) BOOL worksWhenModal;
@property (retain) NSView *contentView;
@property (copy) NSColor *backgroundColor;
@property (readonly) NSWindowStyleMask styleMask;
@property (assign) id delegate;
@property (assign) NSWindowController *windowController;
#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
@property (readonly, getter=isZoomed) BOOL zoomed;
@property BOOL showsResizeIndicator;
@property NSSize aspectRatio;
@property NSSize resizeIncrements;
@property (retain) NSButtonCell *defaultButtonCell;
@property (retain) NSView *initialFirstResponder;
@property (readonly) NSSelectionDirection keyViewSelectionDirection;
@property BOOL canHide;
@property BOOL hasShadow;
@property CGFloat alphaValue;
@property (getter=isOpaque) BOOL opaque;
@property (readonly) NSArray *drawers;
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_2, GS_API_LATEST)
@property BOOL ignoresMouseEvents;
@property (readonly) NSArray *childWindows;
@property (assign) NSWindow *parentWindow;
@property (getter=isMovableByWindowBackground) BOOL movableByWindowBackground;
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_3, GS_API_LATEST)
@property NSSize contentMaxSize;
@property NSSize contentMinSize;
@property NSSize contentAspectRatio;
@property NSSize contentResizeIncrements;
@property BOOL allowsToolTipsWhenApplicationIsInactive;
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_4, GS_API_LATEST)
@property BOOL preservesContentDuringLiveResize;
@property (readonly) NSGraphicsContext *graphicsContext;
@property (readonly) CGFloat userSpaceScaleFactor;
@property BOOL autorecalculatesKeyViewLoop;
@property BOOL showsToolbarButton;
@property BOOL displaysWhenScreenProfileChanges;
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_5, GS_API_LATEST)
@property NSWindowCollectionBehavior collectionBehavior;
#endif
#endif

/*
 * Class methods
 */

/*
 * Computing frame and content rectangles
 */

/**
 * Returns a window with the view of the specified viewController as it's
 * content view.  The window is resizable, titled, closable, and miniaturizable.
 */
#if OS_API_VERSION(MAC_OS_X_VERSION_10_10, GS_API_LATEST)
+ (instancetype) windowWithContentViewController: (NSViewController *)viewController;
#endif

/**
 * Returns the rectangle which would be used for the content view of
 * a window whose on-screen size and position is specified by aRect
 * and which is decorated with the border and title etc given by aStyle.<br />
 * Both rectangles are expressed in screen coordinates.
 */
+ (NSRect) contentRectForFrameRect: (NSRect)aRect
			 styleMask: (NSWindowStyleMask)aStyle;

/**
 * Returns the rectangle which would be used for the on-screen frame of
 * a window if that window had a content view occupying the rectangle aRect
 * and was decorated with the border and title etc given by aStyle.<br />
 * Both rectangles are expressed in screen coordinates.
 */
+ (NSRect) frameRectForContentRect: (NSRect)aRect
			 styleMask: (NSWindowStyleMask)aStyle;

/**
 * Returns the smallest frame width that will fit the given title
 * and style.  This is the on-screen width of the window including
 * decorations.
 */
+ (CGFloat) minFrameWidthWithTitle: (NSString *)aTitle
                         styleMask: (NSWindowStyleMask)aStyle;

#if OS_API_VERSION(MAC_OS_X_VERSION_10_3, GS_API_LATEST)
- (NSRect) contentRectForFrameRect: (NSRect)frameRect;
- (NSRect) frameRectForContentRect: (NSRect)contentRect;
#endif
/*
 * Initializing and getting a new NSWindow object
 */
- (id) initWithContentRect: (NSRect)contentRect
		 styleMask: (NSWindowStyleMask)aStyle
		   backing: (NSBackingStoreType)bufferingType
		     defer: (BOOL)flag;

/**
 * Creates a new window with the specified characteristics.<br />
 * The contentRect is expressed in screen coordinates (for aScreen)
 * and the window frame is calculated from the content rectangle and
 * the window style mask.
 */
- (id) initWithContentRect: (NSRect)contentRect
		 styleMask: (NSWindowStyleMask)aStyle
		   backing: (NSBackingStoreType)bufferingType
		     defer: (BOOL)flag
		    screen: (NSScreen*)aScreen;

/**
 * Converts aPoint from the base coordinate system of the receiver
 * to a point in the screen coordinate system.
 */
- (NSPoint) convertBaseToScreen: (NSPoint)aPoint;

/**
 * Converts aPoint from the screen coordinate system to a point in
 * the base coordinate system of the receiver.
 */
- (NSPoint) convertScreenToBase: (NSPoint)aPoint;

/**
 * Converts aRect from the coordinate system of the screen
 * to the coordinate system of the window.
 */

- (NSRect) convertRectFromScreen: (NSRect)aRect;

/**
 * Converts aRect from the window coordinate system to a rect in
 * the screen coordinate system.
 */
- (NSRect) convertRectToScreen: (NSRect)aRect;

/**
 * Returns the frame of the receiver ... the rectangular area that the window
 * (including any border, title, and other decorations) occupies on screen.
 */
- (NSRect) frame;

/**
 * <p>Sets the frame for the receiver to frameRect and if flag is YES causes
 * the window contents to be refreshed.  The value of frameRect is the
 * desired on-screen size and position of the window including all
 * border/decoration.
 * </p>
 * <p>The size of the frame is constrained to the minimum and maximum
 * sizes set for the receiver (if any).<br />
 * Its position is constrained to be on screen if it is a titled window.
 * </p>
 */
- (void) setFrame: (NSRect)frameRect
	  display: (BOOL)flag;

/**
 * Sets the origin (bottom left corner) of the receiver's frame to be the
 * specified point (in screen coordinates).
 */
- (void) setFrameOrigin: (NSPoint)aPoint;

/**
 * Sets the top left corner of the receiver's frame to be the
 * specified point (in screen coordinates).
 */
- (void) setFrameTopLeftPoint: (NSPoint)aPoint;

/**
 * Sets the size of the receiver's content view  to aSize, implicitly
 * adjusting the size of the receiver's frame to match.
 */
- (void) setContentSize: (NSSize)aSize;

/**
 * Positions the receiver at topLeftPoint (or if topLeftPoint is NSZeroPoint,
 * leaves the receiver unmoved except for any necessary constraint to fit
 * on screen).<br />
 * Returns the position of the top left corner of the receivers content
 * view (after repositioning), so that another window cascaded at the
 * returned point will not obscure the title bar of the receiver.
 */
- (NSPoint) cascadeTopLeftFromPoint: (NSPoint)topLeftPoint;

- (void) center;
- (NSInteger) resizeFlags;
#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
- (void) setFrame: (NSRect)frameRect
	  display: (BOOL)displayFlag
	  animate: (BOOL)animationFlag;
- (NSTimeInterval) animationResizeTime: (NSRect)newFrame;
- (void) performZoom: (id)sender;
- (void) zoom: (id)sender;
- (BOOL) isZoomed;
- (BOOL) showsResizeIndicator;
- (void) setShowsResizeIndicator: (BOOL)show;
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_4, GS_API_LATEST)
- (BOOL) preservesContentDuringLiveResize;
- (void) setPreservesContentDuringLiveResize: (BOOL)flag;
#endif

/*
 * Constraining size
 */
- (NSSize) minSize;
- (NSSize) maxSize;
- (void) setMinSize: (NSSize)aSize;
- (void) setMaxSize: (NSSize)aSize;
- (NSRect) constrainFrameRect: (NSRect)frameRect
		     toScreen: (NSScreen*)screen;
#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
- (NSSize) aspectRatio;
- (void) setAspectRatio: (NSSize)ratio;
- (NSSize) resizeIncrements;
- (void) setResizeIncrements: (NSSize)aSize;
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_3, GS_API_LATEST)
- (NSSize) contentMaxSize;
- (void) setContentMaxSize: (NSSize)size;
- (NSSize) contentMinSize;
- (void) setContentMinSize: (NSSize)size;
- (NSSize) contentAspectRatio;
- (void) setContentAspectRatio: (NSSize)ratio;
- (NSSize) contentResizeIncrements;
- (void) setContentResizeIncrements: (NSSize)increments;
#endif

/*
 * Saving and restoring the frame
 */
+ (void) removeFrameUsingName: (NSString*)name;
- (NSString*) frameAutosaveName;
- (void) saveFrameUsingName: (NSString*)name;
- (BOOL) setFrameAutosaveName: (NSString*)name;
- (void) setFrameFromString: (NSString*)string;
- (BOOL) setFrameUsingName: (NSString*)name;
- (NSString*) stringWithSavedFrame;
#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
- (BOOL) setFrameUsingName: (NSString *)name
		     force: (BOOL)force;
#endif

/*
 * Window status and ordering
 */
- (void) orderBack: sender;
- (void) orderFront: sender;
- (void) orderFrontRegardless;
- (void) orderOut: (id)sender;
- (void) orderWindow: (NSWindowOrderingMode)place
	  relativeTo: (NSInteger)otherWin;
- (BOOL) isVisible;
- (void) setIsVisible: (BOOL)flag;
- (NSInteger) level;
- (void) setLevel: (NSInteger)newLevel;

- (void) becomeKeyWindow;
- (void) becomeMainWindow;
- (BOOL) canBecomeKeyWindow;
- (BOOL) canBecomeMainWindow;
- (BOOL) isKeyWindow;
- (BOOL) isMainWindow;
- (void) makeKeyAndOrderFront: (id)sender;
- (void) makeKeyWindow;
- (void) makeMainWindow;
- (void) resignKeyWindow;
- (void) resignMainWindow;

#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
- (NSButtonCell*) defaultButtonCell;
- (void) setDefaultButtonCell: (NSButtonCell*)aCell;
- (void) disableKeyEquivalentForDefaultButtonCell;
- (void) enableKeyEquivalentForDefaultButtonCell;
#endif

/*
 * Managing the display
 */
- (void) display;
- (void) displayIfNeeded;
- (BOOL) isAutodisplay;
- (void) setAutodisplay: (BOOL)flag;
- (void) setViewsNeedDisplay: (BOOL)flag;
- (void) update;
- (void) useOptimizedDrawing: (BOOL)flag;
- (BOOL) viewsNeedDisplay;

- (BOOL) isFlushWindowDisabled;
- (void) disableFlushWindow;
- (void) enableFlushWindow;
- (void) flushWindow;
- (void) flushWindowIfNeeded;

#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
- (void) cacheImageInRect: (NSRect)aRect;
- (void) discardCachedImage;
- (void) restoreCachedImage;
#endif

/*
 * Window device attributes
 */
- (NSInteger) windowNumber;
- (NSInteger) gState;
- (NSDictionary*) deviceDescription;
- (NSBackingStoreType) backingType;
- (void) setBackingType: (NSBackingStoreType)type;
- (BOOL) isOneShot;
- (void) setOneShot: (BOOL)flag;
#if OS_API_VERSION(MAC_OS_X_VERSION_10_4, GS_API_LATEST)
- (NSGraphicsContext*) graphicsContext;
- (CGFloat) userSpaceScaleFactor;
#endif


/*
 * Screens and window depths
 */
+ (NSWindowDepth) defaultDepthLimit;
- (BOOL) canStoreColor;
- (NSWindowDepth) depthLimit;
- (BOOL) hasDynamicDepthLimit;
- (void) setDepthLimit: (NSWindowDepth)limit;
- (void) setDynamicDepthLimit: (BOOL)flag;

- (NSScreen*) deepestScreen;
- (NSScreen*) screen;

- (NSResponder*) firstResponder;

#if OS_API_VERSION(MAC_OS_X_VERSION_10_5, GS_API_LATEST)
- (NSWindowCollectionBehavior)collectionBehavior;
- (void)setCollectionBehavior:(NSWindowCollectionBehavior)props;
#endif

/**
 * This method attempts to make aResponder the first responder.<br />
 * If aResponder is already the first responder, this method has no
 * effect and simply returns YES.
 * Otherwise, the method sends a -resignFirstResponder message to the
 * current first responder (if there is one) and immediately returns NO if
 * the current first responder refuses to resign.<br />
 * Then the method asks aResponder to become first responder by sending
 * it a -becomeFirstResponder message, and if that returns YES then this
 * method immediately returns YES.<br />
 * However, if that returns NO, the receiver is made the first responder by
 * sending it a -becomeFirstResponder message, and this method returns NO.<br />
 * If aResponder is neither nil nor an instance of NSResponder (or of a
 * subclass of NSResponder) then behavior is undefined (though the current
 * GNUstep implementation just returns NO).
 */
- (BOOL) makeFirstResponder: (NSResponder*)aResponder;

/*
 * Aiding event handling
 */
- (NSEvent*) currentEvent;
- (NSEvent*) nextEventMatchingMask: (NSUInteger)mask;
- (NSEvent*) nextEventMatchingMask: (NSUInteger)mask
			 untilDate: (NSDate*)expiration
			    inMode: (NSString*)mode
			   dequeue: (BOOL)deqFlag;
- (void) discardEventsMatchingMask: (NSUInteger)mask
		       beforeEvent: (NSEvent*)lastEvent;
- (void) postEvent: (NSEvent*)event
	   atStart: (BOOL)flag;
- (void) sendEvent: (NSEvent*)theEvent;
- (BOOL) tryToPerform: (SEL)anAction with: (id)anObject;
- (void) keyDown: (NSEvent*)theEvent;
- (NSPoint) mouseLocationOutsideOfEventStream;
- (BOOL) acceptsMouseMovedEvents;
- (void) setAcceptsMouseMovedEvents: (BOOL)flag;
#if OS_API_VERSION(MAC_OS_X_VERSION_10_2, GS_API_LATEST)
- (BOOL) ignoresMouseEvents;
- (void) setIgnoresMouseEvents: (BOOL)flag;
#endif 

/*
 * The field editor
 */
- (void) endEditingFor: anObject;
- (NSText*) fieldEditor: (BOOL)createFlag
	      forObject: (id)anObject;

#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
- (NSView*) initialFirstResponder;
- (NSSelectionDirection) keyViewSelectionDirection;
- (void) selectKeyViewFollowingView: (NSView*)aView;
- (void) selectKeyViewPrecedingView: (NSView*)aView;
- (void) selectNextKeyView: (id)sender;
- (void) selectPreviousKeyView: (id)sender;
- (void) setInitialFirstResponder: (NSView*)aView;
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_4, GS_API_LATEST)
- (BOOL) autorecalculatesKeyViewLoop;
- (void) setAutorecalculatesKeyViewLoop: (BOOL)flag;
- (void) recalculateKeyViewLoop;
#endif

/*
 * Window graphics
 */
- (NSString*) representedFilename;
- (void) setRepresentedFilename: (NSString*)aString;
- (void) setTitle: (NSString*)aString;
- (void) setTitleWithRepresentedFilename: (NSString*)aString;
- (NSString*) title;

- (BOOL) isDocumentEdited;
- (void) setDocumentEdited: (BOOL)flag;

/*
 * Handling user actions and events
 */
- (void) close;
- (void) performClose: (id)sender;
- (void) setReleasedWhenClosed: (BOOL)flag;
- (BOOL) isReleasedWhenClosed;

- (void) deminiaturize: (id)sender;
- (void) miniaturize: (id)sender;
- (void) performMiniaturize: (id)sender;
- (BOOL) isMiniaturized;

/*
 * The miniwindow
 */
- (NSImage*) miniwindowImage;
- (NSString*) miniwindowTitle;
- (void) setMiniwindowImage: (NSImage*)image;
- (void) setMiniwindowTitle: (NSString*)title;
#if OS_API_VERSION(GS_API_NONE, GS_API_NONE)
- (NSWindow*) counterpart;
#endif

#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
+ (void) menuChanged: (NSMenu*)aMenu;
#endif

/*
 * Windows menu support
 */
- (BOOL) isExcludedFromWindowsMenu;
- (void) setExcludedFromWindowsMenu: (BOOL)flag;

/*
 * Cursor management
 */
- (BOOL) areCursorRectsEnabled;
- (void) disableCursorRects;
- (void) discardCursorRects;
- (void) enableCursorRects;
- (void) invalidateCursorRectsForView: (NSView*)aView;
- (void) resetCursorRects;

/*
 * Dragging
 */
- (void) dragImage: (NSImage*)anImage
		at: (NSPoint)baseLocation
	    offset: (NSSize)initialOffset
	     event: (NSEvent*)event
	pasteboard: (NSPasteboard*)pboard
	    source: sourceObject
	 slideBack: (BOOL)slideFlag;
- (void) registerForDraggedTypes:
  (GS_GENERIC_CLASS(NSArray, NSPasteboardType)*)newTypes;
- (void) unregisterDraggedTypes;

- (BOOL) hidesOnDeactivate;
- (void) setHidesOnDeactivate: (BOOL)flag;
- (BOOL) worksWhenModal;
#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
- (void) setCanHide: (BOOL)flag;
- (BOOL) canHide;
#endif

/*
 * Accessing the content view
 */
- (id) contentView;
- (void) setContentView: (NSView*)aView;
- (void) setBackgroundColor: (NSColor*)color;
- (NSColor*) backgroundColor;
- (NSWindowStyleMask) styleMask;
#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
- (void) setHasShadow: (BOOL)hasShadow;
- (BOOL) hasShadow;
- (void) setAlphaValue: (CGFloat)windowAlpha;
- (CGFloat) alphaValue;
- (void) setOpaque: (BOOL)isOpaque;
- (BOOL) isOpaque;
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_2, GS_API_LATEST)
- (void) invalidateShadow;
#endif

/*
 * Services menu support
 */
- (id) validRequestorForSendType: (NSString*)sendType
		      returnType: (NSString*)returnType;

/*
 * Printing and postscript
 */
- (void) fax: (id)sender;
- (void) print: (id)sender;
- (NSData*) dataWithEPSInsideRect: (NSRect)rect;
#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
- (NSData*) dataWithPDFInsideRect:(NSRect)aRect;
#endif

/*
 * Assigning a delegate
 */
- (id) delegate;
- (void) setDelegate: (id)anObject;

/*
 * The window controller
 */
- (void) setWindowController: (NSWindowController*)windowController;
- (id) windowController;

#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
- (NSArray *) drawers;
- (id) initWithWindowRef: (void *)windowRef;
- (void *)windowRef;
- (void*) windowHandle;
#endif

/*
 * Window buttons
 */
#if OS_API_VERSION(MAC_OS_X_VERSION_10_2, GS_API_LATEST)
+ (NSButton *) standardWindowButton: (NSWindowButton)button 
                       forStyleMask: (NSUInteger) mask;
- (NSButton *) standardWindowButton: (NSWindowButton)button;
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_4, GS_API_LATEST)
- (BOOL) showsToolbarButton;
- (void) setShowsToolbarButton: (BOOL)flag;
#endif

#if OS_API_VERSION(MAC_OS_X_VERSION_10_2, GS_API_LATEST)
- (NSArray *) childWindows;
- (void) addChildWindow: (NSWindow *)child 
                ordered: (NSWindowOrderingMode)place;
- (void) removeChildWindow: (NSWindow *)child;
- (NSWindow *) parentWindow;
- (void) setParentWindow: (NSWindow *)window;
#endif 

#if OS_API_VERSION(MAC_OS_X_VERSION_10_3, GS_API_LATEST)
- (BOOL) allowsToolTipsWhenApplicationIsInactive;
- (void) setAllowsToolTipsWhenApplicationIsInactive: (BOOL)flag;
#endif

#if OS_API_VERSION(MAC_OS_X_VERSION_10_2, GS_API_LATEST)
- (BOOL) isMovableByWindowBackground;
- (void) setMovableByWindowBackground: (BOOL)flag;
#endif

#if OS_API_VERSION(MAC_OS_X_VERSION_10_1, GS_API_LATEST)
/**
 * Returns the sheet attached to the window, or nil.
 */
- (NSWindow *) attachedSheet;
#endif

#if OS_API_VERSION(MAC_OS_X_VERSION_10_4, GS_API_LATEST)
- (BOOL) displaysWhenScreenProfileChanges;
- (void) setDisplaysWhenScreenProfileChanges: (BOOL)flag;
#endif

#if OS_API_VERSION(MAC_OS_X_VERSION_10_9, GS_API_LATEST)
#if GS_HAS_DECLARED_PROPERTIES
@property (readonly) NSWindow *sheetParent;
#else
- (NSWindow *) sheetParent;
#endif

- (void)beginSheet:(NSWindow *)sheet
 completionHandler:(GSNSWindowDidEndSheetCallbackBlock)handler;
#endif

#if OS_API_VERSION(MAC_OS_X_VERSION_10_7, GS_API_LATEST)
#if GS_HAS_DECLARED_PROPERTIES
@property (readonly) CGFloat backingScaleFactor;
#else
- (CGFloat) backingScaleFactor;
#endif
#endif

#if OS_API_VERSION(MAC_OS_X_VERSION_10_5, GS_API_LATEST)
+ (NSInteger)windowNumberAtPoint:(NSPoint)point
     belowWindowWithWindowNumber:(NSInteger)windowNumber;
#endif

@end

@class NSToolbar;

@interface NSWindow (Toolbar)
- (void) runToolbarCustomizationPalette: (id)sender;
- (void) toggleToolbarShown: (id)sender;
- (NSToolbar *) toolbar;
- (void) setToolbar: (NSToolbar*)toolbar;
@end

#if OS_API_VERSION(GS_API_NONE, GS_API_NONE)
/*
 * GNUstep backend methods
 */
@interface NSWindow (GNUstepBackend)

/*
 * Mouse capture/release
 */
- (void) _captureMouse: (id)sender;
- (void) _releaseMouse: (id)sender;

/*
 * Allow subclasses to init without the backend class
 * attempting to create an actual window
 */
- (void) _initDefaults;

/*
 * Let backend set window visibility.
 */
- (void) _setVisible: (BOOL)flag;

@end
#endif

#if OS_API_VERSION(GS_API_NONE, GS_API_NONE)
@interface NSWindow (GNUstepTextView)
/*
 * Called from NSTextView's resignFirstResponder to know which is 
 * the next first responder.
 */
- (id) _futureFirstResponder;
@end
#endif

/*
 * Implemented by the delegate
 */

#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
@protocol NSWindowDelegate <NSObject>
#if OS_API_VERSION(MAC_OS_X_VERSION_10_6, GS_API_LATEST) && GS_PROTOCOLS_HAVE_OPTIONAL
@optional
#else
@end
@interface NSObject (NSWindowDelegate)
#endif

- (BOOL) windowShouldClose: (id)sender;
#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
- (void) windowWillBeginSheet: (NSNotification*)aNotification;
- (void) windowDidEndSheet: (NSNotification*)aNotification;
- (BOOL) windowShouldZoom: (NSWindow*)sender
                  toFrame: (NSRect)aFrame;
- (NSUndoManager*) windowWillReturnUndoManager: (NSWindow*)sender;
- (NSRect) windowWillUseStandardFrame: (NSWindow*)sender
                         defaultFrame: (NSRect)aFrame;
#endif
#if OS_API_VERSION(MAC_OS_X_VERSION_10_3, GS_API_LATEST)
- (NSRect) window: (NSWindow *)window 
willPositionSheet: (NSWindow *)sheet
        usingRect: (NSRect)rect;
#endif
- (NSSize) windowWillResize: (NSWindow*)sender
		     toSize: (NSSize)frameSize;
- (id) windowWillReturnFieldEditor: (NSWindow*)sender
			  toObject: (id)client;
- (void) windowDidBecomeKey: (NSNotification*)aNotification;
- (void) windowDidBecomeMain: (NSNotification*)aNotification;
- (void) windowDidChangeScreen: (NSNotification*)aNotification;
#if OS_API_VERSION(MAC_OS_X_VERSION_10_4, GS_API_LATEST)
- (void) windowDidChangeScreenProfile: (NSNotification *)aNotification;
#endif
- (void) windowDidDeminiaturize: (NSNotification*)aNotification;
- (void) windowDidExpose: (NSNotification*)aNotification;
- (void) windowDidMiniaturize: (NSNotification*)aNotification;
- (void) windowDidMove: (NSNotification*)aNotification;
- (void) windowDidResignKey: (NSNotification*)aNotification;
- (void) windowDidResignMain: (NSNotification*)aNotification;
- (void) windowDidResize: (NSNotification*)aNotification;
- (void) windowDidUpdate: (NSNotification*)aNotification;
- (void) windowWillClose: (NSNotification*)aNotification;
- (void) windowWillMiniaturize: (NSNotification*)aNotification;
- (void) windowWillMove: (NSNotification*)aNotification;
@end
#endif

/* Notifications */
APPKIT_EXPORT NSString *NSWindowDidBecomeKeyNotification;
APPKIT_EXPORT NSString *NSWindowDidBecomeMainNotification;
APPKIT_EXPORT NSString *NSWindowDidChangeScreenNotification;
#if OS_API_VERSION(MAC_OS_X_VERSION_10_4, GS_API_LATEST)
APPKIT_EXPORT NSString *NSWindowDidChangeScreenProfileNotification;
#endif
APPKIT_EXPORT NSString *NSWindowDidDeminiaturizeNotification;
#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
APPKIT_EXPORT NSString *NSWindowDidEndSheetNotification;
#endif
APPKIT_EXPORT NSString *NSWindowDidExposeNotification;
APPKIT_EXPORT NSString *NSWindowDidMiniaturizeNotification;
APPKIT_EXPORT NSString *NSWindowDidMoveNotification;
APPKIT_EXPORT NSString *NSWindowDidResignKeyNotification;
APPKIT_EXPORT NSString *NSWindowDidResignMainNotification;
APPKIT_EXPORT NSString *NSWindowDidResizeNotification;
APPKIT_EXPORT NSString *NSWindowDidUpdateNotification;
#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)
APPKIT_EXPORT NSString *NSWindowWillBeginSheetNotification;
#endif
APPKIT_EXPORT NSString *NSWindowWillCloseNotification;
APPKIT_EXPORT NSString *NSWindowWillMiniaturizeNotification;
APPKIT_EXPORT NSString *NSWindowWillMoveNotification;

#endif /* _GNUstep_H_NSWindow */
