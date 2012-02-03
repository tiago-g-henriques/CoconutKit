//
//  PeriodicScrollViewDemoViewController.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 06.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface PeriodicScrollViewDemoViewController : HLSViewController {
@private
    HLSPeriodicScrollView *m_noneScrollView;
    HLSPeriodicScrollView *m_verticalScrollView;
    HLSPeriodicScrollView *m_horizontalScrollView;
    HLSPeriodicScrollView *m_bothScrollView;
}

@property (nonatomic, retain) IBOutlet HLSPeriodicScrollView *noneScrollView;
@property (nonatomic, retain) IBOutlet HLSPeriodicScrollView *verticalScrollView;
@property (nonatomic, retain) IBOutlet HLSPeriodicScrollView *horizontalScrollView;
@property (nonatomic, retain) IBOutlet HLSPeriodicScrollView *bothScrollView;

@end
