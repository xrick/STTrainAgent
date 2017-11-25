//
//  AgentFacade.m
//  IQAgent
//
//  Created by IanFan on 2016/9/19.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "AgentFacade.h"
#import "URLSessionModel.h"

#define USERDEFAULTS_SESSION_ID @"nsuserDefaults_session_id"

@interface AgentFacade()<URLSessionModelDelegate> {
    NSString *_diagnosisUrlStr;
    NSString *_allTypesUrlStr;
    NSString *_askQuestionPreUrlStr;
    NSString *_askPolyReresultsPreUrlStr;
    NSString *_satisfactionPreUrlStr;
    
    NSString *_serverUrlStr;
    NSString *_authKeyUrlStr;
    NSString *_sessionIdUrlStr;
    
    NSString *_sessionIdStr;
    
    int _inputType;
    NSString *_questionStr;
}
@end


@implementation AgentFacade

#pragma mark - LifeCycle

- (id)init {
    self = [super init];
    if (self) {
        [self setupDefaultUrlStr];
    }
    return self;
}

#pragma mark - Command

- (void)connectDiagnosis {
    [self connectToServerWithUrlStr:_diagnosisUrlStr];
}

- (void)connectAllTypes {
    [self connectToServerWithUrlStr:_allTypesUrlStr];
}

- (void)connectAskQuestion:(NSString *)questionStr intputType:(int)inputTypeInt {
    _questionStr = questionStr;
    _inputType = inputTypeInt;
    
    NSString *urlStr = [self getAskQuestionUrlStrWithQuestionStr:questionStr inputType:inputTypeInt];
    NSLog(@"urlStr =%@",urlStr);
    [self connectToServerWithUrlStr:urlStr];
}

- (void)connectAskPolyResults:(NSString *)questionStr intputType:(int)inputTypeInt {
    _questionStr = questionStr;
    _inputType = inputTypeInt;
    
    NSString *urlStr = [self getAskPolyResultsUrlStrWithQuestionStr:questionStr inputType:inputTypeInt];
    NSLog(@"urlStr =%@",urlStr);
    [self connectToServerWithUrlStr:urlStr];
}

- (void)connectSatisficationWithQuestion:(NSString *)questionStr answer:(NSString *)answerStr satisfation:(int)satisfication {
    NSString *urlStr = [self getSatisficationUrlStrWithQuestionStr:questionStr answerStr:answerStr satisfaction:satisfication];
    [self connectToServerWithUrlStr:urlStr];
    
    [[IQLog sharedInstance] logSatisfactionWithSatisfaction:[self getSatisfactionStr:satisfication] question:questionStr answer:answerStr];
}

- (void)connectToServerWithUrlStr:(NSString *)urlStr {
    URLSessionModel *session = [[URLSessionModel alloc] init];
    session.delegate = self;
    
    [session connectToServerWithUrlStr:urlStr];
}

#pragma mark - Delegate

- (void)urlSessionModelDelegateJsonStr:(NSString *)jsonStr urlStr:(NSString *)urlStr {
    if (jsonStr.length == 0 || urlStr.length == 0) {
        NSLog(@"error urlSessionModelDelegateJsonStr:%@ urlStr:%@", jsonStr, urlStr);
        return;
    }
    
    {
        ContentItem *item = [self parseToContentItemWithJsonStr:jsonStr urlStr:urlStr];
        if ([self.delegate respondsToSelector:@selector(agentFacadeDelegateContentItem:)]) {
            [self.delegate agentFacadeDelegateContentItem:item];
        }
        
        if (item.agent.service == Agent_Service_AskQuestion) {
            [[IQLog sharedInstance] logAskQuestionWithInputType:[Agent getInputTypeName:_inputType agent:item.agent] question:item.agent.question answer:item.agent.showContent];
        }
    }
}

- (void)urlSessionModelDelegateInternetOffline {
    if ([self.delegate respondsToSelector:@selector(agentFacadeDelegateInternetOffline)]) {
        [self.delegate agentFacadeDelegateInternetOffline];
    }
}

#pragma mark - Parse

