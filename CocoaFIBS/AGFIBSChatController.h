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

@interface AGFIBSChatController : NSObject
{
    IBOutlet NSTextView *gameChatMainTextView;					/*" TextView for in-game chat "*/
	IBOutlet AGFIBSAppController *theAppController;				/*" Reference to the app controller "*/
    IBOutlet NSTextField *gameChatTextToSendTextField;			/*" TextField for in-game chat "*/
    IBOutlet NSPopUpButton *gameChatTypeOfChatPopUpButton;		/*" PopUpButton to chosse the type of in-game chat "*/
    IBOutlet NSTextView *publicChatMainTextView;				/*" TextView for public chat "*/
    IBOutlet NSTextField *publicChatTextToSendTextField;		/*" TextField for public chat "*/
    IBOutlet NSTextField *privateChatSendTellToWhomTextField;
	IBOutlet NSWindow *publicChatWindow;
	IBOutlet NSBox *publicChatBox;
}

- (IBAction)gameChatSendButton:(id)sender;
- (IBAction)publicChatSendButton:(id)sender;
- (IBAction)changeTypeOfChat:(id)sender;

- (NSTextField *)privateChatSendTellToWhomTextField;
- (NSTextField *)gameChatTextToSendTextField;

- (void)clipKibitzes:(NSString *)aMessage;
- (void)clipYouKibitz:(NSString *)aMessage;
- (void)clipSay:(NSString *)aMessage;
- (void)clipYouSay:(NSString *)aMessage;
- (void)clipShouts:(NSString *)aMessage;
- (void)clipYouShout:(NSString *)aMessage;

- (AGFIBSAppController *)theAppController;
- (void)setTheAppController:(AGFIBSAppController *)newTheAppController;
- (NSPopUpButton *)gameChatTypeOfChatPopUpButton;
- (void)setGameChatTypeOfChatPopUpButton:(NSPopUpButton *)newGameChatTypeOfChatPopUpButton;
- (void)reset;
- (NSWindow *)publicChatWindow;

@end
