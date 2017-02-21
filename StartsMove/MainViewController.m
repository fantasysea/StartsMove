//
//  MainViewController.m
//  Popping
//
//  Created by André Schneider on 22.05.14.
//  Copyright (c) 2014 André Schneider. All rights reserved.
//

#import "MainViewController.h"
#import "ImageView.h"
#import "Ball.h"
//#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
//#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface MainViewController()
@property(nonatomic,strong) NSMutableArray *balls;
@property(nonatomic,strong) NSMutableArray *imageArray;
@property(nonatomic,strong) NSMutableArray *positions;

@property(nonatomic) CGPoint center;
@property(nonatomic) CGPoint top1;
@property(nonatomic) CGPoint top2;
@property(nonatomic) CGPoint top3;
@property(nonatomic) CGPoint bottom1;
@property(nonatomic) CGPoint bottom2;

@property(nonatomic) CGPoint ballVelocity;
@property (nonatomic) int mCurrentIndex;


@property (nonatomic, strong) CADisplayLink *timer;
@property (nonatomic, assign) CFTimeInterval duration;
@property (nonatomic, assign) CFTimeInterval timeOffset;
@property (nonatomic, assign) CFTimeInterval lastStep;
@property (nonatomic, strong) id fromValue;
@property (nonatomic, strong) id toValue;


- (void)addDragView;
- (void)touchDown:(UIControl *)sender;
- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
@end

@implementation MainViewController

float heighta = 450.0f;
float offya = 0.0;
float progressa = 0.0;
float tempprogressa = 0.0;
float velocitya = 0.0;

//1 2 3 4 5 6  中间向两边拓展，只要确定哪个球是中间的，那么其他
-(NSMutableArray *)imageArray
{
    if (!_imageArray) {
        _imageArray = @[@"ranking",@"ranking",@"ranking",@"ranking",@"ranking", @"friendsPlay", @"friendsPlay", @"friendsPlay", @"friendsPlay"];
    }
    return _imageArray;
}

-(NSMutableArray *)positions
{
    if (!_positions) {
        _positions = [NSMutableArray array];
    }
    return _positions;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.balls = [NSMutableArray array];
    [self addDragView];
}




#pragma mark - Private Instance methods

