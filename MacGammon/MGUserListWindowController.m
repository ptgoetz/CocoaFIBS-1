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

#import "MGUserListWindowController.h"
#import "MGUserCell.h"
#import "MGUserDetailWindowController.h"
#include "MGAppController.h"
#include "MGChatController.h"
#include "CFLog.h"

#define KEY_UP_ARROW 126
#define KEY_DOWN_ARROW 125
#define KEY_HOME 115
#define KEY_END 119
#define KEY_PAGE_UP 116
#define KEY_PAGE_DOWN 121
#define RETURN 36

@implementation MGUserListWindowController
/*"
Instances of this class acts as the controller for the NSTableView that pops out in a drawer and displays a list of connected users and their personal info. An NSTableView displays data for a set of related records, with rows representing individual records and columns representing the attributes of those records.
"*/

- (id)init
{
	userListWindowData = [[NSMutableArray alloc] init];
	NSArray *clipWhoInfoKeys = [@"cookie name opponent watching ready away rating experience idle login hostname client email" componentsSeparatedByString:@" "];
	NSArray *clipWhoInfoMessage = [@"cookie name opponent watching ready away rating experience idle login hostname client email" componentsSeparatedByString:@" "];
	NSMutableDictionary *clipWhoInfoDictionary = [[NSMutableDictionary alloc] initWithObjects:clipWhoInfoMessage forKeys:clipWhoInfoKeys];
	//[userListWindowData addObject:clipWhoInfoDictionary];
	[clipWhoInfoDictionary release];
	selectedRow = 0;
	selectedName = @"";
	sortDescriptorsArray = [[NSMutableArray alloc] init];
	sortDirection = YES;
	return self;
}

-(void)sendNotificationToSendCommandToSocket:(NSString *)stringToSend 
{
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"AGFIBSSendCommandToSocket" object:stringToSend];
}

-(void)removeUserFromList:(NSString *)playerToRemove 
{
	NSEnumerator *enumerator = [userListWindowData objectEnumerator];
	id aPlayerObject;
	NSString *aPlayersName;
	while (aPlayerObject = [enumerator nextObject]) {
		 aPlayersName = [aPlayerObject objectForKey:@"name"];
		if ([playerToRemove isEqualToString:aPlayersName]) {
			[userListWindowData removeObject:aPlayerObject];
			break;
		}
    }
}

- (void)setUserInUserOutWithMsg:(NSString *)msg
{
	[userInUserOutTextField setStringValue:msg];
}

- (void)setCountOfLogedInUsers
{
	[totalLogedInUsers setStringValue:[NSString stringWithFormat:@"%lu", (unsigned long)[userListWindowData count]]];
}

-(int)findInListByLetter:(NSString *)letter 
{
	NSEnumerator *enumerator = [userListWindowData objectEnumerator];
	id aPlayerObject;
	int i = 0;
	NSString *aPlayersName;
	while (aPlayerObject = [enumerator nextObject]) {
		aPlayersName = [aPlayerObject objectForKey:@"name"];
		NSLog(@"letter %@",letter);
		NSLog(@"[aPlayersName] %@",aPlayersName);
		NSLog(@"[aPlayersName substringToIndex:1] %@",[aPlayersName substringToIndex:1]);
		
		if ([letter isEqualToString:[aPlayersName substringToIndex:1]]) {
			NSLog(@"goto %d",i);
			return i;
		}
		i++;
    }
	i = -1;
	return i;
}

- (void)reverseSort 
{
	NSMutableArray *reversedSortDescriptorsArray = [[NSMutableArray alloc] init];
	NSEnumerator *enumerator = [sortDescriptorsArray objectEnumerator];
	id aSortDescriptorObject;
	while (aSortDescriptorObject = [enumerator nextObject]) {
		[reversedSortDescriptorsArray addObject:[aSortDescriptorObject reversedSortDescriptor]];
    }
	[sortDescriptorsArray release];
	sortDescriptorsArray = [reversedSortDescriptorsArray retain];
}

- (void)sort
{
	if ([sortDescriptorsArray count] == 0) {
		NSSortDescriptor *userListSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:sortDirection selector:@selector(caseInsensitiveCompare:)];
		[userListWindowData sortUsingDescriptors:[NSArray arrayWithObject:userListSortDescriptor]];
	}
	else {
		[userListWindowData sortUsingDescriptors:sortDescriptorsArray];
	}
	NSControl *aControl = [[[tableView tableColumns] objectAtIndex:0] dataCellForRow:0];
	
	[aControl setNeedsDisplay:YES];
}

