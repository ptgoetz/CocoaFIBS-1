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

@class MGUserListWindowController;
@class MGPrefController;
@class MGGameController;
@class MGSocketStream;
@class MGChatController;
@class MGLoginWindowController;
@class MGToolbarController;
@class MGTerminalWindowController;

@interface MGAppController : NSObject
{
    IBOutlet MGTerminalWindowController *terminalWindow;
	IBOutlet MGUserListWindowController *userListWindow;			/*" The controller class for the user list window "*/
	IBOutlet MGPrefController *thePrefWindow;						/*" The controller class for the preference list window "*/
	IBOutlet MGGameController *theGameController;					/*" The controller class for the game window "*/
	IBOutlet MGChatController *theChatController;					/*" The controller class for the chat window"*/
	IBOutlet MGLoginWindowController *theLoginWindowController;		/*" The controller class for the login window "*/
	IBOutlet MGToolbarController *theToolbarController;				/*" The controller class for the game window's toolbar "*/
	IBOutlet NSPopUpButton *sortKeyPopUpButton;							/*" PopUpButtonm for sorting the user list "*/
	MGSocketStream *theAGFIBSSocket;								/*" The main communications socket "*/
	BOOL loginDone;	
	BOOL notifiedOfFriendsAndGagAndBlind;								/*" Is the login process compleate? "*/
	BOOL readyToPlayStatus;												/*" Has the user set their status as ready to play? "*/
	IBOutlet NSWindow *loginWindow;										/*" The Login Window "*/
	NSString *loginString;												/*" The login string containing the syntax login MyClient_v0.1 1008 name mypassword "*/
	NSMutableArray *whileDraggingBufferGlobal;
	BOOL whileDraggingBufferNeedsEmpty;
	IBOutlet NSPopUpButton *gameChatTypeOfChatPopUpButton;
	IBOutlet NSMenuItem *connectMenuItem;
	IBOutlet NSMenuItem *disconnectMenuItem;
	IBOutlet NSMenuItem *prefMenuItem;
	int FIBSPreLoginCheckForErrorCount;
	int firstBoardOfNewGame;
}

- (id)init;
- (void)handleFIBSResponseEvent:(int)cookie message:(NSString *)aMessage;

- (MGLoginWindowController *)theLoginWindowController;
- (MGChatController *)theChatController;
- (MGUserListWindowController *)userListWindow;
- (MGToolbarController *)theToolbarController;
- (MGGameController *)theGameController;
- (MGSocketStream *)theAGFIBSSocket;
- (BOOL)readyToPlayStatus;
- (void)setReadyToPlayStatus:(BOOL)newReadyToPlayStatus;
- (void)setTheAGFIBSSocket:(MGSocketStream *)newTheAGFIBSSocket;
- (NSString *)loginString;
- (void)setLoginString:(NSString *)newLoginString;
- (NSMenuItem *)connectMenuItem;
- (NSMenuItem *)disconnectMenuItem;
- (void)playSoundFileLocal:(NSString *)fileName;
- (void)setAsFriend:(NSString *)name;
- (void)removeAsFriend:(NSString *)name;

- (void)sendCommandToSocket:(NSNotification *)notification;
- (void)connect;
- (void)playSoundFile:(NSNotification *)notification;
- (void)prefsHaveChanged:(NSNotification *)notification;
- (void)loginFailed;
- (void)setAsGagAndBlind:(NSString *)name;
- (void)removeAsGagAndBlind:(NSString *)name;
- (void)fibsDisconnected;
- (void)clipWhoEnd;
- (void)setDefaultPrefs;
- (IBAction)showUserListWindow:(id)sender;
- (IBAction)showPrefWindow:(id)sender;
- (void)showGameWindow;
- (IBAction)showTerminalWindow:(id)sender;
- (IBAction)sendBugReport:(id)sender;
- (IBAction)connectMenuItemSelected:(id)sender;
- (IBAction)disconnectMenuItemSelected:(id)sender;
- (IBAction)printBoard:(id)sender;
- (IBAction)makeADonation:(id)sender;
- (IBAction)rollFromMenu:(id)sender;
- (IBAction)doubleFromMenu:(id)sender;
- (void)showPublicChatWindow;
- (BOOL)isFriend:(NSString *)name;
- (BOOL)isGagAndBlind:(NSString *)name;
- (void)reset;
- (void)dealloc;
@end
