//
//  Ball.m
//  Popping
//
//  Created by 无何有 on 15/5/26.
//  Copyright (c) 2015年 André Schneider. All rights reserved.
//

#import "Ball.h"

//
//  ImageViewController.m
//  Popping
//
//  Created by André Schneider on 11.05.14.
//  Copyright (c) 2014 André Schneider. All rights reserved.
//

#import "Ball.h"

@interface Ball()
@property(nonatomic) UIImageView *imageView;
@end

@implementation Ball

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5.f;
        self.layer.masksToBounds = YES;
//        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
//        [self addSubview:_imageView];
    }
    return self;
}

#pragma mark - Property Setters

//- (void)setImage:(UIImage *)image
//{
//    [self.imageView setImage:image];
//    _image = image;
//}

- (void)setMPosition:(CGPoint)position
{
    _mPosition = position;
}

- (void)setMEndPosition:(CGPoint)position
{
    _mEndPosition = position;
}

- (void)setScale:(float)scale
{
    _scale = scale;
}

- (void)setTransparency:(float)transparency
{
    _transparency = transparency;
}
@end
