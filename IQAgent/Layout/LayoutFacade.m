//
//  LayoutFacade.m
//  IQAgent
//
//  Created by IanFan on 2016/10/5.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "LayoutFacade.h"
#import "DemoLayoutViewController.h"
#import "ChatLayoutViewController.h"
#import "TrainLayoutViewController.h"

@interface LayoutFacade()
@property (nonatomic, assign) UIViewController *superVC;
@end

@implementation LayoutFacade

#pragma mark - LifeCycle

- (id)initWithSuperVC:(UIViewController *)superVC {
    self  = [super init];
    if (self) {
        _superVC = superVC;
    }
    return self;
}

- (void)dealloc {
    [self deallocLayoutViewController];
}

#pragma mark - Command

- (void)updateLayoutViewControllerWithService:(Layout_Service)service {
    _service = service;
    
    [self deallocLayoutViewController];
    
    [self getLayoutViewController];
}

- (void)updateLayoutViewControllerServiceBySetting {
    switch ([IQSetting sharedInstance].ITEM_LAYOUT_SERVICE.iDefault) {
        case 0: [self updateLayoutViewControllerWithService:Layout_Service_Train]; break;
        case 1: [self updateLayoutViewControllerWithService:Layout_Service_Chat]; break;
        default: break;
    }
}

- (void)updateLayoutSpeakButton {
    [_layoutViewController updateSpeakButton];
}

#pragma mark - UI

#pragma mark SpeechToText

- (void)uiStartRecording {
    [_layoutViewController uiStartRecording];
}

- (void)uiStopRecording {
    [_layoutViewController uiStopRecording];
}

- (void)uiCancelRecording {
    [_layoutViewController uiCancelRecording];
}

#pragma mark Agent

- (void)uiAgentQuestionWithQuestion:(NSString *)questionStr {
    [_layoutViewController uiAgentQuestionWithQuestion:questionStr];
}

#pragma mark TextToSpeech

- (void)uiTextToSpeechWithText:(NSString *)text {
    [_layoutViewController uiTextToSpeechWithText:text];
}

- (void)uiTextToSpeechWithText:(NSString *)text characterRange:(NSRange)range {
    [_layoutViewController uiTextToSpeechWithText:text characterRange:range];
}

- (void)uiLayoutWithContentItem:(ContentItem *)item {
    [_layoutViewController uiLayouthWithContentItem:item];
}

#pragma mark - Factory

- (BaseLayoutViewController *)getLayoutViewController {
    CGRect frame = _superVC.view.frame;
    
    if (!_layoutViewController) {
        switch (_service) {
            case Layout_Service_Demo:
            {
                DemoLayoutViewController *viewController = [[DemoLayoutViewController alloc] initWithFrame:frame];
                [_superVC.view addSubview:viewController.view];
                _layoutViewController = viewController;
            }
                break;
                
            case Layout_Service_Chat:
            {
                ChatLayoutViewController *viewController = [[ChatLayoutViewController alloc] initWithFrame:frame];
                [_superVC.view addSubview:viewController.view];
                _layoutViewController = viewController;
            }
                break;
                
            case Layout_Service_Train:
            {
                TrainLayoutViewController *viewController = [[TrainLayoutViewController alloc] initWithFrame:frame];
                [_superVC.view addSubview:viewController.view];
                _layoutViewController = viewController;
            }
                break;
                
            default:
                NSLog(@"error getLayoutViewController");
                break;
        }
        
        _layoutViewController.delegate = self.delegate;
        [self.superVC.navigationController pushViewController:_layoutViewController animated:NO];
        [_layoutViewController getDefaultUI];
        
        _layoutViewController.title = [self getNavigationTitleStr];
        
        [self uiTextToSpeechWithText:[self getOpeningShowStr]];
    }
    
    return _layoutViewController;
}

- (void)deallocLayoutViewController {
    if (_layoutViewController) {
        [self.superVC.navigationController popToRootViewControllerAnimated:NO];
        
        _layoutViewController = nil;
    }
}

#pragma mark - Info

- (NSString *)getOpeningShowStr {
    switch (_service) {
        case Layout_Service_Demo: return IQLocalizedString(@"你可以問我有關點餐、股票、哈拉、笑話等等話題", nil);
        case Layout_Service_Chat: return IQLocalizedString(@"我是Vicky，你可以問我有關點餐、股票、哈拉、笑話等等話題", nil);
        case Layout_Service_Train: return IQLocalizedString(@"你可以問我有關火車時刻的問題\n(例：火車台北到高雄)", nil);
        default: NSLog(@"error getOpeningStr"); return IQLocalizedString(@"", nil);
    }
}

- (NSString *)getNavigationTitleStr {
    switch (_service) {
        case Layout_Service_Demo: return IQLocalizedString(@"iBo.ai", nil);
        case Layout_Service_Chat: return IQLocalizedString(@"iBo.ai", nil);
        case Layout_Service_Train: return IQLocalizedString(@"火車來了沒", nil);
        default: NSLog(@"error getNavigationTitleStr"); return IQLocalizedString(@"iBo.ai", nil);
    }
}

@end
