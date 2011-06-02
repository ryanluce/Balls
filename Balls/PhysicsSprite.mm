//
//  PhysicsSprite.m
//  Balls
//
//  Created by Ryan Luce on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhysicsSprite.h"

#define PTM_RATIO 32

@implementation PhysicsSprite
@synthesize cgPointStartedDraggingPoint = _cgPointStartedDraggingPoint, floatTimeStartedDraggingTime = _floatTimeStartedDraggingTime, body, bodyDef;

-(id)initWithFile:(NSString *)filename
{
    self = [super initWithFile:filename];
    if(self)
    {
        model = [BallsModel sharedInstance];
        //initialize the state
        state = kTouchStateUngrabbed;

        
        [self setupPhysics];
    }
    return self;
}

- (CGRect)rectInPixels
{
	CGSize s = [texture_ contentSizeInPixels];
	return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
}

- (CGRect)rect
{
	CGSize s = [texture_ contentSize];
	return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
}



- (BOOL)containsTouchLocation:(UITouch *)touch
{
	CGPoint p = [self convertTouchToNodeSpaceAR:touch];
	CGRect r = [self rectInPixels];
	return CGRectContainsPoint(r, p);
}

- (void)onEnter
{
	//Make sure to tell cocos2d we want touches
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit
{
    //don't need to listen for touches anymore
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}	

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	//If this ball is already touched, just return
    if (state != kTouchStateUngrabbed) return NO;
    //If the touch point is bigger than
	if ( ![self containsTouchLocation:touch] ) return NO;
	//If we've already created a mouse joint for some reason, just use that one
    if(mouseJoint != NULL) return NO;
    
    //Find where the finger is and create a box2d mouseJoint
    CGPoint location = [touch locationInView: [touch view]];
    self.cgPointStartedDraggingPoint = [[CCDirector sharedDirector] convertToGL:location];
    
    b2Vec2 locationInWorld = b2Vec2(self.cgPointStartedDraggingPoint.x/PTM_RATIO, self.cgPointStartedDraggingPoint.y/PTM_RATIO);   
    b2MouseJointDef md;
    md.bodyA = model.groundBody;
    md.bodyB = self.body;
    md.target = locationInWorld;
    md.maxForce = 1000.0f * self.body->GetMass();
    //Make sure it still bounces off the walls
    md.collideConnected = true;
    mouseJoint = (b2MouseJoint *)model.world->CreateJoint(&md);
    //If it's sleeping, box2d won't perform calulations on it, and therefore it won't move
    self.body->SetAwake(true);
   
    //Set current state
	state = kTouchStateGrabbed;
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	
	//Make sure we are in the correct state
	NSAssert(state == kTouchStateGrabbed, @"Paddle - Unexpected state!");	
	
    //Get where the finger currently is, and move the physics joint to that point
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    b2Vec2 locationWorld = b2Vec2(touchPoint.x/PTM_RATIO, touchPoint.y/PTM_RATIO);
    mouseJoint->SetTarget(locationWorld);

}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	//Make sure we are actually coming from being touched
    NSAssert(state == kTouchStateGrabbed, @"Paddle - Unexpected state!");	
    //If we've made a mouseJoint with the physics engine, kill it
    if(mouseJoint)
    {
        model.world->DestroyJoint(mouseJoint);
        mouseJoint = NULL;
    }
    //Return the state to ungrabbed
	state = kTouchStateUngrabbed;
}





- (void)setupPhysics
{
    //Initialize the circle shape within box2d
    
    //Put the ball at a random location
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    NSNumber *randX = [NSNumber numberWithUnsignedInt:arc4random()];
    float floatX = fmod([randX floatValue],winSize.width -50);
    NSNumber *randY = [NSNumber numberWithUnsignedInt:arc4random()];
    float floatY = fmod([randY floatValue],winSize.height -50);        
    self.position = ccp(floatX, floatY);    
    
    //define the body, and position it
    b2BodyDef _bodyDef;
    _bodyDef.type = b2_dynamicBody;
    _bodyDef.position.Set(floatX/PTM_RATIO, floatY/PTM_RATIO);
    _bodyDef.userData = self;
    self.body = model.world->CreateBody(&_bodyDef);
    
    //Define the shape to be a circle with a radius of 25px
    b2CircleShape dynamicCircle;
    dynamicCircle.m_radius = 25.0/PTM_RATIO;
    
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicCircle;	
    fixtureDef.density = 0.9f;
    fixtureDef.friction = 0.5f;
    fixtureDef.restitution = 0.3f;
    self.body->CreateFixture(&fixtureDef);  
    
    
    
}


@end
