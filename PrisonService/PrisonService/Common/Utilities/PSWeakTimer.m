//
//  PSWeakTimer.m
//  Common
//
//  Created by calvin on 14-5-29.
//  Copyright (c) 2014年 BuBuGao. All rights reserved.
//

#import "PSWeakTimer.h"

@interface PSWeakTimerTarget : NSObject

@property (weak) id target;
@property (assign) SEL selector;
@property (weak) NSTimer* timer;
@end

@implementation PSWeakTimerTarget

- (void) fire
{
    if(self.target)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.selector withObject:nil];
#pragma clang diagnostic pop
    }
    else
    {
        [self.timer invalidate];
    }
}


@end

@implementation PSWeakTimer

+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    PSWeakTimerTarget* timerTarget = [[PSWeakTimerTarget alloc] init];
    timerTarget.target = aTarget;
    timerTarget.selector = aSelector;
    timerTarget.timer = [NSTimer scheduledTimerWithTimeInterval:ti target:timerTarget selector:@selector(fire) userInfo:userInfo repeats:yesOrNo];
    return timerTarget.timer;
}

@end
