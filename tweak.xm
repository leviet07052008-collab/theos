#import <substrate.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

static BOOL aimbotOn = YES;
static BOOL wallhackOn = YES;
static BOOL espOn = YES;
static BOOL antibanOn = YES;

// Chống phát hiện jailbreak
static void patchDetection() {
    void *ptrace_ptr = dlsym(RTLD_DEFAULT, "ptrace");
    MSHookFunction(ptrace_ptr, (void*)^int(int req, pid_t pid, caddr_t addr, int data) {
        return req == 31 ? 0 : ((int(*)(int,pid_t,caddr_t,int))ptrace_ptr)(req,pid,addr,data);
    }, NULL);
    
    int (*orig_sysctl)(int*,u_int,void*,size_t*,void*,size_t) = dlsym(RTLD_DEFAULT,"sysctl");
    MSHookFunction(orig_sysctl, (void*)^int(int *n,u_int l,void *o,size_t *ol,void *p,size_t pl) {
        if(n[0]==1 && n[1]==14 && n[2]==1) return 1;
        return orig_sysctl(n,l,o,ol,p,pl);
    }, NULL);
    
    Method m = class_getInstanceMethod([NSFileManager class], @selector(fileExistsAtPath:));
    MSHookMessageEx([NSFileManager class], @selector(fileExistsAtPath:), imp_implementationWithBlock(^BOOL(id s, NSString *p){
        if([p containsString:@"Cydia"]||[p containsString:@"substrate"]) return NO;
        return ((BOOL(*)(id,SEL,NSString*))method_getImplementation(m))(s,@selector(fileExistsAtPath:),p);
    }), NULL);
}

// Aimbot
static void runAimbot() {
    if(!aimbotOn) return;
    id gm = [objc_getClass("FFGameManager") sharedInstance];
    NSArray *pl = [gm allPlayers];
    CGPoint lp = [gm getLocalScreenPos];
    float best = 35.0;
    id target = nil;
    for(id p in pl) {
        if(![p isEnemy] || [p health]<=0 || ![p isVisible]) continue;
        CGPoint sp = [p screenPos];
        float d = hypotf(sp.x-lp.x, sp.y-lp.y);
        if(d < best) { best = d; target = p; }
    }
    if(target) {
        float ang = atan2f([target screenPos].y-lp.y, [target screenPos].x-lp.x);
        [gm setAimPitch:sinf(ang)*0.5 yaw:cosf(ang)*0.5];
    }
}

// Wallhack
static void doWallhack() {
    if(!wallhackOn) return;
    void *glDepth = dlsym(RTLD_DEFAULT,"glDepthMask");
    MSHookFunction(glDepth, (void*)^(GLboolean f){ ((void(*)(GLboolean))glDepth)(GL_FALSE); }, NULL);
}

// ESP Overlay
static UIView *overlay;
static void makeESP() {
    if(!espOn) return;
    overlay = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    overlay.backgroundColor = [UIColor clearColor];
    overlay.userInteractionEnabled = NO;
    [[UIApplication sharedApplication].keyWindow addSubview:overlay];
}
static void drawESP() {
    if(!espOn||!overlay) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [overlay.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        id gm = [objc_getClass("FFGameManager") sharedInstance];
        for(id p in [gm allPlayers]) {
            if(![p isEnemy]||[p health]<=0) continue;
            UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake([p screenPos].x-25,[p screenPos].y-12,50,24)];
            lb.text = [NSString stringWithFormat:@"HP:%.0f",[p health]];
            lb.textColor = [UIColor redColor];
            lb.font = [UIFont boldSystemFontOfSize:10];
            lb.textAlignment = NSTextAlignmentCenter;
            [overlay addSubview:lb];
        }
    });
}

// Anti-Ban
static void doAntiBan() {
    if(!antibanOn) return;
    Class cr = objc_getClass("FFCrashReporter");
    if(cr) {
        MSHookMessageEx(cr, @selector(sendReport), imp_implementationWithBlock(^(id s){}), NULL);
    }
    Class nc = objc_getClass("FFNetworkChecker");
    if(nc) {
        MSHookMessageEx(nc, @selector(checkIntegrity), imp_implementationWithBlock(^(id s){ return YES; }), NULL);
    }
}

%ctor {
    patchDetection();
    doWallhack();
    doAntiBan();
    makeESP();
    CADisplayLink *dl = [CADisplayLink displayLinkWithTarget:[NSObject new] selector:@selector(tick)];
    [dl addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

@interface NSObject(FrogHack)
-(void)tick;
@end
@implementation NSObject(FrogHack)
-(void)tick { runAimbot(); drawESP(); }
@end