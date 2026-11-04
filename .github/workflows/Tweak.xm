#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>
#include <mach-o/dyld.h>
#include <random>
#include <chrono>
#include <thread>
#include <cmath>

bool isAutoPlayEnabled = false;
bool isLinesEnabled = false;

struct Vector3 { float x, y, z; };
typedef void(*Shoot_t)(void* __this, Vector3 direction, float force);
Shoot_t orig_Shoot = nullptr;
std::mt19937 rng(std::random_device{}());

void hooked_Shoot(void* __this, Vector3 direction, float force) {
    if (!isAutoPlayEnabled) {
        if (orig_Shoot) orig_Shoot(__this, direction, force);
        return;
    }
    std::uniform_int_distribution<int> delay_dist(2500, 5000);
    std::this_thread::sleep_for(std::chrono::milliseconds(delay_dist(rng)));
    if (force > 0.82f) force = 0.82f;
    std::uniform_real_distribution<float> jitter(-0.01f, 0.01f);
    direction.x += jitter(rng);
    direction.y += jitter(rng);
    if (orig_Shoot) orig_Shoot(__this, direction, force);
}

@interface CheatMenu : NSObject
+ (void)toggleAutoPlay:(UIButton *)sender;
+ (void)toggleLines:(UIButton *)sender;
@end

@implementation CheatMenu
+ (void)toggleAutoPlay:(UIButton *)sender {
    isAutoPlayEnabled = !isAutoPlayEnabled;
    [sender setTitle:(isAutoPlayEnabled ? @"Auto: ON" : @"Auto: OFF") forState:UIControlStateNormal];
    [sender setBackgroundColor:(isAutoPlayEnabled ? [UIColor greenColor] : [UIColor redColor])];
}
+ (void)toggleLines:(UIButton *)sender {
    isLinesEnabled = !isLinesEnabled;
    [sender setTitle:(isLinesEnabled ? @"Lines: ON" : @"Lines: OFF") forState:UIControlStateNormal];
    [sender setBackgroundColor:(isLinesEnabled ? [UIColor greenColor] : [UIColor redColor])];
}
@end

__attribute__((constructor))
static void init() {
    void* target = (void*)(_dyld_get_image_vmaddr_slide(0) + 0x123456); 
    MSHookFunction(target, (void*)hooked_Shoot, (void**)&orig_Shoot);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        
        UIButton *btnAuto = [UIButton buttonWithType:UIButtonTypeSystem];
        btnAuto.frame = CGRectMake(20, 100, 100, 40);
        [btnAuto setTitle:@"Auto: OFF" forState:UIControlStateNormal];
        [btnAuto setBackgroundColor:[UIColor redColor]];
        [btnAuto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnAuto.layer.cornerRadius = 8;
        [btnAuto addTarget:[CheatMenu class] action:@selector(toggleAutoPlay:) forControlEvents:UIControlEventTouchUpInside];
        [window addSubview:btnAuto];

        UIButton *btnLines = [UIButton buttonWithType:UIButtonTypeSystem];
        btnLines.frame = CGRectMake(20, 150, 100, 40);
        [btnLines setTitle:@"Lines: OFF" forState:UIControlStateNormal];
        [btnLines setBackgroundColor:[UIColor redColor]];
        [btnLines setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnLines.layer.cornerRadius = 8;
        [btnLines addTarget:[CheatMenu class] action:@selector(toggleLines:) forControlEvents:UIControlEventTouchUpInside];
        [window addSubview:btnLines];
    });
}
