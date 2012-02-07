//
//  HLSPeriodicScrollView.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 03.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSPeriodicScrollView.h"

#import "HLSFloat.h"
#import "HLSLogger.h"

@interface HLSPeriodicScrollView ()

- (void)hlsPeriodicScrollViewInit;

@property (nonatomic, retain) UIView *mainContentView;

- (NSArray *)contentViews;
- (NSUInteger)numberOfContentViewsForPeriodicity:(HLSScrollViewPeriodicity)periodicity;
- (void)layoutContent;

@end

@implementation HLSPeriodicScrollView

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self hlsPeriodicScrollViewInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self hlsPeriodicScrollViewInit];        
    }
    return self;
}

- (void)hlsPeriodicScrollViewInit
{
    // Create the main view during initialization. This way callers can create a view hierarchy before the scroll view
    // is actually displayed. The content size of a scroll view is always zero at the beginning.
    // TODO: Check above assertion. Maybe frame size instead of zero?
    self.mainContentView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    self.mainContentView.autoresizingMask = UIViewAutoresizingNone;     // We do not want the content to be resized when the content view is resized (TODO: Check behavior for a scroll view)
    self.mainContentView.backgroundColor = [UIColor randomColor];
    [self addSubview:self.mainContentView];
}

- (void)dealloc
{
    self.mainContentView = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize mainContentView = m_mainContentView;

@synthesize periodicity = m_periodicity;

- (void)setPeriodicity:(HLSScrollViewPeriodicity)periodicity
{
    if (m_periodicity == periodicity) {
        return;
    }
    
    m_periodicity = periodicity;
    
    // Cleanup previously existing view hierarchy (except the main content view. Otherwise we would lose what callers
    // might have put within it!)
    for (UIView *contentView in [self contentViews]) {
        if (contentView == self.mainContentView) {
            continue;
        }
        [contentView removeFromSuperview];
    }
    
    // Create as many main content view clones as needed to ensure periodicity (use archive / unarchive trick to achieve copy)
    for (NSUInteger i = 0; i < [self numberOfContentViewsForPeriodicity:m_periodicity] - 1 /* -1 because the main content view is already there */; ++i) {
        UIView *mainContentViewCopy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.mainContentView]];
        mainContentViewCopy.backgroundColor = [UIColor randomColor];
        [self addSubview:mainContentViewCopy];
    }    
    
    [self layoutContent];
}

// Return all content view (original & clones if any) contained within the scroll view
- (NSArray *)contentViews
{
    NSMutableArray *contentViews = [NSMutableArray array];
    for (UIView *subview in self.subviews) {
        // Filters out scroll view indicators
        if ([subview isKindOfClass:[UIImageView class]]) {
            continue;
        }
        [contentViews addObject:subview];
    }
    return [NSArray arrayWithArray:contentViews];
}

- (NSUInteger)numberOfContentViewsForPeriodicity:(HLSScrollViewPeriodicity)periodicity
{
    switch (periodicity) {
        case HLSScrollViewPeriodicityNone: {
            return 1;
            break;
        }

        case HLSScrollViewPeriodicityHorizontal:
        case HLSScrollViewPeriodicityVertical: {
            return 3;
            break;
        }
            
        case HLSScrollViewPeriodicityBoth: {
            return 9;
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown scrolling direction");
            return 0;
            break;
        }
    }
}

// Override the usual content size method to set the size of the main content view (mainContentView). Internally, the
// content size can be up to 3 times the size of the main content size in each direction depending on periodicity
- (CGSize)contentSize
{
    switch (m_periodicity) {
        case HLSScrollViewPeriodicityNone: {
            return super.contentSize;
            break;
        }
            
        case HLSScrollViewPeriodicityHorizontal: {
            return CGSizeMake(super.contentSize.width / 3.f, super.contentSize.height);
            break;
        }
            
        case HLSScrollViewPeriodicityVertical: {
            return CGSizeMake(super.contentSize.width, super.contentSize.height / 3.f);
            break;
        }
            
        case HLSScrollViewPeriodicityBoth: {
            return CGSizeMake(super.contentSize.width / 3.f, super.contentSize.height / 3.f);
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown scrolling direction");
            return super.contentSize;
            break;
        }
    }
}

