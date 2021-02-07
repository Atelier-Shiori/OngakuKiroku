//
//  AppDelegate.m
//  SwinsianDiscord
//
//  Created by 小鳥遊六花 on 6/12/18.
//  Copyright © 2018 Moy IT Solutions. All rights reserved.
//

#import "AppDelegate.h"
#import "PFAboutWindowController.h"
#import "PFMoveApplication.h"
#import <AFNetworking/AFNetworking.h>
#import "SharedHTTPManager.h"
#import <MSWeakTimer_macOS/MSWeakTimer.h>
#import <SAMKeychain/SAMKeychain.h>
#import <MASPreferences/MASPreferences.h>
#import "GeneralPreferenceController.h"
#import "SoftwareUpdatesPref.h"
#import "MusicTrack.h"

@interface AppDelegate ()
@property (strong, nonatomic) dispatch_queue_t privateQueue;
@property (strong) NSWindowController *_preferencesWindowController;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (strong) NSStatusItem *statusItem;
@property (strong) NSImage *statusImage;
@property (strong) PFAboutWindowController *aboutWindowController;
@property (strong) AFHTTPSessionManager *manager;
@property (strong) MSWeakTimer *timer;
@property (strong) MusicTrack *queuedtrack;
@property bool timeractive;
@end

@implementation AppDelegate

@synthesize _preferencesWindowController;
+ (void)initialize
{
    //Create a Dictionary
    NSMutableDictionary * defaultValues = [NSMutableDictionary dictionary];
    
    // Defaults
    //defaultValues[@"player"] = @"Music";
    defaultValues[@"serverurl"] = @"https://localhost/";
    defaultValues[@"selectedplayer"] = @(0);
    //Register Dictionary
    [[NSUserDefaults standardUserDefaults]
     registerDefaults:defaultValues];
}

- (void) awakeFromNib {
    _manager = [SharedHTTPManager httpmanager];
    
    _privateQueue = dispatch_queue_create("moe.malupdaterosx.ongakukiroku", DISPATCH_QUEUE_CONCURRENT);
    
    
    //Create the NSStatusBar and set its length
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    //Allocates and loads the images into the application which will be used for our NSStatusItem
    _statusImage = [NSImage imageNamed:@"menubaricon"];
    
    //Yosemite Dark Menu Support
    [_statusImage setTemplate:YES];
    
    //Sets the images in our NSStatusItem
    _statusItem.image = _statusImage;
    
    //Tells the NSStatusItem what menu to load
    _statusItem.menu = _statusMenu;
    
    //Sets the tooptip for our item
    [_statusItem setToolTip:NSLocalizedString(@"OngakuKiroku",nil)];
    
    //Enables highlighting
    [_statusItem setHighlightMode:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    PFMoveToApplicationsFolderIfNecessary();
    [self setObserver];
}

- (NSWindowController *)preferencesWindowController {
    if (!_preferencesWindowController)
    {
        NSViewController *generalViewController = [[GeneralPreferenceController alloc] init];
        NSViewController *suViewController = [[SoftwareUpdatesPref alloc] init];
        NSArray *controllers;
        controllers = @[generalViewController,suViewController];
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers];
    }
    return _preferencesWindowController;
}

- (IBAction)showPreferences:(id)sender
{
    //Since LSUIElement is set to 1 to hide the dock icon, it causes unattended behavior of having the program windows not show to the front.
    [NSApp activateIgnoringOtherApps:YES];
    [self.preferencesWindowController showWindow:nil];
}

