---
layout: post
title: Custom Container View Controller
categories:
- Programming
tags:
- objc
- container
---
什么是Container View Controller?苹果文档是这么描述的:
 
    A container view controller contains content owned by other view controllers.

也就是说一个View Controller的view上的某部分内容属于另一个View Controller，那么这个View Controller就是一个Container，比如UINavigationController，UITabBarController。在iOS 5之前苹果是不允许出现自定义的Container的 ，也就是说你创建的一个View Controller的view不能包含另一个View Controller的view，这样对于逻辑复杂的界面来说不易于功能拆分，也许曾经你为了某个显示逻辑的公用，直接将另一个View Controller的view添加为当前View Controller的view的subview，然后发现可以显示，但实际上这种行为是非常危险的。      

iOS 5.0 开始支持Custom Container View Controller，开放了一系列的用于构建自定义Container的接口。如果你想创建一个自己的Container，那么有一些概念你必须得清楚。Container的主要职责就是管理着一个或多个Child View Controller的展示的生命周期，需要传递显示相关以及旋转相关的回调。其实显示或者旋转的回调的触发的源头来自于window,一个app首先有一个主window，初始化的时候需要给这个主window指定一个rootViewController，window会将显示相关的回调(viewWillAppear:, viewWillDisappear:, viewDidAppear:, or viewDidDisappear: )以及旋转相关的回调(willRotateToInterfaceOrientation:duration:
,willAnimateRotationToInterfaceOrientation:duration:,
didRotateFromInterfaceOrientation:)传递给rootViewController。rootViewController需要再将这些callbacks的调用传递给它的Child View Controllers。

### 一.父子关系范式
展示一个名为content的child view controller：

     [self addChildViewController:content];  //1
     content.view.frame = [self frameForContentController]; 
     [self.view addSubview:self.currentClientView]; //2
     [content didMoveToParentViewController:self]; //3

1.将content添加为child view controller，addChildViewController:接口建立了逻辑上的父子关系，子可以通过parentViewController，访问其父VC，addChildViewController:接口的逻辑中会自动调用 `[content willMoveToParentViewController:self];`  
2.建立父子关系后，便是将content的view加入到父VC的view hierarchy上，同时要决定的是 content的view显示的区域范围。   
3.调用child的 didMoveToParentViewController: ，以通知child，完成了父子关系的建立 



移除一个child view controller：
     
     [content willMoveToParentViewController:nil]; //1
     [content.view removeFromSuperview]; //2
     [content removeFromParentViewController]; //3
     

1.通知child，即将解除父子关系，从语义上也可以看出 child的parent即将为nil  
2.将child的view从父VC的view的hierarchy中移除   
3.通过removeFromParentViewController的调用真正的解除关系，removeFromParentViewController会自动调用 [content didMoveToParentViewController:nil]

### 二.appearance callbacks的传递
上面的实现中有一个问题，就是没看到那些appearance callbacks是如何传递的，答案就是appearance callbacks默认情况下是自动调用的，苹果框架底层帮你实现好了，也就是在上面的addSubview的时候，在subview真正加到父view之前，child的viewWillAppear将被调用，真正被add到父view之后，viewDidAppear会被调用。移除的过程中viewWillDisappear，viewDidDisappear的调用过程也是类似的。  
有时候自动的appearance callbacks的调用并不能满足需求，比如child view的展示有一个动画的过程，这个时候我们并不想viewDidAppear的调用在addSubview的时候进行，而是等展示动画结束后再调用viewDidAppear。也许你可能会提到 `transitionFromViewController:toViewController:duration:options:animations:completion:` 这个方法，会帮你自动处理view的add和remove，以及支持animations block，也能够保证在动画开始前调用willAppear或者willDisappear，在调用结束的时候调用didAppear，didDisappear，但是此方式也存在局限性，必须是两个新老子VC的切换，都不能为空，因为要保证新老VC拥有同一个parentViewController，且参数中的viewController不能是系统中的container，比如不能是UINavigationController或者UITabbarController等。    
所以如果你要自己写一个界面容器往往用不了appearence callbacks自动调用的特性，需要将此特性关闭，然后自己去精确控制appearance callbacks的调用时机。   
那如何关闭appearance callbacks的自动传递的特性呢？在iOS 5.x中你需要覆盖`automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers`,然后返回NO,iOS6+中你需要覆盖 `shouldAutomaticallyForwardAppearanceMethods`方法并返回NO.   
手动传递的时候你并不能直接去调用child 的viewWillAppear或者viewDidAppear这些方法，而是需要使用 `beginAppearanceTransition:animated:`和`endAppearanceTransition`接口来间接触发那些appearance callbacks，且begin和end必须成对出现。   
`[content beginAppearanceTransition:YES animated:animated]`触发content的viewWillAppear，`[content beginAppearanceTransition:NO animated:animated]`触发content的viewWillDisappear，和他们配套的[content endAppearanceTransition]分别触发viewDidAppear和viewDidDisappear。   

