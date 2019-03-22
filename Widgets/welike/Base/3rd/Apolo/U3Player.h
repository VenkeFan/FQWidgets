#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "U3PlayerScaleMode.h"

#ifdef U3PLAYER_LIBRARY
#pragma GCC visibility push(default)
#define U3PlayerExport __attribute__((visibility("default")))
#else
#define U3PlayerExport
#endif

typedef NS_ENUM(NSInteger, VideoPlayerState) {
    VideoPlayer_Stop = 0,
    VideoPlayer_Playing = 1,
    VideoPlayer_Pause = 2,
    VideoPlayer_End = 3,
    VideoPlayer_Buffering = 80,
    VideoPlayer_Unknown = 97,
    VideoPlayer_Ready = 98,
    VideoPlayer_Error = 99
};

U3PlayerExport
@interface U3playerCustomProxyConfig : NSObject
@property (nonatomic, assign) NSInteger proxy;
@property (nonatomic, copy) NSString *proxyHost;
@property (nonatomic, assign) NSInteger proxyPort;
@property (nonatomic, copy) NSDictionary<NSString*, NSString*> *authHttpHeaders;
@end

#pragma mark - U3PlayerDelegate
U3PlayerExport
@protocol U3PlayerDelegate <NSObject>

- (void)onPrepared;
- (void)onSeekCompleted;
- (void)onEndOfStream;
- (void)onStopped;

@optional

- (void)onBufferingUpdate:(int)percent;
- (void)onBufferingStateUpdate:(bool)is_start;
- (void)onDownloadRateChange:(int)bytes_per_second;
- (void)onErrorOfStream:(int)what Extra:(int)extra;
- (void)onVideoSizeChanged:(int)width height:(int)height;

- (void)onStatT3:(int64_t)timeMs startTime:(int64_t)startMs endTime:(int64_t)endMs;

- (void)onPaused;
- (void)onResumed;

- (void)onRenderStarting;

- (U3playerCustomProxyConfig*)getHttpProxyInfo:(const NSString*)url;

- (void)onSwitchVideoDon:(int)extra;

@end

#pragma mark - U3Player
U3PlayerExport
@interface U3Player : NSObject

// Status Observer
@property (nonatomic, weak) id<U3PlayerDelegate> delegate;

/*
 * Manage the view display mode.
 * Should be set in Main thread!!!
 */
@property (nonatomic) VideoRenderingScaleMode scaleMode;

/**
 * MediaType
 */
@property (readonly) uint mediaType;

/*
 *   Manage the playing media file
 */

// After set mediaFilePath, engineen should parse the mov to get time rang and thumbnail, and initialize sth in playBackView
@property (strong, nonatomic) NSURL* mediaFilePath;

@property (strong, nonatomic) NSDictionary* httpHeaders;

@property (nonatomic) float initialPlaybackTime; //second

/*
 *   Manage the playing status
 */

// Current time offset ,After set position, Player will be pausing.
@property (nonatomic) float position;

// The currently playable duration of the movie, for progressively downloaded network content.
@property (nonatomic, readonly) float playableDuration;

//
@property (NS_NONATOMIC_IOSONLY, getter=isPlaying, readonly) BOOL playing;

// 0.0 player is stop, 1.0,play at the natural rate of the current item
@property (nonatomic) float rate;

// Player state ,playing , waiting , etc
@property (nonatomic, readonly) VideoPlayerState state;

// Total time about the movie
@property (readonly) float duration;

@property (nonatomic, assign) BOOL isSeeking;
@property (nonatomic, assign) BOOL isBuffering;

/*
 * Manage the player's view
 */
@property (strong, atomic) UIView* playBackView;

+ (void)initStoragePath;

- (instancetype)initWithMute:(BOOL)mute;

