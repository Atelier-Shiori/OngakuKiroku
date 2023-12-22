//
//  GeneralPreferenceController.m
//  OngakuKiroku
//
//  Created by 千代田桃 on 2/5/21.
//  Copyright © 2021 Moy IT Solutions. All rights reserved.
//

#import "GeneralPreferenceController.h"
#import "NSBundle+LoginItem.h"
#import "AppDelegate.h"
#import <SAMKeychain/SAMKeychain.h>

@interface GeneralPreferenceController ()

@end

@implementation GeneralPreferenceController
- (instancetype)init
{
    return [super initWithNibName:@"GeneralPreferenceView" bundle:nil];
}

- (NSString *)viewIdentifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}

- (IBAction)toggleLaunchAtStartup:(id)sender {
    [self toggleLaunchAtStartup];
}
- (void)toggleLaunchAtStartup {
    if ([NSBundle.mainBundle isLoginItem]) {
        [NSBundle.mainBundle removeFromLoginItems];
    }
    else{
        [NSBundle.mainBundle addToLoginItems];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _startatlogin.state = [NSBundle.mainBundle isLoginItem];
    [self setAccountButtonState];
}

- (IBAction)setObserver:(id)sender {
    [(AppDelegate *)NSApplication.sharedApplication.delegate setObserver];
}

- (void)setAccountButtonState {
    bool accountsexist = [self hasAPIKey];
    _saveButton.enabled = !accountsexist;
    _apikey.enabled = !accountsexist;
    _clearButton.enabled = accountsexist;
    if (accountsexist) {
        _apikey.stringValue = [SAMKeychain passwordForService:[NSString stringWithFormat:@"%@", NSBundle.mainBundle.infoDictionary[@"CFBundleName"]] account:@"defaultAccount"];
    }
    else {
        _apikey.stringValue = @"";
    }
    bool laccountsexist = [self haslAPIKey];
    _lsaveButton.enabled = !laccountsexist;
    _lapikey.enabled = !laccountsexist;
    _lclearButton.enabled = laccountsexist;
    if (laccountsexist) {
        _lapikey.stringValue = [SAMKeychain passwordForService:[NSString stringWithFormat:@"%@ - ListenBrainz", NSBundle.mainBundle.infoDictionary[@"CFBundleName"]] account:@"defaultAccount"];
    }
    else {
        _lapikey.stringValue = @"";
    }
}

- (bool)hasAPIKey {
    NSArray *accounts = [SAMKeychain accountsForService:[NSString stringWithFormat:@"%@", NSBundle.mainBundle.infoDictionary[@"CFBundleName"]]];
    return accounts.count > 0;
}

- (bool)haslAPIKey {
    NSArray *accounts = [SAMKeychain accountsForService:[NSString stringWithFormat:@"%@ - ListenBrainz", NSBundle.mainBundle.infoDictionary[@"CFBundleName"]]];
    return accounts.count > 0;
}


- (void)saveAccountToKeychain:(NSString *)apiKey {
    if (_apikey.stringValue.length == 0) {
        [self showsheetmessage:@"Invalid API Key" explaination:@"Please specify a valid API key and try again" window:self.view.window];
        return;
    }
    [SAMKeychain setPassword:apiKey forService:[NSString stringWithFormat:@"%@", NSBundle.mainBundle.infoDictionary[@"CFBundleName"]] account:@"defaultAccount"];
    [self setAccountButtonState];
}
- (void)removeAccountFromKeychain {
    [SAMKeychain deletePasswordForService:[NSString stringWithFormat:@"%@", NSBundle.mainBundle.infoDictionary[@"CFBundleName"]] account:@"defaultAccount"];
    [self setAccountButtonState];
}

- (IBAction)saveAccount:(id)sender {
    [self saveAccountToKeychain:_apikey.stringValue];
}

- (IBAction)clearAccount:(id)sender {
    [self removeAccountFromKeychain];
}

- (void)savelAccountToKeychain:(NSString *)apiKey {
    if (_lapikey.stringValue.length == 0) {
        [self showsheetmessage:@"Invalid API Key" explaination:@"Please specify a valid API key and try again" window:self.view.window];
        return;
    }
    [SAMKeychain setPassword:apiKey forService:[NSString stringWithFormat:@"%@ - ListenBrainz", NSBundle.mainBundle.infoDictionary[@"CFBundleName"]] account:@"defaultAccount"];
    [self setAccountButtonState];
}
- (void)removelAccountFromKeychain {
    [SAMKeychain deletePasswordForService:[NSString stringWithFormat:@"%@ - ListenBrainz", NSBundle.mainBundle.infoDictionary[@"CFBundleName"]] account:@"defaultAccount"];
    [self setAccountButtonState];
}

- (IBAction)savelAccount:(id)sender {
    [self savelAccountToKeychain:_lapikey.stringValue];
}

- (IBAction)clearlAccount:(id)sender {
    [self removeAccountFromKeychain];
}

- (void)showsheetmessage:(NSString *)message
           explaination:(NSString *)explaination
                 window:(NSWindow *)w {
    // Set Up Prompt Message Window
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:NSLocalizedString(@"OK",nil)];
    alert.messageText = message;
    alert.informativeText = explaination;
    // Set Message type to Warning
    alert.alertStyle = 1;
    // Show as Sheet on Preference Window
    [alert beginSheetModalForWindow:w
                      modalDelegate:self
                     didEndSelector:nil
                        contextInfo:NULL];
}
@end
