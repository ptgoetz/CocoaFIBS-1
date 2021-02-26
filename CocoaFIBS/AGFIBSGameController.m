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

#import "AGFIBSGameController.h"
#import "AGFIBSGameModel.h"
#import "AGFIBSGameView.h"
#import "clip.h"
#import "FIBSCookieMonster.h"
#import "AGFIBSInviteToGameWindowController.h"
#import "AGFIBSUserListWindowController.h"
#import "AGFIBSSocketStream.h"
#import "AGFIBSAppController.h"
#include "CFLog.h"

@implementation AGFIBSGameController
/*" 
An instance of this controller class acts as the bridge between the game model and the game view. The methods of this class handle non-view related user interaction such as doubling, opening and closing of the drawer, and the display of score.
"*/

- (id)init 
{
	self = [super init];
	
	return self;
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[matchLengthStepper takeDoubleValueFrom:desieredMatchLengthTextField];
}

- (IBAction)undoMove:(id)sender
{
	[theAGFIBSGameView undoMove];
}

- (IBAction)redoMove:(id)sender
{
	[theAGFIBSGameView redoMove];
}

- (IBAction)matchLengthStepperClicked:(id)sender
{
    int newValue = [sender intValue];
    if (newValue > 0 && newValue < 9) {
       [sender setIncrement:1];
    }
	else if (newValue >= 9 && newValue <= 24) {
       [sender setIncrement:1];
    }
	
	[sender setIntValue:newValue];
    [desieredMatchLengthTextField setIntValue:newValue];
	
	if (newValue > 21) {
       [desieredMatchLengthTextField setStringValue:@"unlimited"];
    }
}

- (void)reset
{
	[self setGameWindowTitleConnected:NO];
	[[[self theAGFIBSGameView] theAGFIBSGameModel] newGame];
	//[[self window] close];	
}

- (void)setGameWindowTitleConnected:(BOOL)connected
{
	if (connected) {
		[[self window] setTitle:@"Game Board (connected)"];
	}
	else {
		[[self window] setTitle:@"Game Board (disconnected)"];
	}
}

- (void)newMatchRequest:(NSString *)aMessage
/*" Tokkenizes a request to play a match from another user. Displays the InviteToGame Window. "*/
{
	NSArray *tokkenizer = [aMessage componentsSeparatedByString:@" "];
	NSString *playerWhoInvitedName = [tokkenizer objectAtIndex:0];
	int proposedMatchLength = [[tokkenizer objectAtIndex:5] intValue];
	
	AGFIBSInviteToGameWindowController *inviteToGameWindow;
	inviteToGameWindow = [[AGFIBSInviteToGameWindowController alloc] init];
	[inviteToGameWindow setPlayerWhoInvitedName:playerWhoInvitedName];
	[inviteToGameWindow setProposedMatchLength:proposedMatchLength];
	
	CFLog(@"userListWindow %@",[[userListWindow getDataForPlayer:@"RepBot"] objectForKey:@"rating"]);
	
	[inviteToGameWindow setPlayerRating:[[userListWindow getDataForPlayer:playerWhoInvitedName] objectForKey:@"rating"]];
	[inviteToGameWindow setPlayerExp:[[userListWindow getDataForPlayer:playerWhoInvitedName] objectForKey:@"experience"]];
	
	[inviteToGameWindow showWindow:self];
}

- (IBAction)undoMoveAsRefreshBoard:(id)sender 
/*" Gets a new board from the server. "*/
{
	[[theAppController theAGFIBSSocket] sendMessage:@"board"];
	[self clearSystemMsg];
}