- (IBAction)sort:(id)sender
{
	NSSortDescriptor *userListSortDescriptor;
	
	if ([[sender title] isEqualToString:@"Name"]) {
		userListSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:sortDirection selector:@selector(caseInsensitiveCompare:)];
		if ([sortDescriptorsArray containsObject:userListSortDescriptor]) {
			if (![sender state]) {
				[sortDescriptorsArray removeObject:userListSortDescriptor];
			}
		}
		else {
			[sortDescriptorsArray addObject:userListSortDescriptor];
		}
	}
	if ([[sender title] isEqualToString:@"Rating"]) {
		userListSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rating" ascending:sortDirection selector:@selector(localizedStandardCompare:)];
		if ([sortDescriptorsArray containsObject:userListSortDescriptor]) {
			if (![sender state]) {
				[sortDescriptorsArray removeObject:userListSortDescriptor];
			}
		}
		else {
			[sortDescriptorsArray addObject:userListSortDescriptor];
		}
	}
		if ([[sender title] isEqualToString:@"Client"]) {
		userListSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"clientIcon" ascending:sortDirection selector:@selector(caseInsensitiveCompare:)];
		if ([sortDescriptorsArray containsObject:userListSortDescriptor]) {
			if (![sender state]) {
				[sortDescriptorsArray removeObject:userListSortDescriptor];
			}
		}
		else {
			[sortDescriptorsArray addObject:userListSortDescriptor];
		}
	}
	if ([[sender title] isEqualToString:@"Status"]) {
		userListSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"status" ascending:!sortDirection selector:@selector(caseInsensitiveCompare:)];
		if ([sortDescriptorsArray containsObject:userListSortDescriptor]) {
			if (![sender state]) {
				[sortDescriptorsArray removeObject:userListSortDescriptor];
			}
		}
		else {
			[sortDescriptorsArray addObject:userListSortDescriptor];
		}
	}
	if ([[sender title] isEqualToString:@"Experience"]) {
		userListSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"experience" ascending:sortDirection];
		if ([sortDescriptorsArray containsObject:userListSortDescriptor]) {
			if (![sender state]) {
				[sortDescriptorsArray removeObject:userListSortDescriptor];
			}
		}
		else {
			[sortDescriptorsArray addObject:userListSortDescriptor];
		}
	}
	if ([[sender title] isEqualToString:@"Relationship"]) {
		userListSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"relationship" ascending:sortDirection];
		if ([sortDescriptorsArray containsObject:userListSortDescriptor]) {
			if (![sender state]) {
				[sortDescriptorsArray removeObject:userListSortDescriptor];
			}
		}
		else {
			[sortDescriptorsArray addObject:userListSortDescriptor];
		}
	}

	if ([sortDescriptorsArray count]) {
		[userListWindowData sortUsingDescriptors:sortDescriptorsArray];
	}
	
    NSLog(@"%@", [sortDescriptorsArray description]);
	NSControl *aControl = [[[tableView tableColumns] objectAtIndex:0] dataCellForRow:0];
	[self selectRowAfterDataSourceUpdate];
	[aControl setNeedsDisplay:YES];
}

- (NSString *)selectedName
{
    return selectedName;
}

- (void)setSelectedName:(NSString *)aName
{
    [aName retain];
    [selectedName release];
    selectedName = aName;
}

-(void)selectRow 
{
	NSControl *aControl;
	NSEnumerator *enumerator = [userListWindowData objectEnumerator];
	id aPlayerObject;
	while (aPlayerObject = [enumerator nextObject]) {
		[aPlayerObject setObject:@"NO" forKey:@"selected"];
	}
	
	[[userListWindowData objectAtIndex:selectedRow] setObject:@"YES" forKey:@"selected"];
	
	aControl = [[[tableView tableColumns] objectAtIndex:0] dataCellForRow:selectedRow];
	[aControl setNeedsDisplay:YES];
	[self setSelectedName:[[userListWindowData objectAtIndex:selectedRow] objectForKey:@"name"]];
	
	[tableView selectRow:selectedRow byExtendingSelection:NO];
	[tableView scrollRowToVisible:selectedRow];
	[self updateUserDetailWindow:[self selectedName]];
}

