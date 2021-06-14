# SelectorForward 本Demo主要讲述iOS中Runtime的消息转发、重定向功能
具体可参考博文https://blog.csdn.net/MinggeQingchun/article/details/117793379 

消息的转发分为三步：

1、第一次转发：方法解析 Method resolution
对象在收到无法解读的消息，也就是找不到的方法之后，就会调用如下两个方法：

+ (BOOL)resolveClassMethod:(SEL)sel; //类方法
+ (BOOL)resolveInstanceMethod:(SEL)sel;//实例方法

2、第二次转发：快速转发
（后面第二阶段、第三阶段都针对对象来处理，不考虑类方法）
如果第一次转发方法的实现没有被找到，那么会调用如下方法：

- (id)forwardingTargetForSelector:(SEL)aSelector

3、第三次转发：常规转发 Normal forwarding
如果第二次转发也没有找到可以处理方法的对象的话，那么会调用如下方法：

- (void)forwardInvocation:(NSInvocation *)anInvocation;
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;
- (void)doesNotRecognizeSelector:(SEL)aSelector;

当Man类 收到一条code的消息的时候，发现前两步都没办法处理掉，走到第三步：

这时Man类的
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector方法就会被调用，这个方法会返回一个code的方法签名，

如果返回了code的方法签名的话，Man类的
- (void)forwardInvocation:(NSInvocation *)anInvocation方法会被调用，在这个方法里处理我们调用的code方法，

如果这个方法里也处理不了的话，就会执行
doesNotRecognizeSelector方法，引起一个unrecognized selector sent to instance异常崩溃。
