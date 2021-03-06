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


#import "MGTerminalWindowController.h"
#include "CFLog.h"


@implementation MGTerminalWindowController

- (id)init
{
	self = [super initWithWindowNibName:@"TerminalWindow"];
	isDragging = NO;
	commandHistory = [[NSMutableArray alloc] initWithCapacity:1];
	historyPoint = 0;
    return self;
}

- (void)windowDidLoad
{
	[[self window] setFrameAutosaveName:@"TerminalWindow"];
    NSLog(@"window did load, setting font..");
    NSLog(@"view: %@", terminalInputTextField);
    [terminalDisplayTextView setFont:[NSFont fontWithName:@"Courier" size:12]];
}

- (IBAction)addToSavedCommands:(id)sender
{
	if (![[terminalInputTextField stringValue] isEqualToString:@""]) {
		[savedTerminalCommandsPopUpButton addItemWithTitle:[terminalInputTextField stringValue]];
		NSMutableArray *terminalWindowSavedCommands = [NSMutableArray arrayWithCapacity:1];
		[terminalWindowSavedCommands addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"terminalWindowSavedCommands"]];
		[terminalWindowSavedCommands addObject:[terminalInputTextField stringValue]];
		[[NSUserDefaults standardUserDefaults] setObject:terminalWindowSavedCommands forKey:@"terminalWindowSavedCommands"];
		[terminalInputTextField setStringValue:@""];
	}
}

- (IBAction)removeFromSavedCommands:(id)sender
{
		NSMutableArray *terminalWindowSavedCommands = [NSMutableArray arrayWithCapacity:1];
		[terminalWindowSavedCommands addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"terminalWindowSavedCommands"]];
		[terminalWindowSavedCommands removeObject:[savedTerminalCommandsPopUpButton titleOfSelectedItem]];
		[[NSUserDefaults standardUserDefaults] setObject:terminalWindowSavedCommands forKey:@"terminalWindowSavedCommands"];
}

- (void)displayInTerminal:(NSMutableString *)aMessage
{
	NSMutableString *consoleString = [NSMutableString string];
	[consoleString appendFormat:@"%@ \n", aMessage];

   NSRange r = NSMakeRange([[terminalDisplayTextView string] length], 0);
   [terminalDisplayTextView replaceCharactersInRange:r withString:[consoleString substringFromIndex:0]];
	if (NSMaxY([terminalDisplayTextView bounds]) == NSMaxY([terminalDisplayTextView visibleRect])) {
		[terminalDisplayTextView scrollRangeToVisible:NSMakeRange([[terminalDisplayTextView string] length], [[terminalDisplayTextView string] length])];
	}
}

- (IBAction)sendCommandToTerminal:(id)sender
{
    NSLog(@"sendCommandToTerminal()");
    NSNotificationCenter *nc;
    nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Terminal Command: %@", [sender stringValue]);
    NSMutableString *consoleString = [NSMutableString string];
    [consoleString appendFormat:@"> %@", [sender stringValue]];
    [self displayInTerminal: consoleString];
    
	[nc postNotificationName:@"AGFIBSSendCommandToSocket" object:[sender stringValue]];
    terminalInputTextField.stringValue = @"";
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
    if (command == @selector(moveDown:)) {
		if (historyPoint < [commandHistory count]-1) {
			historyPoint++;
			[control setStringValue:[commandHistory objectAtIndex:historyPoint]];
		}
		else if (historyPoint == [commandHistory count]-1) {
			historyPoint++;
			[control setStringValue:@""];
		}
		
		return YES;
	}
    if (command == @selector(moveUp:)) {
		if (historyPoint > 0) {
			historyPoint--;
		}
		[control setStringValue:[commandHistory objectAtIndex:historyPoint]];
		return YES;
	}
	return NO;
}

- (BOOL)isDragging {
    return isDragging;
}

- (void)setIsDragging:(BOOL)newIsDragging {
    if (isDragging != newIsDragging) {
        isDragging = newIsDragging;
    }
}

@end
