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

- (NSArray *)contentViews;
- (NSUInteger)numberOfContentViewCopiesForDirection:(ScrollViewDirection)direction;
- (NSUInteger)mainContentViewIndex;
- (UIView *)mainContentView;
- (CGSize)mainContentSize;

@end

@implementation HLSPeriodicScrollView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Find in which directions scrolling can occur
    ScrollViewDirection direction = ScrollViewDirectionNone;
    if (floatgt(self.contentSize.width, CGRectGetWidth(self.frame))
            && floatgt(self.contentSize.height, CGRectGetHeight(self.frame))) {
        direction = ScrollViewDirectionBoth;
    }
    else if (floatgt(self.contentSize.width, CGRectGetWidth(self.frame))) {
        direction = ScrollViewDirectionHorizontal;
    }
    else if (floatgt(self.contentSize.height, CGRectGetHeight(self.frame))) {
        direction = ScrollViewDirectionVertical;
    }
    
    // Create a main content view if none exists
    if ([[self contentViews] count] == 0) {
        UIView *mainContentView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentSize.width, self.contentSize.height)] autorelease];
        mainContentView.backgroundColor = [UIColor randomColor];
        [self addSubview:mainContentView];
    }
    
    // Scrolling abilities changed (or initial subview layout): Update view replication accordingly
    if (m_direction != direction) {
        // Cleanup previously existing clones
        UIView *mainContentView = [self mainContentView];
        for (UIView *subview in [self contentViews]) {
            // Do not waste time removing the main view
            if (subview == mainContentView) {
                continue;
            }
            
            [subview removeFromSuperview];
        }
        
        // Create as many clones as needed to ensure periodicity
        for (NSUInteger i = 0; i < [self numberOfContentViewCopiesForDirection:direction]; ++i) {
            UIView *mainContentViewCopy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:mainContentView]];
            mainContentViewCopy.backgroundColor = [UIColor randomColor];
            [self addSubview:mainContentViewCopy];
        }
        
        // Adjust content size and view frames
        CGSize mainContentSize = [self mainContentSize];
        switch (direction) {
            // No content replication needed
            case ScrollViewDirectionNone: {
                super.contentSize = mainContentSize;
                break;
            }
                
            // Replicate content twice horizontally for periodicity
            case ScrollViewDirectionHorizontal: {
                super.contentSize = CGSizeMake(3.f * mainContentSize.width, mainContentSize.height);
                
                // Layout subviews
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
                
            // Replicate content twice vertically for periodicity
            case ScrollViewDirectionVertical: {
                super.contentSize = CGSizeMake(mainContentSize.width, 3.f * mainContentSize.height);
                
                // Layout subviews
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
                
            // Replicate content in 8 directions for periodicity
            case ScrollViewDirectionBoth: {
                super.contentSize = CGSizeMake(3.f * mainContentSize.width, 3.f * mainContentSize.height);
                
                // Layout subviews
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
    m_direction = direction;
}

- (NSArray *)contentViews
{
    NSMutableArray *contentViews = [NSMutableArray array];
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            continue;
        }
        [contentViews addObject:subview];
    }
    return [NSArray arrayWithArray:contentViews];
}

- (NSUInteger)numberOfContentViewCopiesForDirection:(ScrollViewDirection)direction
{
    switch (direction) {
        case ScrollViewDirectionNone: {
            return 0;
            break;
        }
            
        case ScrollViewDirectionHorizontal: {
            return 2;
            break;
        }
            
        case ScrollViewDirectionVertical: {
            return 2;
            break;
        }
            
        case ScrollViewDirectionBoth: {
            return 8;
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown scrolling direction");
            return 0;
            break;
        }
    }
}

- (NSUInteger)mainContentViewIndex
{
    switch (m_direction) {
        case ScrollViewDirectionNone: {
            return 0;
            break;
        }
            
        //  +---+---+---+
        //  | 0 |(1)| 2 |
        //  +---+---+---+
        case ScrollViewDirectionHorizontal: {
            return 1;
            break;
        }

        //  +---+
        //  | 0 |
        //  +---+
        //  |(1)|
        //  +---+
        //  | 2 |
        //  +---+
        case ScrollViewDirectionVertical: {
            return 1;
            break;
        }

        //  +---+---+---+
        //  | 0 | 1 | 2 |
        //  +---+---+---+
        //  | 3 |(4)| 5 |
        //  +---+---+---+
        //  | 6 | 7 | 8 |
        //  +---+---+---+
        case ScrollViewDirectionBoth: {
            return 4;
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown scrolling direction");
            return 0;
            break;
        }
    }
}

- (UIView *)mainContentView
{
    return [[self contentViews] objectAtIndex:[self mainContentViewIndex]];
}

- (CGSize)mainContentSize
{
    return [self mainContentView].frame.size;
}

#if 0
// TODO: Must also override over view hierarchy management methods
- (void)addSubview:(UIView *)view
{

}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
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
