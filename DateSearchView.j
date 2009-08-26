@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import "QueryBar.j"
//http://pagesperso-orange.fr/cocoadev/SmartFolders/
@implementation DateSearchView : CPView
{
	CPArray _bars;
	CPString label;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if(self)
    {
        var title = [[CPTextField alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    	[title setObjectValue:@"Date"];
    	[title setFont:[CPFont boldSystemFontOfSize:14]];
    	[self addSubview:title];
        
        label = @"Year specimen collected";
        var dateQueryBar = [[QueryBar alloc] initWithFrame:CGRectMake(20, 26, 560, 26) identifier:@"Date" delegate:self];//(10, 27, 550, 26)
        [dateQueryBar addTextWithLabel:label];
        [dateQueryBar addPopUpButtonWithSelectLabel:@"is" inLabels:@"is", @"is between", @"is or after", @"is or before", @"is not", @"is not between"];
        [dateQueryBar addTextFieldItemWithDelegate:nil];
        [dateQueryBar addAddButtonEnabled:NO removeButtonEnabled:YES];
        [self addSubview:dateQueryBar];
        //[self setNeedsDisplay:YES];
        _bars = [[CPArray alloc] initWithObjects:dateQueryBar];
        [self setPostsFrameChangedNotifications:YES];
    }
    return self;
}

-(void)switchedSecondPopUpItem:(id)sender toTitle:(CPString)aTitle
{
	[[_bars objectAtIndex:0] removeFromSuperview];
	[_bars removeObjectAtIndex:0];
    var newDateQueryBar = [[QueryBar alloc] initWithFrame:CGRectMake(20, 26, 560, 26) identifier:@"Date" delegate:self];//(10, 27, 550, 26)
    [newDateQueryBar addTextWithLabel:label];
    [newDateQueryBar addPopUpButtonWithSelectLabel:aTitle inLabels:@"is", @"is between", @"is or after", @"is or before", @"is not", @"is not between"];
        
	if([aTitle isEqualToString:@"is between"] || [aTitle isEqualToString:@"is not between"])
    {
    	[newDateQueryBar addTextFieldsSeperatedByLabel:@"and"];
    }
    else
    {
    	[newDateQueryBar addTextFieldItemWithDelegate:nil];
    }
    
    [newDateQueryBar addAddButtonEnabled:NO removeButtonEnabled:YES];
    [self addSubview:newDateQueryBar];
    [_bars addObject:newDateQueryBar];
}

-(void)removeSearchItem:(id)sender
{
	if([_bars count] == 1)
	{
		[[self superview] searchWasRemoved:self shouldDeselect:YES];
		return;
	}
}

-(CPArray)searchValues
{
	var dateQuery = [[CPArray alloc] init];
	var qPart = [[CPArray alloc] init];
	[qPart addObject:@"Year Collected"];
	[qPart addObject:[[_bars objectAtIndex:0] titleOfSecondItem]];
	[qPart addObject:[[_bars objectAtIndex:0] titleOfThirdItem]];
	if(![[[_bars objectAtIndex:0] titleOfThirdItem] isEqualToString:@""])
		[dateQuery addObject:qPart];	
	return dateQuery;
}

@end