- (void)setObserver {
    // Set Notification center
    NSDistributedNotificationCenter *center =
    [NSDistributedNotificationCenter defaultCenter];
    [center removeObserver:self];
    switch ([NSUserDefaults.standardUserDefaults integerForKey:@"selectedplayer"]) {
        case 0: {
            if (@available(macOS 10.5, *)) {
                NSLog(@"Setting Observer for Music");
                [center addObserver:self
                       selector:@selector(playerInfoChanged:)
                           name:@"com.apple.Music.playerInfo"
                         object:nil];
                [self getMusicPlayerDuration];
            }
            else {
                NSLog(@"Setting Observer for iTunes");
                [center addObserver:self
                selector:@selector(playerInfoChanged:)
                    name:@"com.apple.iTunes.playerInfo"
                  object:nil];
                [self getiTunesPlayerDuration];
            }
            break;
        }
        case 1: {
            NSLog(@"Setting Observer for Swinsian");
            [center addObserver: self
                       selector: @selector(trackPlaying:)
                           name: @"com.swinsian.Swinsian-Track-Playing"
                         object: nil];
            [center addObserver: self
                       selector: @selector(trackPaused:)
                           name: @"com.swinsian.Swinsian-Track-Paused"
                         object: nil];
            [center addObserver: self
                       selector: @selector(trackStopped:)
                           name: @"com.swinsian.Swinsian-Track-Stopped"
                         object: nil];
            break;
        }
        default:
            break;
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)showabout:(id)sender {
    // Properly show the about window in a menu item application
    [NSApp activateIgnoringOtherApps:YES];
    if (!_aboutWindowController) {
        _aboutWindowController = [PFAboutWindowController new];
    }
    (self.aboutWindowController).appURL = [[NSURL alloc] initWithString:@"https://malupdaterosx.moe/ongakukiroku/"];
    NSMutableString *copyrightstr = [NSMutableString new];
    NSDictionary *bundleDict = [NSBundle mainBundle].infoDictionary;
    [copyrightstr appendFormat:@"%@",bundleDict[@"NSHumanReadableCopyright"]];
    (self.aboutWindowController).appCopyright = [[NSAttributedString alloc] initWithString:copyrightstr
                                                                                attributes:@{
                                                                                             NSForegroundColorAttributeName:[NSColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f],
                                                                                             NSFontAttributeName:[NSFont fontWithName:[NSFont systemFontOfSize:12.0f].familyName size:11]}];
    
    [self.aboutWindowController showWindow:nil];
}

- (void)trackPlaying:(NSNotification *)myNotification {
    NSDictionary *userInfo = myNotification.userInfo;
    NSNumber *currentTime = userInfo[@"currentTime"];
    NSNumber *length = userInfo[@"length"];
    NSLog(@"Swinsian - %@ - %@ - %f",userInfo[@"title"], userInfo[@"artist"] , length.floatValue - currentTime.floatValue);
    if (![self checkedScrobbled:userInfo[@"title"] artist:userInfo[@"artist"] album:userInfo[@"album"]] && length.floatValue > 30) {
        [self queuescrobble:[[MusicTrack alloc] initWithTitle:userInfo[@"title"] withAlbum:userInfo[@"album"] withArtist:userInfo[@"artist"] withDuration:length.floatValue withPos:currentTime.floatValue]];
    }
}
- (void)trackPaused:(NSNotification *)myNotification {
    [self stoptimer];
}
- (void)trackStopped:(NSNotification *)myNotification {
    [self stoptimer];
    [self hideNowPlaying];
}

- (void)playerInfoChanged:(NSNotification *)theNotification
{
    NSDictionary *info = [theNotification userInfo];
    
    if ([(NSString *)info[@"Player State"] isEqualToString:@"Stopped"]) {
        [self stoptimer];
        return;
    }
    
    if ([(NSString *)info[@"Player State"] isEqualToString:@"Playing"]) {
        if (@available(macOS 10.5, *)) {
            float pos = [self getMusicPlayerPosition];
            float duration = [self getMusicPlayerDuration];
            NSLog(@"Apple Music - %@ - %@ - %f",info[@"Name"], info[@"Artist"] , duration-pos);
            if (![self checkedScrobbled:info[@"Name"] artist:info[@"Artist"] album:info[@"Album"]] && duration >= 30) {
                [self queuescrobble:[[MusicTrack alloc] initWithTitle:info[@"Name"] withAlbum:info[@"Album"] withArtist:info[@"Artist"] withDuration:duration withPos:pos]];
            }
        }
        else {
            float duration = [self getiTunesPlayerDuration];
            NSLog(@"iTunes - %@ - %@ - %f",info[@"Name"], info[@"Artist"] , [self convertElaspedTimeToInterval:info[@"elapsedStr"]]);
            if (![self checkedScrobbled:info[@"Name"] artist:info[@"Artist"] album:info[@"Album"]] && duration >= 30) {
                [self queuescrobble:[[MusicTrack alloc] initWithTitle:info[@"Name"] withAlbum:info[@"Album"] withArtist:info[@"Artist"] withDuration:duration withPos:[self convertElaspedTimeToInterval:info[@"elapsedStr"]]]];
            }
        }
    }
    
    if ([(NSString *)info[@"Player State"] isEqualToString:@"Paused"]) {
        [self stoptimer];
    }
}

- (float)getMusicPlayerPosition {
    return [self executeAppleScriot:@"tell application \"Music\" to get player position"].floatValue;
}

- (float)getMusicPlayerDuration {
    return [self executeAppleScriot:@"tell application \"Music\" to get duration of current track"].floatValue;
}

- (float)getiTunesPlayerDuration {
    return [self executeAppleScriot:@"tell application \"iTunes\" to get duration of current track"].floatValue;
}

- (NSString *)executeAppleScriot:(NSString *)command {
    @try {
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/usr/bin/osascript";
        task.arguments = @[@"-e", command];
        NSPipe *pipe;
        pipe = [NSPipe pipe];
        task.standardOutput = pipe;
        
        NSFileHandle *file;
        file = pipe.fileHandleForReading;
        [task setEnvironment:@{@"LC_ALL" : @"en_US.UTF-8"}];
        [task launch];
        
        NSData *data;
        data = [file readDataToEndOfFile];
        
        NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        if (string.length > 0) {
            return string;
        }
    }
    @catch (NSException *ex) {
        return @"";
    }
    return @"";
}

- (float)convertElaspedTimeToInterval:(NSString *)elapsed {
    NSString *tmpstr = [elapsed stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSArray *intervals = [tmpstr componentsSeparatedByString:@":"];
    if (intervals.count == 3) {
        int hours = ((NSString *)intervals[0]).intValue;
        int minutes = ((NSString *)intervals[1]).intValue;
        int seconds = ((NSString *)intervals[2]).intValue;
        return ((hours*60*60)+(minutes*60)+seconds);
    }
    else {
        int minutes = ((NSString *)intervals[0]).intValue;
        int seconds = ((NSString *)intervals[1]).intValue;
        return ((minutes*60)+seconds);
    }
    return 0;
}

- (void)queuescrobble:(MusicTrack *)data {
    if (![self hasAPIKey]) {
        NSLog(@"Not queuing Scrobble, missing API Key");
        return;
    }
    if ([_queuedtrack.title isEqualToString:data.title] && [_queuedtrack.album isEqualToString:data.album] && [_queuedtrack.artist isEqualToString:data.artist]) {
        _queuedtrack.currentposition = data.currentposition;
    }
    else {
        _queuedtrack = data;
    }
    float elapsedtime = _queuedtrack.duration-_queuedtrack.currentposition;
    NSLog(@"Queuing title %@ - %@ - %f", _queuedtrack.title, _queuedtrack.artist, elapsedtime);
    _timer =  [MSWeakTimer scheduledTimerWithTimeInterval:elapsedtime-5
                                                   target:self
                                                 selector:@selector(fireTimer)
                                                 userInfo:nil
                                                  repeats:NO
                                            dispatchQueue:_privateQueue];
    _timeractive = YES;
    [self setNowPlaying:_queuedtrack.title artist:_queuedtrack.artist];
}

- (void)fireTimer {
    _timeractive = NO;
    // toggle
    [self scrobble:_queuedtrack.title artist:_queuedtrack.artist length:_queuedtrack.duration];
}

- (void)stoptimer {
    if (_timeractive) {
        [_timer invalidate];
        _timeractive = NO;
        NSLog(@"Stopping queued scrobble, Player paused/stopped");
    }
}

- (void)scrobble:(NSString *)title artist:(NSString *)artist length:(int)length {
    [_manager POST:[NSString stringWithFormat:@"%@/apis/mlj_1/newscrobble", [NSUserDefaults.standardUserDefaults valueForKey:@"serverurl"]] parameters:@{@"title" : title, @"artist" : artist, @"key" : [SAMKeychain passwordForService:[NSString stringWithFormat:@"%@", NSBundle.mainBundle.infoDictionary[@"CFBundleName"]] account:@"defaultAccount"], @"seconds" : @(length) } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Scrobble Successful: %@ - %@", title, artist);
        _queuedtrack.scrobbled = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Scrobble Unsuccessful: %@", error.localizedDescription);
    }];
}

- (bool)checkedScrobbled:(NSString *)title artist:(NSString *)artist album:(NSString *)album {
    if (_queuedtrack.scrobbled && _queuedtrack) {
        if ([title isEqualToString:_queuedtrack.title] && [artist isEqualToString:_queuedtrack.artist] && [album isEqualToString:_queuedtrack.album]) {
            return YES;
        }
    }
    return NO;
}

- (IBAction)viewScrobbleLog:(id)sender {
    [Log openLogFile];
}

- (void)setNowPlaying:(NSString *)title artist:(NSString *)artist {
    _nowPlayingSepItem.hidden = NO;
    _nowPlayingMenuItem.hidden = NO;
    _titleMenuItem.hidden = NO;
    _artistMenuItem.hidden = NO;
    _titleMenuItem.title = title;
    _artistMenuItem.title = artist;
}

- (void)hideNowPlaying {
    _nowPlayingSepItem.hidden = YES;
    _nowPlayingMenuItem.hidden = YES;
    _titleMenuItem.hidden = YES;
    _artistMenuItem.hidden = YES;
}

- (bool)hasAPIKey {
    NSArray *accounts = [SAMKeychain accountsForService:[NSString stringWithFormat:@"%@", NSBundle.mainBundle.infoDictionary[@"CFBundleName"]]];
    return accounts.count > 0;
}
@end
