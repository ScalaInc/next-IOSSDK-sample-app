//
//  PusherHelper.h
//  ScalaMobileSDKIOS
//
//  Created by Wenyao Hu on 10/14/14.
//  Copyright (c) 2014 scala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PusherController.h"
@class PusherHelper;
@protocol PusherHelperDelegate <NSObject>

-(void) didReceiveApplicationCreatedPusherEvent:(NSDictionary*) dataNode;
-(void) didReceiveApplicaitonDeletedPusherEvent:(NSDictionary*) dataNode;
-(void) didReceiveNodeUpdatePusherEvent:(NSMutableDictionary*) updatedNode;
-(void) didReceiveNodeDeletedPusherEvent:(NSMutableDictionary*) deletedNode;
-(void) didReceiveNodeCreatedPusherEvent:(NSMutableDictionary*) createdNode;
-(void) didReceiveBeaconAddedPusherEvent:(NSDictionary*) dataNode;
-(void) didReceiveBeaconDeletedPusherEvent:(NSDictionary*) dataNode;
-(void) didReceiveAssociationCreatedPusherEvent:(NSDictionary*) dataNode;
-(void) didReceiveAssociationDeletedPusherEvent:(NSDictionary*) dataNode;

@end

@interface PusherHelper : NSObject <PusherControllerDelegate>
@property(nonatomic, assign)id<PusherHelperDelegate> delegate;


-(id) initWithPushController:(PusherController*) pushController;
@end
