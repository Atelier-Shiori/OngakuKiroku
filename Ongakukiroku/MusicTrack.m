//
//  MusicTrack.m
//  OngakuKiroku
//
//  Created by 千代田桃 on 2/6/21.
//  Copyright © 2021 Moy IT Solutions. All rights reserved.
//

#import "MusicTrack.h"

@implementation MusicTrack
- (instancetype)init {
    self = [super init];
    return self;
}
- (instancetype)initWithTitle:(NSString *)title withAlbum:(NSString *)album withArtist:(NSString *)artist withDuration:(float)duration withPos:(float)position {
    self = [super init];
    if (self) {
        _title = title;
        _album = album;
        _artist = artist;
        _duration = duration;
        _currentposition = position;
    }
    return self;
}
@end
