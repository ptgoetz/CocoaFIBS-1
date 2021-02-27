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

#import "AGFIBSPrefController.h"
#include "CFLog.h"

@implementation AGFIBSPrefController

- (id)init
{
    self = [super initWithWindowNibName:@"PrefWindow"];
	[self getCustomBoards];
    return self;
}

- (void)windowDidLoad
{
	//Start Position
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"startPosition"] == 2) {
        [rightStartPositionPrefRadioButton setState:NSControlStateValueOn];
	}
	else {
        [leftStartPositionPrefRadioButton setState:NSControlStateValueOn];
	}
	
	//Sound
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"soundOnOff"] == 1) {
        [onSoundPrefRadioButton setState:NSControlStateValueOn];
	}
	else {
        [offSoundPrefRadioButton setState:NSControlStateValueOn];
	}
	
	//highlightTargetPips
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"highlightTargetPips"] == 1) {
        [highlightTargetPipsPrefCheckboxButton setState:NSControlStateValueOn];
	}
	else {
        [highlightTargetPipsPrefCheckboxButton setState:NSControlStateValueOn];
	}
}

- (void)getCustomBoards
{
	NSString *boardsFolderInBundle = [NSString stringWithFormat:@"%@/Contents/Resources/boards", [[NSBundle mainBundle] bundlePath]];
	contentsOfBoardsFolder = [NSMutableArray arrayWithCapacity:0];
	[contentsOfBoardsFolder addObjectsFromArray:[[NSFileManager defaultManager] directoryContentsAtPath:boardsFolderInBundle]];
	
	if ([[contentsOfBoardsFolder objectAtIndex:0] isEqualToString:@".DS_Store"]) {
		[contentsOfBoardsFolder removeObjectAtIndex:0];
	}
}

- (IBAction)changeCustomBoard:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[sender titleOfSelectedItem]  forKey:@"customBoard"];
	[self prefsHaveChanged];
}

- (IBAction)leftStartPositionPrefRadioButtonClicked:(id)sender
{
    [rightStartPositionPrefRadioButton setState:NSControlStateValueOff];
	[[NSUserDefaults standardUserDefaults] setInteger:1  forKey:@"startPosition"];
	[self prefsHaveChanged];
}

- (IBAction)rightStartPositionPrefRadioButtonClicked:(id)sender
{
    [leftStartPositionPrefRadioButton setState:NSControlStateValueOff];
	[[NSUserDefaults standardUserDefaults] setInteger:2  forKey:@"startPosition"];
	[self prefsHaveChanged];
}

- (IBAction)onSoundnPrefRadioButtonClicked:(id)sender
{
    [offSoundPrefRadioButton setState:NSControlStateValueOff];
	[[NSUserDefaults standardUserDefaults] setInteger:1  forKey:@"soundOnOff"];

}
- (IBAction)offSoundPrefRadioButtonClicked:(id)sender
{
    [onSoundPrefRadioButton setState:NSControlStateValueOff];
	[[NSUserDefaults standardUserDefaults] setInteger:0  forKey:@"soundOnOff"];
}

- (IBAction)highlightTargetPipsPrefCheckboxButtonClicked:(id)sender
{
    if ([highlightTargetPipsPrefCheckboxButton state] == NSControlStateValueOn) {
		[[NSUserDefaults standardUserDefaults] setBool:YES  forKey:@"highlightTargetPips"];
	}
    else if ([highlightTargetPipsPrefCheckboxButton state] == NSControlStateValueOff) {
		[[NSUserDefaults standardUserDefaults] setBool:NO  forKey:@"highlightTargetPips"];
	}
}

- (void)prefsHaveChanged
{
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"AGFIBSPrefsHaveChanged" object:nil];
}

@end
