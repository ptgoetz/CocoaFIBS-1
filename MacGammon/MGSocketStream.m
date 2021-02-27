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

#import "MGSocketStream.h"
#import "MGAppController.h"
#import "NetSocket.h"
#include "MGSocketStream.h"
#include "FIBSCookieMonster.h"
#include "CFLog.h"

@implementation MGSocketStream
/*" 
An instance of this class creates and returns input and output streams for a socket connection with the specified port on host. This class handles connection, disconnection, sending data, and stream events such as open, close, data available, and errors. When a line is received by the stream it is passed into the FIBSCookieMonster for RegEx parsing and then the returned string is passed to the app controller for handling. 
"*/

- (id)init
{
	if (![super init]) {
		return nil;
	}
	mSocket = nil;
	toBeWrittenQueue = [[NSMutableArray alloc] init];
	blockSending = NO;
	return self;
}

- (id)initWithServer:(NSString *)myServerAddress port:(int)myPort
{
    [super init];
	serverAddress = myServerAddress;
	serverPort = myPort;
	connected = NO;
    return self;
}

- (void)setAppController:(MGAppController *)controller
{
    theAppController = controller;
}

#pragma mark -

- (void)netsocketConnected:(NetSocket*)inNetSocket
{
	NSLog( @"Socket: Connected" );
    NSLog(@"%p", theAppController);
	[self setConnected:YES];
}

- (void)netsocketDisconnected:(NetSocket*)inNetSocket
{
    NSLog( @"Socket: Disconnected" );
    [theAppController fibsDisconnected];
}

- (void)netsocketDataSent:(NetSocket*)inNetSocket
{
	//NSLog( @"Socket: Data sent" );
}

- (NSInputStream *)inputStream 
{
    return [[inputStream retain] autorelease];
}

- (void)setInputStream:(NSInputStream *)newInputStream 
{
    if (inputStream != newInputStream) {
        [inputStream release];
        inputStream = [newInputStream retain];
    }
    return;
}

- (NSOutputStream *)outputStream 
{
    return [[outputStream retain] autorelease];
}

- (void)setOutputStream:(NSOutputStream *)newOutputStream 
{
    if (outputStream != newOutputStream) {
        [outputStream release];
        outputStream = [newOutputStream retain];
    }
}

- (id)delegate 
{
    return [[delegate retain] autorelease];
}

- (void)setDelegate:(id)newDelegate 
{
	delegate = newDelegate;
}

- (bool)isConnected
{
    return connected;
}

- (void)setConnected:(bool)isConnected
{
    connected = isConnected;
}

- (void)connect
{
	
	// Create a new NetSocket connected to the host. Since NetSocket is asynchronous, the socket is not 
	// connected to the host until the delegate method is called.
	
	int lserverPort = [[[NSUserDefaults standardUserDefaults] stringForKey:@"serverPort"]intValue];
	NSString *lserverAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"serverAddress"];
	
	mSocket = [[NetSocket netsocketConnectedToHost:lserverAddress port:lserverPort] retain];
	
	toBeWrittenQueue = [[NSMutableArray alloc] init];
	
	sendMessageFromQueueTimer = [NSTimer scheduledTimerWithTimeInterval:1
			target:self 
			selector:@selector(sendMessages) 
			userInfo:nil 
			repeats:YES];
	[self sendMessages];
			
	// Schedule the NetSocket on the current runloop
	[mSocket scheduleOnCurrentRunLoop];
	
	// Set the NetSocket's delegate to ourself
	[mSocket setDelegate:self];
	
	ResetFIBSCookieMonster();
}

- (void)disconnect
{
    NSLog(@"disconnect!!!!!!!!!");
	[self sendMessageNow:@"exit2"];
	[self reset];
}

