//
//  CFLog.h
//  CocoaFIBS
//
//  Created by P. Taylor Goetz on 2/3/21.
//

#ifndef CFLog_h
#define CFLog_h
#endif /* CFLog_h */

#define DEBUG

#ifdef DEBUG
    #define CFLog(s, ...) NSLog(@"<%@:%d> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent],  __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
    #define CFLog(...)
#endif
