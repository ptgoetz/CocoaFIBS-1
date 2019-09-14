/*
CocoaFIBS - A Mac OS X CLient for the FIBS Backgammon Server
Copyright (C) 2005  Adam Gerson

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#import <Cocoa/Cocoa.h>

@class AGFIBSAppController;

@interface AGFIBSToolbarController : NSObject
{
    IBOutlet id window;									/*" The window that the toolbar is attached to "*/
    NSToolbar *toolbar;									/*" The toolbar attached to the game window "*/
    NSMutableDictionary *items;							/*" All items that are in the toolbar "*/
	IBOutlet AGFIBSAppController *theAppController;		/*" The application controller "*/
	BOOL isAway;
}

-(BOOL)isSystemGreaterThen10_3;

- (void)awakeFromNib;

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;
- (int)count;
- (BOOL)toolbarIsVisible;

- (IBAction)customize:(id)sender;
- (IBAction)showhide:(id)sender;

- (void)toggleUserListDrawer;
- (void)sendToggleReady;
- (void)sendToggleGreedy;
- (void)sendToggleDouble;
- (void)resignGammon;
- (void)resignBackgammon;
- (void)resignWithHow:(NSString *)how;
- (void)toggleReadyToolbarItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationWillTerminate:(NSNotification *)aNotification;
- (void)applicationDidBecomeActive:(NSNotification *)aNotification;
- (void)applicationDidResignActive:(NSNotification *)aNotification;
- (void)dealloc;

- (void)dealloc;
@end
