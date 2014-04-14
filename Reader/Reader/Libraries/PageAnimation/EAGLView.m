//
//  EAGLView.m
//  ConeCurl
//
//  Created by W. Dana Nuon on 4/18/10.
//  Copyright W. Dana Nuon 2010. All rights reserved.
//

#import "EAGLView.h"

#import "ES1Renderer.h"

@implementation EAGLView

@synthesize animating;
@dynamic animationFrameInterval;
@synthesize animationTime;

// You must implement this method
+ (Class)layerClass
{
  return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder
{    
  if ((self = [super initWithCoder:coder]))
  {
      [self initialize];
  }
  
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    if (!renderer)
    {
        renderer = [[ES1Renderer alloc] init];
    }
    
    animating = FALSE;
    displayLinkSupported = FALSE;
    animationFrameInterval = 1;
    displayLink = nil;
    animationTimer = nil;
    
    // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
    // class is used as fallback when it isn't available.
    
    displayLinkSupported = TRUE;
    
    rightPage_ = [[CCPage alloc] init];
    rightPage_.currentFrame = 0;
    rightPage_.framesPerCycle = 120;
    rightPage_.width = 1;
    rightPage_.height = 1;
    rightPage_.columns = PAGE_COLUMNS;
    rightPage_.rows = PAGE_ROWS;
    [rightPage_ createMesh];
}

- (void)drawView:(id)sender
{
  [renderer renderObject:rightPage_];
  if (animating)
  {
    [rightPage_ incrementTime];
    self.animationTime = [rightPage_ currentTime];
    [rightPage_ deformForTime:animationTime];
  }
}

- (void)drawViewForTime:(CGFloat)time
{
  [rightPage_ deformForTime:time];
  [renderer renderObject:rightPage_];
}

- (void)layoutSubviews
{
  [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    
    UIImage *backImage = [UIImage imageNamed:@"back512"];
    UIImage *frontImage = [UIImage imageNamed:@"front512"];
    
  [renderer setupView:(CAEAGLLayer*)self.layer 
           frontImage:frontImage 
            backImage:backImage];
  [self drawView:nil];
}

- (NSInteger)animationFrameInterval
{
  return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
  // Frame interval defines how many display frames must pass between each time the
  // display link fires. The display link will only fire 30 times a second when the
  // frame internal is two on a display that refreshes 60 times a second. The default
  // frame interval setting of one will fire 60 times a second when the display refreshes
  // at 60 times a second. A frame interval setting of less than one results in undefined
  // behavior.
  if (frameInterval >= 1)
  {
    animationFrameInterval = frameInterval;
    
    if (animating)
    {
      [self stopAnimation];
      [self startAnimation];
    }
  }
}

- (void)startAnimation
{
  if (!animating)
  {
    if (displayLinkSupported)
    {
      // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
      // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
      // not be called in system versions earlier than 3.1.
      
      displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
      [displayLink setFrameInterval:animationFrameInterval];
      [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else
      animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView:) userInfo:nil repeats:TRUE];
    
    rightPage_.currentFrame = animationTime * rightPage_.framesPerCycle;
    animating = TRUE;
  }
}

- (void)stopAnimation
{
  if (animating)
  {
    if (displayLinkSupported)
    {
      [displayLink invalidate];
      displayLink = nil;
    }
    else
    {
      [animationTimer invalidate];
      animationTimer = nil;
    }
    
    animating = FALSE;
  }
}

- (CCPage *)activePage
{
  return rightPage_;
}

- (void)dealloc
{

}

@end
