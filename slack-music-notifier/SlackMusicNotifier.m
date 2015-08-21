//
//  SlackMusicNotifier.m
//  slack-music-notifier
//
//  Created by Chris Ellsworth on 8/11/15.
//  Copyright (c) 2015 Chris Ellsworth. All rights reserved.
//

#import "SlackMusicNotifier.h"
#import "iTunes.h"
#import "Spotify.h"
#import "Rdio.h"

@interface SlackMusicNotifier ()
@property (nonatomic, strong) iTunesApplication *iTunes;
@property (nonatomic, strong) SpotifyApplication *spotify;
@property (nonatomic, strong) RdioApplication *rdio;
@property (nonatomic, strong) NSDictionary *args;
@end

@implementation SlackMusicNotifier

- (void)start {
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesDidUpdate:) name:@"com.apple.iTunes.playerInfo" object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyDidUpdate:) name:@"com.spotify.client.PlaybackStateChanged" object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(rdioDidUpdate:) name:@"com.rdio.desktop.playStateChanged" object:nil];
    
    if(!self.args[@"--webhook-url"] || !self.args[@"--name"]) {
        printf("Usage: slack-music-notifier --webhook-url <url> --name <name>");
    } else {
        [[NSRunLoop currentRunLoop] run];
    }
}

- (void)stop {
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"com.apple.iTunes.playerInfo" object:nil];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"com.spotify.client.PlaybackStateChanged" object:nil];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"com.rdio.desktop.playStateChanged" object:nil];
}

- (void)post:(NSString *)text {
    [self log:text];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.args[@"--webhook-url"]]];
    request.HTTPMethod = @"POST";
    
    NSString *body = [NSString stringWithFormat:@"payload={\"username\": \"%@\", \"text\": \"%@\"}", self.args[@"--name"], text];
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error != nil) {
            [self log:[NSString stringWithFormat:@"Error: %@", error]];
            return;
        }
        
        NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self log:[NSString stringWithFormat:@"Response: %@", responseBody]];
    }];
    [task resume];
}

- (void)iTunesDidUpdate:(NSNotification *)notification {
    if(self.iTunes.playerState == iTunesEPlSPlaying) {
        [self post:[NSString stringWithFormat:@"%@ - %@", self.iTunes.currentTrack.artist, self.iTunes.currentTrack.name]];
    }
}

- (void)spotifyDidUpdate:(NSNotification *)notification {
    if(self.spotify.playerState == SpotifyEPlSPlaying) {
        [self post:[NSString stringWithFormat:@"%@ - %@", self.spotify.currentTrack.artist, self.spotify.currentTrack.name]];
    }
}

- (void)rdioDidUpdate:(NSNotification *)notification {
    if(self.rdio.playerState == RdioEPSSPlaying) {
        [self post:[NSString stringWithFormat:@"%@ - %@", self.rdio.currentTrack.artist, self.rdio.currentTrack.name]];
    }
}

- (NSDictionary *)args {
    if(!_args) {
        NSArray *array = [NSProcessInfo processInfo].arguments;
        NSMutableDictionary *args = [[NSMutableDictionary alloc] init];

        for(int i = 1; i < array.count; i++) {
            if(i % 2 == 1) {
                args[array[i]] = array[i + 1];
            }
        }
        _args = args;
    }
    return _args;
}

- (iTunesApplication *)iTunes {
    if(!_iTunes) {
        _iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    }
    return _iTunes;
}

- (SpotifyApplication *)spotify {
    if(!_spotify) {
        _spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    }
    return _spotify;
}

- (RdioApplication *)rdio {
    if(!_rdio) {
        _rdio = [SBApplication applicationWithBundleIdentifier:@"com.rdio.desktop"];
    }
    return _rdio;
}

- (void)log:(NSString *)data {
    if(self.args[@"--verbose"]) {
        NSLog(@"%@", data);
    }
}

- (void)dealloc {
    [self stop];
}

@end
