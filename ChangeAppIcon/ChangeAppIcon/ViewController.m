//
//  ViewController.m
//  ChangeAppIcon
//
//  Created by huangjian on 2018/8/23.
//  Copyright © 2018年 huangjian. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
@interface ViewController ()
@property (nonatomic,assign)BOOL isDd;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self runtimeDeleteAlert];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.isDd=!self.isDd;
    if (self.isDd) {
        [self changeAppIconWithName:@"Icon1"];
    }else
    {
        [self changeAppIconWithName:@"Icon2"];
    }
}

- (void)changeAppIconWithName:(NSString *)iconName {
    if (![[UIApplication sharedApplication] supportsAlternateIcons]) {
        return;
    }
    if ([iconName isEqualToString:@""]) {
        iconName = nil;
    }
    [[UIApplication sharedApplication] setAlternateIconName:iconName completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"更换app图标发生错误了 ： %@",error);
        }
    }];
}
-(void)runtimeDeleteAlert
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method presentM = class_getInstanceMethod(self.class, @selector(presentViewController:animated:completion:));
        Method presentSwizzlingM = class_getInstanceMethod(self.class, @selector(hj_presentViewController:animated:completion:));
        // 交换方法实现
        method_exchangeImplementations(presentM, presentSwizzlingM);
    });
}
- (void)hj_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if ([viewControllerToPresent isKindOfClass:[UIAlertController class]]) {
        NSLog(@"title : %@",((UIAlertController *)viewControllerToPresent).title);
        NSLog(@"message : %@",((UIAlertController *)viewControllerToPresent).message);
        // 换图标时的提示框的title和message都是nil，由此可特殊处理
        UIAlertController *alertController = (UIAlertController *)viewControllerToPresent;
        if (alertController.title == nil && alertController.message == nil) { // 是换图标的提示
            //可以自己做逻辑
            NSLog(@"干掉弹窗");
            return;
        } else {// 其他提示还是正常处理
            [self hj_presentViewController:viewControllerToPresent animated:flag completion:completion];
            return;
        }
    }
    
    [self hj_presentViewController:viewControllerToPresent animated:flag completion:completion];
}
@end
