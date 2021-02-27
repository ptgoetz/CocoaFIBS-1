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

#import "MGUserDetailWindowController.h"

@implementation MGUserDetailWindowController
- (id)initWithWhoInfoDictionary:(NSDictionary *)newClipWhoInfoDictionary
{
    self = [super initWithWindowNibName:@"UserDetailWindow"];
	[self setClipWhoInfoDictionary:newClipWhoInfoDictionary];
	
    return self;
}

- (void)dealloc
{
	[clipWhoInfoDictionary release];
	[super dealloc];
}

- (void)setClipWhoInfoDictionary:(NSDictionary *)newClipWhoInfoDictionary {
        [clipWhoInfoDictionary release];
		
		clipWhoInfoDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
	
		[clipWhoInfoDictionary addEntriesFromDictionary:newClipWhoInfoDictionary];
		
		[clipWhoInfoDictionary setObject:[self intToBoolAsString:[[clipWhoInfoDictionary objectForKey:@"ready"] intValue]] forKey:@"ready"];
		[clipWhoInfoDictionary setObject:[self intToBoolAsString:[[clipWhoInfoDictionary objectForKey:@"away"] intValue]] forKey:@"away"];
		
		if ([[clipWhoInfoDictionary objectForKey:@"opponent"] isEqualToString:@"-"]) {
			[clipWhoInfoDictionary setObject:@"Not Playing" forKey:@"opponent"];
		}
		if ([[clipWhoInfoDictionary objectForKey:@"watching"] isEqualToString:@"-"]) {
			[clipWhoInfoDictionary setObject:@"Not Watching" forKey:@"watching"];
		}
}

- (IBAction)updateWho:(id)sender
{
	NSString *stringToSend = [NSString stringWithFormat:@"who %@", [clipWhoInfoDictionary objectForKey:@"name"]];
	[self sendNotificationToSendCommandToSocket:stringToSend];
}

-(void)sendNotificationToSendCommandToSocket:(NSString *)stringToSend 
{
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"AGFIBSSendCommandToSocket" object:stringToSend];
}

- (NSString *)intToBoolAsString:(int)boolAsInt
{
	if (boolAsInt == 1) {
		return @"Yes";
	}
	else {
		return @"No";
	}
}

- (void)windowDidLoad
{
	[[self window] setFrameAutosaveName:@"UserDetailWindow"];	
}

@end
