//
//  PhysicsSprite.h
//  Balls
//
//  Created by Ryan Luce on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "BallsModel.h"



typedef enum tagTouchState {
	kTouchStateGrabbed,
	kTouchStateUngrabbed
} TouchState;


@interface PhysicsSprite : CCSprite<CCTargetedTouchDelegate> {

    float _floatTimeStartedDraggingTime;
    CGPoint _cgPointStartedDraggingPoint;
    TouchState state;
    BallsModel *model;
   
    b2Body *body;
    b2BodyDef *bodyDef;
    b2MouseJoint *mouseJoint;
   // b2CircleDef *shapeDef;
}



@property float floatTimeStartedDraggingTime;
@property CGPoint cgPointStartedDraggingPoint;

@property (nonatomic, assign) b2Body *body;
@property (nonatomic, assign) b2BodyDef *bodyDef;




- (CGRect)rect;
- (CGRect)rectInPixels;
 
- (void)flingWithEndLocation:(CGPoint)endLocation;
- (void)setupPhysics;
@end