// Modify the view
- (void)setFrame:(CGRect)frame;
// gernal operating
- (BOOL)prepare; // return YES not mean successful. means preparing.
- (void)play;
- (void)stop;
- (void)pause;
- (void)seek:(float)position;
- (void)setVolume:(float)left right:(float)right;

- (int)switchVideoPath:(NSString *)path header:(NSDictionary* )httpHeaders;

- (void)startRecordGif:(NSString *)path;
- (void)stopRecordGif;
- (BOOL)startCutJPG:(NSString *)path;
- (void)stopCutJPG;

// The original size about the movie
@property (readonly) CGSize originalSize;

// Get the thumbnail image
- (UIImage*)getThumbnailImageAtPosition:(float)position;

//
@property (NS_NONATOMIC_IOSONLY, getter=getCurrentVideoFrameImage, readonly, strong) UIImage* currentVideoFrameImage;
// While there are multi audios and subtitles in current mov
// Get audio tracks in movie file
@property (NS_NONATOMIC_IOSONLY, getter=getAudioTracks, readonly, copy) NSArray* audioTracks;
@property (nonatomic, readonly) int curAudioIndex;
@property (nonatomic, readonly, getter=isPlayable) BOOL playable;

@end

#pragma mark - U3Player(Cache)
@interface U3Player (Cache)
+ (UInt64)cacheSizeOfUrl:(NSString *)url;
+ (UInt64)cachesSize;
+ (int)pruneCache;
@end

#pragma mark - U3Player(Options)
U3PlayerExport
@interface U3Player (Options)

/*
 * for metadata, request key like ro.metadata.video_codec_name
 * other scopes : global, instance
 * since v2.8.5
 * return 0 on success, other value if failed.
 */
- (NSString*)valueForOptionKey:(NSString*)aKey;

/*
 * set a option with key.
 * return 0 if ok.
 * since v2.8.5
 * changed from - (int)setSettingValue:(NSString*)aValue forKey:(NSString*)aKey;
 */
- (int)setOptionValue:(NSString*)aValue forKey:(NSString*)aKey;

/*
 * get options
 * since v2.8.5
 * TODO: currently return empty dict.
 * changed from - (NSString*)allSettingValues;
 */
- (NSDictionary *)allOptions;

/* set all options.
 * return 0 if ok.
 * since v2.8.5
 * changed from - (int)setSettingValues:(NSString*)values;
 * param: a dict with key/value pairs. keys as follow:
 * "rw.global.enable_cache": "yes" or "no"
 * "rw.global.ap_seek_buf": ms
 * "rw.global.ap_first_buf": ms
 * "rw.global.ap_max_buf": ms
 * "rw.global.raw_queue_bytes": M for audio, video=audio*2
 * return 0 on success, other value if failed.
 */
- (int)setOptions:(NSDictionary*)options;

/*
 * get global options
 * since v2.8.5
 * currently return empty dict because there are no global options
 */
+ (NSDictionary *)allGlobalOptions;

/*
 * set global options
 * return 0 if ok.
 * since v2.8.5
 * param: rw.global.xxx/ro.global.xxx or rw.metadata.xxx
 * return 0 on success, other value if failed.
 */
+ (int)setGlobalOptions:(NSDictionary *)options;

/*
 * get a global option
 * since v2.8.5
 */
+ (NSString*)valueForGlobalOptionKey:(NSString*)aKey;

/*
 * set a option with key.
 * return 0 if ok.
 * since v2.8.5
 * changed from - (int)setSettingValue:(NSString*)aValue forKey:(NSString*)aKey;
 * return 0 on success, other value if failed.
 */
+ (int)setGlobalOptionValue:(NSString*)aValue forKey:(NSString*)aKey;


@end

#pragma mark - U3Player(Statistics)
U3PlayerExport
@interface U3Player (Statistics)

- (void)requestStatisticWithCompletion:(void (^)(NSDictionary* stat))completion;

@end

#ifdef U3PLAYER_LIBRARY
#pragma GCC visibility pop
#endif


