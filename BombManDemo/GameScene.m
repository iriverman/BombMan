//
//  GameScene.m
//  BombManDemo
//
//  Created by JIA SHUN JIN on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"


@implementation GameScene
@synthesize mainLayer;
@synthesize dataManager;


- (void) dealloc
{
	[self unschedule:@selector(tick:)];
    //	[menuLayer release];
	[mainLayer release];
	[dataManager release];
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
        
		
		[self endGame];
	}
	
	return self;
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
