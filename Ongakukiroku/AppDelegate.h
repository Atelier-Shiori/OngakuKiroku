//
//  AppDelegate.h
//  SwinsianDiscord
//
//  Created by 小鳥遊六花 on 6/12/18.
//  Copyright © 2018 Moy IT Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong) IBOutlet NSMenuItem * nowPlayingMenuItem;
@property (strong) IBOutlet NSMenuItem * nowPlayingSepItem;
@property (strong) IBOutlet NSMenuItem * artistMenuItem;
@property (strong) IBOutlet NSMenuItem * titleMenuItem;
- (void)setObserver;
@end

