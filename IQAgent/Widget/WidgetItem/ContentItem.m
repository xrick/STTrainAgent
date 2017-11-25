//
//  ContentItem.m
//  IQAgent
//
//  Created by IanFan on 2016/12/6.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "ContentItem.h"
#import "NSDate+Utils.h"

@implementation ButtonItem
-(id)init {
    if (self = [super init]) {
    }
    return self;
}
@end

@implementation Element
-(id)init {
    if (self = [super init]) {
        self.buttons = [[NSMutableArray alloc] init];
    }
    return self;
}
@end

@implementation Payload
-(id)init {
    if (self = [super init]) {
        self.elements = [[NSMutableArray alloc] init];
    }
    return self;
}
@end

@implementation Attachment
-(id)init {
    if (self = [super init]) {
        self.payload = [[Payload alloc] init];
    }
    return self;
}
@end

@implementation Message
-(id)init {
    if (self = [super init]) {
        self.attachment = [[Attachment alloc] init];
    }
    return self;
}
@end

@implementation Recipient
-(id)init {
    if (self = [super init]) {
    }
    return self;
}
@end

@implementation AllTypesItem
@synthesize typesID;
@synthesize text;
@synthesize sequence;

+ (AllTypesItem *)copyItem:(AllTypesItem *)item; {
    AllTypesItem *copyItem = [[AllTypesItem alloc] init];
    copyItem.typesID = item.typesID;
    copyItem.text = item.text;
    copyItem.sequence = item.sequence;
    return copyItem;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInteger:typesID] forKey:@"typesID"];
    [aCoder encodeObject:text forKey:@"text"];
    [aCoder encodeObject:[NSNumber numberWithInteger:sequence] forKey:@"sequence"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.typesID = [[aDecoder decodeObjectForKey:@"typesID"] integerValue];
        self.text = [aDecoder decodeObjectForKey:@"text"];
        self.sequence = [[aDecoder decodeObjectForKey:@"sequence"] integerValue];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        text = @"";
    }
    return self;
}

@end


@implementation ResponseStatusItem
@synthesize errorCode;
@synthesize message;
@synthesize stackTrace;

+ (ResponseStatusItem *)copyItem:(ResponseStatusItem *)item; {
    ResponseStatusItem *copyItem = [[ResponseStatusItem alloc] init];
    copyItem.errorCode = item.errorCode;
    copyItem.message = item.message;
    copyItem.stackTrace = item.stackTrace;
    return copyItem;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:errorCode forKey:@"errorCode"];
    [aCoder encodeObject:message forKey:@"message"];
    [aCoder encodeObject:stackTrace forKey:@"stackTrace"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.errorCode = [aDecoder decodeObjectForKey:@"errorCode"];
        self.message = [aDecoder decodeObjectForKey:@"message"];
        self.stackTrace = [aDecoder decodeObjectForKey:@"stackTrace"];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        errorCode = @"";
        message = @"";
        stackTrace = @"";
    }
    return self;
}

@end


@implementation Agent

@synthesize service;
@synthesize result;
@synthesize isSuccess;
@synthesize responseStatusItem;
@synthesize sessionID;
@synthesize allTypesArray;
@synthesize question;
@synthesize speakContent;
@synthesize showContent;
@synthesize emotion;
@synthesize url;
@synthesize inputType;

+ (Agent *)copyItem:(Agent *)item; {
    Agent *copyItem = [[Agent alloc] init];
    copyItem.service = item.service;
    copyItem.result = item.result;
    copyItem.isSuccess = item.isSuccess;
    copyItem.responseStatusItem = [ResponseStatusItem copyItem:item.responseStatusItem];
    copyItem.sessionID = item.sessionID;
    copyItem.allTypesArray = [[NSArray alloc] initWithArray:item.allTypesArray];
    copyItem.question = item.question;
    copyItem.speakContent = item.speakContent;
    copyItem.showContent = item.showContent;
    copyItem.emotion = item.emotion;
    copyItem.url = item.url;
    copyItem.inputType = item.inputType;
    return copyItem;
}

+ (NSString *)getInputTypeName:(int)inputType agent:(Agent *)agent {
    NSString *inputTypeStr = [NSString stringWithFormat:@"%03d",inputType];
    NSString *inputTypeName = [NSString stringWithFormat:@"%@",inputTypeStr];
    
    if (inputType != 0 && agent && agent.allTypesArray.count > 0) {
        for (AllTypesItem *item in agent.allTypesArray) {
            if (item.typesID == inputType) {
                inputTypeName = [inputTypeName stringByAppendingString:item.text];
                return inputTypeName;
            }
        }
    }
    
    inputTypeName = [inputTypeName stringByAppendingString:@"綜合"];
    return inputTypeName;;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInteger:service] forKey:@"service"];
    [aCoder encodeObject:[NSNumber numberWithBool:result] forKey:@"result"];
    [aCoder encodeObject:[NSNumber numberWithBool:isSuccess] forKey:@"isSuccess"];
    [aCoder encodeObject:responseStatusItem forKey:@"responseStatusItem"];
    [aCoder encodeObject:sessionID forKey:@"sessionID"];
    [aCoder encodeObject:allTypesArray forKey:@"allTypesArray"];
    [aCoder encodeObject:question forKey:@"question"];
    [aCoder encodeObject:speakContent forKey:@"speakContent"];
    [aCoder encodeObject:showContent forKey:@"showContent"];
    [aCoder encodeObject:emotion forKey:@"emotion"];
    [aCoder encodeObject:url forKey:@"url"];
    [aCoder encodeObject:[NSNumber numberWithInt:inputType] forKey:@"inputType"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.service = [[aDecoder decodeObjectForKey:@"service"] integerValue];
        self.result = [[aDecoder decodeObjectForKey:@"result"] boolValue];
        self.isSuccess = [[aDecoder decodeObjectForKey:@"isSuccess"] boolValue];
        self.responseStatusItem = [aDecoder decodeObjectForKey:@"responseStatusItem"];
        self.sessionID = [aDecoder decodeObjectForKey:@"sessionID"];
        self.allTypesArray = [aDecoder decodeObjectForKey:@"allTypesArray"];
        self.question = [aDecoder decodeObjectForKey:@"question"];
        self.speakContent = [aDecoder decodeObjectForKey:@"speakContent"];
        self.showContent = [aDecoder decodeObjectForKey:@"showContent"];
        self.emotion = [aDecoder decodeObjectForKey:@"emotion"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.inputType = [[aDecoder decodeObjectForKey:@"inputType"] intValue];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        sessionID = @"";
        question = @"";
        speakContent = @"";
        showContent = @"";
        emotion = @"";
        url = @"";
    }
    return self;
}

@end

@implementation ContentItem
-(id)init {
    if (self = [super init]) {
        self.agent = [[Agent alloc] init];
        self.recipient = [[Recipient alloc] init];
        self.message = [[Message alloc] init];
    }
    return self;
}

- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end {
    if (!start) {
        self.recipient.showDateLabel = YES;
        return;
    }
    
    NSString *subStart = [start substringWithRange:NSMakeRange(0, 19)];
    NSDate *startDate = [NSDate dateFromString:subStart withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *subEnd = [end substringWithRange:NSMakeRange(0, 19)];
    NSDate *endDate = [NSDate dateFromString:subEnd withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //这个是相隔的秒数
    NSTimeInterval timeInterval = [startDate timeIntervalSinceDate:endDate];
    
    //相距5分钟显示时间Label
    if (fabs (timeInterval) > 5*60) {
        self.recipient.showDateLabel = YES;
    }else{
        self.recipient.showDateLabel = NO;
    }
    
}

@end
