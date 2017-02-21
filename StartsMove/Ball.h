//
//  Ball.h
//  Popping
//
//  Created by 无何有 on 15/5/26.
//  Copyright (c) 2015年 André Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Ball : UIImageView
//@property(nonatomic) UIImage *image;
@property (nonatomic) CGPoint mPosition;
@property (nonatomic) CGPoint mEndPosition;
@property (nonatomic) float scale;
@property (nonatomic) float transparency;
@property (nonatomic) int index;
@end
