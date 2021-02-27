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


#import "MGUserCell.h"
#import "RoundRects.h"

#define FIBS_GAME_WINDOW_TITLE @"FIBS Game Window"

@implementation MGUserCell
/*" Instances of this class act as custom drawn cells for our TableView. "*/

- (id)init
{
    [super init];
    return self;
}

-(void)setObjectValue:(id)x
{
	userListWindowData = x;
}

- (void)setNeedsDisplay:(BOOL)yn
{
    [[self controlView] setNeedsDisplay:yn];
}

- (NSCellType)type
{
    return NSNullCellType;
}

- (NSImage*)imageForClientName:(NSString *)clientName
{
	return [NSImage imageNamed:[userListWindowData objectForKey:@"clientIcon"]];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSColor *AGFIBSBlueColor = [NSColor colorWithCalibratedRed:(56.0/255.0) green:(117.0/255.0) blue:(215.0/255.0) alpha:1.0];
	NSString *userName = [userListWindowData objectForKey:@"name"];
	NSString *status = [userListWindowData objectForKey:@"ready"];
	NSString *client = [userListWindowData objectForKey:@"client"];
	NSColor *textColor = [NSColor blackColor];
	NSImage *statusImage = nil;
	
	NSData *friendsListAsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"friendsList"];
	NSMutableArray *friendsList = [NSKeyedUnarchiver unarchiveObjectWithData:friendsListAsData];
	
	NSData *gagAndBlindListAsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"gagAndBlindList"];
	NSMutableArray *gagAndBlindList = [NSKeyedUnarchiver unarchiveObjectWithData:gagAndBlindListAsData];


	if ([self isHighlighted] && [[controlView window] isKeyWindow] && [[controlView window] firstResponder] == controlView) {
		textColor = [NSColor whiteColor];
	}
	else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"username"] isEqualToString:userName] || [friendsList containsObject:userName]) {
		textColor = AGFIBSBlueColor;
	}
	else if ([gagAndBlindList containsObject:userName]) {
		textColor = [NSColor grayColor];
	}
	else {
		textColor = [NSColor blackColor];
	}
	
	if ([status isEqualToString:@"0"]) {
		status = @"Not Ready";
		statusImage = [NSImage imageNamed:@"statusNotReady"];
	}
	else if ([status isEqualToString:@"1"]) {
		status = @"Ready";
		statusImage = [NSImage imageNamed:@"statusReady"];
		//[NSColor colorWithCalibratedRed:0.0 green:0.6 blue:0.0 alpha:1.0];
	}
	if (![[userListWindowData objectForKey:@"opponent"] isEqualToString:@"-"]) {
		status = [NSString stringWithFormat:@"Playing %@",[userListWindowData objectForKey:@"opponent"]];
		statusImage = [NSImage imageNamed:@"statusYellow"];
	}
		
	NSMutableAttributedString *userNameString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",userName]];
	
	NSMutableAttributedString *ratingAndExperienceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rating %@ Exp %@",[userListWindowData objectForKey:@"rating"],[[userListWindowData objectForKey:@"experience"] stringValue]]];
	
	NSMutableAttributedString *statusAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)",status]];
	
	[userNameString	addAttribute:NSFontAttributeName
				value:[NSFont boldSystemFontOfSize:14]
				range:NSMakeRange(0,[userName length])];
	
	[userNameString	addAttribute:NSForegroundColorAttributeName
				value:textColor
				range:NSMakeRange(0,[userName length])];
				
	[ratingAndExperienceString	addAttribute:NSFontAttributeName
				value:[NSFont systemFontOfSize:10]
				range:NSMakeRange(0,[ratingAndExperienceString length])];
				
	[ratingAndExperienceString	addAttribute:NSForegroundColorAttributeName
				value:textColor
				range:NSMakeRange(0,[ratingAndExperienceString length])];
				
	[statusAttributedString	addAttribute:NSFontAttributeName
				value:[NSFont systemFontOfSize:10]
				range:NSMakeRange(0,[status length]+3)];
				
	[statusAttributedString	addAttribute:NSForegroundColorAttributeName
				value:textColor
				range:NSMakeRange(0,[status length]+3)];
	
	[userNameString appendAttributedString:statusAttributedString];
	
	NSRect chipRect = NSMakeRect(cellFrame.origin.x+8,cellFrame.origin.y+17,10,12);
	NSRect chipRect2 = NSMakeRect(0,0,10,12);
	
	[[self imageForClientName:client] setFlipped:YES];
    [[self imageForClientName:client] drawInRect:chipRect fromRect:chipRect2 operation:NSCompositingOperationSourceOver fraction:1.0];
	
	chipRect = NSMakeRect(cellFrame.origin.x+8,cellFrame.origin.y+3,10,11);
	chipRect2 = NSMakeRect(0,0,10,11);
	
	[statusImage setFlipped:YES];
    [statusImage drawInRect:chipRect fromRect:chipRect2 operation:NSCompositingOperationSourceOver fraction:1.0];
	
	[userNameString drawAtPoint:NSMakePoint(cellFrame.origin.x+30,cellFrame.origin.y)];
	
	[ratingAndExperienceString drawAtPoint:NSMakePoint(cellFrame.origin.x+30,cellFrame.origin.y+20)];
}

@end
