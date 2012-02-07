//
//  HLSPeriodicScrollView.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 03.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

typedef enum {
    HLSScrollViewPeriodicityEnumBegin = 0,
    HLSScrollViewPeriodicityNone = HLSScrollViewPeriodicityEnumBegin,
    HLSScrollViewPeriodicityHorizontal,
    HLSScrollViewPeriodicityVertical,
    HLSScrollViewPeriodicityBoth,
    HLSScrollViewPeriodicityEnumEnd,
    HLSScrollViewPeriodicityEnumSize = HLSScrollViewPeriodicityEnumEnd - HLSScrollViewPeriodicityEnumBegin
} HLSScrollViewPeriodicity;

@interface HLSPeriodicScrollView : UIScrollView <UIScrollViewDelegate> {
@private
    HLSScrollViewPeriodicity m_periodicity;
    UIView *m_mainContentView;
}

@property (nonatomic, assign) HLSScrollViewPeriodicity periodicity;

@end