### 三.rotation callbacks的传递
也许在iPhone上很少要关心的屏幕旋转问题的，但是大屏幕的iPad上就不同了，很多时候你需要关心横竖屏。rotation callbacks 一般情况下只需要关心三个方法
`willRotateToInterfaceOrientation:duration:`在旋转开始前，此方法会被调用；`willAnimateRotationToInterfaceOrientation:duration:` 此方法的调用在旋转动画block的内部，也就是说在此方法中的代码会作为旋转animation block的一部分；`didRotateFromInterfaceOrientation:`此方法会在旋转结束时被调用。而作为view controller container 就要肩负起旋转的决策以及旋转的callbacks的传递的责任。  

当使用框架的自动传递的特性的时候，作为容器的view controller 会自动
将这些方法传递给所有的child viewcontrollers， 有时候你可能不需要传递给所有的child viewcontroller，而只需要传递给正在显示的child viewcontroller，那么你就需要禁掉旋转回调自动传递的特性，和禁掉appearance callbacks自动传递的方式类似，需要覆盖相关方法并返回NO，在iOS5.x中，appearance callbacks和rotation callbacks禁掉是公用一个方法的就是 `automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers`，在iOS6之后分成两个独立的方法，旋转的则是 `shouldAutomaticallyForwardRotationMethods`。   
旋转相关的除了上面的几个rotation callbacks方法外，还有一个十分重要的概念，就是一个view controller可以决定自己是否支持当前取向的旋转，这个东西在iOS6前后的实现方式还不一样，iOS6之前使用的方法是 `shouldAutorotateToInterfaceOrientation`，就是一个view controller覆盖此方法，根据传入的即将旋转的取向的参数，来决定是否旋转。而iOS6.0之后的实现则拆分成两个方法 `shouldAutorotate`和`supportedInterfaceOrientations`,前者决定再旋转的时候是否去根据`supportedInterfaceOrientations`所支持的取向来决定是否旋转，也就是说如果`shouldAutorotate`返回YES的时候，才会去调用`supportedInterfaceOrientations`检查当前view controller支持的取向，如果当前取向在支持的范围中，则进行旋转，如果不在则不旋转；而当`shouldAutorotate`返回NO的时候，则根本不会去管`supportedInterfaceOrientations`这个方法，反正是不会跟着设备旋转就是了。   
而作为界面容器你要注意的就是你需要去检查你的child view controller，检查他们对横竖屏的支持情况，以便容器自己决策在横竖屏旋转时候是否支持当前的取向，和上面的callbacks传递的方向相比，这其实是一个反向的传递。


