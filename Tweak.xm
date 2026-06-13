#import <UIKit/UIKit.h>
#import <substrate.h>

static UIWindow *menuWindow;
static BOOL espEnabled = NO, aimlockEnabled = NO, noRecoilEnabled = NO, wallhackEnabled = NO;

static void showMenu() {
    menuWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 80, [UIScreen mainScreen].bounds.size.width, 220)];
    menuWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
    menuWindow.windowLevel = UIWindowLevelAlert + 2;
    
    NSArray *titles = @[@"ESP", @"Aimlock", @"No Recoil", @"Wallhack"];
    for (int i = 0; i < 4; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20 + (i%2)*150, 30 + (i/2)*60, 130, 45);
        [btn setTitle:[titles[i] stringByAppendingString:@" (Tắt)"] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor darkGrayColor];
        btn.layer.cornerRadius = 8;
        btn.tag = i + 1;
        [btn addTarget:self action:@selector(toggleCheat:) forControlEvents:UIControlEventTouchUpInside];
        [menuWindow addSubview:btn];
    }
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(20, 160, 280, 40);
    [closeBtn setTitle:@"Ẩn Menu" forState:UIControlStateNormal];
    closeBtn.backgroundColor = [UIColor redColor];
    [closeBtn addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    [menuWindow addSubview:closeBtn];
    
    menuWindow.hidden = NO;
}

static void toggleCheat(UIButton *sender) {
    switch(sender.tag) {
        case 1: espEnabled = !espEnabled; break;
        case 2: aimlockEnabled = !aimlockEnabled; break;
        case 3: noRecoilEnabled = !noRecoilEnabled; break;
        case 4: wallhackEnabled = !wallhackEnabled; break;
    }
    NSString *newTitle = [sender.titleLabel.text componentsSeparatedByString:@" ("][0];
    newTitle = [newTitle stringByAppendingString: (espEnabled||aimlockEnabled||noRecoilEnabled||wallhackEnabled) ? @" (Bật)" : @" (Tắt)"];
    [sender setTitle:newTitle forState:UIControlStateNormal];
    sender.backgroundColor = (espEnabled||aimlockEnabled||noRecoilEnabled||wallhackEnabled) ? [UIColor greenColor] : [UIColor darkGrayColor];
}

static void closeMenu() { menuWindow.hidden = YES; }

// Hook antiban
%hook GGAntiCheatManager
- (BOOL)isGameTampered { return NO; }
- (BOOL)isMemoryModified { return NO; }
- (void)sendViolationReport:(id)report { }
%end

%hook GGAntiMod
- (BOOL)checkInjectedDylibs { return NO; }
- (BOOL)isDebuggerAttached { return NO; }
%end

// Hook cheat
%hook PlayerWeapon
- (float)getRecoilMultiplier { return noRecoilEnabled ? 0 : %orig; }
%end

%hook EnemyPawn
- (BOOL)isVisible { return espEnabled ? YES : %orig; }
%end

%ctor {
    dispatch_async(dispatch_get_main_queue(), ^{ showMenu(); });
    NSLog(@"[FFMenu] Loaded");
}