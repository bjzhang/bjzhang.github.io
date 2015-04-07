---
layout: post
title: Handoff Between iOS App & Website
categories:
- Programming
tags:
- iOS
- handoff
---

### 一.Handoff的基本常识

iOS 8以及Mac OS X Yosemite之后引入了一个新的功能特性：Handoff。Handoff也就是Continuity特性，连续互通，比如你用iPhone写邮件写到一半想在Mac上继续写，或者Mac上看到一个网页想在手机上浏览，这些便是Handoff的使用场景了。

Handoff的支持有一些硬性的要求：

- 互通的所有设备必须支持 Buletooth LE 4.0，Handoff使用BLE信号来传递用户活动数据。
- 设备处于联网状态，有时候有些数据还是会通过互联网来传递的，比如Mail App的邮件内容的同步。
- 所有设备必须连到同一个iCloud账户。
- 当然你还得保证当前设备的Handoff功能打开了(iOS:设置->通用->Handoff 与建议的应用程序。 Mac:系统偏好设置->通用,倒数第二栏有个选项,"允许这台Mac和iCloud设备之间使用Handoff")

BLE并不像传统的蓝牙，并不需要人工手动进行配对，只要打开就行了，所有的配对数据传输都是自动完成的；设备并不一定需要连在同一个WIFI网络中，Handoff的活动数据通过BLE进行传递，保证及时性以及数据的安全性，你可以在使用过程中尝试将WIFI或者网络关闭，设备还是可以接受到Handoff的通知的。

苹果已经对很多内置的App做了Handoff支持，如Safari浏览器，邮件，电话，消息，提醒事项等都是支持的，在你开始Handoff编程之前可以先使用这些App进行Handoff功能的体验。


### 二.iOS App 到 Web Browser

Handoff编程的核心类便是NSUserActivity了，代表着一个用户的活动，每一个Activity都有一个activityType，用来标识Activity的类型。当App 到 App之间进行Handoff的话，那么接受方需要满足几个条件

- App必须是通过发布证书或者开发者证书进行打包的
- 和发布Activity的App拥有相同的TeamID
- info.plist中声明了接受的Activity的activityType(key 为 NSUserActivityTypes)

不过很多应用其实也只是在移动设备上有App，在Mac上绝大多数还是走的浏览器，所以iOS App和浏览器的Handoff的需求就变的很常见了。这个时候Activity的另一个叫做webpageURL的属性便有用武之地了，当没有合适的App能够处理当前的Activity的话，系统会转给默认的浏览器进行处理（当然你的这个默认的浏览器的info.plist的NSUserActivityTypes数组中必须声明了 NSUserActivityTypeBrowsingWeb这个type，目前Mac版本的Chrome已经支持了）。

```
self.myActivity = [[NSUserActivity alloc] initWithActivityType: @"com.taobao.handoff.act.home"];
self.myActivity.webpageURL = [NSURL URLWithString:@"http://www.taobao.com"];
[self.myActivity becomeCurrent];
```

当上面的代码执行之后，Activity便会进行分发，接受者接受后，若没有App能够处理当前类型的Activity的话便转交给默认的浏览器去处理了，这里需要特别注意的就是activity的生命周期，当activity被invalidate或者被释放了，那么这个Handoff消息也就消失了，相关设备的Handoff消息就会消失。

关于Handoff的调试，由于到目前为止模拟器还是没有支持Handoff的，所以你必须使用开发者证书进行真机调试。

### 三.Web Browser 到 iOS App

相比于App到Web Browser，Web Browser到iOS App的Handoff实现起来就复杂一些了。
首先先描述下大体的流程：
 
1. 首先在Mac上使用Safari浏览器浏览目标网站，Handoff消息会通过BLE进行分发
2. iOS设备接收到Handoff消息后，检查对应的webpageURL，看是否有某个App的associated-domains （entitlement中的一项）中包含了这个webpageURL, associated-domains对应的Handoff的配置URL样式为 activitycontinuation:example.com
3. 如果某个App的associated-domains存在相应的webpageURL,那么iOS会去这个网站的固定的一个URL（地址为https://example.com/apple-app-site-association）获取一个签名过的文件（源文件为一个JSON文件）,如果解密后文件中的App IDs中包含了 之前匹配的App的App ID，那么这个Activity便交给这个匹配的App进行处理。

下面讲解详细的操作步骤

#### 1.客户端
首先当然还是折腾客户端工程，当你创建好工程，创建好App ID，XCode中设置好自己的Developer账户之后，你便可以设置编译的Code Sign的相关东西了，配置都得选自动的，这样就可以通过XCode来管理配置 App ID 以及相应的 Provisioning Profiles了，当你通过developer后台网站就可以看到Provisioning Profiles中有一堆所谓的Managed by Xcode的条目了。

你需要在XCode工程对应的Target的Capabilities这个Tab中开启Associated Domains，这个时候时候你可能会遇到错误提示“You must be a team admin or agent in order to enable this capability.”,其实即使账户是admin还是会报错，这个可能是XCode的bug吧，你需要切换到General这个tab中将Team先选None，然后再切换到你对应的Team，这个时候Team下方显示错误了，其实就是你更改了Entitlements，而这个和Provisioning Profiles有关联，所以你的Provisioning Profiles也需要重新更新，点击Team下方的Fix Issue按钮，等待重新下载新的Provisioning Profiles，然后回到Capabilities这个tab你会发现刚才的错误已经不见了。 

