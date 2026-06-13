#import <UIKit/UIKit.h>
#import <substrate.h>

static UIWindow *menuWindow;
static BOOL espEnabled = NO;
static BOOL aimlockEnabled = NO;
static BOOL noRecoilEnabled = NO;
static BOOL wallhackEnabled = NO;

// ==================== MENU UI ====================
static void toggleESP() { espEnabled = !espEnabled; }
static void toggleAimlock() { aimlockEnabled = !aimlockEnabled; }
static void toggleNoRecoil() { noRecoilEnabled = !noRecoilEnabled; }
static void toggleWallhack() { wallhackEnabled = !wallhackEnabled; }
static void hideMenu() { menuWindow.hidden = YES; }

static void buttonTapped(UIButton *sender) {
    switch(sender.tag) {
        case 0: toggleESP(); break;
        case 1: toggleAimlock(); break;
        case 2: toggleNoRecoil(); break;
        case 3: toggleWallhack(); break;
        case 4: hideMenu(); break;
    }
    if(sender.tag < 4) {
        BOOL isOn = (sender.tag==0 && espEnabled) ||
                    (sender.tag==1 && aimlockEnabled) ||
                    (sender.tag==2 && noRecoilEnabled) ||
                    (sender.tag==3 && wallhackEnabled);
        NSString *title = [sender.titleLabel.text componentsSeparatedByString:@" ("][0];
        [sender setTitle:[title stringByAppendingFormat:@" (%@)", isOn ? @"ON" : @"OFF"] forState:UIControlStateNormal];
        sender.backgroundColor = isOn ? [UIColor greenColor] : [UIColor darkGrayColor];
    }
}

static void showMenu() {
    menuWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, 230)];
    menuWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.85];
    menuWindow.windowLevel = UIWindowLevelAlert + 2;
    menuWindow.layer.cornerRadius = 12;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, menuWindow.frame.size.width, 30)];
    title.text = @"FF Menu v1.0";
    title.textColor = [UIColor redColor];
    title.textAlignment = NSTextAlignmentCenter;
    [menuWindow addSubview:title];
    
    NSArray *names = @[@"ESP", @"Aimlock", @"No Recoil", @"Wallhack"];
    for (int i = 0; i < 4; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20 + (i%2)*150, 50 + (i/2)*55, 130, 40);
        [btn setTitle:[names[i] stringByAppendingString:@" (OFF)"] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor darkGrayColor];
        btn.layer.cornerRadius = 8;
        btn.tag = i;
        [btn addTarget:nil action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [menuWindow addSubview:btn];
    }
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(20, 170, 280, 40);
    [closeBtn setTitle:@"Ẩn Menu" forState:UIControlStateNormal];
    closeBtn.backgroundColor = [UIColor redColor];
    closeBtn.tag = 4;
    [closeBtn addTarget:nil action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [menuWindow addSubview:closeBtn];
    
    menuWindow.hidden = NO;
}

// ==================== ANTIBAN NÂNG CAO ====================

// Chặn toàn bộ báo cáo vi phạm
%hook GGAntiCheatManager
- (BOOL)isGameTampered { return NO; }
- (BOOL)isMemoryModified { return NO; }
- (void)reportViolation:(id)violation { }
- (void)sendCheatData:(id)data { }
%end

%hook GGAntiMod
- (BOOL)checkInjectedDylibs { return NO; }
- (BOOL)verifyCodeSignature { return YES; }
- (BOOL)isDebuggerAttached { return NO; }
%end

%hook FFMemoryScanner
- (void)startScan { }
- (id)getScanResult { return nil; }
- (void)scanForModules { }
- (id)getLoadedLibraries {
    NSArray *libs = %orig;
    NSMutableArray *filtered = [NSMutableArray array];
    for(NSString *lib in libs) {
        if(![lib containsString:@"FFMenu"] && ![lib containsString:@"dylib"]) {
            [filtered addObject:lib];
        }
    }
    return filtered;
}
%end

%hook FFNetworkManager
- (void)sendData:(id)data {
    NSString *str = [data description];
    if([str containsString:@"cheat"] || [str containsString:@"violation"] || 
       [str containsString:@"mod"] || [str containsString:@"hack"] || 
       [str containsString:@"inject"]) {
        return;
    }
    %orig;
}
- (void)sendReport:(id)report {
    return;
}
%end

%hook FFDeviceInfo
- (id)getDeviceID { return @"original_fake_id"; }
- (id)getPhoneNumber { return nil; }
- (BOOL)isJailbroken { return NO; }
- (id)getBundleID { return @"com.dts.freefireth"; }
%end

%hook FFSignatureValidator
- (BOOL)validateSignature { return YES; }
- (BOOL)checkBundleIdentifier { return YES; }
%end

%hook MSCheck
- (BOOL)isSubstratePresent { return NO; }
%end

// ==================== CHEAT ====================
%hook PlayerWeapon
- (float)recoilMultiplier {
    return noRecoilEnabled ? 0.0 : %orig;
}
- (float)getSpread {
    return noRecoilEnabled ? 0.0 : %orig;
}
%end

%hook EnemyPawn
- (BOOL)isVisibleToPlayer {
    return espEnabled ? YES : %orig;
}
- (CGPoint)getHeadPosition {
    if(aimlockEnabled) {
        CGPoint head = %orig;
        head.x += 1.0; // aimlock giả lập
        return head;
    }
    return %orig;
}
- (id)getBonePosition:(int)bone {
    if(aimlockEnabled && bone == 0) {
        return %orig;
    }
    return %orig;
}
%end

%hook WallActor
- (BOOL)isOccluding {
    return wallhackEnabled ? NO : %orig;
}
- (BOOL)canBlockBullet {
    return wallhackEnabled ? NO : %orig;
}
%end

// ==================== KHỞI TẠO ====================
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showMenu();
    });
}