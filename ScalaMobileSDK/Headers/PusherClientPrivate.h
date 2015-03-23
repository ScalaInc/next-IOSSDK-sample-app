//
//  PusherClientPrivate.h
//  ScalaMobileSDK
//
//  Created by Wenyao Hu on 4/10/14.
//  Copyright (c) 2014 scala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
#import "PusherClient.h"

@interface PusherClient () <SRWebSocketDelegate>

@property (nonatomic, strong, readwrite) NSString *socketID;
@property (nonatomic, weak, readwrite) id<PusherClientDelegate> delegate;
@property (nonatomic, strong) SRWebSocket *webSocket;
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *pusherSite;
@property (nonatomic, strong) NSMutableDictionary *connectedChannels;


- (void)_sendEvent:(NSString *)eventName dictionary:(NSDictionary *)dictionary;
- (void)_reconnectChannels;
- (void)_removeChannel:(PusherChannel *)channel;
- (void)_reachabilityChanged:(NSNotification *)notification;

#if TARGET_OS_IPHONE
- (void)_appDidEnterBackground:(NSNotification *)notificaiton;
- (void)_appDidBecomeActive:(NSNotification *)notification;
#endif

@end