//
//  UIImage+BetterImageNamed.h
//  GoodMorning
//
//  Created by Kent Liu on 2011/9/6.
//  Copyright 2011年 SoftArt Laboratory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (BetterImageNamed)

+ (UIImage *)betterImageNamed:(NSString*)name;

+ (UIImage *)betterImageNamed:(NSString*)name fileType:(NSString *)type;

@end