- (IBAction)togglePrivateChatViewable:(id)sender 
{
	NSRect aFrame;
    NSWindow *mainWindow = [self window];
	NSSize newSize = NSMakeSize(0,0);
    if ([sender state] == NSControlStateValueOn) {
		newSize = NSMakeSize([mainWindow frame].size.width,[mainWindow frame].size.height+100);
	}
    else if ([sender state] == NSControlStateValueOff) {
		newSize = NSMakeSize([mainWindow frame].size.width,[mainWindow frame].size.height-100);
	}
    
	float newHeight = newSize.height;
    float newWidth = newSize.width;

    aFrame = [NSWindow contentRectForFrameRect:[mainWindow frame] styleMask:[mainWindow styleMask]];
    
    aFrame.origin.y += aFrame.size.height;
    aFrame.origin.y -= newHeight;
    aFrame.size.height = newHeight;
    aFrame.size.width = newWidth;
    
    aFrame = [NSWindow frameRectForContentRect:aFrame styleMask:[mainWindow styleMask]];
    
    [mainWindow setFrame:aFrame display:YES animate:YES];
}
- (void)resumeMatchRequest:(NSString *)aMessage
/*" Tokkenizes a request to resume a match from another user. Displays the InviteToGame Window. "*/
{
	NSArray *tokkenizer = [aMessage componentsSeparatedByString:@" "];
	NSString *playerWhoInvitedName = [tokkenizer objectAtIndex:0];
	int proposedMatchLength = 0;
	
	AGFIBSInviteToGameWindowController *inviteToGameWindow;
	inviteToGameWindow = [[AGFIBSInviteToGameWindowController alloc] init];
	[inviteToGameWindow setPlayerWhoInvitedName:playerWhoInvitedName];
	[inviteToGameWindow setProposedMatchLength:proposedMatchLength];
	[inviteToGameWindow showWindow:self];
}

- (NSString *)opponentNameValue {
    return [opponentName stringValue];
}

- (void)updateTheGameView
{
	[theAGFIBSGameView setNeedsDisplay:YES];
	
	NSString *scoreString;
	NSString *pipCountDifString;
	NSString *matchLengthString;
	int pipCountDif = playerPipCount - opponentPipCount;
	
	if ([[[[theAGFIBSGameView theAGFIBSGameModel] fibsBoardStateDictionary] objectForKey:@"player"] isEqualTo:@"You"]) {
		[playerName setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]];
	}
	else {
		[playerName setStringValue:[[[theAGFIBSGameView theAGFIBSGameModel] fibsBoardStateDictionary] objectForKey:@"player"]];
	}
	
	[opponentName setStringValue:[[[theAGFIBSGameView theAGFIBSGameModel] fibsBoardStateDictionary] objectForKey:@"opponent"]];
	
	scoreString = [NSString stringWithFormat:@"%@\t\t\t%d", [[[theAGFIBSGameView theAGFIBSGameModel] fibsBoardStateDictionary] objectForKey:@"playerScore"], playerPipCount];
	[playerScore setStringValue:scoreString];
	
	scoreString = [NSString stringWithFormat:@"%@\t\t\t%d", [[[theAGFIBSGameView theAGFIBSGameModel] fibsBoardStateDictionary] objectForKey:@"opponentScore"], opponentPipCount];
	[opponentScore setStringValue:scoreString];
	
	pipCountDifString = [NSString stringWithFormat:@"%d",pipCountDif];
	[pipCountDifField setStringValue:pipCountDifString];
	
	matchLengthString = [NSString stringWithFormat:@"Match: %@",[[[theAGFIBSGameView theAGFIBSGameModel] fibsBoardStateDictionary] objectForKey:@"matchLength"]];
	[matchLengthField setStringValue:matchLengthString];
}

- (void)displaySystemMsg:(NSString *)aMessage withTime:(BOOL)timeLimit
{
	if (timeLimit) {
		NSTimer *timer;
		double systemMsgClearDelayTime = 60.0;
		timer = [NSTimer scheduledTimerWithTimeInterval:systemMsgClearDelayTime 
			target:self 
			selector:@selector(clearSystemMsg) 
			userInfo:nil 
			repeats:NO];
	}
	[systemMsgText setStringValue:aMessage];
}

- (void)clearSystemMsg
{
    CFLog(@"clearSystemMsg");
    [systemMsgText setStringValue:@""];
}

