# next-IOSSDK-sample-app
A sample application to use ScalaMobileSDKIOS library (libScalaMobileSDKIOS.a) using web view

The general usage of libScalaMobileSDKIOS.a is to create javascript applications at next.scala.com web site and a mobile device instance representing IOS device which will run this sample application. Assign the javascript application to the mobile device. Each mobile device will have a clientId/clientSecret associated with. The clientId/clientSecret needs to be stored in samplie application's ApplicationProperties.plist file, so that IOS application will retrieved the associated javascript application. Each application will have an URL associated with. When launching sample IOS application, the javascript application's URL will be loaded at IOS device. ScalaMobileSDKIOS also provides list of javascript hooks to communicate between native code and javascript code.

Steps to create a sample application

1.  create a single page application with a image view and a web view. By default, the image view will be displayed on the device initially, and the web view will be loaded in background. If the web view application calls "fadeInWebView", the application will swap image view and web view on IOS device.

2.  include ScalaMobileSDK folder (including Headers folder and libScalaMobileSDKIOS.a) into your application. add the fllowing frameworks:
	CoreMedia.framework
	CoreVideo.framework
	libiconv.dylib
	AVFoundation.framework
	QuartzCore.framework
	CFNetwork.framework
	libicucore.dylib
	Security.framework
	AdSupport.framework
	SystemConfiguration.framework
	CoreLocation.framework
	CoreBluetooth.framework
	Foundation.framework
	UIKit.framework
	CoreGraphics.framework

3.  in project file, go to "Build Settings" -> "Linking" -> "Other Linker Flags", add entry of "-ObjC"

4.  codes in AppDelegate.m file:

    a.  need to registerForRemoteNotifications at 
        - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
          ......
          [application registerForRemoteNotifications];
          ......
        }
    
    b.  get the deviceToken and send it to ScalaMobileSDK through NSNotificationCenter:
    	- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    	    DLog(@"My token is: %@", deviceToken);
    	    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    	    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    	    [[NSUserDefaults standardUserDefaults]setValue:token forKey:@"devicetoken"];
    	    [[NSUserDefaults standardUserDefaults]synchronize];
    
    	    NSString * message = [NSString stringWithFormat:@"%@%@", @"getDeviceToken:", token];
    	    [[NSNotificationCenter defaultCenter]
     		postNotificationName:@"ApplicationEvent"
     		object:message];
	    }

    c.	notify ScalaMobileSDK when application will enter foreground through NSNotificationCenter:
	- (void)applicationWillEnterForeground:(UIApplication *)application {
    	    // ask ScalaMobileSDK to check cache, rebuild data has been changed.
    	    if(_recheckCache) {
        	[[NSNotificationCenter defaultCenter]
         	    postNotificationName:@"ApplicationEvent"
         	    object:@"recheckCache"];
    	    }
    		......
	}
		
    d.	notify application when application will terminate to clear web view content:
	- (void)applicationWillTerminate:(UIApplication *)application {
    		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   			[[NSURLCache sharedURLCache] removeAllCachedResponses];
    		[[NSNotificationCenter defaultCenter]
     			postNotificationName:@"ApplicationEvent"
     			object:@"ApplicationWillTerminate"];
		}

4.	code in ViewController.m file:
	a.	initialize ScalaMobileSDK, and load web view
		- (void)viewDidLoad {
			....
			scala = [[ScalaMobileSDK alloc] init];
    		scala.delegate = self;
    		scala.parentViewController = self;
    		[self loadWebView];
		}
		
	b.	switch device screen between image view and web view depending on the internet connectivity, and the function call from javascript application.
		if the application URL is sort of "initializer", always load application URL.
		-(void) loadWebView {
			......
			if([fullURL rangeOfString:@"initializer"].location != NSNotFound){
                webViewDisplayed = NO;
                [self performTransition:UIViewAnimationOptionTransitionCrossDissolve];
                webViewDisplayed = YES;
            }
			.......
		}
	
	c.	retrieve javascript fucntion call
		-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    		......
    		if ([requestString hasPrefix:@"js-frame:"]) {
        		DLog(@"beacon request");
        		NSArray *components = [requestString componentsSeparatedByString:@":"];
        
        		NSString *function = (NSString*)[components objectAtIndex:1];
        		int callbackId = [((NSString*)[components objectAtIndex:2]) intValue];
        		NSString *argsAsString = [(NSString*)[components objectAtIndex:3]
                                  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        		NSData* data = [argsAsString dataUsingEncoding:NSUTF8StringEncoding];
        		NSError *e;
        		NSArray *args = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];

        		[self handleCall:function callbackId:callbackId args:args];
        		return NO;
    		}
    
    		return YES;
		}
		
		all javascript function will come starting with "js-frame:", navtive code will take the request string, and parse it with funciton name and arguments.
		
	e.	handle javascript function call
		- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args {
    		if ([functionName isEqualToString:@"getBeacons"]) {
    			// return all beacon information including in-associated nodes.
        		NSString *returnString = @"{\"beacons\":";
        		NSArray* beaconArray = [scala getBeaconArray];
        		NSError *writeError = nil;
        		NSData *data = [NSJSONSerialization dataWithJSONObject:beaconArray options:NSJSONWritingPrettyPrinted error:&writeError];
        		returnString = [NSString stringWithFormat:@"%@%@", returnString, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        		returnString = [NSString stringWithFormat:@"%@%@", returnString, @"}" ];
        		DLog(@"return string: %@", returnString);
        
        		[self returnResult:callbackId args:returnString,nil];
    			.......
    		}
		}
		
		after the result from ScalaMobileSDK, convert result to string, and return it to javascript through NativeBridge.call.
		
	f.	return results to javascript application
		-(void)returnResultAfterDelay:(NSString*)str {
    		......
    	    [self.webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:str waitUntilDone:NO];
		}	
    
    g.	implement ScalaMobileSDKDelegate functions.
    	-(void) didGetReturnResults:(NSString *)returnString forCallbackId:(int)callbackId 
    	-(void) didGetNodeChangePusherEvent:(NSDictionary*)pusherData
    	-(void) didGetApplicationChangePusherEvent:(NSDictionary*)pusherData
    	-(void) didGetRefreshCacheRequest
    	-(void) didGetNewClosestBeacon:(NSString*) returnString withType:(NSString*) type
	-(void) didGetInternetConnection
	-(void) didLoseInternetConnection
		
     h.	refer to javascript SDK document for the usage of javascript functions (javascript hooks) to communicate with IOS native code.
    			
    			
    			
    			
    			
    			
    			
    			
    			
    			
