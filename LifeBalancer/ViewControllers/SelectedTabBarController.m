//
//  SelectedTabBar.m
//  LifeBalancer
//
//  Created by Eugene Zozulya on 1/6/15.
//  Copyright (c) 2015 Czarto. All rights reserved.
//

#import "SelectedTabBarController.h"

@implementation SelectedTabBarController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self selectItemForViewController:self.selectedViewController];
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	[self deselectAllItems];
	[self selectItemForViewController:viewController];
}

#pragma mark - Private Methods

- (void)deselectAllItems
{
	for(UITabBarItem *item in self.tabBar.items)
	{
		[item setTitleTextAttributes:@{
									   NSFontAttributeName: [UIFont systemFontOfSize:16],
									   NSForegroundColorAttributeName: [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0]
									   }forState:UIControlStateNormal];

	}
}

- (void)selectItemForViewController:(UIViewController*)viewController
{
	NSUInteger index = [self.viewControllers indexOfObject:viewController];
	if(index != NSNotFound)
	{
		UITabBarItem *item = [self.tabBar.items objectAtIndex:index];
		[item setTitleTextAttributes:@{
									   NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
									   NSForegroundColorAttributeName: [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0]
									   }forState:UIControlStateNormal];
	}
}

@end
