//
//  MusicTrack.h
//  OngakuKiroku
//
//  Created by 千代田桃 on 2/6/21.
//  Copyright © 2021 Moy IT Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicTrack : NSObject
@property (strong) NSString *title;
@property (strong) NSString *artist;
@property (strong) NSString *album;
@property float duration;
@property float currentposition;
@property bool scrobbled;
@property bool ignored;
- (instancetype)initWithTitle:(NSString *)title withAlbum:(NSString *)album withArtist:(NSString *)artist withDuration:(float)duration withPos:(float)position;
@end

NS_ASSUME_NONNULL_END
