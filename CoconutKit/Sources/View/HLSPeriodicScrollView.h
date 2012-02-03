//
//  HLSPeriodicScrollView.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 03.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

typedef enum {
    ScrollViewDirectionEnumBegin = 0,
    ScrollViewDirectionNone = ScrollViewDirectionEnumBegin,
    ScrollViewDirectionHorizontal,
    ScrollViewDirectionVertical,
    ScrollViewDirectionBoth,
    ScrollViewDirectionEnumEnd,
    ScrollViewDirectionEnumSize = ScrollViewDirectionEnumEnd - ScrollViewDirectionEnumBegin
} ScrollViewDirection;

@interface HLSPeriodicScrollView : UIScrollView <UIScrollViewDelegate> {
@private
    ScrollViewDirection m_direction;
}

@end