- (void)addDragView
{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handlePan:)];
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    ImageView *imageView = [[ImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    imageView.center = self.view.center;
//    [imageView setImage:[UIImage imageNamed:@"boat.jpg"]];
    [imageView addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [imageView addGestureRecognizer:recognizer];
    
    [self.view addSubview:imageView];
    
    [self addBalls];
    offya = 0.0;
    
}

-(void)randomBallPosition{
    _center = self.view.center;
    _top1 = CGPointMake(self.view.center.x+100, self.view.center.y-80);
    _top2 = CGPointMake(self.view.center.x+100, self.view.center.y-150);
    _top3 = CGPointMake(self.view.frame.size.width+10, -10);
    _bottom1 = CGPointMake(self.view.center.x-100, self.view.center.y+120);
    _bottom2 = CGPointMake(-10, self.view.frame.size.height+10);
    
}

- (void)addBalls{
    _center = self.view.center;
    _top1 = CGPointMake(self.view.center.x+100, self.view.center.y-80);
    _top2 = CGPointMake(self.view.center.x+100, self.view.center.y-150);
    _top3 = CGPointMake(self.view.frame.size.width-20, 90);
    _bottom1 = CGPointMake(self.view.center.x-100, self.view.center.y+120);
    _bottom2 = CGPointMake(20, self.view.frame.size.height-50);
    
    self.mCurrentIndex = 2;
    for (int i = 0; i<[self.imageArray count]; i++) {
        Ball *ball = [[Ball alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        ball.layer.cornerRadius = CGRectGetWidth(ball.bounds)/2;
        ball.backgroundColor = RGBACOLOR(52,152,219,1);
        ball.center = _top3;
        ball.index = i;
        ball.transform = CGAffineTransformScale(ball.transform,0, 0);
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 100, 20)];
        name.text = [NSString stringWithFormat:@"%d",i+1];
        [ball addSubview:name];
        [self.view addSubview:ball];
        
        [self.balls addObject:ball];
    }
    [self resetBallsPosition];
    [self resetScale];
}
-(void)resetScale{
    
    Ball *mid = self.balls[self.mCurrentIndex];
    Ball *bottom1 = self.balls[[self nextIndex:self.mCurrentIndex]];
    Ball *bottom2 = self.balls[[self nextIndex:[self nextIndex:self.mCurrentIndex]]];
    Ball *top1 = self.balls[[self preIndex:self.mCurrentIndex]];
    Ball *top2 = self.balls[[self preIndex:[self preIndex:self.mCurrentIndex]]];
    Ball *top3 = self.balls[[self preIndex:[self preIndex:[self preIndex:self.mCurrentIndex]]]];
    mid.transform = CGAffineTransformIdentity;
    bottom1.transform = CGAffineTransformIdentity;
    bottom2.transform = CGAffineTransformIdentity;
    top1.transform = CGAffineTransformIdentity;
    top2.transform = CGAffineTransformIdentity;
    top3.transform = CGAffineTransformIdentity;
    mid.scale = 1;
    bottom1.scale = 0.6;
    bottom2.scale = 0;
    top1.scale = 0.5;
    top2.scale = 0.2;
    top3.scale = 0;
    
    mid.transform = CGAffineTransformScale(mid.transform,mid.scale, mid.scale);
    bottom1.transform = CGAffineTransformScale(bottom1.transform,bottom1.scale, bottom1.scale);
    bottom2.transform = CGAffineTransformScale(mid.transform,0, 0);
    top1.transform = CGAffineTransformScale(top1.transform,top1.scale, top1.scale);
    top2.transform = CGAffineTransformScale(top2.transform,top2.scale, top2.scale);
    top3.transform = CGAffineTransformScale(top3.transform,top3.scale, top3.scale);
    
}

//这里需要判断在上半区还是下半区
-(void)refleshScale:(float)progress{

    Ball *mid = self.balls[self.mCurrentIndex];
    Ball *bottom1 = self.balls[[self nextIndex:self.mCurrentIndex]];
    Ball *bottom2 = self.balls[[self nextIndex:[self nextIndex:self.mCurrentIndex]]];
    Ball *top1 = self.balls[[self preIndex:self.mCurrentIndex]];
    Ball *top2 = self.balls[[self preIndex:[self preIndex:self.mCurrentIndex]]];
    Ball *top3 = self.balls[[self preIndex:[self preIndex:[self preIndex:self.mCurrentIndex]]]];
    
    mid.transform = CGAffineTransformIdentity;
    bottom1.transform = CGAffineTransformIdentity;
    bottom2.transform = CGAffineTransformIdentity;
    top1.transform = CGAffineTransformIdentity;
    top2.transform = CGAffineTransformIdentity;
    top3.transform = CGAffineTransformIdentity;
    if (progress>=0) {
        float offScale = mid.scale-bottom1.scale;
        mid.transform = CGAffineTransformScale(mid.transform,mid.scale-progress*offScale, mid.scale-progress*offScale);
        
        float offScale2 = bottom1.scale-bottom2.scale;
        bottom1.transform = CGAffineTransformScale(bottom1.transform,bottom1.scale-progress*offScale2, bottom1.scale-progress*offScale2);
        

        bottom2.transform = CGAffineTransformScale(mid.transform,0, 0);
        
        float offScale4 = mid.scale-top1.scale;
        top1.transform = CGAffineTransformScale(top1.transform,top1.scale+progress*offScale4, top1.scale+progress*offScale4);
        
        float offScale5 = top1.scale-top2.scale;
        top2.transform = CGAffineTransformScale(top2.transform,top2.scale+progress*offScale5, top2.scale+progress*offScale5);
        
        float offScale6 = top2.scale-top3.scale;
        top3.transform = CGAffineTransformScale(top3.transform,top3.scale+progress*offScale6, top3.scale+progress*offScale6);
        
    }else{
        float offScale = mid.scale-top1.scale;
        mid.transform = CGAffineTransformScale(mid.transform,mid.scale-fabsf(progress)*offScale, mid.scale-fabsf(progress)*offScale);
        
        float offScale2 = mid.scale-bottom1.scale;
        bottom1.transform = CGAffineTransformScale(bottom1.transform,bottom1.scale+fabsf(progress)*offScale2, bottom1.scale+fabsf(progress)*offScale2);
        
        float offScale3 = bottom1.scale-bottom2.scale;
        bottom2.transform = CGAffineTransformScale(bottom2.transform,bottom2.scale+fabsf(progress)*offScale3, bottom2.scale+fabsf(progress)*offScale3);
        
        float offScale4 = top1.scale-top2.scale;
        top1.transform = CGAffineTransformScale(top1.transform,top1.scale-fabsf(progress)*offScale4, top1.scale-fabsf(progress)*offScale4);
        
        float offScale5 = top2.scale-top3.scale;
        top2.transform = CGAffineTransformScale(top2.transform,top2.scale-fabsf(progress)*offScale5, top2.scale-fabsf(progress)*offScale5);
        
        top3.transform = CGAffineTransformScale(top3.transform,0, 0);
        
        
    }
    
    
}
//屏幕中下一个位置的ball
-(int)nextIndex:(int)index{
    int nextIndex = 0;
    if (index==0) {
         nextIndex = [self.imageArray count] - 1;
    }else{
         nextIndex = index - 1;
    }
    return  nextIndex;
}

-(int)preIndex:(int)index{
    int preIndex = 0;
    if (index==[self.imageArray count]-1) {
        preIndex = 0;
    }else{
        preIndex = index + 1;
    }
    return  preIndex;
}


-(void)resetBallsPosition{
    Ball *mid = self.balls[self.mCurrentIndex];
    Ball *bottom1 = self.balls[[self nextIndex:self.mCurrentIndex]];
    Ball *bottom2 = self.balls[[self nextIndex:[self nextIndex:self.mCurrentIndex]]];
    Ball *top1 = self.balls[[self preIndex:self.mCurrentIndex]];
    Ball *top2 = self.balls[[self preIndex:[self preIndex:self.mCurrentIndex]]];
    Ball *top3 = self.balls[[self preIndex:[self preIndex:[self preIndex:self.mCurrentIndex]]]];
    
    mid.center =mid.mPosition =  _center;
    bottom1.center =bottom1.mPosition =  _bottom1;
    bottom2.center =bottom2.mPosition =  _bottom2;
    top1.center = top1.mPosition = _top1;
    top2.center = top2.mPosition = _top2;
    top3.center = top3.mPosition = _top3;

    mid.mEndPosition = bottom1.mPosition;
    bottom1.mEndPosition = bottom2.mPosition;
    bottom2.mEndPosition = bottom2.mPosition;
    top1.mEndPosition = mid.mPosition;
    top2.mEndPosition = top1.mPosition;
    top3.mEndPosition = top2.mPosition;
}


-(void)refleshBallsPosition:(float)progress{
    Ball *mid = self.balls[self.mCurrentIndex];
    Ball *bottom1 = self.balls[[self nextIndex:self.mCurrentIndex]];
    Ball *bottom2 = self.balls[[self nextIndex:[self nextIndex:self.mCurrentIndex]]];
    Ball *top1 = self.balls[[self preIndex:self.mCurrentIndex]];
    Ball *top2 = self.balls[[self preIndex:[self preIndex:self.mCurrentIndex]]];
    Ball *top3 = self.balls[[self preIndex:[self preIndex:[self preIndex:self.mCurrentIndex]]]];
    
    
    
    
    if (progress>=0) {
        //往下
        mid.center = [self pointOnCubicBezierWithControlPoints:mid.mPosition endp:bottom1.mPosition c1p:mid.mPosition c2p:bottom1.mPosition p:progress];
        bottom1.center = [self pointOnCubicBezierWithControlPoints:bottom1.mPosition endp:bottom2.mPosition c1p:bottom1.mPosition c2p:bottom2.mPosition p:progress];
        bottom2.center = [self pointOnCubicBezierWithControlPoints:bottom2.mPosition endp:bottom2.mPosition c1p:bottom2.mPosition c2p:bottom2.mPosition p:progress];
        top1.center = [self pointOnCubicBezierWithControlPoints:top1.mPosition endp:mid.mPosition c1p:top1.mPosition c2p:mid.mPosition p:progress];
        top2.center = [self pointOnCubicBezierWithControlPoints:top2.mPosition endp:top1.mPosition c1p:top2.mPosition c2p:top1.mPosition p:progress];
        top3.center = [self pointOnCubicBezierWithControlPoints:top3.mPosition endp:top2.mPosition c1p:top3.mPosition c2p:top2.mPosition p:progress];
    }else{
        mid.center = [self pointOnCubicBezierWithControlPoints:mid.mPosition endp:top1.mPosition c1p:mid.mPosition c2p:top1.mPosition p:fabsf(progress)];
        bottom1.center = [self pointOnCubicBezierWithControlPoints:bottom1.mPosition endp:mid.mPosition c1p:bottom1.mPosition c2p:mid.mPosition p:fabsf(progress)];
        bottom2.center = [self pointOnCubicBezierWithControlPoints:bottom2.mPosition endp:bottom1.mPosition c1p:bottom2.mPosition c2p:bottom1.mPosition p:fabsf(progress)];
        top1.center = [self pointOnCubicBezierWithControlPoints:top1.mPosition endp:top2.mPosition c1p:top1.mPosition c2p:top2.mPosition p:fabsf(progress)];
        top2.center = [self pointOnCubicBezierWithControlPoints:top2.mPosition endp:top3.mPosition c1p:top2.mPosition c2p:top3.mPosition p:fabsf(progress)];
        top3.center = [self pointOnCubicBezierWithControlPoints:top3.mPosition endp:top3.mPosition c1p:top3.mPosition c2p:top3.mPosition p:fabsf(progress)];


    }


    

}

- (void)touchDown:(UIControl *)sender {
    offya = tempprogressa*heighta;
    self.ballVelocity = CGPointMake(0, 0);
    NSLog(@"offy = %f tempprogress = %f",offya,tempprogressa);
    tempprogressa = 0.0;
    progressa = 0.0;
    self.timeOffset = 0.0;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{

    CGPoint translation = [recognizer translationInView:self.view];
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    self.ballVelocity = [recognizer velocityInView:self.view];
    NSLog(@"velocity.x = %f  velocity.y = %f",self.ballVelocity.x,self.ballVelocity.y);
    offya += translation.y;
    if (offya>=0) {
        if (offya>heighta) {
            tempprogressa = 0.0;
            self.timeOffset = 0.0;
            [self.timer invalidate];
            self.timer = nil;
            [self resetIndex];
            offya = (int)offya%(int)heighta;
        }
    }else{
        if (fabsf(offya)>heighta) {
            tempprogressa = 0.0;
            self.timeOffset = 0.0;
            [self.timer invalidate];
            self.timer = nil;
            [self resetReIndex];
            offya = (int)offya%(int)heighta;
        }
    }
    float p = (float)offya/heighta;
    progressa = p;
    [self refleshBallsPosition:p];
    [self refleshScale:p];
    NSLog(@"offy = %f translation.y = %f  translation.x = %f  p = %f",offya,translation.y,translation.x,p);
    if(recognizer.state == UIGestureRecognizerStateEnded) {
        if (offya!=heighta) {
            [self animate];
        }
    }
    
}


// Bezier curve are: '[(0,0), c1, c2, (1,1)]'
-(CGPoint)pointOnCubicBezierWithControlPoints:(CGPoint)startp endp:(CGPoint)endp c1p:(CGPoint)c1p c2p:(CGPoint)c2p p:(float)t {
    // x = (1-t)^3 *x0 + 3*t*(1-t)^2 *x1 + 3*t^2*(1-t) *x2 + t^3 *x3
    // y = (1-t)^3 *y0 + 3*t*(1-t)^2 *y1 + 3*t^2*(1-t) *y2 + t^3 *y3
    
    float c0x = startp.x, c0y = startp.y;
    float c3x = endp.x, c3y = endp.y;
    float c1x = c1p.x, c1y = c1p.y;
    float c2x = c2p.x, c2y = c2p.y;
    float ax, bx, cx;
    float ay, by, cy;
    float tSquared, tCubed;
    float x, y;
    
    cx = 3.0 * (c1x - c0x);
    bx = 3.0 * (c2x - c1x) - cx;
    ax = c3x - c0x - cx - bx;
    
    cy = 3.0 * (c1y - c0y);
    by = 3.0 * (c2y - c1y) - cy;
    ay = c3y - c0y - cy - by;
    
    tSquared = t * t;
    tCubed = tSquared * t;
    
    x = (ax * tCubed) + (bx * tSquared) + (cx * t) + c0x;
    y = (ay * tCubed) + (by * tSquared) + (cy * t) + c0y;
    
    return CGPointMake(x, y);
}


-(CGPoint)pointOnCubicBezierWithPosition:(CGPoint)startp endp:(CGPoint)endp c1p:(CGPoint)c1p c2p:(CGPoint)c2p p:(CGPoint)position {
    // x = (1-t)^3 *x0 + 3*t*(1-t)^2 *x1 + 3*t^2*(1-t) *x2 + t^3 *x3
    // y = (1-t)^3 *y0 + 3*t*(1-t)^2 *y1 + 3*t^2*(1-t) *y2 + t^3 *y3

    
    float c0x = startp.x, c0y = startp.y;
    float c3x = endp.x, c3y = endp.y;
    float c1x = c1p.x, c1y = c1p.y;
    float c2x = c2p.x, c2y = c2p.y;
    float ax, bx, cx;
    float ay, by, cy;
    float tSquared, tCubed;
    float x, y;
    
    cx = 3.0 * (c1x - c0x);
    bx = 3.0 * (c2x - c1x) - cx;
    ax = c3x - c0x - cx - bx;
    
    cy = 3.0 * (c1y - c0y);
    by = 3.0 * (c2y - c1y) - cy;
    ay = c3y - c0y - cy - by;
    
    float t;
    tSquared = t * t;
    tCubed = tSquared * t;
    
    x = (ax * tCubed) + (bx * tSquared) + (cx * t) + c0x;
    y = (ay * tCubed) + (by * tSquared) + (cy * t) + c0y;
    
    return CGPointMake(x, y);
}


- (void)animate
{

    //configure the animation
    self.duration = 0.5*(1-fabsf(progressa));
    self.timeOffset = 0.0;
    self.fromValue = [NSValue valueWithCGPoint:CGPointMake(150, 32)];
    self.toValue = [NSValue valueWithCGPoint:CGPointMake(150, 268)];
    //stop the timer if it's already running
    [self.timer invalidate];
    //start the timer
    self.lastStep = CACurrentMediaTime();
    self.timer = [CADisplayLink displayLinkWithTarget:self
                                             selector:@selector(step:)];
    [self.timer addToRunLoop:[NSRunLoop mainRunLoop]
                     forMode:NSDefaultRunLoopMode];
}
//TODO 当手快速活动到中间位置，也就是完成度接近100％的时候，需要滑倒下一个星球。目前只处理了向下的时候，向上的时候可以处理，不过出现的频率太低，暂时不做处理
- (void)step:(CADisplayLink *)timer
{
    //calculate time delta
    CFTimeInterval thisStep = CACurrentMediaTime();
    CFTimeInterval stepDuration = thisStep - self.lastStep;
    self.lastStep = thisStep;
    //update time offset
    self.timeOffset = MIN(self.timeOffset + stepDuration, self.duration);
    //get normalized time offset (in range 0 - 1)
    float time = self.timeOffset / self.duration;
    //移动到了下半区
    if (progressa>=0) {
        //向下
        if (self.ballVelocity.y>=0.0) {
            float offP = 1-progressa;
            tempprogressa = progressa+time*offP;
            
        }else{
            float offP = progressa;
            tempprogressa = progressa-time*offP;
            
        }
        
    }else{
        //向下
        if (self.ballVelocity.y>=0.0) {
            float offP = fabsl(progressa);
            tempprogressa = progressa+time*offP;
            
        }else{
            float offP = 1-fabsl(progressa);
            tempprogressa = progressa-time*offP;
            
        }
        
    }
    
    [self refleshBallsPosition:tempprogressa];
    [self refleshScale:tempprogressa];
    NSLog(@"self.timeOffset is = %f  tempprogress is %f  progress is %f",self.timeOffset,tempprogressa,progressa);
    //stop the timer if we've reached the end of the animation
    if (self.timeOffset >= self.duration) {
        [self.timer invalidate];
        self.timer = nil;
        
        if (tempprogressa!=0.0) {
            if (progressa>=0) {
                [self resetIndex];
            }else{
                [self resetReIndex];
            }
        }
        offya = 0;
        tempprogressa = 0.0;
        self.timeOffset = 0.0;
        
        if(fabsf(progressa)>=0.8&&fabsf(self.ballVelocity.y)>=800.0){
            progressa = 0.0;
            [self animate];
        }
        progressa = 0.0;
    }
}

-(void)resetIndex{
    
    Ball *ball = self.balls[0];
    [self.balls removeObjectAtIndex:0];
    [self.balls addObject:ball];
    [self resetBallsPosition];
    [self resetScale];
}

-(void)resetReIndex{
    
    Ball *ball = self.balls[[self.balls count]-1];
    [self.balls removeObjectAtIndex:[self.balls count]-1];
    [self.balls insertObject:ball atIndex:0];
    [self resetBallsPosition];
    [self resetScale];
}

@end
