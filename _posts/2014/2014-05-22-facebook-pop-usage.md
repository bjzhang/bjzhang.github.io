---
layout: post
title: Facebook Pop 使用指南
categories:
- Programming
tags:
- facebook
- pop
---

当听闻Facebook要开源自己的Animation框架的时候，我还以为是基于Core Animation进行的封装，包含了一些动画效果库。等源码真正出来后，才发现完全想错了，Facebook Pop其实是基于CADisplayLink(Mac平台上使用的CVDisplayLink)实现的独立于Core Animation之外的动画方案。这里就不细说其实现原理了，主要讲讲Facebook Pop如何使用。

## 一.基本概念
在计算机的世界里面，其实并不存在绝对连续的动画，你所看到的屏幕上的动画本质上都是离散的，只是在一秒的时间里面离散的帧多到一定的数量人眼就觉得是连续的了，在iOS中，最大的帧率是60帧每秒。
iOS提供了Core Animation框架，只需要开发者提供关键帧信息，比如提供某个animatable属性终点的关键帧信息，然后中间的值则通过一定的算法进行插值计算，从而实现补间动画。 Core Aniamtion中进行插值计算所依赖的时间曲线由CAMediaTimingFunction提供。
Pop Animation在使用上和Core Animation很相似，都涉及Animation对象以及Animation的载体的概念，不同的是Core Animation的载体只能是CALayer，而Pop Animation可以是任意基于NSObject的对象。当然大多数情况Animation都是界面上显示的可视的效果，所以动画执行的载体一般都直接或者间接是UIView或者CALayer。但是如果你只是想研究Pop Animation的变化曲线，你也完全可以将其应用于一个普通的数据对象，比如下面这个对象:

    @interface AnimatableModel : NSObject
    @property (nonatomic,assign) CGFloat animatableValue;
    @end

    #import "AnimatableModel.h"
    @implementation AnimatableModel
    - (void)setAnimatableValue:(CGFloat)animatableValue{
      _animatableValue = animatableValue;
      NSLog(@"%f",animatableValue);
    }

    @end

此对象只有一个CGFloat类型的属性，非常简单，这里在AnimatableModel对象上运行几种Pop Animation进行测试，以便统计animatableValue的变化曲线。

由于此对象的属性不在Pop Property的标准属性中，所以需要创建一个POPAnimatableProperty，

      POPAnimatableProperty *animatableProperty = [POPAnimatableProperty propertyWithName:@"com.geeklu.animatableValue" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            [obj setAnimatableValue:values[0]];
        };
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [obj animatableValue];
        };
    }];

统计的数据来自上面属性变化时的Log数据，制图的时候将时间中除了秒之外的时间部分删除了，所有数据都来自真实测试的数据，并使用Number进行了曲线的绘制。图中的每个点代表一个离散的节点，为了方便观看，使用直线将这些离散的点连接起来了。
<img src="http://ww4.sinaimg.cn/mw1024/65cc0af7gw1ego7boez1uj20oc0icju4.jpg" style="width: 50%; height: 50%"/>​

### PopBasicAniamtion With EaseOut TimingFunction

    POPBasicAnimation *animation = [POPBasicAnimation animation];
    animation.property = animatableProperty;
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:100];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.duration = 1.5;

    _animatableModel = [[AnimatableModel alloc] init];
    [_animatableModel pop_addAnimation:animation forKey:@"easeOut"];

<img src="http://ww1.sinaimg.cn/mw1024/65cc0af7gw1egnh3razkxj20sy0kadh2.jpg" style="width: 50%; height: 50%"/>​

从上图可以看到，动画开始的时候变化速率较快，到结束的时候就很慢了，这就是所谓的Ease Out效果。

### PopSpringAniamtion

    POPSpringAnimation *animation = [POPSpringAnimation animation];
    animation.property = animatableProperty;
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:100];
    animation.dynamicsMass = 5;

    _animatableModel = [[AnimatableModel alloc] init];
    [_animatableModel pop_addAnimation:animation forKey:@"spring"];

<img src="http://ww4.sinaimg.cn/mw1024/65cc0af7gw1egnh8m1lhtj20oi0gg0u4.jpg" style="width: 50%; height: 50%"/>​

一开始快速向终点方向靠近，然后会在终点附近来回摆动，摆动幅度逐渐变弱，最后在终点停止。

通过上面的两个属性值变化的曲线你可以很好的理解动画的类型和属性的变化曲线之前的关联了。
## 二.属性动画的使用
这里就讲讲Pop Aniamtion自带的几种动画的使用。 PopAnimation自带的动画都是基于POPPropertyAnimation的，POPPropertyAnimation有个很重要的部分就是 POPAnimatableProperty，用来描述animatable的属性。上一节中就看到了如何来创建一个POPAnimatableProperty对象，在初始化的时候，需要在初始化的block中设置writeBlock和readBlock

    void (^readBlock)(id obj, CGFloat values[])
    void (^writeBlock)(id obj, const CGFloat values[])

这两个block都是留给动画引擎来使用的，前者用于向目标属性写值,使用者需要做的就是从values中提取数据设置给obj；后者用于读取，也就是从objc中读取放到values中。values[] 最多支持4个数据，也就是说Pop Aniamtion属性数值的维度最大支持4维。
为了使用便捷，Pop Animation框架提供了很多现成的POPAnimatableProperty预定义，你只需要使用预定义的propertyWithName来初始化POPAnimatableProperty便可，比如以下一些预定义的propertyWithName：

    kPOPLayerBackgroundColor
    ...
    kPOPViewAlpha
    ...

这样预定义的POPAnimatableProperty已经帮你设置好writeBlock和readBlock。
下面的一些基于POPPropertyAnimation的动画都提供了快捷的方法，直接传入propertyWithName便创建好了特定property的动画了。
下面列举的各个实例都可以在这里找到：[https://github.com/kejinlu/facebook-pop-sample](https://github.com/kejinlu/facebook-pop-sample)。

### 1.POPBasicAnimation
基本动画，接口方面和CABasicAniamtion很相似，使用可以提供初始值fromValue，这个 终点值toValue，动画时长duration以及决定动画节奏的timingFunction。timingFunction直接使用的CAMediaTimingFunction,是使用一个横向纵向都为一个单位的拥有两个控制点的贝赛尔曲线来描述的，横坐标为时间，纵坐标为动画进度。
<img src="http://ww2.sinaimg.cn/mw1024/65cc0af7gw1egpvtrn8qmj209307qdhf.jpg" style="width: 50%; height: 50%"/>​
这里举一个View移动的例子：

    NSInteger height = CGRectGetHeight(self.view.bounds);
    NSInteger width = CGRectGetWidth(self.view.bounds);

    CGFloat centerX = arc4random() % width;
    CGFloat centerY = arc4random() % height;

    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(centerX, centerY)];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration = 0.4;
    [self.testView pop_addAnimation:anim forKey:@"centerAnimation"];

这里self.view上放了一个用于动画的testView，然后取一个随机坐标，进行动画。

### 2.PopSpringAnimation



### 3.PopDecayAnimation
基于Bezier曲线的timingFuntion是无法表述Decay Aniamtion的，所以Pop就单独实现了一个 PopDecayAnimation，用于衰减动画。



## 四.交互式动画
