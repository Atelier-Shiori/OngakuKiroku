//
//  GeneralPreferenceController.h
//  OngakuKiroku
//
//  Created by 千代田桃 on 2/5/21.
//  Copyright © 2021 Moy IT Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>
#import <MASPreferences/MASPreferences.h>

NS_ASSUME_NONNULL_BEGIN

@interface GeneralPreferenceController : NSViewController <MASPreferencesViewController>
@property (strong) IBOutlet NSButton * startatlogin;
@property (strong) IBOutlet NSTextField *apikey;
@property (strong) IBOutlet NSButton *saveButton;
@property (strong) IBOutlet NSButton *clearButton;
@property (strong) IBOutlet NSTextField *lapikey;
@property (strong) IBOutlet NSButton *lsaveButton;
@property (strong) IBOutlet NSButton *lclearButton;
@end

NS_ASSUME_NONNULL_END
