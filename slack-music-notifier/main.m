//
//  main.m
//  slack-music-notifier
//
//  Created by Chris Ellsworth on 8/11/15.
//  Copyright (c) 2015 Chris Ellsworth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SlackMusicNotifier.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [[[SlackMusicNotifier alloc] init] start];
    }
    return 0;
}
