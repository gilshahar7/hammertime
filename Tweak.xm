@interface MTTimer
@property (nonatomic, assign, readonly) NSUInteger state;
@end

@interface NAFuture : NSObject
@end

@interface MTTimerManager
- (NAFuture *)currentTimer;
-(id)stopCurrentTimer;
-(id)pauseCurrentTimer;
-(id)resumeCurrentTimer;
@end

@interface CSTimerView : UIView
- (id)_viewDelegate;
@end

@interface CSTimerViewController
-(void)_stopTimer;
@end

@interface _UILegibilitySettings
@property (nonatomic, strong, readwrite) UIColor *primaryColor;
@end

@interface SBUILegibilityLabel : UIView
@property (nonatomic, strong, readwrite) _UILegibilitySettings *legibilitySettings;
- (void)_updateLabelForLegibilitySettings;
- (void)setTextColor:(id)arg1;
@end

static BOOL shouldSkip = false;
static BOOL shouldSkip2 = false;

%hook CSTimerViewController
- (void)_stopTimer{
  if(shouldSkip == false){
    %orig;
    shouldSkip2 = false;
  }else{
    shouldSkip = false;
  }
}
%end

%hook CSTimerView
-(void)movedToWindow:(id)arg1{
  %orig;
  if([[self gestureRecognizers] count] == 0){
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    [self addGestureRecognizer:singleFingerTap];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPress];
    [[[[self superview] superview] superview] addSubview:[self superview]];
  }
}

%new
-(void)handleSingleTap {
  MTTimerManager * timerManager = MSHookIvar<MTTimerManager *>([self _viewDelegate], "_timerManager");
  MTTimer *currentTimer = [[timerManager currentTimer] valueForKey:@"_resultValue"];
  NSUInteger state = currentTimer.state;
  SBUILegibilityLabel *label = self.subviews[0];
  if(state == 2){
    [timerManager resumeCurrentTimer];
    label.legibilitySettings.primaryColor = [UIColor whiteColor];
    [label _updateLabelForLegibilitySettings];
    [label setTextColor:[UIColor whiteColor]];
    shouldSkip2 = false;
  }else if(state == 3){
    shouldSkip = true;
    shouldSkip2 = true;
    [timerManager pauseCurrentTimer];
    label.legibilitySettings.primaryColor = [UIColor systemOrangeColor];
    [label _updateLabelForLegibilitySettings];
    [label setTextColor:[UIColor systemOrangeColor]];
  }
}

- (void)updateTimerLabel{
  if(shouldSkip2 == false){
    %orig;
  }
}

%new
-(void)handleLongPress:(UILongPressGestureRecognizer*)sender{
  if (sender.state == UIGestureRecognizerStateBegan){
    [MSHookIvar<MTTimerManager *>([self _viewDelegate], "_timerManager") stopCurrentTimer];

    [[self _viewDelegate] _stopTimer];
   }
}

%end
