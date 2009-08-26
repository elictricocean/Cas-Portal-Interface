@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import "QueryBar.j"
//http://pagesperso-orange.fr/cocoadev/SmartFolders/
@implementation CollectionSearchView : CPView
{
	CPArray _bars;
	CPArray labels;
	CPNotificationCenter nc;
}

- (id)initWithFrame:(CGRect)aFrame 
{
    self = [super initWithFrame:aFrame];
    if(self)
    {
    	var title = [[CPTextField alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    	[title setObjectValue:@"Collection"];
    	[title setFont:[CPFont boldSystemFontOfSize:14]];
    	[self addSubview:title];
        labels = [[CPArray alloc] initWithObjects:@"Specimen location", @"Catalog Number", @"Collector", @"Collector's Number"];
        var collectionQueryBar = [[QueryBar alloc] initWithFrame:CGRectMake(20, 26, 560, 26) identifier:@"Collection" delegate:self];//(10, 27, 550, 26)
        [collectionQueryBar addPopUpButtonWithSelectLabel:@"Specimen location" inLabelArray:labels];
        [collectionQueryBar addIsIsNotItem];
		[collectionQueryBar addPopUpButtonWithSelectLabel:@"at California Academy of Sciences" inLabels:@"at California Academy of Sciences", @"at CAS Stanford University (Amphibians)", @"at CAS Stanford University (Reptiles)"];
        [collectionQueryBar addAddButtonEnabled:YES removeButtonEnabled:YES];
        [self addSubview:collectionQueryBar];
        //[self setNeedsDisplay:YES];
        _bars = [[CPArray alloc] initWithObjects:collectionQueryBar];
        //[self setPostsFrameChangedNotifications:YES];
        nc = [CPNotificationCenter defaultCenter];
    }
    return self;
}

-(void)switchedFirstPopUpItem:(id)sender toTitle:(CPString)aTitle
{
	var frame = [sender frame];
	//[sender removeFromSuperview];
	
	var item = [[QueryBar alloc] initWithFrame:frame identifier:@"Location" delegate:self];//(10, 27, 550, 26)
    [item addPopUpButtonWithSelectLabel:aTitle inLabelArray:labels];
	if([aTitle isEqualToString:@"Specimen location"])
	{
		[item addIsIsNotItem];
		[item addPopUpButtonWithSelectLabel:@"at California Academy of Sciences" inLabels:@"at California Academy of Sciences", @"at CAS Stanford University (Amphibians)", @"at CAS Stanford University (Reptiles)"];
	}
	else if([aTitle isEqualToString:@"Catalog Number"])
	{ 
		[item addIsBetweenItemWithSelectedLabel:@"is"];
        [item addTextFieldItemWithDelegate:nil];
	}
	else if([aTitle isEqualToString:@"Collector"])
	{
		[item addIsContainsItem];
	    [item addTextFieldItemWithDelegate:self];
	}
	else if([aTitle isEqualToString:@"Collector's Number"])
	{
		[item addIsContainsItem];
		[item addTextFieldsSeperatedByLabel:@"-" widthOfFirstTextField:30];
	}
	[item addAddButtonEnabled:YES removeButtonEnabled:YES];	
    [self replaceSubview:sender with:item];
	[_bars replaceObjectAtIndex:[_bars indexOfObject:sender] withObject:item];
}

-(void)switchedSecondPopUpItem:(id)sender toTitle:(CPString)aTitle
{
	if(![sender isTitleOfFirstItem:@"Catalog Number"])
		return;
		
    var frame = [sender frame];
	//[sender removeFromSuperview];
	
	var item = [[QueryBar alloc] initWithFrame:frame identifier:@"Location" delegate:self];//(10, 27, 550, 26)
    [item addPopUpButtonWithSelectLabel:@"Catalog Number" inLabelArray:labels];
	if([aTitle isEqualToString:@"is between"] || [aTitle isEqualToString:@"is not between"])
	{
		[item addIsBetweenItemWithSelectedLabel:aTitle];
		[item addTextFieldsSeperatedByLabel:@"and"];
	}
	else
	{
		[item addIsBetweenItemWithSelectedLabel:aTitle];
		[item addTextFieldItemWithDelegate:nil];
	}
	[item addAddButtonEnabled:YES removeButtonEnabled:YES];	
    //[self addSubview:item];
	[self replaceSubview:sender with:item];
	[_bars replaceObjectAtIndex:[_bars indexOfObject:sender] withObject:item];
}

-(void)addSearchItemAfterSearchItem:(CPString)selectedTitle
{
	if([_bars count] == 1)
		[[_bars objectAtIndex:0] enableAddRemovebuttons];
		
    var y = CPRectGetMinY([[_bars lastObject] frame]) + 27;
	var frame = CGRectMake(20, y, 560, 26);
    
	var newSelectedLabel;
    if([selectedTitle isEqualToString:@"Specimen location"]) 
        newSelectedLabel = @"Catalog Number";
    else if([selectedTitle isEqualToString:@"Catalog Number"]) 
        newSelectedLabel = @"Collector";
    else if([selectedTitle isEqualToString:@"Collector"])
        newSelectedLabel = @"Collector's Number";
    else if([selectedTitle isEqualToString:@"Collector's Number"])
        newSelectedLabel = @"Specimen location"; 

	var collectionQueryBar 	= [[QueryBar alloc] initWithFrame:frame identifier:@"Location" delegate:self];//(10, 27, 550, 26)
	[collectionQueryBar addPopUpButtonWithSelectLabel:newSelectedLabel inLabelArray:labels];
	if([newSelectedLabel isEqualToString:@"Specimen location"])
	{
		[collectionQueryBar addIsIsNotItem];
		[collectionQueryBar addPopUpButtonWithSelectLabel:@"at California Academy of Sciences" inLabels:@"at California Academy of Sciences", @"at CAS Stanford University (Amphibians)", @"at CAS Stanford University (Reptiles)"];
	}
	else if([newSelectedLabel isEqualToString:@"Catalog Number"])
	{ 
		[collectionQueryBar addIsBetweenItemWithSelectedLabel:@"is"];
		[collectionQueryBar addTextFieldItemWithDelegate:nil];
	}
	else if([newSelectedLabel isEqualToString:@"Collector"])
	{
		[collectionQueryBar addIsContainsItem];
	    [collectionQueryBar addTextFieldItemWithDelegate:self];
	}
	else if([newSelectedLabel isEqualToString:@"Collector's Number"])
	{
		[collectionQueryBar addIsContainsItem];
		[collectionQueryBar addTextFieldsSeperatedByLabel:@"-" widthOfFirstTextField:30];
	}
	[collectionQueryBar addAddButtonEnabled:YES removeButtonEnabled:YES];
	//[collectionQueryBar enableAddRemovebuttons];
	[self addSubview:collectionQueryBar];
	[_bars addObject:collectionQueryBar];
    [self setFrameSize:CGSizeMake(560, CPRectGetHeight([self frame]) + CPRectGetHeight([collectionQueryBar frame]) + 1)];
    [nc postNotificationName:@"FrameChanged" object:self];
}

-(void)removeSearchItem:(id)sender
{
	if([_bars count] == 1)
	{
		[[self superview] searchWasRemoved:self shouldDeselect:YES];
		return;
	}
	
	[sender removeFromSuperview];
	var oldIndex = [_bars indexOfObject:sender];
	[_bars removeObjectAtIndex:oldIndex];
	for(var i = oldIndex; i < [_bars count]; i++)
	{
		var newOrigin = CPPointMake(CPRectGetMinX([[_bars objectAtIndex:i] frame]), CPRectGetMinY([[_bars objectAtIndex:i] frame]) - CPRectGetHeight([sender frame]) - 1);
		[[_bars objectAtIndex:i] setFrameOrigin:newOrigin];
	}
	if([_bars count] == 1)
		[[_bars objectAtIndex:0] enableAddButton:YES removeButton:YES];
		
	[self setFrameSize:CGSizeMake(560, CPRectGetHeight([self frame]) - CPRectGetHeight([sender frame]) - 1)];//27
	[nc postNotificationName:@"FrameChanged" object:self];
}

-(CPArray)searchValues
{
	var collectionQuery = [[CPArray alloc] init];
	for(var i = 0; i < [_bars count]; i++)
	{
		var currentBar = [_bars objectAtIndex:i];
		var qPart = [[CPArray alloc] initWithObjects:[currentBar titleOfFirstItem]];
		if([currentBar isTitleOfFirstItem:@"Specimen location"])
		{
			var components = [[currentBar titleOfSecondItem] componentsSeparatedByString:@" "];
			[qPart addObject:[components objectAtIndex:0]];
			if([[components objectAtIndex:1] isEqualToString:@"California Academy of Sciences"])
				[qPart addObject:@"CAS"];
			if([[components objectAtIndex:1] isEqualToString:@"CAS Stanford University (Amphibians)"])
				[qPart addObject:@"CAS-SUA"];
			if([[components objectAtIndex:1] isEqualToString:@"CAS Stanford University (Reptiles)"])
				[qPart addObject:@"CAS-SUR"];
		}
		else
		{
			[qPart addObject:[currentBar titleOfSecondItem]];
			[qPart addObject:[currentBar titleOfThirdItem]];
		}
		if(![[currentBar titleOfThirdItem] isEqualToString:@""])
			[collectionQuery addObject:qPart];
	}
	return collectionQuery;
}

@end       
        