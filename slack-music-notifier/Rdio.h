/*
 * Rdio.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class RdioApplication, RdioTrack, RdioApplication;

enum RdioEPSS {
	RdioEPSSPaused = 'kPSp',
	RdioEPSSPlaying = 'kPSP',
	RdioEPSSStopped = 'kPSS'
};
typedef enum RdioEPSS RdioEPSS;

enum RdioERep {
	RdioERepNone = 'kReN' /* Do not repeat */,
	RdioERepOne = 'kReO' /* Repeat the currently playing track */,
	RdioERepAll = 'kReA' /* Repeat the currently playing source (i.e. album, playlist) */
};
typedef enum RdioERep RdioERep;



/*
 * Rdio Suite
 */

// The Rdio application.
@interface RdioApplication : SBApplication

@property (copy, readonly) RdioTrack *currentTrack;  // The current playing track.
@property NSInteger soundVolume;  // The sound output volume (0 = min, 100 = max)
@property (readonly) RdioEPSS playerState;  // Is Rdio stopped, paused, or playing?
@property NSInteger playerPosition;  // The player’s position within the currently playing track in seconds.
@property BOOL shuffle;  // The player's shuffle state
@property RdioERep repeatState;  // The player's repeat state

- (void) addToCollection;  // Add current song to your collection.
- (void) removeFromCollection;  // Remove current song from your collection.
- (void) syncToMobile;  // Sync current song to mobile.
- (void) removeFromMobile;  // Remove current song from mobile.
- (void) nextTrack;  // Skip to the next track.
- (void) previousTrack;  // Skip to the previous track.
- (void) playpause;  // Toggle play/pause.
- (void) pause;  // Pause playback.
- (void) playSource:(NSString *)source;  // Resume playback.

@end

// A Rdio track.
@interface RdioTrack : SBObject

@property (copy, readonly) NSString *artist;  // The artist of the track.
@property (copy, readonly) NSString *album;  // The album of the track.
@property (readonly) NSInteger duration;  // The length of the track in seconds.
@property (copy, readonly) NSString *name;  // The name of the track.
@property (copy, readonly) NSData *artwork;  // Artwork for the currently playing track.
@property (copy, readonly) NSString *rdioUrl;  // The URL of the track.
@property (copy, readonly) NSString *key;  // The current playing track's key.


@end



/*
 * Standard Suite
 */

// The application's top level scripting object.
@interface RdioApplication (StandardSuite)

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the frontmost (active) application?
@property (copy, readonly) NSString *version;  // The version of the application.

@end