- (void)reset
{
	NSLog(@"Socket Reset!!!!!!!!!");
	[mSocket release];
	mSocket = nil;
	[toBeWrittenQueue release];
	toBeWrittenQueue = nil;
	[sendMessageFromQueueTimer invalidate];
	sendMessageFromQueueTimer = nil;
	[self setConnected:NO];
	ReleaseFIBSCookieMonster();
}

- (void)sendMessageNow:(NSString *)stringToSend
{
    NSString *message = [stringToSend stringByAppendingString:@"\r\n"];
	[mSocket writeString:message encoding:NSUTF8StringEncoding];
	NSLog(@"SENT %@",message);
	[self setBlockSendingYes];
}

- (void)sendMessage:(NSString *)stringToSend
{
    NSString *message = [stringToSend stringByAppendingString:@"\r\n"];
    //if (blockSending) {
    if (false) {
		[toBeWrittenQueue addObject:message];
	}
	else {
		[self sendMessageNow:stringToSend];
	}
}

- (void)sendMessages
{
    // GAAAHHH!!! Is this the pip/game state bug???!!!
    // TODO async was a bad idea, refactor this
    //NSLog(@"Message count: %u", [toBeWrittenQueue count]);
	if ([toBeWrittenQueue count] > 0) {
		[mSocket writeString:[toBeWrittenQueue objectAtIndex:0] encoding:NSUTF8StringEncoding];
		NSLog(@"SENT ASYNC %@",[toBeWrittenQueue objectAtIndex:0]);
		[toBeWrittenQueue removeObjectAtIndex:0];
	}
}


- (void)setBlockSendingYes
{
        blockSending = YES;
}

- (void)setBlockSendingNo
{
        blockSending = NO;
}

- (void)netsocket:(NetSocket*)inNetSocket dataAvailable:(unsigned)inAmount
// If the stream has bytes available to read, read it and strip the new line chars.
{
	NSString *messageString = [mSocket readString:NSUTF8StringEncoding];
	NSString *newLineChar = @"\n";
	NSString *carriageReturnChar = @"\r";
	NSString *cookieString = nil;
	NSArray *arrayToStripNewLineCharFromString = [ messageString componentsSeparatedByString:newLineChar];
	int numberOfLinesInBuffer = [arrayToStripNewLineCharFromString count];
	int cookie = 0;
	int i = 0;

	//Append the last line of the previous data avilible block to the first line of this one
	for (i=0; i < numberOfLinesInBuffer; i++) {
		NSMutableString *oneStringFromArray = [NSMutableString stringWithCapacity:1];	
		[oneStringFromArray setString:[arrayToStripNewLineCharFromString objectAtIndex:i]];
		[oneStringFromArray setString:[self findAndReplaceStringInString:oneStringFromArray find:carriageReturnChar replace:@""]];
		//Convert NSString to cstring
		int aBufferSize = [oneStringFromArray length];
		char aBuffer[aBufferSize];
		NSData *cString = [[NSData alloc] initWithData:[oneStringFromArray dataUsingEncoding:[NSString defaultCStringEncoding]]];
		[cString getBytes:aBuffer];
		cookie = FIBSCookie(aBuffer);
		[cString release];
		[delegate handleFIBSResponseEvent:cookie message:oneStringFromArray];
		//Format a nice string to print to the terminal
		cookieString = [[NSString alloc] initWithFormat:@"(%d)", cookie];
		[oneStringFromArray setString:[cookieString stringByAppendingString:oneStringFromArray]];
        //NSLog(@"%@", oneStringFromArray);
		[cookieString release];
	}
}

- (NSString *)findAndReplaceStringInString:(NSString *)string find:(NSString *)findString replace:(NSString *)replaceString
{
	NSArray *found = [string componentsSeparatedByString:findString]; 
	NSString *replaced = [found componentsJoinedByString:replaceString];
	return replaced;
}

- (void)dealloc
{
	[mSocket release];
	[toBeWrittenQueue release];
	mSocket = nil;
	[super dealloc];
}

@end
