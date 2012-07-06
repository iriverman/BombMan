//
//  GameScene.h
//  BombManDemo
//
//  Created by JIA SHUN JIN on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CCScene.h"
#import "GameLayer.h"
#import "DataManager.h"

@interface GameScene : CCScene
{
    GameLayer *mainLayer;
	DataManager *dataManager;
}

@property (nonatomic, retain) GameLayer *mainLayer;
//@property (nonatomic, retain) MenuLayer *menuLayer;
@property (nonatomic, retain) DataManager *dataManager;

@end