- (void)setContentSize:(CGSize)contentSize
{
    switch (m_periodicity) {
        case HLSScrollViewPeriodicityNone: {
            super.contentSize = contentSize;
            break;
        }
            
        //  +---+---+---+
        //  | 0 | 1 | 2 |
        //  +---+---+---+
        case HLSScrollViewPeriodicityHorizontal: {
            super.contentSize = CGSizeMake(3.f * contentSize.width, contentSize.height);
            break;
        }
            
        //  +---+
        //  | 0 |
        //  +---+
        //  | 1 |
        //  +---+
        //  | 2 |
        //  +---+
        case HLSScrollViewPeriodicityVertical: {
            super.contentSize = CGSizeMake(contentSize.width, 3.f * contentSize.height);
            break;
        }
            
        //  +---+---+---+
        //  | 0 | 1 | 2 |
        //  +---+---+---+
        //  | 3 | 4 | 5 |
        //  +---+---+---+
        //  | 6 | 7 | 8 |
        //  +---+---+---+
        case HLSScrollViewPeriodicityBoth: {
            super.contentSize = CGSizeMake(3.f * contentSize.width, 3.f * contentSize.height);
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown scrolling direction");
            super.contentSize = contentSize;
            break;
        }
    }
    
    [self layoutContent];
}

#if 0
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    
}
#endif

#pragma mark View layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
#if 0
    // Adjust content size and view frames
    CGSize mainContentSize = self.contentSize;
    switch (m_periodicity) {
        case HLSScrollViewPeriodicityNone: {
            break;
        }
            
        case HLSScrollViewPeriodicityHorizontal: {
            self.contentOffset = CGPointMake(mainContentSize.width + fmodf(self.contentOffset.x, self.contentSize.width), 
                                             0.f);
            break;
        }
            
        case HLSScrollViewPeriodicityVertical: {
            self.contentOffset = CGPointMake(0.f, 
                                             self.contentSize.height + fmodf(self.contentOffset.y, self.contentSize.height));
            break;
        }
            
        case HLSScrollViewPeriodicityBoth: {
            self.contentOffset = CGPointMake(mainContentSize.width + fmodf(self.contentOffset.x, self.contentSize.width), 
                                             self.contentSize.height + fmodf(self.contentOffset.y, self.contentSize.height));
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown scrolling direction");
            break;
        }                
    }
#endif
    
#if 0    
    if (floatge(self.contentOffset.x, 2 * self.contentSize.width)) {
        self.contentOffset = CGPointMake(3 * self.contentSize.width, 0.f /* TODO: Same in y-direction */);
    }
    else if (floatle(self.contentOffset.x, self.contentSize.width - CGRectGetWidth(self.frame))) {
        self.contentOffset = CGPointMake(0.f, 0.f /* TODO: Same in y-direction */);
    }
#endif
}

- (void)layoutContent
{
    // Adjust content size and view frames
    CGSize mainContentSize = self.contentSize;
    switch (m_periodicity) {
        case HLSScrollViewPeriodicityNone: {
            self.mainContentView.frame = CGRectMake(0.f, 
                                                    0.f, 
                                                    mainContentSize.width, 
                                                    mainContentSize.height);
            break;
        }
            
        case HLSScrollViewPeriodicityHorizontal: {
            NSUInteger index = 0;
            for (UIView *subview in [self contentViews]) {
                NSInteger i = index % 3;
                subview.frame = CGRectMake(i * mainContentSize.width, 
                                           0.f, 
                                           mainContentSize.width, 
                                           mainContentSize.height);
                ++index;
            }
            break;
        }
            
        case HLSScrollViewPeriodicityVertical: {
            NSUInteger index = 0;
            for (UIView *subview in [self contentViews]) {
                NSInteger j = index % 3;
                subview.frame = CGRectMake(0.f, 
                                           j * mainContentSize.height, 
                                           mainContentSize.width, 
                                           mainContentSize.height);
                ++index;
            }
            break;
        }
            
        case HLSScrollViewPeriodicityBoth: {
            NSUInteger index = 0;
            for (UIView *subview in [self contentViews]) {
                NSInteger i = index % 3;
                NSInteger j = index / 3;
                subview.frame = CGRectMake(i * mainContentSize.width, 
                                           j * mainContentSize.height, 
                                           mainContentSize.width, 
                                           mainContentSize.height);
                ++index;
            }
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown scrolling direction");
            break;
        }                
    }
}

#if 0
// TODO: Must also override over view hierarchy management methods
- (void)addSubview:(UIView *)view
{

}


- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    [self layoutSubviews];
}
#endif

// TODO: Must override all scroll view methods & probably implement all delegate methods to return correct coordinates
//       and act on the content view transparently  

@end