其实Capabilities中的操作除了会在本地生成entitlements文件，还会同步到developer后台去，会修改app对应的App ID的配置，以及在developer后台生成新的Provisioning Profiles。这些东西都和打包签名息息相关。

接着在Associated Domains下加上所需要支持handoff的domains

```
activitycontinuation:taobao.com
```

activitycontinuation是服务名，taobao.com是支持的域名
当Mac上的浏览器访问一个网站的时候，此网站的域名如果被某个App的Associated Domains包含了，那么Handoff底层会去这个域名一个指定的路径下访问一个文件，这个指定的路径便是 :
https://taobao.com/apple-app-site-association ,这个路径需要返回一个签名过的文件数据，里面指定了当前网站所支持Handoff的App ID们，这个下面会提及到

#### 2.服务器端
需要进行Handoff的网站，需要在https的特定的路径下放一个签名过的文件，这个文件里面指明了Handoff支持哪些App（Domain-approved apps IDs），这个文件的明文为JSON格式,在对JSON文件签名前最好去掉所有无用的空格以及检测下JSON格式的正确性，避免后面带来问题

```
{"activitycontinuation":{"apps":["XN6U3EV979.com.taobao.handoff"]}}
```


签名则是使用网站的ssl的私钥以及证书进行签名（如果不存在中级证书，那么中级证书可以去掉）

```
cat json.txt | openssl smime -sign -inkey taobao.com.key
                             -signer taobao.com.pem
                             -certfile intermediate.pem
                             -noattr -nodetach
                             -outform DER > apple-app-site-association
```

生成的文件放到网站根目录下以及确保可以通过指定的路径进行访问。


#### 3.如何进行本机调试 

要想在开发机器上进行网站的Handoff的调试则首先的问题就是SSL证书，你需要自己搞一个CA证书，在Mac上可以通过Keychain Access(钥匙串访问)这个App中的证书助理来生成 。

首先是CA证书,这里生成的是自签名的根证书，CA证书的作用就是给网站的SSL的证书进行签名用的，然后创建网站的SSL证书,一步一步走下去，然后通过刚才的CA证书进行签发，这样生成的证书就可以直接用于网站的SSL证书了。

然后选择一个Web Server，我这里选用的[Jetty](http://download.eclipse.org/jetty/)，直接下载下来然后就可以直接使用自带的demo了，主要是需要自己配置下SSL。

将默认的ssl配置拷贝到demo工程相应的目录下
```
Luke@LukesMac:~/Workspace/jetty » cp etc/jetty-ssl.xml demo-base/etc/ 
```

从Keychian Access中导出之前生成的证书文件，导出格式为p12，这样就会包含私钥了。假设导出文件为 lukesmac.p12,导出时候 需要你设置一个密码，你就将其设置为 keypwd
然后需要将这个p12文件导入demo工程的keystore文件中，默认在demo工程的etc目录下已经存在一个keystore文件，直接导入这个keystore

```
keytool -importkeystore -srckeystore lukesmac.p12 -srcstoretype PKCS12 -destkeystore keystore
```
默认keystore的密钥库口令为storepwd,导入的过程中你还需要输入你上面设置的私钥密码（因为jetty-ssl.xml中配置的私钥密码以及默认keystore中的私钥密码默认为keypwd
,所以为了方便上面导出私钥所设置的私钥密码保持一致为keypwd）。最后你还需要在demo工程的根目录下的start.ini中加入一行

```
etc/jetty-ssl.xml
```

然后你就可以开开心心的启动了，

```
Luke@LukesMac:~/Workspace/jetty/demo-base » java -jar ../start.jar
```


然后我便可以通过 https://lukesmac.local:8443/ 进行访问了

下面需要将json.txt进行签名，

首先你需要从上面导出的p12文件中搞出私钥文件，再从Keychain Access中导出一份证书的cer文件

```
openssl pkcs12 -in lukesmac.p12 -nocerts -out privateKey.pem
cat json.txt | openssl smime -sign -inkey privateKey.pem -signer lukesmac.cer -noattr -nodetach -outform DER > apple-app-site-association
```

将生成的apple-app-site-association文件放到 demo工程的ROOT目录下，然后重启以及在浏览器中对这个文件进行访问测试。

这个时候你以为一切就绪了，发现手机上handoff的图标依然是safari，打开后发现，网页根本无法打开，其原因就是自己生成的自签名的CA证书不被信任，这个时候你可以讲CA证书按照cer的格式导出，然后通过邮件发送，在iPhone上的邮箱App中点击这个cer的附件，系统会跳转到设置的描述文件的界面去，你需要进行安装证书，之后这个CA证书签发的SSL证书对于这台设备都是可信任的了。


最后就是客户端添加处理逻辑了，可以在Appdelegate中添加如下方法，就可以对传递过来的userActivity进行处理

```
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray *restorableObjects))restorationHandler NS_AVAILABLE_IOS(8_0);
```
