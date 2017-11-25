//
//  SettingViewController.m
//  IQAgent
//
//  Created by IanFan on 2016/12/12.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "SettingViewController.h"

#define CELL_IDENTIFIER @"Cell"
static CGFloat cellHeight = 50;

//語音辨識(ASR)
#define TAG_ASR_SERVICE           100
#define TAG_ASR_TAP               101

//文字轉語音(TTS)
#define TAG_TTS_SERVICE           200
#define TAG_TTS_VOLUME            201
#define TAG_TTS_SPEED             202
#define TAG_TTS_PITCH             203
#define TAG_TTS_RESET             204

//電腦人介面
#define TAG_LAYOUT_SERVICE        300

//IQAgent
#define TAG_RATE                  800
#define TAG_FEEDBACK              801
#define TAG_COOPERATION           802
#define TAG_ABOUT                 803
#define TAG_LICENSE               804

//其它
#define TAG_IMAGEVIEW             900

@interface SettingViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    CGFloat _statusBarHeight;
    CGFloat _navigationBarHeight;
    CGFloat _tabBarHeight;
}
@property (retain, nonatomic) UITableView *tableView;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = IQLocalizedString(@"設定", nil);
    
    [self getTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
//    [self.tabBarController.tabBar setHidden:NO];
    
    [self.tableView reloadData];
    
    [[IQLog sharedInstance] logScreenName:NSStringFromClass([self class])];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
//    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = 1;

    if (section == 0) {
        num = 1;
    }
    else if (section == 1) {
        num = 1;
    }
    else if (section == 2) {
        num = 4;
    }
    
//    if (section == 0) {
//        num = 2;
//    }
//    else if (section == 1) {
//        num = 4;
//    }
//    else if (section == 2) {
//        num = 1;
//    }
//    else if (section == 3) {
//        num = 4;
//    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_IDENTIFIER];
    
    //prepare cell
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.view.frame.size.width, cellHeight);
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UISwitch class]]) {
            [view removeFromSuperview];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = 0;
    cell.textLabel.text = @"";
    cell.imageView.image = nil;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.indentationWidth = 10;
    cell.indentationLevel = 1;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = IQLocalizedString(@"發話（錄音）模式", nil);
            //            cell.detailTextLabel.text = IQLocalizedString(@"1.按住說話->放開送出 2.點擊說話->點擊送出", nil);
            cell.tag = TAG_ASR_TAP;
            [self addSegmentOnCell:cell tag:cell.tag];
        }
        /*
        if (indexPath.row == 0) {
            cell.textLabel.text = IQLocalizedString(@"語音辨識服務", nil);
            cell.tag = TAG_ASR_SERVICE;
            [self addSegmentOnCell:cell tag:cell.tag];
            
        } else if (indexPath.row == 1) {
            cell.textLabel.text = IQLocalizedString(@"發話（錄音）模式", nil);
            //            cell.detailTextLabel.text = IQLocalizedString(@"1.按住說話->放開送出 2.點擊說話->點擊送出", nil);
            cell.tag = TAG_ASR_TAP;
            [self addSegmentOnCell:cell tag:cell.tag];
        }
        */
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = IQLocalizedString(@"電腦人服務", nil);
            cell.tag = TAG_LAYOUT_SERVICE;
            [self addSegmentOnCell:cell tag:cell.tag];
        }
    }
    else if (indexPath.section == 2) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
        cell.textLabel.textColor = [UIColor blueColor];
        
        if (indexPath.row == 0) {
            cell.textLabel.text = IQLocalizedString(@"給予好評", nil);
            cell.tag = TAG_RATE;
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = IQLocalizedString(@"問題建議", nil);
            cell.tag = TAG_FEEDBACK;
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = IQLocalizedString(@"合作提案", nil);
            cell.tag = TAG_COOPERATION;
        }
        else if (indexPath.row == 3) {
            cell.textLabel.text = IQLocalizedString(@"有關我們", nil);
            cell.tag = TAG_ABOUT;
        }
        //        else if (indexPath.row == 4) {
        //            cell.textLabel.text = IQLocalizedString(@"開放原始碼授權", nil);
        //            cell.tag = TAG_LICENSE;
        //        }
    }
    
    /*
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = IQLocalizedString(@"語音辨識服務", nil);
            cell.tag = TAG_ASR_SERVICE;
            [self addSegmentOnCell:cell tag:cell.tag];
            
        } else if (indexPath.row == 1) {
            cell.textLabel.text = IQLocalizedString(@"發話（錄音）模式", nil);
//            cell.detailTextLabel.text = IQLocalizedString(@"1.按住說話->放開送出 2.點擊說話->點擊送出", nil);
            cell.tag = TAG_ASR_TAP;
            [self addSegmentOnCell:cell tag:cell.tag];
        }
    }
    else if (indexPath.section == 1) {
//        if (indexPath.row == 0) {
//            cell.textLabel.text = IQLocalizedString(@"朗讀服務", nil);
//            cell.tag = TAG_TTS_SERVICE;
//            [self addSegmentOnCell:cell tag:cell.tag];
//        }
        if (indexPath.row == 0) {
            cell.textLabel.text = IQLocalizedString(@"音量大小", nil);
            cell.tag = TAG_TTS_VOLUME;
            [self addSliderOnCell:cell tag:cell.tag];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = IQLocalizedString(@"聲調高低", nil);
            cell.tag = TAG_TTS_PITCH;
            [self addSliderOnCell:cell tag:cell.tag];
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = IQLocalizedString(@"語速快慢", nil);
            cell.tag = TAG_TTS_SPEED;
            [self addSegmentOnCell:cell tag:cell.tag];
        }
        else if (indexPath.row == 3) {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.textLabel.text = IQLocalizedString(@"恢復預設", nil);
            cell.tag = TAG_TTS_RESET;
            [self addSegmentOnCell:cell tag:cell.tag];
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = IQLocalizedString(@"電腦人服務", nil);
            cell.tag = TAG_LAYOUT_SERVICE;
            [self addSegmentOnCell:cell tag:cell.tag];
        }
    }
    else if (indexPath.section == 3) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
        cell.textLabel.textColor = [UIColor blueColor];
        
        if (indexPath.row == 0) {
            cell.textLabel.text = IQLocalizedString(@"給予好評", nil);
            cell.tag = TAG_RATE;
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = IQLocalizedString(@"問題建議", nil);
            cell.tag = TAG_FEEDBACK;
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = IQLocalizedString(@"合作提案", nil);
            cell.tag = TAG_COOPERATION;
        }
        else if (indexPath.row == 3) {
            cell.textLabel.text = IQLocalizedString(@"有關我們", nil);
            cell.tag = TAG_ABOUT;
        }
//        else if (indexPath.row == 4) {
//            cell.textLabel.text = IQLocalizedString(@"開放原始碼授權", nil);
//            cell.tag = TAG_LICENSE;
//        }
    }
    */
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName = @"";
    
    if (section == 0) {
        sectionName = IQLocalizedString(@"語音辨識", nil);
    }
    else if (section == 1) {
        sectionName = IQLocalizedString(@"A.I.類型", nil);
    }
    else if (section == 2) {
    }
    
    /*
    if (section == 0) {
        sectionName = IQLocalizedString(@"語音辨識", nil);
    }
    else if (section == 1) {
        sectionName = IQLocalizedString(@"TTS 朗讀", nil);
    }
    else if (section == 2) {
        sectionName = IQLocalizedString(@"A.I.類型", nil);
    }
    else if (section == 3) {
    }
     */
    
    return sectionName;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    switch (cell.tag) {
        case TAG_TTS_RESET:
            [self cellTapped:cell];
            break;
            
        case TAG_RATE:
        {
            [IQCommonTool openAppStoreRate];
        }
            break;
            
        case TAG_FEEDBACK:
        {
            [IQCommonTool openEmailFeedback];
        }
            break;
            
        case TAG_COOPERATION:
        {
            [IQCommonTool openEmailCooperation];
        }
            break;
            
        case TAG_ABOUT:
        {
            [IQCommonTool openOfficialWebsite];
        }
            break;
            
        case TAG_LICENSE:
        {
//            [self pushToLicenseViewController];
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = cellHeight;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    float height = 40;
    if      (section == 0) { height = 40; }
    else if (section == 1) { height = 40; }
    else if (section == 2) { height = 20; }
//    if      (section == 0) { height = 40; }
//    else if (section == 1) { height = 40; }
//    else if (section == 2) { height = 40; }
//    else if (section == 3) { height = 20; }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 1.0;
    return height;
}

#pragma mark - Command

- (void)cellTapped:(UITableViewCell *)cell {
    if (cell.tag == TAG_TTS_RESET) {
        [IQSetting sharedInstance].ITEM_TTS_SERVICE.iDefault = 0;
        [IQSetting sharedInstance].ITEM_TTS_VOLUME.iDefault = 100;
        [IQSetting sharedInstance].ITEM_TTS_SPEED.iDefault = 0;
        [IQSetting sharedInstance].ITEM_TTS_PITCH.iDefault = 100;
        [IQSetting sharedInstance].ITEM_LAYOUT_SERVICE.iDefault = 0;
        [self.tableView reloadData];
    }
}

#pragma mark - addOnCell

/*
#pragma mark UIButton

- (void)addButtonOnCell:(UITableViewCell *)cell tag:(NSInteger)tag {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [b setTitle:cell.textLabel.text forState:UIControlStateNormal];
    CGSize size = CGSizeMake(100, cellHeight-10);
    b.frame = CGRectMake(cell.contentView.bounds.size.width - size.width - 5.0f,
                         (cell.contentView.bounds.size.height - size.height) / 2.0f,
                         size.width,
                         size.height);
    b.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    b.tag = tag;
    [b addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:b];
}

- (void)buttonTapped:(UIButton *)sender {
    switch (sender.tag) {
            //一般
        case TAG_TTS_TEST:
            break;
        case TAG_TTS_RESET:
        {
            
        }
            break;
        default: break;
    }
    
    [IQSetting sharedInstance].isEdited = YES;
}
*/

#pragma mark UISwitch

/*
- (void)addSwitchOnCell:(UITableViewCell *)cell tag:(NSInteger)tag {
    UISwitch *s = [[UISwitch alloc] init];
    CGSize size = [s sizeThatFits:CGSizeZero];
    s.frame = CGRectMake(cell.contentView.bounds.size.width - size.width - 5.0f,
                         (cell.contentView.bounds.size.height - size.height) / 2.0f,
                         size.width,
                         size.height);
    s.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    s.tag = tag;
    [s addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:s];
    
    switch (tag) {
//        case TAG_KEYPREVIEW:            s.on = [IQSetting sharedInstance].ITEM_COMPOSING_BUFFER_MODE.bDefault; break;
        default:
            break;
    }
}

- (void)switchChanged:(UISwitch *)sender {
    UISwitch *s = sender;
    
    switch (sender.tag) {
//        case TAG_KEYPREVIEW:            [IQSetting sharedInstance].ITEM_COMPOSING_BUFFER_MODE.bDefault = s.on; break;
        default:
            break;
    }
    
    [IQSetting sharedInstance].isEdited = YES;
}
 */

#pragma mark Segment

- (void)addSegmentOnCell:(UITableViewCell *)cell tag:(NSInteger)tag {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    switch (tag) {
        case TAG_ASR_SERVICE: {
            [items addObject:IQLocalizedString(@"Apple", nil)];
            [items addObject:IQLocalizedString(@"Google", nil)];
        }
            break;
            
        case TAG_ASR_TAP: {
            [items addObject:IQLocalizedString(@"點擊", nil)];
            [items addObject:IQLocalizedString(@"按住", nil)];
        }
            break;
            
        case TAG_TTS_SERVICE: {
            [items addObject:IQLocalizedString(@"Apple", nil)];
            [items addObject:IQLocalizedString(@"Google", nil)];
        }
            break;
            
        case TAG_TTS_SPEED: {
            [items addObject:IQLocalizedString(@"慢", nil)];
            [items addObject:IQLocalizedString(@"一般", nil)];
//            [items addObject:IQLocalizedString(@"快", nil)];
        }
            break;
            
        case TAG_TTS_RESET: {
            [items addObject:IQLocalizedString(@"恢復預設", nil)];
        }
            break;
            
        case TAG_LAYOUT_SERVICE: {
            [items addObject:IQLocalizedString(@"火車來了沒", nil)];
            [items addObject:IQLocalizedString(@"客服", nil)];
        }
            break;
            
        default:
            break;
    }
    
    UISegmentedControl *s = [[UISegmentedControl alloc] initWithItems:items];
    if (items.count <= 2) {
        for (int i=0; i<s.numberOfSegments; i++) {
            [s setWidth:80 forSegmentAtIndex:i];
        }
    }
    CGSize size = [s sizeThatFits:CGSizeMake(160, 0)];
    s.frame = CGRectMake(cell.contentView.bounds.size.width - size.width - 5.0f,
                         (cell.frame.size.height - size.height) / 2.0f,
                         size.width,
                         size.height);
    s.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    s.tag = tag;
    [s addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:s];
    
    switch (tag) {
        case TAG_ASR_SERVICE:
            s.selectedSegmentIndex = [IQSetting sharedInstance].ITEM_ASR_SERVICE.iDefault;
            break;
        case TAG_ASR_TAP:
            s.selectedSegmentIndex = [IQSetting sharedInstance].ITEM_ASR_TAP.iDefault;
            break;
        case TAG_TTS_SERVICE:
            s.selectedSegmentIndex = [IQSetting sharedInstance].ITEM_TTS_SERVICE.iDefault;
            break;
        case TAG_TTS_SPEED:
            s.selectedSegmentIndex = [IQSetting sharedInstance].ITEM_TTS_SPEED.iDefault + 1;
            break;
        case TAG_LAYOUT_SERVICE:
            s.selectedSegmentIndex = [IQSetting sharedInstance].ITEM_LAYOUT_SERVICE.iDefault;
            break;
        default: break;
    }
}

- (void)segmentChanged:(UISegmentedControl *)sender {
    UISegmentedControl *s = sender;
    
    switch (sender.tag) {
        case TAG_ASR_SERVICE:
            if ([IQSetting sharedInstance].ITEM_ASR_SERVICE.iDefault != s.selectedSegmentIndex) {
                [IQSetting sharedInstance].ITEM_ASR_SERVICE.iDefault = s.selectedSegmentIndex;
                if ([self.delegate respondsToSelector:@selector(settingViewControllerDeleagteUpdateSpeechToText)]) {
                    [self.delegate settingViewControllerDeleagteUpdateSpeechToText];
                }
            }
            break;
        case TAG_ASR_TAP:
            if ([IQSetting sharedInstance].ITEM_ASR_TAP.iDefault != s.selectedSegmentIndex) {
                [IQSetting sharedInstance].ITEM_ASR_TAP.iDefault = s.selectedSegmentIndex;
                if ([self.delegate respondsToSelector:@selector(settingViewControllerDeleagteUpdateSpeakButton)]) {
                    [self.delegate settingViewControllerDeleagteUpdateSpeakButton];
                }
            }
            break;
        case TAG_TTS_SERVICE:
            [IQSetting sharedInstance].ITEM_TTS_SERVICE.iDefault = s.selectedSegmentIndex;
            break;
        case TAG_TTS_SPEED:
            [IQSetting sharedInstance].ITEM_TTS_SPEED.iDefault = s.selectedSegmentIndex - 1;
            break;
        case TAG_LAYOUT_SERVICE:
            if ([IQSetting sharedInstance].ITEM_LAYOUT_SERVICE.iDefault != s.selectedSegmentIndex) {
                [IQSetting sharedInstance].ITEM_LAYOUT_SERVICE.iDefault = s.selectedSegmentIndex;
                if ([self.delegate respondsToSelector:@selector(settingViewControllerDeleagteUpdateLayout)]) {
                    [self.delegate settingViewControllerDeleagteUpdateLayout];
                }
            }
            break;
        case TAG_TTS_RESET:
            if (s.selectedSegmentIndex == 0) {
                [self cellTapped:(UITableViewCell *)sender];
                [self performSelector:@selector(unselectSegment:) withObject:sender afterDelay:0.1];
            }
            break;
        default: break;
    }
    
    [IQSetting sharedInstance].isEdited = YES;
}

- (void)unselectSegment:(UISegmentedControl *)sender {
    sender.selectedSegmentIndex = -100;
}

#pragma mark Slider

- (void)addSliderOnCell:(UITableViewCell *)cell tag:(NSInteger)tag {
    UISlider *s = [[UISlider alloc] init];
    CGSize size = [s sizeThatFits:CGSizeMake(150, 0)];
    s.frame = CGRectMake(cell.contentView.bounds.size.width - size.width - 15.0f,
                         (cell.contentView.bounds.size.height - size.height) / 2.0f,
                         size.width,
                         size.height);
    s.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    s.tag = tag;
    [s addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:s];
    
    switch (s.tag) {
        case TAG_TTS_VOLUME:
            s.maximumValue = 1;
            s.minimumValue = 0;
            s.value = (float)[IQSetting sharedInstance].ITEM_TTS_VOLUME.iDefault/100.0;
            break;
            
        case TAG_TTS_PITCH:
            s.maximumValue = 2;
            s.minimumValue = 0.2;
            s.value = (float)[IQSetting sharedInstance].ITEM_TTS_PITCH.iDefault/100.0;
            break;
            
        default:
            break;
    }
}

- (void)sliderChanged:(UISlider *)sender {
    UISlider *s = sender;
    
    switch (sender.tag) {
        case TAG_TTS_VOLUME:
            [IQSetting sharedInstance].ITEM_TTS_VOLUME.iDefault = (NSInteger)(s.value*100);
            break;
            
        case TAG_TTS_PITCH:
            [IQSetting sharedInstance].ITEM_TTS_PITCH.iDefault = (NSInteger)(s.value*100);
            break;
            
        default:
            break;
    }
    
    [IQSetting sharedInstance].isEdited = YES;
}

#pragma mark - Factory

- (UITableView *)getTableView {
    if (!self.tableView) {
        CGRect tableFrame  = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        UITableView *tableView =[[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.bounces = YES;
        tableView.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.00];
        [self.view addSubview:tableView];
        self.tableView = tableView;
    }
    return self.tableView;
}

@end