### 四.创建自己的容器基类
当你需要构建自己的container view controller的时候，每一个container都会有一些相同的逻辑，如果你每一个都写一遍会存在很多重复代码，所以最好你创建一个container基类，去实现容器都需要的逻辑。

    #import "ContainerBaseController.h"

    @implementation ContainerBaseController

    #pragma mark -
    #pragma mark Overrides
    //NS_DEPRECATED_IOS(5_0,6_0)
    - (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers{
    return NO;
    }

    //NS_AVAILABLE_IOS(6_0)
    - (BOOL)shouldAutomaticallyForwardAppearanceMethods{
        return NO;
    }

    //NS_AVAILABLE_IOS(6_0)
    - (BOOL)shouldAutomaticallyForwardRotationMethods{
    return NO;
    }

    - (void)viewWillAppear:(BOOL)animated{
        [super viewWillAppear:animated];
    
        NSArray *viewControllers = [self childViewControllersWithAppearanceCallbackAutoForward];
        for (UIViewController *viewController in viewControllers) {
            [viewController beginAppearanceTransition:YES animated:animated];
        }
    }

    - (void)viewDidAppear:(BOOL)animated{
        [super viewDidAppear:animated];
    
        NSArray *viewControllers = [self childViewControllersWithAppearanceCallbackAutoForward];
        for (UIViewController *viewController in viewControllers) {
            [viewController endAppearanceTransition];
        }
    }

    - (void)viewWillDisappear:(BOOL)animated{
        [super viewWillDisappear:animated];
    
        NSArray *viewControllers = [self childViewControllersWithAppearanceCallbackAutoForward];
        for (UIViewController *viewController in viewControllers) {
            [viewController beginAppearanceTransition:NO animated:animated];
        }
    }

    - (void)viewDidDisappear:(BOOL)animated{
        [super viewDidDisappear:animated];
    
        NSArray *viewControllers = [self childViewControllersWithAppearanceCallbackAutoForward];
        for (UIViewController *viewController in viewControllers) {
            [viewController endAppearanceTransition];
        }
    }


    - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
        [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
        NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
        for (UIViewController *viewController in viewControllers) {
            [viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    }
    }

    - (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
        [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
        NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
        for (UIViewController *viewController in viewControllers) {
                [viewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
        }
    }

    - (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
        [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
        NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
        for (UIViewController *viewController in viewControllers) {
            [viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
        }
    }

    /*
     NS_AVAILABLE_IOS(6_0) 
     向下查看和旋转相关的ChildViewController的shouldAutorotate的值
     只有所有相关的子VC都支持Autorotate，才返回YES
     */
    - (BOOL)shouldAutorotate{
        NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
        BOOL shouldAutorotate = YES;
        for (UIViewController *viewController in viewControllers) {
            shouldAutorotate = shouldAutorotate &&  [viewController shouldAutorotate];
        }
    
        return shouldAutorotate;
    }

    /*
     NS_AVAILABLE_IOS(6_0) 
     此方法会在设备旋转且shouldAutorotate返回YES的时候才会被触发
     根据对应的所有支持的取向来决定是否需要旋转
     作为容器，支持的取向还决定于自己的相关子ViewControllers
     */
    - (NSUInteger)supportedInterfaceOrientations{
        NSUInteger supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    
        NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
        for (UIViewController *viewController in viewControllers) {
            supportedInterfaceOrientations = supportedInterfaceOrientations & [viewController supportedInterfaceOrientations];
        }
    
        return supportedInterfaceOrientations;
    }


    /*
     NS_DEPRECATED_IOS(2_0, 6_0) 6.0以下，设备旋转时，此方法会被调用
     用来决定是否要旋转
     */
    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
        BOOL shouldAutorotate = YES;
        NSArray *viewControllers = [self childViewControllersWithRotationCallbackAutoForward];
        for (UIViewController *viewController in viewControllers) {
        shouldAutorotate = shouldAutorotate &&  [viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
        }
        return shouldAutorotate;
    }

    #pragma mark -
    #pragma mark Should be overridden by subclass
    - (NSArray *)childViewControllersWithAppearanceCallbackAutoForward{
        return self.childViewControllers;
    }

    - (NSArray *)childViewControllersWithRotationCallbackAutoForward{
        return self.childViewControllers;
    }

    @end



### 五.创建自己的Container
...未完待续

  
