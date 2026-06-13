#import <Foundation/Foundation.h>

extern "C" {
    void fake_antiban_signature() {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"com.ff.original" forKey:@"game_signature"];
        [defaults synchronize];
    }
}