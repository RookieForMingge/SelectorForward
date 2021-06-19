//
//  MainViewController.m
//  SelectorForward
//
//  Created by zhangming on 2021/6/10.
//

#import "MainViewController.h"
#import "Man.h"
#import "SuperMan.h"
#import "Son.h"

#import <objc/runtime.h> //包含对类、成员变量、属性、方法的操作
//#import <objc/message.h> 包含消息机制

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    //第一次转发：方法解析 Method resolution
//    [self FirsForward];
//
//    //第二次转发：快速转发 Fast forwarding
//    [self SecondForward];
//
//    //第三次转发：常规转发 Normal forwarding
//    [self ThirdForward];
    
    //unrecognized selector sent to instance 防护crash
    [self testUnrecognizedSelectorCrash];
}

#pragma mark - 第一次转发：方法解析 Method resolution
- (void)FirsForward {
    Man *man = [[Man alloc]init];
    //找不到实例方法
    [man performSelector:@selector(drinkPear)];

    //找不到类方法
    [Man performSelector:@selector(smoke)];
    
    //找不到类方法
    SuperMan *superMan = [[SuperMan alloc] init];
    SEL select = NSSelectorFromString(@"eat");
    [SuperMan resolveClassMethod:select];
    [superMan performSelector:@selector(eat)];
}

/*- (void)findDrinkPearMethod {
    NSLog(@"实例方法：Man drinkPear");
}

//Man类实例方法(在MainViewController拦截就导致不会再走第二次，第三次转发)
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if ([super resolveInstanceMethod:sel]) {
        return YES;
    }else {
        //IMP imp参数 OC写法：class_getMethodImplementation
        class_addMethod([Man class],@selector(drinkPear),class_getMethodImplementation([MainViewController class], @selector(findDrinkPearMethod)),"v@:");
        return YES;
    }
    
//    if (sel == @selector(drinkPear)) {
//        //IMP imp参数 OC写法：class_getMethodImplementation
//        class_addMethod([Man class],sel,class_getMethodImplementation([MainViewController class], @selector(findDrinkPearMethod)),"v@:");
//        return YES;
//    }
//    return [super resolveInstanceMethod:sel];
}*/

#pragma mark - 第二次转发：快速转发 Fast forwarding
- (void)SecondForward {
    Man *man = [[Man alloc]init];
    [man performSelector:@selector(study)];
}

#pragma mark - 第三次转发：常规转发 Normal forwarding
- (void)ThirdForward {
    Man *man = [[Man alloc]init];
    [man performSelector:@selector(code)];
    //三次转发都找不到的方法
    [man performSelector:@selector(missMethod)];
}

#pragma mark - unrecognized selector sent to instance 防护crash
- (void)testUnrecognizedSelectorCrash {
    Son *son = [Son new];
    [son performSelector:@selector(missMethod)];
}

@end
