# next-IOSSDK-sample-app
A sample application to use ScalaMobileSDKIOS library (libScalaMobileSDKIOS.a) using web view

The general usage of libScalaMobileSDKIOS.a is to create javascript applications at next.scala.com web site and a mobile device instance representing IOS device which will run this sample application. Assign the javascript application to the mobile device. Each mobile device will have a clientId/clientSecret associated with. The clientId/clientSecret needs to be stored in samplie application's ApplicationProperties.plist file, so that IOS application will retrieved the associated javascript application. Each application will have an URL associated with. When launching sample IOS application, the javascript application's URL will be loaded at IOS device. ScalaMobileSDKIOS also provides list of javascript hooks to communicate between native code and javascript code.

Steps to create a sample application
1.  create a single page application with a image view and a web view. By default, the image view will be displayed on the device initially, and the web view will be loaded in background. If the web view application calls "fadeInWebView", the application will swap image view and web view on IOS device.

2.  include ScalaMobileSDK folder (including Headers folder and libScalaMobileSDKIOS.a) into your application.

3.  codes in AppDelegate.m file:
    a.  need to registerForRemoteNotifications at 
        - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
          ......
          [application registerForRemoteNotifications];
          ......
        }
    b.  