-(void)selectRowAfterDataSourceUpdate
{
	NSEnumerator *enumerator = [userListWindowData objectEnumerator];
	id aPlayerObject;
	int i = 0;
	while (aPlayerObject = [enumerator nextObject]) {
		if ([[aPlayerObject objectForKey:@"selected"] isEqualToString:@"YES"]) {
			selectedRow = i;
		}
		i++;
	}
	
	[tableView selectRow:selectedRow byExtendingSelection:NO];
}

-(BOOL)containsPlayer:(NSString *)playerName 
{
	NSEnumerator *enumerator = [userListWindowData objectEnumerator];
	id aPlayerObject;
	while (aPlayerObject = [enumerator nextObject]) {
		if ([playerName isEqual:[aPlayerObject objectForKey:@"name"]]) {
			return YES;
		}
	}
	return NO;
}

-(NSDictionary *)getDataForPlayer:(NSString *)playerName 
/*" "*/
{	
	NSEnumerator *enumerator = [userListWindowData objectEnumerator];
	NSDictionary *aPlayerObject;
	while (aPlayerObject = [enumerator nextObject]) {
		if ([playerName isEqualToString:[aPlayerObject objectForKey:@"name"]]) {
			NSLog(@"found for get%@", [aPlayerObject objectForKey:@"name"]);
			return aPlayerObject;
		}
	}
	return nil;
}

-(void)setAttribute:(NSString *)attribute forPlayer:(NSString *)playerName withValue:(NSString *)value 
/*" "*/
{	
	NSEnumerator *enumerator = [userListWindowData objectEnumerator];
	NSMutableDictionary *aPlayerObject;
	int i = 0;
	while (aPlayerObject = [enumerator nextObject]) {
		i++;
		if ([playerName isEqualToString:[aPlayerObject objectForKey:@"name"]]) {
			NSLog(@"found for set%@", [aPlayerObject objectForKey:@"name"]);
			break;
		}
	}
	[aPlayerObject setObject:value forKey:attribute];
	[userListWindowData replaceObjectAtIndex:i withObject:aPlayerObject];
}

-(BOOL)containsAnyFriends
{
	NSEnumerator *enumerator = [userListWindowData objectEnumerator];
	id aPlayerObject;
	while (aPlayerObject = [enumerator nextObject]) {
		if ([theAppController isFriend:[aPlayerObject objectForKey:@"name"]]) {
			return YES;
		}
	}
	return NO;
}

-(BOOL)handleGagAndBlinds
{
	NSEnumerator *enumerator = [userListWindowData objectEnumerator];
	id aPlayerObject;
	while (aPlayerObject = [enumerator nextObject]) {
		if ([theAppController isGagAndBlind:[aPlayerObject objectForKey:@"name"]]) {
			[self sendNotificationToSendCommandToSocket:[NSString stringWithFormat:@"gag %@", [aPlayerObject objectForKey:@"name"]]];
			[self sendNotificationToSendCommandToSocket:[NSString stringWithFormat:@"blind %@", [aPlayerObject objectForKey:@"name"]]];
			return YES;
		}
	}
	return NO;
}

-(void)mouseDown:(NSEvent *)theEvent 
{
	selectedRow = [tableView rowAtPoint:[tableView convertPoint:[theEvent locationInWindow] fromView:nil]];
	[self selectRow];
}

-(void)updateUserDetailWindow:(NSString *)name 
{
	if ([[theUserDetailWindow window] isVisible]) {
		[self showUserDetailWindowForUser:name];
	}
}

- (void)keyDown:(NSEvent *)theEvent
{
	NSLog(@"key %d",[theEvent keyCode]);
	
	if ([theEvent keyCode] == KEY_UP_ARROW && selectedRow > 0) {
		selectedRow -=1;
	}
	else if ([theEvent keyCode] == KEY_DOWN_ARROW && selectedRow < [self numberOfRowsInTableView:tableView]-1) {
		selectedRow +=1;
	}
	else if ([theEvent keyCode] == KEY_HOME) {
		selectedRow = 0;
	}
	else if ([theEvent keyCode] == KEY_END) {
		selectedRow = [self numberOfRowsInTableView:tableView]-1;
	}
	else if ([theEvent keyCode] == KEY_PAGE_UP) {
	}
	else if ([theEvent keyCode] == KEY_PAGE_DOWN) {
	}
	else if ([theEvent keyCode] == RETURN) {
		[self showUserDetailWindowForUser:[self selectedName]];
	}
	else {
		if ([self findInListByLetter:[theEvent charactersIgnoringModifiers]] > -1) {
			selectedRow = [self findInListByLetter:[theEvent charactersIgnoringModifiers]];
		}
	}
	
	[self selectRow];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    selectedRow = [tableView rowAtPoint:[tableView convertPoint:[theEvent locationInWindow] fromView:nil]];
	[self selectRow];
	if([theEvent clickCount] == 2) {
		[self setDynamicMenuItems];
		[NSMenu popUpContextMenu:myMenu withEvent:theEvent forView:tableView];
    }
}

