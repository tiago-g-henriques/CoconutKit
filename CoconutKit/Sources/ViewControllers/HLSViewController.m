//
//  HLSViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSViewController.h"

#import <objc/runtime.h>
#import "HLSConverters.h"
#import "HLSLogger.h"
#import "NSBundle+HLSDynamicLocalization.h"

@interface HLSViewController ()

- (void)hlsViewControllerInit;
- (void)currentLocalizationDidChange:(NSNotification *)notification;

@end

@implementation HLSViewController

#pragma mark Object creation and destruction

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [self hlsViewControllerInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self hlsViewControllerInit];
    }
    return self;
}

// Common initialization code
- (void)hlsViewControllerInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocalizationDidChange:) name:HLSCurrentLocalizationDidChangeNotification object:nil];
    [self localize];
    HLSLoggerDebug(@"View controller %@ initialized", self);
}

- (void)dealloc
{
    HLSLoggerDebug(@"View controller %@ deallocated", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HLSCurrentLocalizationDidChangeNotification object:nil];
    [self releaseViews];
    [super dealloc];
}

- (void)releaseViews
{
    HLSLoggerDebug(@"Views released for view controller %@", self);
}

#pragma mark Accessors and mutators

- (void)setView:(UIView *)view
{
    [super setView:view];
    if (! view) {
        HLSLoggerDebug(@"View controller %@: view set to nil", self);
    }
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self localize];
    HLSLoggerDebug(@"View controller %@: view did load", self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    HLSLoggerDebug(@"View controller %@: view will appear", self);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    HLSLoggerDebug(@"View controller %@: view did appear", self);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    HLSLoggerDebug(@"View controller %@: view will disappear", self);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    HLSLoggerDebug(@"View controller %@: view did disappear", self);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViews];
    HLSLoggerDebug(@"View controller %@: view did unload", self);
}

#pragma mark Localization

- (void)localize
{
    IMP selfIMP = class_getMethodImplementation([self class], _cmd);
    IMP superIMP = class_getMethodImplementation([self superclass], _cmd);
    BOOL isOverriden = (selfIMP != superIMP);
    if (! isOverriden && [[[NSBundle mainBundle] localizations] count] > 1) {
        HLSLoggerWarn(@"%@ is not localized", [self class]);
    }
}

- (void)currentLocalizationDidChange:(NSNotification *)notification
{
    [self localize];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // This fixes an inconsistency of UIViewController, see HLSViewController.h documentation
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    HLSLoggerDebug(@"View controller %@ will rotate to interface orientation %@", self, HLSStringFromInterfaceOrientation(toInterfaceOrientation));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    HLSLoggerDebug(@"View controller %@ did rotate from interface orientation %@", self, HLSStringFromInterfaceOrientation(fromInterfaceOrientation));
}

#pragma mark Memory warnings

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    HLSLoggerDebug(@"View controller %@ did receive a memory warning", self);
}

@end
