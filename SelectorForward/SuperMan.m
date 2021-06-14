//
//  SuperMan.m
//  SelectorForward
//
//  Created by zhangming on 2021/6/11.
//

#import "SuperMan.h"
#import <objc/runtime.h> //包含对类、成员变量、属性、方法的操作

//C语言函数
void eat(id self,SEL sel){
    NSLog(@"第一次转发：方法解析----类方法：eat");
}

@implementation SuperMan

+ (BOOL)resolveClassMethod:(SEL)sel {
    /**
     class: 给哪个类添加方法
     SEL: 添加哪个方法
     IMP: 方法实现 => 函数 => 函数入口 => 函数名
     type: 方法类型：void用v来表示，id参数用@来表示，SEL用:来表示
     */

//    Method exchangeM = class_getInstanceMethod([self class], @selector(eatWithPersonName:));
//    class_addMethod([self class], sel, class_getMethodImplementation(self, @selector(eatWithPersonName:)),method_getTypeEncoding(exchangeM));

    if (sel == NSSelectorFromString(@"eat")) {
        //C语言函数写法：(IMP)eat
        class_addMethod(self, @selector(eat), (IMP)eat, "v@:");
        return YES;
    } else if (sel == NSSelectorFromString(@"writeCode")) {
        NSLog(@"我在写代码");
        return YES;
    }
    return [super resolveClassMethod:sel];
}

@end