- (ContentItem *)parseToContentItemWithJsonStr:(NSString *)jsonStr urlStr:(NSString *)urlStr {
//    NSLog(@"jsonStr = %@",jsonStr);
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    ContentItem *item = [[ContentItem alloc] init];
    if ([urlStr containsString:_diagnosisUrlStr]) {
        item.agent.service = Agent_Service_Diagnosis;
    }
    else if ([urlStr containsString:_allTypesUrlStr]) {
        item.agent.service = Agent_Service_AllTypes;
    }
    else if (_askQuestionPreUrlStr && [urlStr containsString:_askQuestionPreUrlStr]) {
        item.agent.service = Agent_Service_AskQuestion;
    }
    else if (_askPolyReresultsPreUrlStr && [urlStr containsString:_askPolyReresultsPreUrlStr]) {
        item.agent.service = Agent_Service_AskPolyResults;
        NSLog(@"_askPolyReresultsPreUrlStr && [urlStr containsString:_askPolyReresultsPreUrlStr]");
    }
    else if (_satisfactionPreUrlStr && [urlStr containsString:_satisfactionPreUrlStr]) {
        item.agent.service = Agent_Service_Satisfaction;
    }
    else {
        NSLog(@"error didFinishDownloadingToURL");
    }
    
    switch (item.agent.service) {
        case Agent_Service_Diagnosis:
        {
            //{"Result":"True","ResponseStatus":{}}
            //{"IsSuccess":false,"ResponseStatus":{"ErrorCode":"999","Message":"No AuthKey","StackTrace":""}}
            
            BOOL result = ([[jsonDic objectForKey:@"Result"] isEqualToString:@"True"])? YES : NO;
            
            item.agent.result = result;
        }
            break;
            
        case Agent_Service_AllTypes:
        {
            //{"AllTypes":[{"TypesID":1,"Text":"一般","Sequence":"1"},{"TypesID":2,"Text":"點餐","Sequence":"2"},{"TypesID":3,"Text":"測試(基金)","Sequence":"3"},{"TypesID":4,"Text":"測試(E)","Sequence":"4"},{"TypesID":5,"Text":"測試(M)","Sequence":"5"},{"TypesID":6,"Text":"IDEAs","Sequence":"6"},{"TypesID":7,"Text":"KISS","Sequence":"7"},{"TypesID":8,"Text":"Fuhu","Sequence":"8"},{"TypesID":9,"Text":"FET","Sequence":"9"},{"TypesID":10,"Text":"Gcard","Sequence":"10"},{"TypesID":11,"Text":"工研院","Sequence":"11"}],"SessionID":"a3ffdd4ad7b740b2b1230f90","isSuccess":true,"ResponseStatus":{}}
            
            BOOL isSuccess = [[jsonDic objectForKey:@"isSuccess"] boolValue];
            item.agent.isSuccess = isSuccess;
            
            //if (_sessionIdStr.length == 0) {
                NSString *sessionID = [jsonDic objectForKey:@"SessionID"];
                sessionID = (sessionID.length > 0)? sessionID : @"";
                item.agent.sessionID = sessionID;
                _sessionIdStr = sessionID;
                _sessionIdUrlStr = [NSString stringWithFormat:@"&SessionID=%@",sessionID];
                //                [self saveSessionId:sessionID];
            //}
            
            NSArray *allTypesArray = [jsonDic objectForKey:@"AllTypes"];
            NSMutableArray *allTypesItems = [[NSMutableArray alloc] init];
            for (NSDictionary *allTypesDic in allTypesArray) {
                NSInteger typesID = [[allTypesDic objectForKey:@"TypesID"] integerValue];
                NSString *text = [allTypesDic objectForKey:@"Text"];
                NSInteger sequence = [[allTypesDic objectForKey:@"Sequence"] integerValue];
                
                AllTypesItem *item = [[AllTypesItem alloc] init];
                item.typesID = typesID;
                item.text = (text.length > 0)? text : @"";
                item.sequence = sequence;
                
                [allTypesItems addObject:item];
            }
            
            NSArray *sortedAllTypesItems = [allTypesItems sortedArrayUsingComparator:^NSComparisonResult(AllTypesItem *item1, AllTypesItem *item2){
                return [[NSString stringWithFormat:@"%3d",(int)item1.sequence] compare:[NSString stringWithFormat:@"%3d",(int)item2.sequence]];
            }];
            item.agent.allTypesArray = sortedAllTypesItems;
        }
            break;
            
        case Agent_Service_AskQuestion:
        {
            //{"IsSuccess":true,"SpeakContent":"你好!","ShowContent":"你好!","ResponseStatus":{}}
            //{"IsSuccess":false,"ResponseStatus":{"ErrorCode":"999","Message":"No AuthKey","StackTrace":""}}
            
            NSString *speakContent = [jsonDic objectForKey:@"SpeakContent"];
            speakContent = (speakContent.length > 0)? speakContent : @"";
            
            speakContent = [[IQSetting sharedInstance] convertUserNameBySettingWithStr:speakContent];
            NSAttributedString *speakContentAttrStr = [[NSAttributedString alloc] initWithData:[speakContent dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            NSString *showContent = [jsonDic objectForKey:@"ShowContent"];
            showContent = (speakContent.length > 0)? speakContent : @"";
            showContent = [[IQSetting sharedInstance] convertUserNameBySettingWithStr:showContent];
            NSAttributedString *showContentAttrStr = [[NSAttributedString alloc] initWithData:[showContent dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            BOOL isSuccess = [[jsonDic objectForKey:@"IsSuccess"] boolValue];
            speakContent = speakContentAttrStr.string;
            showContent = showContentAttrStr.string;
            NSString *emotion = [jsonDic objectForKey:@"Emotion"];
            NSString *url = [jsonDic objectForKey:@"Url"];
            
            item.agent.isSuccess = isSuccess;
            item.agent.question = _questionStr;
            item.agent.speakContent = (speakContent.length > 0)? speakContent : @"";
            item.agent.showContent = (showContent.length > 0)? showContent : @"";
            item.agent.emotion = (emotion.length > 0)? emotion : @"";
            item.agent.url = (url.length > 0)? url : @"";
            item.agent.inputType = _inputType;
            item.recipient.from = Message_From_Other;
            item.message.attachment.type = Message_Type_Text;
            item.message.text = showContent;
            
            if ([showContent containsString:@"班次"]) {
                [self parseToContentItemWithTrainJsonStr:showContent contentItem:item];
            }
            if ([speakContent containsString:@"班次"]) {
                NSArray *trainStrs = [speakContent componentsSeparatedByString:@"："];
                
                if (trainStrs.count >= 1) {
                    NSString *speakContent = [trainStrs firstObject];
                    item.agent.speakContent = speakContent;
                }
            }
            
//            {"IsSuccess":true,"SpeakContent":"你好阿！","ShowContent":"你好阿！","ResponseStatus":{}};
//            
//            NSString *j = {"recipient":{"id":"USER_ID"},"message":{"attachment":{"type":"template","payload":{"template_type":"generic","elements":[{"title":"Welcome to Peter\'s Hats","item_url":"https://petersfancybrownhats.com","image_url":"https://petersfancybrownhats.com/company_image.png","subtitle":"We\'ve got the right hat for everyone.","buttons":[{"type":"web_url","url":"https://petersfancybrownhats.com","title":"View Website"},{"type":"postback","title":"Start Chatting","payload":"DEVELOPER_DEFINED_PAYLOAD"}]}]}}}};
        }
            break;
            
        case Agent_Service_AskPolyResults:
        {
            //{"PolyResultType":"Generic","OtherRelatedResults":[{"Index":1,"Title":"從新竹到高雄最接近的列車如下","SubTitle":"日期:2017/01/09 第1頁","Items":[{"Title":"16:10:00-19:54:00 自強號","Action":"Url","Data":"http://twtraffic.tra.gov.tw/twrail/SearchResultContent.aspx?searchdate=2017/01/09&traincode=135&fromstation=115&tostation=185"},{"Title":"18:10:00-21:51:00 自強號","Action":"Url","Data":"http://twtraffic.tra.gov.tw/twrail/SearchResultContent.aspx?searchdate=2017/01/09&traincode=139&fromstation=115&tostation=185"},{"Title":"18:40:00-22:19:00 自強號","Action":"Url","Data":"http://twtraffic.tra.gov.tw/twrail/SearchResultContent.aspx?searchdate=2017/01/09&traincode=141&fromstation=115&tostation=185"}]}],"IsSuccess":true,"SpeakContent":"從新竹到高雄最接近的列車為：16:10:00~19:54:00 自強號","ShowContent":"從新竹到高雄最接近的列車為：16:10:00~19:54:00 自強號","ResponseStatus":{}}
            
            NSString *speakContent = [jsonDic objectForKey:@"SpeakContent"];
            speakContent = (speakContent.length > 0)? speakContent : @"";
            
            speakContent = [[IQSetting sharedInstance] convertUserNameBySettingWithStr:speakContent];
            NSAttributedString *speakContentAttrStr = [[NSAttributedString alloc] initWithData:[speakContent dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            NSString *showContent = [jsonDic objectForKey:@"ShowContent"];
            showContent = (speakContent.length > 0)? speakContent : @"";
            showContent = [[IQSetting sharedInstance] convertUserNameBySettingWithStr:showContent];
            NSAttributedString *showContentAttrStr = [[NSAttributedString alloc] initWithData:[showContent dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            BOOL isSuccess = [[jsonDic objectForKey:@"IsSuccess"] boolValue];
            speakContent = speakContentAttrStr.string;
            showContent = showContentAttrStr.string;
            NSString *emotion = [jsonDic objectForKey:@"Emotion"];
            NSString *url = [jsonDic objectForKey:@"Url"];
            
            item.agent.isSuccess = isSuccess;
            item.agent.question = _questionStr;
            item.agent.speakContent = (speakContent.length > 0)? speakContent : @"";
            item.agent.showContent = (showContent.length > 0)? showContent : @"";
            item.agent.emotion = (emotion.length > 0)? emotion : @"";
            item.agent.url = (url.length > 0)? url : @"";
            item.agent.inputType = _inputType;
            item.recipient.from = Message_From_Other;
            item.message.attachment.type = Message_Type_Text;
            item.message.text = showContent;
            
            NSString *polyResultType = [jsonDic objectForKey:@"PolyResultType"];
            
            NSString *otherRelatedResults = [jsonDic objectForKey:@"OtherRelatedResults"];
            
            [self parseToContentItemWithPolyResultType:polyResultType otherRelatedResults:otherRelatedResults contentItem:item];
        }
            break;
            
        case Agent_Service_Satisfaction:
        {
            //{"IsSuccess":true,"ResponseStatus":{}}
            //{"IsSuccess":false,"ResponseStatus":{"ErrorCode":"999","Message":"No AuthKey","StackTrace":""}}
            
            BOOL isSuccess = [[jsonDic objectForKey:@"IsSuccess"] boolValue];
            
            item.agent.isSuccess = isSuccess;
        }
            break;
            
        default:
            NSLog(@"error parseWithJsonStr");
            break;
    }
    
    NSDictionary *responseStatusDic = [jsonDic objectForKey:@"ResponseStatus"];
    if (responseStatusDic.count > 0) {
        NSString *errorCode = [responseStatusDic objectForKey:@"ErrorCode"];
        NSString *message = [responseStatusDic objectForKey:@"Message"];
        NSString *stackTrace = [responseStatusDic objectForKey:@"StackTrace"];
        
        item.agent.responseStatusItem = [[ResponseStatusItem alloc] init];
        item.agent.responseStatusItem.errorCode = (errorCode.length > 0)? errorCode : @"";
        item.agent.responseStatusItem.message = (message.length > 0)? message : @"";
        item.agent.responseStatusItem.stackTrace = (stackTrace.length > 0)? stackTrace : @"";
    }
    
    /*
     NSLog(@"result = %d", item.result);
     NSLog(@"isSuccess = %d", item.isSuccess);
     NSLog(@"sessionID = %@", item.sessionID);
     NSLog(@"speakContent = %@", item.speakContent);
     NSLog(@"showContent = %@", item.showContent);
     NSLog(@"emotion = %@", item.emotion);
     NSLog(@"url = %@", item.url);
     NSLog(@"type = %d", (int)item.type);
     
     if (item.responseStatusItem) {
     NSLog(@"errorCode = %@", item.responseStatusItem.errorCode);
     NSLog(@"errorMessage = %@", item.responseStatusItem.message);
     NSLog(@"errorStackTrace = %@", item.responseStatusItem.stackTrace);
     }
     
     for (int i=0; i<[item.allTypesArray count]; i++) {
     AllTypesItem *allTypesItem = [item.allTypesArray objectAtIndex:i];
     NSLog(@"allTypesTypesID = %d", (int)allTypesItem.typesID);
     NSLog(@"allTypesText = %@", allTypesItem.text);
     NSLog(@"allTypesSequence = %d", (int)allTypesItem.sequence);
     }
     */
    
    return item;
}

- (ContentItem *)parseToContentItemWithTrainJsonStr:(NSString *)trainJsonStr contentItem:(ContentItem *)item {
    item.message.attachment.type = Message_Type_Template;
    item.message.attachment.payload.template_type = Template_Type_Button;
    
    NSArray *trainStrs = [trainJsonStr componentsSeparatedByString:@"："];
    
    NSString *contentStr = [trainStrs firstObject];
//    NSLog(@"[trainStrs firstObject] = %@",[trainStrs firstObject]);
    item.agent.showContent = contentStr;
    item.message.text = contentStr;
    
    NSArray *stations = [contentStr componentsSeparatedByString:@"【"];
    NSString *fromStation = [[[stations objectAtIndex:1] componentsSeparatedByString:@"】"] firstObject];
    NSString *toStation = [[[stations lastObject] componentsSeparatedByString:@"】"] firstObject];
    NSString *fromStationNumber = [self convertToSationNumberWithStationName:fromStation];
    NSString *toStationNumber = [self convertToSationNumberWithStationName:toStation];
//    NSLog(@"fromStation = %@, number = %@",fromStation, fromStationNumber);
//    NSLog(@"toStation = %@, number = %@", toStation, toStationNumber);
    
    NSString *json = [trainStrs lastObject];
//    NSLog(@"trainJson = %@",json);
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];//options:NSJSONReadingMutableContainers
    
//    NSLog(@"jsonArray = %@",jsonArray);
//    NSLog(@"jsonArray.count = %d",(int)jsonArray.count);
    
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    
    for (int i=0; i<jsonArray.count; i+=3) {
        Element *element = [[Element alloc] init];
        element.image_url = @"";
        element.title = contentStr;
        NSDictionary *dic = [jsonArray objectAtIndex:i];
        NSString *date = [dic objectForKey:@"Date"];
        element.subtitle = [NSString stringWithFormat:@"日期:%@ 第%d頁", date, (i/3)+1];
        element.item_url = @"";
        
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        
        for (int j=i; j<i+3 && j<jsonArray.count; j++) {
            ButtonItem *button = [[ButtonItem alloc] init];
            
            NSDictionary *dic = [jsonArray objectAtIndex:j];
            NSString *date = [dic objectForKey:@"Date"];
            NSString *delay = [dic objectForKey:@"Delay"];
            delay = ([delay isKindOfClass:[NSNull class]] || delay.length == 0)? @"" : delay;
//            NSString *delayUpdate = [dic objectForKey:@"DelayUpdate"];
//            delayUpdate = ([delayUpdate isKindOfClass:[NSNull class]] || delayUpdate.length == 0)? @"" : delayUpdate;
            NSString *arrivalTime = [dic objectForKey:@"ArrivalTime"];
            NSString *departureTime = [dic objectForKey:@"DepartureTime"];
            NSString *trainClassification = [dic objectForKey:@"TrainClassification"];
            NSString *trainNum = [dic objectForKey:@"TrainNum"];
            
            NSString *url = [NSString stringWithFormat:
                             @"http://twtraffic.tra.gov.tw/twrail/SearchResultContent.aspx?searchdate=%@&traincode=%@&fromstation=%@&tostation=%@",
                             date, trainNum, fromStationNumber, toStationNumber];
            
            button.type = Button_Type_WebUrl;
            button.url = url;
            
            NSString *title = [NSString stringWithFormat:@"%@-%@ %@ ", departureTime, arrivalTime, trainClassification];
            title = [NSString stringWithFormat:@"%@ %@", title, delay];
            NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title];
            
            if (delay.length == 0) {
                [attributedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.035 green:0.467 blue:0.949 alpha:1.00] range:NSMakeRange(0,title.length)];
            }
            else {
                [attributedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.035 green:0.467 blue:0.949 alpha:1.00] range:NSMakeRange(0,title.length - delay.length)];
                [attributedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(title.length - delay.length, delay.length)];
            }
            button.attributedTitle = attributedTitle;
            
            [buttons addObject:button];
        }
        
        element.buttons = buttons;
        [elements addObject:element];
    }
    
    item.message.attachment.payload.elements = elements;
    
//    for (Element *element in elements) {
//        NSLog(@"element.title = %@",element.title);
//        NSLog(@"element.subtitle = %@",element.subtitle);
//        NSLog(@"element.buttons.count = %d",(int)element.buttons.count);
//        for (Button *button in element.buttons) {
//            NSLog(@"button.title = %@",button.title);
//            NSLog(@"button.url = %@",button.url);
//        }
//    }
    
    return item;
}

//處理火車的JSON字串
- (ContentItem *)parseToContentItemWithPolyResultType:(NSString *)polyResultType otherRelatedResults:(NSString *)otherRelatedResults contentItem:(ContentItem *)item {
    
    /*
     {"PolyResultType":"Generic",
     "OtherRelatedResults":[
     {"Index":1,"Title":"從新竹到高雄最接近的列車如下",
     "SubTitle":"日期:2017/01/09 第1頁",
     "ImgUrl":"https://iqagent.iq-t.com/FacebookTrainWebhook/TRA.jpg",
     "Items":[
     {"Title":"16:10:00-19:54:00 自強號","Action":"Url","Data":"http://twtraffic.tra.gov.tw/twrail/SearchResultContent.aspx?searchdate=2017/01/09&traincode=135&fromstation=115&tostation=185"},
     {"Title":"18:10:00-21:51:00 自強號","Action":"Url","Data":"http://twtraffic.tra.gov.tw/twrail/SearchResultContent.aspx?searchdate=2017/01/09&traincode=139&fromstation=115&tostation=185"},
     {"Title":"18:40:00-22:19:00 自強號","Action":"Url","Data":"http://twtraffic.tra.gov.tw/twrail/SearchResultContent.aspx?searchdate=2017/01/09&traincode=141&fromstation=115&tostation=185"}]}],
     "IsSuccess":true,"SpeakContent":"從新竹到高雄最接近的列車為：16:10:00~19:54:00 自強號",
     "ShowContent":"從新竹到高雄最接近的列車為：16:10:00~19:54:00 自強號","ResponseStatus":{}}
     */
    
     //NSLog(@"otherRelatedResults = %@",otherRelatedResults);
    
    if ([polyResultType isEqualToString:@"Generic"]) {
        item.message.attachment.type = Message_Type_Template;
        item.message.attachment.payload.template_type = Template_Type_Button;
        
        NSArray *jsonArray = (NSArray *)otherRelatedResults;
        
        NSMutableArray *elements = [[NSMutableArray alloc] init];
        
        for (int i=0; i<jsonArray.count; i++) {
            NSDictionary *dic = [jsonArray objectAtIndex:i];
            
            Element *element = [[Element alloc] init];
            element.image_url = [dic objectForKey:@"ImgUrl"];
            element.index = [[dic objectForKey:@"Index"] integerValue];
            element.title = [dic objectForKey:@"Title"];
            element.subtitle = [dic objectForKey:@"SubTitle"];
            
            NSMutableArray *buttons = [[NSMutableArray alloc] init];
            
            NSString *buttonStr = [dic objectForKey:@"Items"];
            NSArray *buttonArray = (NSArray *)buttonStr;
            
            for (int j=0; j< buttonArray.count; j++) {
                ButtonItem *button = [[ButtonItem alloc] init];
                
                NSDictionary *dic = [buttonArray objectAtIndex:j];
//                {"Title":"16:10:00-19:54:00 自強號","Action":"Url","Data":"http://twtraffic.tra.gov.tw/twrail/SearchResultContent.aspx?searchdate=2017/01/09&traincode=135&fromstation=115&tostation=185"},
                
                NSString *title = [dic objectForKey:@"Title"];
                NSString *action = [dic objectForKey:@"Action"];
                NSString *data = [dic objectForKey:@"Data"];
                
                button.title = title;
                
                if ([action isEqualToString:@"Url"]) {
                    button.type = Button_Type_WebUrl;
                    button.url = data;
                }
                
                /*
                NSString *title = [NSString stringWithFormat:@"%@-%@ %@ ", departureTime, arrivalTime, trainClassification];
                title = [NSString stringWithFormat:@"%@ %@", title, delay];
                NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title];
                
                if (delay.length == 0) {
                    [attributedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.035 green:0.467 blue:0.949 alpha:1.00] range:NSMakeRange(0,title.length)];
                }
                else {
                    [attributedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.035 green:0.467 blue:0.949 alpha:1.00] range:NSMakeRange(0,title.length - delay.length)];
                    [attributedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(title.length - delay.length, delay.length)];
                }
                button.attributedTitle = attributedTitle;
                */
                
                [buttons addObject:button];
            }
            
            element.buttons = buttons;
            [elements addObject:element];
        }
        
        item.message.attachment.payload.elements = elements;
    }
    
//    for (Element *element in item.message.attachment.payload.elements) {
//        NSLog(@"element.title = %@",element.title);
//        NSLog(@"element.subtitle = %@",element.subtitle);
//        NSLog(@"element.buttons.count = %d",(int)element.buttons.count);
//        for (ButtonItem *button in element.buttons) {
//            NSLog(@"button.title = %@",button.title);
//            NSLog(@"button.url = %@",button.url);
//        }
//    }
    
    return item;
}

#pragma mark Info

- (NSString *)convertToSationNumberWithStationName:(NSString *)stationName  {
    NSDictionary *stationDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"4",@"臺東",
                                @"4",@"台東",
                                @"8",@"鹿野",
                                @"9",@"瑞源",
                                @"10",@"瑞和",
                                @"12",@"關山",
                                @"15",@"池上",
                                @"18",@"富里",
                                @"20",@"東竹",
                                @"22",@"東里",
                                @"25",@"玉里",
                                @"29",@"瑞穗",
                                @"31",@"富源",
                                @"34",@"光復",
                                @"35",@"萬榮",
                                @"36",@"鳳林",
                                @"40",@"豐田",
                                @"41",@"壽豐",
                                @"43",@"志學",
                                @"45",@"吉安",
                                @"51",@"花蓮",
                                @"52",@"北埔",
                                @"54",@"新城",
                                @"57",@"和平",
                                @"62",@"南澳",
                                @"63",@"東澳",
                                @"66",@"蘇澳",
                                @"67",@"蘇澳新",
                                @"69",@"冬山",
                                @"70",@"羅東",
                                @"73",@"宜蘭",
                                @"75",@"礁溪",
                                @"77",@"頭城",
                                @"83",@"福隆",
                                @"84",@"貢寮",
                                @"85",@"雙溪",
                                @"88",@"猴硐",
                                @"89",@"瑞芳",
                                @"92",@"基隆",
                                @"93",@"八堵",
                                @"94",@"七堵",
                                @"96",@"汐止",
                                @"97",@"南港",
                                @"98",@"松山",
                                @"100",@"臺北",
                                @"100",@"台北",
                                @"101",@"萬華",
                                @"102",@"板橋",
                                @"103",@"樹林",
                                @"121",@"後龍",
                                @"123",@"白沙屯",
                                @"125",@"通霄",
                                @"126",@"苑裡",
                                @"128",@"大甲",
                                @"130",@"清水",
                                @"131",@"沙鹿",
                                @"133",@"大肚",
                                @"105",@"鶯歌",
                                @"106",@"桃園",
                                @"108",@"中壢",
                                @"110",@"楊梅",
                                @"112",@"湖口",
                                @"113",@"新豐",
                                @"114",@"竹北",
                                @"115",@"新竹",
                                @"118",@"竹南",
                                @"163",@"嘉義",
                                @"137",@"苗栗",
                                @"139",@"銅鑼",
                                @"140",@"三義",
                                @"143",@"后里",
                                @"144",@"豐原",
                                @"145",@"潭子",
                                @"146",@"臺中",
                                @"146",@"台中",
                                @"280",@"新烏日",
                                @"149",@"彰化",
                                @"151",@"員林",
                                @"153",@"社頭",
                                @"154",@"田中",
                                @"155",@"二水",
                                @"156",@"林內",
                                @"158",@"斗六",
                                @"159",@"斗南",
                                @"161",@"大林",
                                @"162",@"民雄",
                                @"203",@"枋寮",
                                @"167",@"新營",
                                @"170",@"隆田",
                                @"172",@"善化",
                                @"173",@"新市",
                                @"174",@"永康",
                                @"175",@"臺南",
                                @"175",@"台南",
                                @"178",@"大湖",
                                @"179",@"路竹",
                                @"180",@"岡山",
                                @"183",@"楠梓",
                                @"288",@"新左營",
                                @"185",@"高雄",
                                @"186",@"鳳山",
                                @"188",@"九曲堂",
                                @"190",@"屏東",
                                @"195",@"潮州",
                                @"197",@"南州",
                                @"199",@"林邊",
                                @"211",@"大武",
                                @"213",@"瀧溪",
                                @"215",@"金崙",
                                @"217",@"太麻里",
                                @"219",@"知本",
                                @"220",@"康樂",
                                nil];
    return [stationDic objectForKey:stationName];
}

#pragma mark - Factory

- (void)setupDefaultUrlStr {
    BOOL isDevelopMode = NO;
    _serverUrlStr = isDevelopMode? @"http://192.168.1.145:57000/BotWebService.ashx/" : @"http://bot.iq-t.com/BotWebService.ashx/json/syncreply/";
    _authKeyUrlStr = [NSString stringWithFormat:@"&authKey=%@",@"0CA13AA82094411E9D52"];
    _diagnosisUrlStr = [self getDiagnosisUrlStr];
    _allTypesUrlStr = [self getAllTypesUrlStr];
    
    //    if ([self isSessionIdExist]) {
    //        _sessionIdStr = [self getSessionId];
    //        _sessionIdUrlStr = [NSString stringWithFormat:@"&SessionID=%@",_sessionIdStr];
    //    }
}

- (NSString *)getDiagnosisUrlStr {
    //http://bot.iq-t.com/BotWebService.ashx/json/syncreply/Diagnosis?command=ping&authKey=8A2DA05455775E8987
    
    NSString *diagnosis = [NSString stringWithFormat:@"%@?",@"Diagnosis"];
    NSString *command = [NSString stringWithFormat:@"command=%@",@"ping"];
    _diagnosisUrlStr = [NSString stringWithFormat:@"%@%@%@%@", _serverUrlStr, diagnosis, command, _authKeyUrlStr];
    //NSLog(@"diagnosisUrlStr = %@",_diagnosisUrlStr);
    return _diagnosisUrlStr;
}

- (NSString *)getAllTypesUrlStr {
    //http://bot.iq-t.com/BotWebService.ashx/json/syncreply/AllTypes?FromAPP=1&authKey=8A2DA05455775E8987
    
    NSString *allTypes = [NSString stringWithFormat:@"AllTypes?"];
    NSString *fromApp = [NSString stringWithFormat:@"FromAPP=%d",1];
    _allTypesUrlStr = [NSString stringWithFormat:@"%@%@%@%@", _serverUrlStr, allTypes, fromApp, _authKeyUrlStr];
    //NSLog(@"allTypesUrlStr = %@",_allTypesUrlStr);
    return _allTypesUrlStr;
}

- (NSString *)getAskQuestionUrlStrWithQuestionStr:(NSString *)questionStr inputType:(int)inputTypeInt {
    //http://bot.iq-t.com/BotWebService.ashx/json/syncreply/AskQuestion?ComputerName=Yong-Computer&InputType=0&IPAddress=192.168.1.93&SessionID=f1914617e2d942ec9b61080b&authKey=8A2DA05455775E8987&Text=你好
    
    //AskQuestion
    NSString *askQuestion = [NSString stringWithFormat:@"%@?",@"AskQuestion"];
    NSString *computerName = [NSString stringWithFormat:@"%@=%@",@"ComputerName",[self getPercentEncodingText:[IQCommonTool getDeviceName]]];
    NSString *inputType = [NSString stringWithFormat:@"&%@=%d", @"InputType", inputTypeInt];
    NSString *ipAddress = [NSString stringWithFormat:@"&%@=%@",@"IPAddress",[IQCommonTool getIPAddress]];
    NSString *question = [NSString stringWithFormat:@"&%@=%@",@"Text",[self  getPercentEncodingText:questionStr]];
    _askQuestionPreUrlStr = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", _serverUrlStr, askQuestion, computerName, inputType, ipAddress, _sessionIdUrlStr, _authKeyUrlStr];
    NSString *askQuestionUrlStr = [NSString stringWithFormat:@"%@%@", _askQuestionPreUrlStr, question];
    //NSLog(@"askQuestionUrlStr = %@",askQuestionUrlStr);
    return askQuestionUrlStr;
}

- (NSString *)getAskPolyResultsUrlStrWithQuestionStr:(NSString *)questionStr inputType:(int)inputTypeInt {
    // http://bot.iq-t.com/BotWebService.ashx/json/syncreply/AskPolyResults?ComputerName=Yong-Computer&InputType=0&IPAddress=192.168.1.93&SessionID=f1914617e2d942ec9b61080b&Text=台北到高雄&authKey=8A2DA05455775E8987
    
    //AskQuestion
    NSString *askPolyResults = [NSString stringWithFormat:@"%@?",@"AskPolyResults"];
    NSString *computerName = [NSString stringWithFormat:@"%@=%@",@"ComputerName",[self getPercentEncodingText:[IQCommonTool getDeviceName]]];
    NSString *inputType = [NSString stringWithFormat:@"&%@=%d", @"InputType", inputTypeInt];
    NSString *ipAddress = [NSString stringWithFormat:@"&%@=%@",@"IPAddress",[IQCommonTool getIPAddress]];
    NSString *question = [NSString stringWithFormat:@"&%@=%@",@"Text",[self  getPercentEncodingText:questionStr]];
    _askPolyReresultsPreUrlStr = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", _serverUrlStr, askPolyResults, computerName, inputType, ipAddress, _sessionIdUrlStr, _authKeyUrlStr];
    NSString *askQuestionUrlStr = [NSString stringWithFormat:@"%@%@", _askPolyReresultsPreUrlStr, question];
    //NSLog(@"askQuestionUrlStr = %@",askQuestionUrlStr);
    return askQuestionUrlStr;
}

- (NSString *)getSatisficationUrlStrWithQuestionStr:(NSString *)questionStr answerStr:(NSString *)answerStr satisfaction:(int)satisfactionInt {
    //http://bot.iq-t.com/BotWebService.ashx/json/syncreply/Satisfaction?&SessionID=f1914617e2d942ec9b61080b&authKey=8A2DA05455775E8987&Question=你好&Answer=你好!&Satification=SurveyGood
    
    //Satisfaction
    NSString *satisfaction = [NSString stringWithFormat:@"%@?",@"Satisfaction"];
    NSString *question = [NSString stringWithFormat:@"&%@=%@",@"Question",[self getPercentEncodingText:questionStr]];
    NSString *answer = [NSString stringWithFormat:@"&%@=%@",@"Answer",[self getPercentEncodingText:answerStr]];
    NSString *satisfStr = [self getSatisfactionStr:satisfactionInt];
    NSString *satisf = [NSString stringWithFormat:@"&%@=%@",@"Satisfaction",satisfStr];
    _satisfactionPreUrlStr = [NSString stringWithFormat:@"%@%@%@%@", _serverUrlStr, satisfaction, _sessionIdUrlStr, _authKeyUrlStr];
    NSString *satisfationUrlStr = [NSString stringWithFormat:@"%@%@%@%@", _satisfactionPreUrlStr, question, answer, satisf];
    //NSLog(@"satisfationUrlStr = %@",satisfationUrlStr);
    return satisfationUrlStr;
}

#pragma mark SessionID

- (BOOL)isSessionIdExist {
    BOOL isExist = ([self getSessionId])? YES : NO;
    return isExist;
}

- (NSString *)getSessionId {
    NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_SESSION_ID];
    return sessionId;
}

- (void)saveSessionId:(NSString *)sessionId {
    if (sessionId.length == 0) {
        NSLog(@"error saveSessionId = %@",sessionId);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:sessionId forKey:USERDEFAULTS_SESSION_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Info

- (NSString *)getSatisfactionStr:(int)satisfactionInt {
    switch (satisfactionInt) {
        case 1:  return @"SurveyGood";
        case 0:
        default: return @"SurveyBad";
    }
}

- (NSString *)getPercentEncodingText:(NSString *)text {
    text = (text.length > 0)? text : @"";
    text = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return text;
}

- (BOOL)isGotNecessaryData {
    if (_sessionIdStr.length > 0) {
        return YES;
    }
    return NO;
}

@end
