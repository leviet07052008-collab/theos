#import <substrate.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <dlfcn.h>

@interface FrogLoop : NSObject
- (void)tick;
@end

@implementation FrogLoop
- (void)tick {
    static UIView *overlay;
    if (!overlay) {
        overlay = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlay.backgroundColor = [UIColor clearColor];
        overlay.userInteractionEnabled = NO;
        [[UIApplication sharedApplication].keyWindow addSubview:overlay];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [overlay.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        Class c = objc_getClass("FFGameManager");
        if (!c) return;
        id gm = [c performSelector:@selector(sharedInstance)];
        if (!gm) return;
        NSArray *arr = [gm performSelector:@selector(allPlayers)];
        if (!arr) return;
        for (id p in arr) {
            if (![[p valueForKey:@"isEnemy"] boolValue]) continue;
            float hp = [[p valueForKey:@"health"] floatValue];
            if (hp <= 0) continue;
            float x = [[p valueForKey:@"screenX"] floatValue];
            float y = [[p valueForKey:@"screenY"] floatValue];
            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(x-25, y-12, 50, 20)];
            l.text = [NSString stringWithFormat:@"%.0f", hp];
            l.textColor = [UIColor redColor];
            l.font = [UIFont systemFontOfSize:10];
            l.textAlignment = NSTextAlignmentCenter;
            [overlay addSubview:l];
        }
    });
}
@end

%ctor {
    int (*pt)(int, pid_t, caddr_t, int) = dlsym(RTLD_DEFAULT, "ptrace");
    MSHookFunction(pt, (void*)^int(int r, pid_t p, caddr_t a, int d){ return r==31?0:pt(r,p,a,d); }, NULL);
    int (*sc)(int*,u_int,void*,size_t*,void*,size_t) = dlsym(RTLD_DEFAULT, "sysctl");
    MSHookFunction(sc, (void*)^int(int *n,u_int l,void *o,size_t *ol,void *p,size_t pl){ return (n[0]==1&&n[1]==14&&n[2]==1)?1:sc(n,l,o,ol,p,pl); }, NULL);
    FrogLoop *loop = [[FrogLoop alloc] init];
    [CADisplayLink displayLinkWithTarget:loop selector:@selector(tick)];
}