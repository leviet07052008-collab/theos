#import <substrate.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

@interface FrogHackLoop : NSObject
- (void)tick;
@end

@implementation FrogHackLoop
- (void)tick {
    // ESP render
    static UIView *overlay = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        overlay = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlay.backgroundColor = [UIColor clearColor];
        overlay.userInteractionEnabled = NO;
        [[UIApplication sharedApplication].keyWindow addSubview:overlay];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [overlay.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        Class gmClass = objc_getClass("FFGameManager");
        if (!gmClass) return;
        id gm = [gmClass performSelector:@selector(sharedInstance)];
        if (!gm) return;
        NSArray *players = [gm performSelector:@selector(allPlayers)];
        if (!players) return;
        for (id p in players) {
            if (![[p valueForKey:@"isEnemy"] boolValue]) continue;
            float hp = [[p valueForKey:@"health"] floatValue];
            if (hp <= 0) continue;
            float x = [[p valueForKey:@"screenX"] floatValue];
            float y = [[p valueForKey:@"screenY"] floatValue];
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(x-25, y-12, 50, 20)];
            lbl.text = [NSString stringWithFormat:@"HP:%.0f", hp];
            lbl.textColor = [UIColor redColor];
            lbl.font = [UIFont boldSystemFontOfSize:10];
            lbl.textAlignment = NSTextAlignmentCenter;
            [overlay addSubview:lbl];
        }
    });
}
@end

%ctor {
    @autoreleasepool {
        // Anti ptrace
        int (*real_ptrace)(int, pid_t, caddr_t, int) = dlsym(RTLD_DEFAULT, "ptrace");
        MSHookFunction(real_ptrace, (void*)^int(int r, pid_t p, caddr_t a, int d){
            if(r == 31) return 0;
            return real_ptrace(r,p,a,d);
        }, NULL);

        // Anti sysctl
        int (*real_sysctl)(int*,u_int,void*,size_t*,void*,size_t) = dlsym(RTLD_DEFAULT, "sysctl");
        MSHookFunction(real_sysctl, (void*)^int(int *n,u_int l,void *o,size_t *ol,void *p,size_t pl){
            if(n[0]==1 && n[1]==14 && n[2]==1) return 1;
            return real_sysctl(n,l,o,ol,p,pl);
        }, NULL);

        // Anti file check
        MSHookMessageEx([NSFileManager class], @selector(fileExistsAtPath:), imp_implementationWithBlock(^BOOL(id s, NSString *path){
            if([path containsString:@"Cydia"] || [path containsString:@"substrate"]) return NO;
            return NO;
        }), NULL);

        // Anti crash report
        Class cr = objc_getClass("FFCrashReporter");
        if(cr) MSHookMessageEx(cr, @selector(sendReport), imp_implementationWithBlock(^(id s){}), NULL);

        // Game loop
        FrogHackLoop *loop = [[FrogHackLoop alloc] init];
        [CADisplayLink displayLinkWithTarget:loop selector:@selector(tick)];
    }
}