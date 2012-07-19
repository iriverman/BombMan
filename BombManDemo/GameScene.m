//
//  GameScene.m
//  BombManDemo
//
//  Created by JIA SHUN JIN on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
@interface GameScene(Private)
-(void)endGame;
@end

@implementation GameScene
@synthesize mainLayer;
@synthesize dataManager;
@synthesize joyStick = _joyStick;



- (void) dealloc
{
	[self unschedule:@selector(tick:)];
    //	[menuLayer release];
	[mainLayer release];
	[dataManager release];
    _joyStick = nil;
	[super dealloc];
}

- (id) init
{
	self = [super init];
	
	if (self)
	{
		dataManager = [DataManager sharedManager];
		dataManager.currentlevel = 0;
		dataManager.score = 0;
		
		GameLayer *layer = [[GameLayer alloc] init];
		self.mainLayer = layer;
		[layer release];
		
		
		[self addChild:mainLayer];
        
        _joyStick=[CCJoyStick initWithBallRadius:25 MoveAreaRadius:65 isFollowTouch:NO isCanVisible:YES isAutoHide:NO hasAnimation:YES];
        //		[_joyStick setBallTexture:@"Ball.png"];
		[_joyStick setDockTexture:@"c1.png"];
        //		[_joyStick setStickTexture:@"Stick.jpg"];
		[_joyStick setHitAreaWithRadius:100];
		
		_joyStick.position=ccp(100,100);
        _joyStick.delegate=self;
		[self addChild:_joyStick];
        
		
		[self endGame];
	}
	
	return self;
}

- (void) onCCJoyStickUpdate:(CCNode*)sender Angle:(float)angle Direction:(CGPoint)direction Power:(float)power
{
    if (sender==_joyStick) {
		NSLog(@"angle:%f power:%f direction:%f,%f",angle,power,direction.x,direction.y);
        CGPoint point = [self.mainLayer getPlayerPosition];

        if (-45 < angle && angle < 45) {
            point.x += direction.x * (power*8);
        }
        else if(angle > 45 && angle < 135)
        {
            point.y += direction.y * (power*8);
        }
        else if(angle > 135 || angle < -135){
            point.x += direction.x * (power*8);
        }
        else if(angle > -135 && angle < -45){
            point.y += direction.y * (power*8);
        }
        
        
        [self.mainLayer playerMoveTo:point];
        
        
//		beetle.rotation = -angle;
//		
//		float nextx=beetle.position.x;
//		float nexty=beetle.position.y;
//		
//		nextx+=direction.x * (power*8);
//		nexty+=direction.y * (power*8);
//		
//		if(nexty>320){
//			nexty=0;
//		}
//		if(nexty<0){
//			nexty=320;
//		}
//		if(nextx<0){
//			nextx=480;
//		}
//		if(nextx>480){
//			nextx=0;
//		}
//		
//		beetle.position=ccp(nextx,nexty);
	}
}

- (void) nextLevel
{	
	dataManager.currentlevel += 1;
    
}

- (void) endGame
{
}

- (void) restartGame
{	
	dataManager.currentlevel = 0;
	dataManager.score = 0;
    
}


@end
