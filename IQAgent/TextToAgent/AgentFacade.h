//
//  AgentFacade.h
//  IQAgent
//
//  Created by IanFan on 2016/9/19.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 IQT Bot REST Service 說明文件
 
 開發線位置：http://192.168.1.145:57000/BotWebService.ashx
 產品線位置：http://bot.iq-t.com/BotWebService.ashx
 
 3. Diagnosis 服務說明：確認雲端目前連線狀態
 http://bot.iq-t.com/BotWebService.ashx/json/syncreply/Diagnosis?command=ping&authKey=8A2DA05455775E8987
 authKey: 8A2DA05455775E8987
 Command: Ping
 
 {"Result":"True","ResponseStatus":{}}
 Result: True代表可以連線。False代表無法連線。
 ResponseStatus: 偵錯用，可以忽略
 
 4.	AllTypes 服務說明：取得目前所有問答類型及提供SessionID
 http://bot.iq-t.com/BotWebService.ashx/json/syncreply/AllTypes?FromAPP=0&authKey=8A2DA05455775E8987
 authKey: 8A2DA05455775E8987
 FromAPP: 若來自APP端，設為True。1
 
 {"AllTypes":[{"TypesID":1,"Text":"一般","Sequence":"1"},{"TypesID":2,"Text":"點餐","Sequence":"2"}],"SessionID":"f1914617e2d942ec9b61080b","isSuccess":true,"ResponseStatus":{}}
 isSuccess: true成功取得資料。false代表有狀況。
 AllTypes: 集合物件QuestionCommand: Sequence:顯示的排序，1。Text:顯示文字，一般。TypesID:問題類型的索引值，在AskQuestion提供此ID代表要使用指定的問答類型。1
 SessionID: Server產生用來辨識用戶的辨識碼。f1914617e2d942ec9b61080b
 ResponseStatus: 偵錯用，可以忽略
 
 5.	AskQuestion服務說明：問答服務。 用戶可設定問答類型。問答類型來自AllTypes 提供
 http://bot.iq-t.com/BotWebService.ashx/json/syncreply/AskQuestion?ComputerName=Yong-Computer&InputType=0&IPAddress=192.168.1.93&SessionID=f1914617e2d942ec9b61080b&Text=你好&authKey=8A2DA05455775E8987
 authKey: 8A2DA05455775E8987
 ComputerName: 用戶電腦名稱。Yong-Computer
 InputType:本數值來自AllTypes指定類型的TypesID。如沒有指定類型，則設定為0。0
 IPAddress:用戶電腦IP。192.168.1.93
 SessionID:用戶識別碼。f1914617e2d942ec9b61080b
 Text:使用者提問。你好
 
 {"IsSuccess":true,"SpeakContent":"你好!","ShowContent":"你好!","ResponseStatus":{}}
 IsSuccess:True成功取得資料。 False代表有狀況。
 ShowContent:服務提供的答案，用以顯示。你好!
 SpeakContent:服務提供的答案，用以朗讀。你好!
 ResponseStatus:偵錯用，可以忽略
 
 6.	Satisfaction服務說明：滿意度結果回傳。目前提供「滿意」或「不滿意」
 http://bot.iq-t.com/BotWebService.ashx/json/syncreply/Satisfaction?&SessionID=f1914617e2d942ec9b61080b&Question=你好&Satification=SurveyGood&Answer=你好!&authKey=8A2DA05455775E8987
 authKey: 8A2DA05455775E8987
 Question:使用者提問。你好
 Answer: 服務提供的答案。以ShowContent為基準。你好!
 Satification: SurveyBad 代表不滿意。SurveyGood代表滿意
 SessionID: 用戶識別碼。f1914617e2d942ec9b61080b
 
 {"IsSuccess":true,"ResponseStatus":{}}
 IsSuccess:布林。判斷是否成功。True成功取得資料。 False代表有狀況。
 ResponseStatus:偵錯用，可以忽略
 
 7.AskPolyResults服務說明：問機器人問題，回答包含列表
 http://bot.iq-t.com/BotWebService.ashx/json/syncreply/AskPolyResults?ComputerName=Yong-Computer&InputType=0&IPAddress=192.168.1.93&SessionID=f1914617e2d942ec9b61080b&Text=台北到高雄&authKey=8A2DA05455775E8987
 authKey: 8A2DA05455775E8987
 ComputerName: 用戶電腦名稱。Yong-Computer
 InputType:本數值來自AllTypes指定類型的TypesID。如沒有指定類型，則設定為0。0
 IPAddress:用戶電腦IP。192.168.1.93
 SessionID:用戶識別碼。f1914617e2d942ec9b61080b
 Text:使用者提問。你好
 
 {"PolyResultType":"Generic","OtherRelatedResults":[{"Index":1,"Title":"從新竹到高雄最接近的列車如下","SubTitle":"日期:2017/01/09 第1頁","Items":[{"Title":"16:10:00-19:54:00 自強號","Action":"Url","Data":"http://twtraffic.tra.gov.tw/twrail/SearchResultContent.aspx?searchdate=2017/01/09&traincode=135&fromstation=115&tostation=185"},{"Title":"18:10:00-21:51:00 自強號","Action":"Url","Data":"http://twtraffic.tra.gov.tw/twrail/SearchResultContent.aspx?searchdate=2017/01/09&traincode=139&fromstation=115&tostation=185"},{"Title":"18:40:00-22:19:00 自強號","Action":"Url","Data":"http://twtraffic.tra.gov.tw/twrail/SearchResultContent.aspx?searchdate=2017/01/09&traincode=141&fromstation=115&tostation=185"}]}],"IsSuccess":true,"SpeakContent":"從新竹到高雄最接近的列車為：16:10:00~19:54:00 自強號","ShowContent":"從新竹到高雄最接近的列車為：16:10:00~19:54:00 自強號","ResponseStatus":{}}
 */

typedef NS_ENUM(NSInteger, Agent_Service) {
    Agent_Service_None           = 0,
    Agent_Service_Diagnosis         ,
    Agent_Service_AllTypes          ,
    Agent_Service_AskQuestion       ,
    Agent_Service_AskPolyResults    ,
    Agent_Service_Satisfaction      ,
};

@protocol AgentFacadeDelegate;

@interface AgentFacade : NSObject
@property (assign, nonatomic) id<AgentFacadeDelegate> delegate;
//Command
- (void)connectDiagnosis;//是否連線正常
- (void)connectAllTypes;//取得基本資訊：聊天類型、SessionID
- (void)connectAskQuestion:(NSString *)questionStr intputType:(int)inputTypeInt;//傳文字給電腦人
- (void)connectAskPolyResults:(NSString *)questionStr intputType:(int)inputTypeInt;//傳文字給電腦人，回的內容可能有列表
- (void)connectSatisficationWithQuestion:(NSString *)questionStr answer:(NSString *)answerStr satisfation:(int)satisfication;//滿意度
//Info
- (BOOL)isGotNecessaryData;//是否取得基本資訊：SessionID
@end

@protocol AgentFacadeDelegate <NSObject>
- (void)agentFacadeDelegateContentItem:(ContentItem *)item;//電腦人回傳的item
- (void)agentFacadeDelegateInternetOffline;
@end
