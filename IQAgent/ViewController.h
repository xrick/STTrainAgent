//
//  ViewController.h
//  IQAgent
//
//  Created by IanFan on 2016/9/13.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReachabilityFacade.h"
#import "LayoutFacade.h"
#import "SpeechToTextFacade.h"
#import "AgentFacade.h"
#import "TextToSpeechFacade.h"

@interface ViewController : UIViewController<ReachabilityDelegate, LayoutDelegate, SpeechToTextDelegate, AgentFacadeDelegate, TextToSpeechFacadeDelegate>
@property (retain, nonatomic) ReachabilityFacade *reachabilityFacade;//網路狀態接口
@property (retain, nonatomic) LayoutFacade *layoutFacade;//UI呈現接口
@property (retain, nonatomic) SpeechToTextFacade *speechToTextFacade;//語音辨識接口
@property (retain, nonatomic) AgentFacade *agentFacade;//電腦人大腦接口
@property (retain, nonatomic) TextToSpeechFacade *textToSpeechFacade;//文字朗讀（TTS）接口

@end

