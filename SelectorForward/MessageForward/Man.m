//
//  Man.m
//  SelectorForward
//
//  Created by zhangming on 2021/6/10.
//

#import "Man.h"
#import "Son.h"
#import "CodeMan.h"

#import <objc/runtime.h> //包含对类、成员变量、属性、方法的操作
//#import "NSObject+MessageForwarding.h"

@implementation Man

- (instancetype)init {
    self = [super init];
    if (self) {
//        [self performSelector:@selector(sel) withObject:nil];
    }

    return self;
}

#pragma mark - 第一次转发：方法解析  Method resolution
//实例方法IMP方法名
id dynamicInstanceMethodIMP(id self, SEL _cmd) {
    NSLog(@"第一次转发：方法解析----%s:实例方法",__FUNCTION__);
    return @"1";
}

//类方法IMP方法名
id dynamicClassMethodIMP(id self, SEL _cmd) {
    NSLog(@"第一次转发：方法解析----%s:类方法",__FUNCTION__);
    return @"2";
}

/*  class_addMethod方法
 class_addMethod(Class _Nullable cls, SEL _Nonnull name, IMP _Nonnull imp,
                 const char * _Nullable types)
 Class cls：添加新方法的那个类名(实例方法，传入CLass；类方法，传入MetaClss；可以这样理解，OC里的Class里的加号方法，相当于该类的MetalClas的实例方法，类调用类方法，和对象调用实例方法，其实底层实现都是一样的。类也是对象。)
 SEL name：要添加的方法名
 IMP imp：实现这个方法的函数
 const char *types：要添加的方法的返回值和参数；如："v@:@"：v：是添加方法无返回值     @表示是id(也就是要添加的类) ：表示添加的方法类型   @表示：参数类型
 */

/**实例方法
 对象：在接受到无法解读的消息的时候 首先会调用所属类的类方法

 @param sel 传递进入的方法
 @return 如果YES则能接受消息 NO不能接受消息 进入第二步
 */
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(drinkPear)) {
        //实例方法，传入CLass
        //对类进行对象方法 需要把方法添加进入类内
        class_addMethod([self class], sel, (IMP)(dynamicInstanceMethodIMP), "@@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

/**类方法
 类：如果是类方法的调用，首先会触发该类方法
 
 @param sel 传递进入的方法
 @return 如果YES则能接受消息 NO不能接受消息 进入第二步
 */
+ (BOOL)resolveClassMethod:(SEL)sel {
    if (sel == @selector(smoke)) {
        //对类进行添加类方法 需要将方法添加进入元类内；将[self class]或self.class替换为object_getClass/objc_getMetaClass
        //C语言函数写法：(IMP)(dynamicClassMethodIMP)；类方法，Class cls传MetaClass
        class_addMethod(object_getClass(self)/*[self getMetaClassWithChildClass:self]*/,sel,(IMP)(dynamicClassMethodIMP), "@@:");
        //OC语言写法：class_getMethodImplementation([self class], @selector(findSmokeMethod))
//        class_addMethod(object_getClass(self),@selector(smoke),class_getMethodImplementation([self class], @selector(findSmokeMethod)),"@@:");
        
        //检测元类
        [self isMetaClass];
        
        return YES;
    }
    return [super resolveClassMethod:sel];
}

/**
 判断是否是元类
 */
+ (void)isMetaClass {
    /**class_isMetaClass 方法
     通过 class_isMetaClass 方法可以验证判断是否是元类
     */
    Class c1 = object_getClass(self);
    Class c2 = [self getMetaClassWithChildClass:self];
    BOOL object_getClass = class_isMetaClass(c1);
    BOOL objc_getMetaClass = class_isMetaClass(c2);
    NSLog(@"object_getClass是否是元类：%@",object_getClass?@"YES":@"NO");
    NSLog(@"objc_getMetaClass是否是元类：%@",objc_getMetaClass?@"YES":@"NO");
}

/**
 获取类的元类

 @param childClass 目标类别
 @return 返回元类
 */
+ (Class)getMetaClassWithChildClass:(Class)childClass{
    //转换字符串类别
    const  char * classChar = [NSStringFromClass(childClass) UTF8String];
    //需要char的字符串 获取元类
    return objc_getMetaClass(classChar);
}

#pragma mark - 第二次转发：快速转发 Fast forwarding
- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSLog(@"第二次转发：快速转发----forwardingTargetForSelector:  %@", NSStringFromSelector(aSelector));
    Son *son = [[Son alloc] init];
    if ([son respondsToSelector: aSelector]) {
        return son;
    }
    return [super forwardingTargetForSelector: aSelector];
}

#pragma mark - 第三次转发：常规转发 Normal forwarding
//返回SEL方法的签名，返回的签名是根据方法的参数来封装的
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSLog(@"第三次转发：常规转发----method signature for selector: %@", NSStringFromSelector(aSelector));
    if (aSelector == @selector(code)) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    return [super methodSignatureForSelector:aSelector];
}

//拿到方法签名，并且处理（创建备用对象响应传递进来等待响应的SEL）
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"forwardInvocation: %@", NSStringFromSelector([anInvocation selector]));
    
    if ([anInvocation selector] == @selector(code)) {
        //创建备用对象
        CodeMan *codeMan = [[CodeMan alloc] init];
        //备用对象响应传递进来等待响应的SEL
        [anInvocation invokeWithTarget:codeMan];
    }else {        
        [super forwardInvocation:anInvocation];
        
//        //如果处理不了的话，调用doesNotRecognizeSelector方法返回崩溃
//        SEL sel = anInvocation.selector;
//        [self doesNotRecognizeSelector:sel];
    }
}

// 如果备用对象不能响应 则抛出异常
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    NSLog(@"doesNotRecognizeSelector: %@", NSStringFromSelector(aSelector));
    [super doesNotRecognizeSelector:aSelector];
}

- (void)showMessage:(NSString*)message{
    NSLog(@"message = %@",message);
}

@end
