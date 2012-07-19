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
#import "CCJoyStick.h"

@interface GameScene : CCScene<CCJoyStickDelegate>
{
    GameLayer *mainLayer;
	DataManager *dataManager;
    CCJoyStick *_joyStick;
}

@property (nonatomic, retain) GameLayer *mainLayer;
//@property (nonatomic, retain) MenuLayer *menuLayer;
@property (nonatomic, retain) DataManager *dataManager;
@property (nonatomic, retain) CCJoyStick *joyStick;

@end
