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
@synthesize cgPointStartedDraggingPoint = _cgPointStartedDraggingPoint, floatTimeStartedDraggingTime = _floatTimeStartedDraggingTime, boolIsFlingable = _boolIsFlingable, boolIsTouching = _boolIsTouching, body, bodyDef;

-(id)initWithFile:(NSString *)filename
{
    self = [super initWithFile:filename];
    if(self)
    {
        model = [BallsModel sharedInstance];
        state = kTouchStateUngrabbed;

        //this will be random in the future
        //hardcode width for now

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
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}	

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (state != kTouchStateUngrabbed) return NO;
	if ( ![self containsTouchLocation:touch] ) return NO;
	
   
    self.floatTimeStartedDraggingTime = [[BallsModel sharedInstance] floatCurrentTime];
    CGPoint location = [touch locationInView: [touch view]];
    self.cgPointStartedDraggingPoint = [[CCDirector sharedDirector] convertToGL:location];
    
    if(mouseJoint != NULL) return NO;
    
    b2Vec2 locationInWorld = b2Vec2(self.cgPointStartedDraggingPoint.x/PTM_RATIO, self.cgPointStartedDraggingPoint.y/PTM_RATIO);   
    b2MouseJointDef md;
    md.bodyA = model.groundBody;
    md.bodyB = self.body;
    md.target = locationInWorld;
    md.maxForce = 1000.0f * self.body->GetMass();

    md.collideConnected = true;
    mouseJoint = (b2MouseJoint *)model.world->CreateJoint(&md);
    self.body->SetAwake(true);
     NSLog(@"Touches began");
    
	state = kTouchStateGrabbed;
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	// If it weren't for the TouchDispatcher, you would need to keep a reference
	// to the touch from touchBegan and check that the current touch is the same
	// as that one.
	// Actually, it would be even more complicated since in the Cocos dispatcher
	// you get NSSets instead of 1 UITouch, so you'd need to loop through the set
	// in each touchXXX method.
	
	NSAssert(state == kTouchStateGrabbed, @"Paddle - Unexpected state!");	
	
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    b2Vec2 locationWorld = b2Vec2(touchPoint.x/PTM_RATIO, touchPoint.y/PTM_RATIO);
    NSLog(@"touch moved");
    mouseJoint->SetTarget(locationWorld);

    
	//[self flingWithEndLocation:touchPoint];
	//self.position = CGPointMake(touchPoint.x, touchPoint.y);
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state == kTouchStateGrabbed, @"Paddle - Unexpected state!");	
    CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];	
    //[self flingWithEndLocation:touchPoint];
    if(mouseJoint)
    {
        //NSLog(@"touch cancelled");
        model.world->DestroyJoint(mouseJoint);
        mouseJoint = NULL;
    }
	state = kTouchStateUngrabbed;
}



- (void)flingWithEndLocation:(CGPoint)endLocation
{
	float x,y,t,xs,ys;
	x = (endLocation.x - self.cgPointStartedDraggingPoint.x)/PTM_RATIO;
	y = (endLocation.y - self.cgPointStartedDraggingPoint.y)/PTM_RATIO;
	t = [[BallsModel sharedInstance] floatCurrentTime] - self.floatTimeStartedDraggingTime + 0.05f;
	if (t<0.07f){
		t = 0.07f; //fixing extreme values and fixing division by zero
	}
	xs = x * 2/ t;
	ys = y * 2/ t;
	if (xs != 0 || ys != 0){
		self.body->SetLinearVelocity(b2Vec2(xs,ys));
	}
    
}

- (void)setupPhysics
{
    CCLOG(@"setting up physics");
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    NSNumber *randX = [NSNumber numberWithUnsignedInt:arc4random()];
    float randPosition1 = fmod([randX floatValue],winSize.width -50);
    NSNumber *randY = [NSNumber numberWithUnsignedInt:arc4random()];
    float randPosition2 = fmod([randY floatValue],winSize.height -50);        
    self.position = ccp(randPosition1, randPosition2);    
    
    
    b2BodyDef _bodyDef;
    _bodyDef.type = b2_dynamicBody;
    _bodyDef.position.Set(randPosition1/PTM_RATIO, randPosition2/PTM_RATIO);
    _bodyDef.userData = self;
    self.body = model.world->CreateBody(&_bodyDef);
    
    b2CircleShape dynamicCircle;
    dynamicCircle.m_radius = 25.0/PTM_RATIO;
    
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicCircle;	
    fixtureDef.density = 0.9f;
    fixtureDef.friction = 0.5f;
    fixtureDef.restitution = 0.3f;
    self.body->CreateFixture(&fixtureDef);  
    
    
     
     /*CCSprite *sprite = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(0,0,50,50)];
     //this will be random in the future
     sprite.position = ccp(100, 100);
     [batch addChild:sprite];
     
     b2BodyDef bodyDef;
     bodyDef.type = b2_dynamicBody;
     bodyDef.position.Set(100/PTM_RATIO, 100/PTM_RATIO);
     bodyDef.userData = sprite;
     b2Body *body = world->CreateBody(&bodyDef);
     
     b2CircleShape dynamicCircle;
     dynamicCircle.m_radius = 50/PTM_RATIO;
     
     // Define the dynamic body fixture.
     b2FixtureDef fixtureDef;
     fixtureDef.shape = &dynamicCircle;	
     fixtureDef.density = 1.0f;
     fixtureDef.friction = 0.3f;
     body->CreateFixture(&fixtureDef);*/
    
}


@end
