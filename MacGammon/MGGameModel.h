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

@class MGTriangle;
@class MGDice;

#import <Foundation/Foundation.h>

@interface MGGameModel : NSObject <NSCoding> {
	NSMutableArray			*gameBoard;					/*" Contains 24 AGFIBSTriangle objects "*/						
	MGDice				*playerDice;				/*" The players current roll "*/
	MGDice				*opponentDice;				/*" The opponent current roll "*/
	MGDice				*playerDiceFromLastTurn;	/*" "*/
	MGDice				*opponentDiceFromLastTurn;	/*"  "*/
	MGTriangle			*playerBar;					/*" The players bar where bumped chips are held "*/
	MGTriangle			*opponentBar;				/*" The opponent's bar where bumped chips are held "*/
	MGTriangle			*playerHome;				/*" The player's home for bearing off chips to "*/
	int						opponentHome;				/*" The opponent home for bearing off chips to "*/
	int						theCube;					/*" The doubling cube "*/	
	NSString				*playerName;				/*" The players name "*/
	NSString				*opponentName;				/*" The opponents name "*/
	int						color;						/*" The player's color "*/
	MGTriangle			*draggedFromTriangle;		/*" A reference to the last triangle where a chip was dragged from "*/
	MGTriangle			*draggedToTriangle;			/*" A reference to the last triangle where a chip was dragged to "*/
	NSDictionary			*fibsBoardStateDictionary;	/*" A dictionary that holds the FIBS_Board state returned from the server "*/
	int						direction;
}

- (id)init;

- (void)newGame;
- (void)updateModelFromFIBS_Board;
- (BOOL)isPlayerHome;
- (int)clearTrianglesInHomeForBareoff;
- (int)howManyChipsNotHome;

- (MGDice *)playerDice;
- (void)setPlayerDice:(MGDice *)newPlayerDice;
- (MGDice *)opponentDice;
- (void)setOpponentDice:(MGDice *)newOpponentDice;
- (MGDice *)playerDiceFromLastTurn;
- (void)setPlayerDiceFromLastTurn:(MGDice *)newPlayerDiceFromLastTurn;
- (MGDice *)opponentDiceFromLastTurn;
- (void)setOpponentDiceFromLastTurn:(MGDice *)newOpponentDiceFromLastTurn;
- (MGTriangle *)playerBar;
- (void)setPlayerBar:(MGTriangle *)newPlayerBar;
- (MGTriangle *)opponentBar;
- (void)setOpponentBar:(MGTriangle *)newOpponentBar;
- (MGTriangle *)playerHome;
- (void)setPlayerHome:(MGTriangle *)newPlayerHome;
- (int)opponentHome;
- (void)setOpponentHome:(int)newOpponentHome;
- (int)theCube;
- (void)setTheCube:(int)newTheCube;
- (NSString *)playerName;
- (void)setPlayerName:(NSString *)newPlayerName;
- (NSString *)opponentName;
- (void)setOpponentName:(NSString *)newOpponentName;
- (int)color;
- (void)setColor:(int)newColor;
- (MGTriangle *)draggedFromTriangle;
- (void)setDraggedFromTriangle:(MGTriangle *)newDraggedFromTriangle;
- (MGTriangle *)draggedToTriangle;
- (void)setDraggedToTriangle:(MGTriangle *)newDraggedToTriangle;
- (NSDictionary *)fibsBoardStateDictionary;
- (void)setFibsBoardStateDictionary:(NSDictionary *)newFibsBoardStateDictionary;
- (int)direction;
- (void)setDirection:(int)newDirection;
- (void)setGameBoard:(NSMutableArray *)aGameBoard;
- (NSMutableArray *)gameBoard;
-(int)pipNumToArrayPos:(int)pipPos;

- (void)dealloc;



@end