-(void)setDynamicMenuItems
{
	if ([theAppController isFriend:[self selectedName]]) {
		[[[[myMenu itemWithTitle:@"Relationship"] submenu] itemWithTag:9] setTitle:@"Not Friend"];
		[[[[myMenu itemWithTitle:@"Relationship"] submenu] itemWithTag:9] setTag:10];
	}
	else if (![theAppController isFriend:[self selectedName]]) {
		[[[[myMenu itemWithTitle:@"Relationship"] submenu] itemWithTag:10] setTitle:@"Friend"];
		[[[[myMenu itemWithTitle:@"Relationship"] submenu] itemWithTag:10] setTag:9];
	}
	
	NSString *personalizedMeniItem = [NSString stringWithFormat:@"Chat With %@", [self selectedName]];
	[[myMenu itemWithTag:4] setTitle:personalizedMeniItem];
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent 
{
	selectedRow = [tableView rowAtPoint:[tableView convertPoint:[theEvent locationInWindow] fromView:nil]];
	[self selectRow];
	[self setDynamicMenuItems];
	return myMenu;
}

- (IBAction)menuItem:(id)sender
{
	NSLog(@"Menu Clicked %@", [[userListWindowData objectAtIndex:selectedRow] objectForKey:@"name"]);
	NSLog(@"tag %ld", (long)[sender tag]);
	NSString *stringToSend;
	
	if ([sender tag] == 0) {
		if (sortDirection == YES)
			sortDirection = NO;
		else if (sortDirection == NO)
			sortDirection = YES;
			
		[self reverseSort];
		[self sort];
		[self selectRowAfterDataSourceUpdate];
	}
	else if ([sender tag] == 1) {
		stringToSend = [NSString stringWithFormat:@"invite %@ %@", [self selectedName], [gameLengthTextField stringValue]];
		[self sendNotificationToSendCommandToSocket:stringToSend];
	}
	else if ([sender tag] == 2) {
		stringToSend = [NSString stringWithFormat:@"invite %@", [self selectedName]];
		[self sendNotificationToSendCommandToSocket:stringToSend];
	}
	else if ([sender tag] == 3) {
		stringToSend = [NSString stringWithFormat:@"watch %@", [self selectedName]];
		[self sendNotificationToSendCommandToSocket:stringToSend];
		
	}
	else if ([sender tag] == 4) {
		[[theAppController theChatController] changeTypeOfChat:nil];
		[gameChatTypeOfChatPopUpButton addItemWithTitle: [NSString stringWithFormat:@"tell %@", [self selectedName]]];
		[gameChatTypeOfChatPopUpButton selectItemAtIndex:([gameChatTypeOfChatPopUpButton numberOfItems]-1)];
		[[theAppController theChatController] changeTypeOfChat:nil];
		[[[theAppController theGameController] window] makeFirstResponder:[[theAppController theChatController] gameChatTextToSendTextField]];
	}
	else if ([sender tag] == 5) {
		[self sendNotificationToSendCommandToSocket:@"unwatch"];
	}
	else if ([sender tag] == 6) {
		stringToSend = [NSString stringWithFormat:@"look %@", [self selectedName]];
		[self sendNotificationToSendCommandToSocket:stringToSend];
	}
	else if ([sender tag] == 7) {
		stringToSend = [NSString stringWithFormat:@"tell repbot %@ %@",[sender title], [self selectedName]];
		[self sendNotificationToSendCommandToSocket:stringToSend];
	}
	else if ([sender tag] == 8) {
		stringToSend = [NSString stringWithFormat:@"tell repbot %@", [sender title]];
		[self sendNotificationToSendCommandToSocket:stringToSend];
	}
    else if ([[sender title]  isEqual: @"Friend"] || [sender tag] == 9) {
		[theAppController setAsFriend:[self selectedName]];
		stringToSend = [NSString stringWithFormat:@"who %@", [self selectedName]];
		[self sendNotificationToSendCommandToSocket:stringToSend];
	}
	else if ([sender title] == @"Not Friend" || [sender tag] == 10) {
		[theAppController removeAsFriend:[self selectedName]];
		stringToSend = [NSString stringWithFormat:@"who %@", [self selectedName]];
		[self sendNotificationToSendCommandToSocket:stringToSend];
	}
	else if ([sender tag] == 11) {
		stringToSend = [NSString stringWithFormat:@"gag %@", [self selectedName]];
		[self sendNotificationToSendCommandToSocket:stringToSend];
		
		stringToSend = [NSString stringWithFormat:@"blind %@", [self selectedName]];
		[self sendNotificationToSendCommandToSocket:stringToSend];
	}
	else if ([sender tag] == 12) {
		[self showUserDetailWindowForUser:[self selectedName]];
	}
}

- (NSProgressIndicator *)whoLoadingProgressIndicator {
    return [[whoLoadingProgressIndicator retain] autorelease];
}

- (void)whoListLoadingDone {
    [whoLoadingProgressIndicator stopAnimation:nil];
	[totalLogedInUsers setHidden:NO];
}

- (void)reset
{
	[totalLogedInUsers setStringValue:@""];
	[totalLogedInUsers setHidden:YES];
	[[self userListWindowData] removeAllObjects];
	[[self tableView] reloadData];
}	
	
- (void)showUserDetailWindowForUser:(NSString *)name
{
	if ([self getDataForPlayer:name] != nil) {
		if (!theUserDetailWindow) {
			theUserDetailWindow = [[MGUserDetailWindowController alloc] initWithWhoInfoDictionary:[self getDataForPlayer:name]];
		}
		else {
			[theUserDetailWindow setClipWhoInfoDictionary:[self getDataForPlayer:name]];
		}
		[[theUserDetailWindow window] makeKeyAndOrderFront:self];
		[theUserDetailWindow showWindow:self];
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem tag] == 1) {
		return YES;
	} 
	else if ([menuItem tag] == 2) {
		return YES;
	}
	else if ([menuItem tag] == 3) {
		return YES;
	}
	else if ([menuItem tag] == 4) {
		return YES;
	}
	else if ([menuItem tag] == 5) {
		return YES;
	}
	else if ([menuItem tag] == 6) {
		return YES;
	}
	else if ([menuItem tag] == 7) {
		return YES;
	}
	else if ([menuItem tag] == 8) {
		return YES;
	}
	else if ([menuItem tag] == 9) {
		return YES;
	}
	else if ([menuItem tag] == 10) {
		return YES;
	}
	else if ([menuItem tag] == 11) {
		return YES;
	}
	else if ([menuItem tag] == 12) {
		return YES;
	}
	else {
		return NO;
	}
}

