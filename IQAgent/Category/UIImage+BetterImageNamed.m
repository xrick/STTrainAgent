//
//  UIImage+BetterImageNamed.m
//  GoodMorning
//
//  Created by Kent Liu on 2011/9/6.
//  Copyright 2011年 SoftArt Laboratory. All rights reserved.
//

#import "UIImage+BetterImageNamed.h"


@implementation UIImage (BetterImageNamed)

+ (UIImage *)betterImageNamed:(NSString*)name {
    NSArray *imageExtensions = [NSArray arrayWithObjects:@"png",@"jpg",@"jpeg",@"jp2",@"tiff",@"gif",nil];
    
    NSString *extension = @"";
    
    if ([[name pathExtension] isEqualToString:@""]) {
        for (NSString *ext in imageExtensions) {
            NSString *tempName = [NSString stringWithFormat:@"%@.%@",name,ext];
            
            NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:tempName];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                extension = ext;
            }
        }
        
        if ([extension isEqualToString:@""]) {
            //會cache，記憶體不可分頁
            UIImage *image = [UIImage imageNamed:name];
            return image;
        }
    }
    
    /*
    //不會cache，使用二進制取用圖片數據，適合大圖片或下載圖片，記憶體不可分頁
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%@.%@",name,fittingExtension]];
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage imageWithData:imageData];
    */
    
    //不會cache，記憶體可分頁
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:extension]];
    
    return image;
}
 
+ (UIImage *)betterImageNamed:(NSString*)name fileType:(NSString *)type {
    UIImage *imageResult = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:type]];
    
    return imageResult;
}

@end