- (void)setPipCounts:(NSString *)aMessage
{
	NSArray *tokkenizer = [aMessage componentsSeparatedByString:@" "];
	playerPipCount = [[tokkenizer objectAtIndex:2] intValue];
	opponentPipCount = [[tokkenizer objectAtIndex:6] intValue];
	[self updateTheGameView];
}

- (IBAction)toggleUserListDrawer:(id)sender
{
	[userListDrawer setContentSize:NSMakeSize(273,50)];	
	[[userListWindow tableView] reloadData];
	[userListDrawer toggle:nil];
	NSRect aFrame = [NSWindow contentRectForFrameRect:[[self window] frame] styleMask:[[self window] styleMask]];
	//CFLog(@"content, %f", aFrame.size.height);
aFrame = [NSWindow frameRectForContentRect:aFrame styleMask:[[self window] styleMask]];
	CFLog(@"frame, %f", aFrame.size.height);
}

- (IBAction)clickedOnPlayerUsername:(id)sender 
{
	[userListWindow showUserDetailWindowForUser:[playerName stringValue]];
}

- (IBAction)clickedOnOpponentUsername:(id)sender 
{
	[userListWindow showUserDetailWindowForUser:[opponentName stringValue]];
}

- (IBAction)openUserListDrawer 
{
	[[userListWindow tableView] reloadData];
	[userListDrawer open];
}

- (AGFIBSGameView *)theAGFIBSGameView {
    return [[theAGFIBSGameView retain] autorelease];
}

- (void)awakeFromNib
{
	[theAGFIBSGameView setTheAGFIBSGameModel:[[AGFIBSGameModel alloc] init]];
	[[theAGFIBSGameView theAGFIBSGameModel] newGame];
	
	[[self window] setFrameAutosaveName:@"GameWindow"];		
	[self toggleUserListDrawer:nil];
	[theAGFIBSGameView setNeedsDisplay:YES];
	[theAGFIBSGameView setParentWindow:[self window]];
	[desieredMatchLengthTextField setDelegate:self];
}

- (void)displayModelForUserChoiceWithMessageText:(NSString *)messageText button1Title:(NSString *)button1Title button2Title:(NSString *)button2Title iconImage:(NSImage *)iconImage didEndSelector:(SEL)didEndSelector
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[[alert window] setAlphaValue:1.0];
	[alert addButtonWithTitle:button1Title];
	[alert addButtonWithTitle:button2Title];
	[alert setMessageText:messageText];
	[alert setIcon:iconImage];
	[alert setInformativeText:@""];
    [alert setAlertStyle:NSAlertStyleWarning];
	//[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:didEndSelector contextInfo:nil]; 
	NSNumber *returnCode = [NSNumber numberWithInt:[alert runModal]];
	[self performSelector: didEndSelector withObject: returnCode];
}

- (void)askedToResignAlertDidEndWithReturnCode:(NSNumber *)returnCode
{
    if ([returnCode intValue] == NSAlertFirstButtonReturn) {
		[[theAppController theAGFIBSSocket] sendMessage:@"accept"];
    }
	if ([returnCode intValue] == NSAlertSecondButtonReturn) {
		[[theAppController theAGFIBSSocket] sendMessage:@"reject"];
    }
}

- (void)askedToDoubleAlertDidEndWithReturnCode:(NSNumber *)returnCode
{
    if ([returnCode intValue] == NSAlertFirstButtonReturn) {
		[[theAppController theAGFIBSSocket] sendMessage:@"accept"];
    }
	if ([returnCode intValue] == NSAlertSecondButtonReturn) {
		[[theAppController theAGFIBSSocket] sendMessage:@"reject"];
    }
}

- (AGFIBSAppController *)theAppController 
{
    return [[theAppController retain] autorelease];
}

- (void)setTheAppController:(AGFIBSAppController *)newTheAppController 
{
    if (theAppController != newTheAppController) {
        [theAppController release];
        theAppController = [newTheAppController retain];
    }
}

@end