- (NSPopUpButton *)gameChatTypeOfChatPopUpButton 
{
    return [[gameChatTypeOfChatPopUpButton retain] autorelease];
}

- (void)setGameChatTypeOfChatPopUpButton:(NSPopUpButton *)newGameChatTypeOfChatPopUpButton 
{
    if (gameChatTypeOfChatPopUpButton != newGameChatTypeOfChatPopUpButton) {
        [gameChatTypeOfChatPopUpButton release];
        gameChatTypeOfChatPopUpButton = [newGameChatTypeOfChatPopUpButton retain];
    }
}

- (NSMutableArray *)userListWindowData 
{
	return [[userListWindowData retain] autorelease];
}

- (void)setUserListWindowData:(NSMutableArray *)newUserListWindowData 
{
    if (userListWindowData != newUserListWindowData) {
        [userListWindowData release];
        userListWindowData = [newUserListWindowData retain];
    }
}

- (NSTableView *)tableView 
{
    return [[tableView retain] autorelease];
}

- (void)setTableView:(NSTableView *)newTableView 
{
    if (tableView != newTableView) {
        [tableView release];
        tableView = [newTableView retain];
    }
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [userListWindowData count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    return [userListWindowData objectAtIndex:row];
}

- (void)awakeFromNib
{
    MGUserCell *csc;
    csc = [[MGUserCell alloc] init];
    [column setDataCell:csc];
    [csc release];
}

@end
