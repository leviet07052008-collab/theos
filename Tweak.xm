#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

static BOOL headshotEnabled = YES;
static BOOL noRecoilEnabled = YES;
static BOOL noSpreadEnabled = YES;
static BOOL aimbotEnabled = YES;
static BOOL speedHackEnabled = NO;
static BOOL magicBulletEnabled = NO;

static UIView *menuView = nil;
static UIWindow *overlayWindow = nil;

// Menu chính
@interface FFMenuView : UIView
@property (nonatomic, strong) UIButton *toggleBtn;
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, assign) BOOL isOpen;
@end

@implementation FFMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isOpen = NO;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    // Nút toggle
    self.toggleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toggleBtn.frame = CGRectMake(10, 60, 55, 55);
    self.toggleBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
    self.toggleBtn.layer.cornerRadius = 27.5;
    self.toggleBtn.layer.borderWidth = 1;
    self.toggleBtn.layer.borderColor = [UIColor yellowColor].CGColor;
    [self.toggleBtn setTitle:@"⚡" forState:UIControlStateNormal];
    [self.toggleBtn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    self.toggleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    [self.toggleBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.toggleBtn];
    
    // Panel menu
    self.panel = [[UIView alloc] initWithFrame:CGRectMake(10, 125, 200, 320)];
    self.panel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9]];
    self.panel.layer.cornerRadius = 15;
    self.panel.layer.borderWidth = 1;
    self.panel.layer.borderColor = [UIColor grayColor].CGColor;
    self.panel.hidden = YES;
    [self addSubview:self.panel];
    
    // Title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 200, 30)];
    title.text = @"FFMenu v1.123.1.8";
    title.textColor = [UIColor yellowColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:16];
    [self.panel addSubview:title];
    
    // Các nút chức năng
    NSArray *titles = @[
        [NSString stringWithFormat:@"%@ Headshot", headshotEnabled ? @"✅" : @"❌"],
        [NSString stringWithFormat:@"%@ No Recoil", noRecoilEnabled ? @"✅" : @"❌"],
        [NSString stringWithFormat:@"%@ No Spread", noSpreadEnabled ? @"✅" : @"❌"],
        [NSString stringWithFormat:@"%@ Aimbot", aimbotEnabled ? @"✅" : @"❌"],
        [NSString stringWithFormat:@"%@ Speed Hack", speedHackEnabled ? @"✅" : @"❌"],
        [NSString stringWithFormat:@"%@ Magic Bullet", magicBulletEnabled ? @"✅" : @"❌"]
    ];
    
    NSArray *selectors = @[@"toggleHeadshot", @"toggleNoRecoil", @"toggleNoSpread", @"toggleAimbot", @"toggleSpeedHack", @"toggleMagicBullet"];
    
    for (int i = 0; i < titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(10, 50 + i * 42, 180, 36);
        btn.backgroundColor = [UIColor darkGrayColor];
        btn.layer.cornerRadius = 8;
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.tag = i;
        [btn addTarget:self action:NSSelectorFromString(selectors[i]) forControlEvents:UIControlEventTouchUpInside];
        [self.panel addSubview:btn];
    }
}

- (void)toggleMenu {
    self.isOpen = !self.isOpen;
    self.panel.hidden = !self.isOpen;
}

- (void)updateButton:(int)index title:(NSString *)title {
    UIButton *btn = self.panel.subviews[index + 1];
    [btn setTitle:title forState:UIControlStateNormal];
}

- (void)toggleHeadshot {
    headshotEnabled = !headshotEnabled;
    [self updateButton:0 title:[NSString stringWithFormat:@"%@ Headshot", headshotEnabled ? @"✅" : @"❌"]];
}

- (void)toggleNoRecoil {
    noRecoilEnabled = !noRecoilEnabled;
    [self updateButton:1 title:[NSString stringWithFormat:@"%@ No Recoil", noRecoilEnabled ? @"✅" : @"❌"]];
}

- (void)toggleNoSpread {
    noSpreadEnabled = !noSpreadEnabled;
    [self updateButton:2 title:[NSString stringWithFormat:@"%@ No Spread", noSpreadEnabled ? @"✅" : @"❌"]];
}

- (void)toggleAimbot {
    aimbotEnabled = !aimbotEnabled;
    [self updateButton:3 title:[NSString stringWithFormat:@"%@ Aimbot", aimbotEnabled ? @"✅" : @"❌"]];
}

- (void)toggleSpeedHack {
    speedHackEnabled = !speedHackEnabled;
    [self updateButton:4 title:[NSString stringWithFormat:@"%@ Speed Hack", speedHackEnabled ? @"✅" : @"❌"]];
}

- (void)toggleMagicBullet {
    magicBulletEnabled = !magicBulletEnabled;
    [self updateButton:5 title:[NSString stringWithFormat:@"%@ Magic Bullet", magicBulletEnabled ? @"✅" : @"❌"]];
}

@end

// Hooks
%hook FIRBulletWeapon
- (float)getDamageMultiplier {
    if (headshotEnabled) return 999.0f;
    return %orig;
}
- (BOOL)isHeadshotOnly {
    return headshotEnabled ? YES : %orig;
}
%end

%hook FIRWeapon
- (float)getRecoilMultiplier {
    if (noRecoilEnabled) return 0.0f;
    return %orig;
}
- (float)getSpreadMultiplier {
    if (noSpreadEnabled) return 0.0f;
    return %orig;
}
%end

%hook FIRCharacter
- (float)getMovementSpeedMultiplier {
    if (speedHackEnabled) return 2.5f;
    return %orig;
}
%end

%hook FIRPlayerController
- (void)aimAtTarget:(id)target {
    if (aimbotEnabled && target) {
        // Aimbot logic
        %orig(target);
    } else {
        %orig(target);
    }
}
%end

%hook FIRBullet
- (void)updatePosition {
    if (magicBulletEnabled) {
        // Magic bullet: bỏ qua vật cản
        [self setHitPoint:CGPointMake(9999, 9999)];
    }
    %orig;
}
%end

%hook FIRAntiCheat
- (BOOL)detectCheat { return NO; }
- (void)banPlayer { return; }
- (BOOL)isBanned { return NO; }
- (void)reportData:(id)data { return; }
%end

%hook FIRNetworkManager
- (void)sendPacket:(id)packet {
    // Chặn gửi report cheat
    if ([packet isKindOfClass:NSClassFromString(@"FIRReportPacket")]) {
        return;
    }
    %orig;
}
%end

// Khởi tạo menu
%ctor {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *n) {
            overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            overlayWindow.windowLevel = UIWindowLevelAlert + 1;
            overlayWindow.backgroundColor = [UIColor clearColor];
            overlayWindow.userInteractionEnabled = YES;
            FFMenuView *menu = [[FFMenuView alloc] initWithFrame:overlayWindow.bounds];
            overlayWindow.rootViewController = [[UIViewController alloc] init];
            [overlayWindow.rootViewController.view addSubview:menu];
            overlayWindow.hidden = NO;
        }];
    });
}