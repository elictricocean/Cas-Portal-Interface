@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import "QueryBar.j"
@import "CASMapWindow.j"

@implementation LocationSearchView : CPView
{
	CPArray _bars;
	CPArray labels;
	CPNotificationCenter nc;
	var simpleWarning;
	CPWindow mapWindow;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if(self)
    {
    	var title = [[CPTextField alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    	[title setObjectValue:@"Location"];
    	[title setFont:[CPFont boldSystemFontOfSize:14]];
    	[self addSubview:title];

		var mapButton = [CPButton buttonWithTitle:@"Fill using map"];
		[mapButton setFrameOrigin:CGPointMake(CPRectGetWidth([self frame]) - 5 - CPRectGetWidth([mapButton frame]), 0)];
		[mapButton setTarget:self];
		[mapButton setAction:@selector(openMap:)];
		[self addSubview:mapButton];
    	
        labels = [[CPArray alloc] initWithObjects:@"Continent/Ocean", @"Country", @"State/Province", @"County", @"Island Group", @"Locality", @"Elevation", @"Bounding Box", @"Point/Radius"];
        var simpleLabels = [[CPArray alloc] initWithObjects:@"Name (Simple)", @"Continent/Ocean", @"Country", @"State/Province", @"County", @"Island Group", @"Locality", @"Elevation", @"Bounding Box", @"Point/Radius"];
        var locationQueryBar = [[QueryBar alloc] initWithFrame:CGRectMake(20, 26, 560, 26) identifier:@"Location" delegate:self];//(10, 27, 550, 26)
        [locationQueryBar addPopUpButtonWithSelectLabel:@"Name (Simple)" inLabelArray:simpleLabels];
        [locationQueryBar addIsContainsItem];
        [locationQueryBar addTextFieldItemWithDelegate:self];
        [locationQueryBar addAddButtonEnabled:NO removeButtonEnabled:YES];
        [self addSubview:locationQueryBar];
        _bars = [[CPArray alloc] initWithObjects:locationQueryBar];
		simpleWarning = [[CPTextField alloc] initWithFrame:CGRectMake(20, CPRectGetMinY([locationQueryBar frame])+CPRectGetHeight([locationQueryBar frame])+5, 560, 40)];
		[simpleWarning setAlignment:CPCenterTextAlignment]
		[simpleWarning setStringValue:@"Name (Simple) is used when you don't know anything in the drop down list.\n If you feel comfortable, change the first popup to enter advanced queries and add more fields."];
		[simpleWarning setFont:[CPFont systemFontOfSize:12]];
		[simpleWarning setTextColor:[CPColor grayColor]]; 
		[self addSubview:simpleWarning];
        nc = [CPNotificationCenter defaultCenter];
    }
    return self;
}

-(void)switchedFirstPopUpItem:(id)sender toTitle:(CPString)aTitle
{
    if(![aTitle isEqualToString:@"Name (Simple)"] && ![sender addAddRemoveButtonsEnabled])
	{
        [sender enableAddButton:YES removeButton:YES];
		[simpleWarning removeFromSuperview];
		[self setFrame:CGRectMake(CPRectGetMinX([self frame]), CPRectGetMinY([self frame]), CPRectGetWidth([self frame]), 52)];
		[nc postNotificationName:@"FrameChanged" object:self];
	}
    else if([aTitle isEqualToString:@"Name (Simple)"] && [sender addAddRemoveButtonsEnabled])
        [sender disableAddRemovebuttons];

	var frame = [sender frame];
	var item = [[QueryBar alloc] initWithFrame:frame identifier:@"Location" delegate:self];//(10, 27, 550, 26)
    [item addPopUpButtonWithSelectLabel:aTitle inLabelArray:labels];
	if([aTitle isEqualToString:@"Elevation"])
	{
		[item addIsBetweenItemWithSelectedLabel:@"is between"];
        [item addTextFieldsSeperatedByLabel:@"and"];
	}
	else if([aTitle isEqualToString:@"Bounding Box"])
	{
		[item addIsContainsItem];
    	[item addTextFieldItemWithPlaceholder:@"{lat,lon,width,height}"];
	}
	else if([aTitle isEqualToString:@"Point/Radius"])
	{
		[item addIsContainsItem];
    	[item addTextFieldItemWithPlaceholder:@"{lon,lat,radius in km}"];
	}
	else
	{ 
		[item addIsContainsItem];
        [item addTextFieldItemWithDelegate:self];
	}
	[item addAddButtonEnabled:YES removeButtonEnabled:YES];	
    [self replaceSubview:sender with:item];
	[_bars replaceObjectAtIndex:[_bars indexOfObject:sender] withObject:item];
} 

-(void)switchedSecondPopUpItem:(id)sender toTitle:(CPString)aTitle
{
	if(![sender isTitleOfFirstItem:@"Elevation"])
		return;
		
	var frame = [sender frame];
	var item = [[QueryBar alloc] initWithFrame:frame identifier:@"Location" delegate:self];//(10, 27, 550, 26)
	[item addPopUpButtonWithSelectLabel:@"Elevation" inLabelArray:labels];
	if([aTitle isEqualToString:@"is between"] || [aTitle isEqualToString:@"is not between"])
	{
		[item addIsBetweenItemWithSelectedLabel:aTitle];
	    [item addTextFieldsSeperatedByLabel:@"and"];
	}
	else
	{ 
		[item addIsBetweenItemWithSelectedLabel:aTitle];
		[item addTextFieldItemWithDelegate:self];
	}
	[item addAddButtonEnabled:YES removeButtonEnabled:YES];
	[self replaceSubview:sender with:item];
	[_bars replaceObjectAtIndex:[_bars indexOfObject:sender] withObject:item];
}

-(void)addSearchItemAfterSearchItem:(CPString)selectedTitle
{
	if([_bars count] == 1)
		[[_bars objectAtIndex:0] enableAddRemovebuttons];
		
    var y = CPRectGetMinY([[_bars lastObject] frame]) + 27;
    var locationQueryBar = [[QueryBar alloc] initWithFrame:CGRectMake(20, y, 560, 26) identifier:@"Location" delegate:self];
    
    var newSelectedLabel;
    if([selectedTitle isEqualToString:@"Continent/Ocean"]) 
        newSelectedLabel = @"Country";
    else if([selectedTitle isEqualToString:@"Country"]) 
        newSelectedLabel = @"State/Province";
    else if([selectedTitle isEqualToString:@"State/Province"])
        newSelectedLabel = @"County";
    else if([selectedTitle isEqualToString:@"County"])
        newSelectedLabel = @"Island Group"; 
    else if([selectedTitle isEqualToString:@"Island Group"])   
        newSelectedLabel = @"Locality";
    else if([selectedTitle isEqualToString:@"Locality"])
        newSelectedLabel = @"Elevation";
    else if([selectedTitle isEqualToString:@"Elevation"])
        newSelectedLabel = @"Bounding Box";
    else if([selectedTitle isEqualToString:@"Bounding Box"])
        newSelectedLabel = @"Point/Radius";
    else if([selectedTitle isEqualToString:@"Point/Radius"])
        newSelectedLabel = @"Continent/Ocean";
    
    [locationQueryBar addPopUpButtonWithSelectLabel:newSelectedLabel inLabelArray:labels];
	if([newSelectedLabel isEqualToString:@"Elevation"])
	{
		[locationQueryBar addIsBetweenItemWithSelectedLabel:@"is between"];
	    [locationQueryBar addTextFieldsSeperatedByLabel:@"and"];
	}
	else if([newSelectedLabel isEqualToString:@"Bounding Box"])
	{
		[locationQueryBar addIsContainsItem];
    	[locationQueryBar addTextFieldItemWithPlaceholder:@"{lat,lon,width,height}"];
	}
	else if([newSelectedLabel isEqualToString:@"Point/Radius"])
	{
		[locationQueryBar addIsContainsItem];
    	[locationQueryBar addTextFieldItemWithPlaceholder:@"{lon,lat,radius in km}"];
	}
	else
	{
    	[locationQueryBar addIsContainsItem];
    	[locationQueryBar addTextFieldItemWithDelegate:self];
	}
    [locationQueryBar addAddButtonEnabled:YES removeButtonEnabled:YES];
    [self addSubview:locationQueryBar];
    [_bars addObject:locationQueryBar];
    [self setFrameSize:CGSizeMake(560, CPRectGetHeight([self frame]) + CPRectGetHeight([locationQueryBar frame]) + 1)];
    [nc postNotificationName:@"FrameChanged" object:self];
}

-(void)addSearchItemWithTitle:(CPString)aTitle value:(CPString)aValue
{
	var addRemoveButton = YES;
	if([_bars count] == 1)
	{	
		CPLog(@"title is " + [[_bars objectAtIndex:0] titleOfFirstItem]);	
		if([[_bars objectAtIndex:0] isTitleOfFirstItem:@"Name (Simple)"])
		{
			[[_bars objectAtIndex:0] removeFromSuperview];
			[_bars removeObjectAtIndex:0];
			[simpleWarning removeFromSuperview];
			addRemoveButton = NO;
		}
		else
			[[_bars objectAtIndex:0] enableAddRemovebuttons];
	}
		
    var y = 27;
    if([_bars count] > 0)
    	y += CPRectGetMinY([[_bars lastObject] frame]);
    	
	var locationQueryBar = [[QueryBar alloc] initWithFrame:CGRectMake(20, y, 560, 26) identifier:@"Location" delegate:self];
    
   	[locationQueryBar addPopUpButtonWithSelectLabel:aTitle inLabelArray:labels];
	[locationQueryBar addIsContainsItem];
	if([aTitle isEqualToString:@"Bounding Box"])
	{
		[locationQueryBar addTextFieldItemWithPlaceholder:@"{lat,lon,width,height}"];
	}
	else if([aTitle isEqualToString:@"Point/Radius"])
	{
		[locationQueryBar addTextFieldItemWithPlaceholder:@"{lon,lat,radius in km}"];
	}
	else
    	[locationQueryBar addTextFieldItemWithDelegate:self];
    [locationQueryBar setStringValueForThirdItem:aValue];
    [locationQueryBar addAddButtonEnabled:YES removeButtonEnabled:addRemoveButton];
    [self addSubview:locationQueryBar];
    [_bars addObject:locationQueryBar];
    [self setFrameSize:CGSizeMake(560, CPRectGetHeight([self frame]) + CPRectGetHeight([locationQueryBar frame]) + 1)];
    [nc postNotificationName:@"FrameChanged" object:self];
}

-(void)removeSearchItem:(id)sender
{
	if([_bars count] == 1)
	{
		[[self superview] searchWasRemoved:self shouldDeselect:YES];
		return;
	}
	
	/*if([_bars count] == 1)
	{
		[[_bars objectAtIndex:0] enableAddButton:YES removeButton:NO];
		return;
	}*/
	[sender removeFromSuperview];
	var oldIndex = [_bars indexOfObject:sender];
	[_bars removeObjectAtIndex:oldIndex];
	for(var i = oldIndex; i < [_bars count]; i++)
	{
		var newOrigin = CPPointMake(CPRectGetMinX([[_bars objectAtIndex:i] frame]), CPRectGetMinY([[_bars objectAtIndex:i] frame]) - CPRectGetHeight([sender frame]) - 1);
		[[_bars objectAtIndex:i] setFrameOrigin:newOrigin];
	}
	//if([_bars count] == 1)
		//[[_bars objectAtIndex:0] enableAddButton:YES removeButton:YES];
		
	[self setFrameSize:CGSizeMake(560, CPRectGetHeight([self frame]) - CPRectGetHeight([sender frame]) - 1)];
	[nc postNotificationName:@"FrameChanged" object:self];
}

-(CPArray)searchValues
{
	var locationQuery = [[CPArray alloc] init];
	for(var i = 0; i < [_bars count]; i++)
	{
		var currentBar = [_bars objectAtIndex:i];
		var qPart = [[CPArray alloc] initWithObjects:[currentBar titleOfFirstItem]];
		[qPart addObject:[currentBar titleOfSecondItem]];
		[qPart addObject:[currentBar titleOfThirdItem]];
		
		if(![[currentBar titleOfThirdItem] isEqualToString:@""])
			[locationQuery addObject:qPart];	
	}
	return locationQuery;
}

-(void)openMap:(id)sender
{
	if(!mapWindow)
		mapWindow = [[CASMapWindow alloc] initWithDelegate:self];
		
	[mapWindow orderFront:sender];
}

-(void)mapEndedWithValues:(CPArray)anArray
{
	for(var i = 0; i < [anArray count]; i++)
	{
		var info = [anArray objectAtIndex:i];
		if(![[info objectForKey:@"type"] isEqualToString:@"location"])
			[self addSearchItemWithTitle:[info objectForKey:@"type"] value:[info objectForKey:@"title"]];
		else
		{
			if([info objectForKey:@"Continent/Ocean"])
				[self addSearchItemWithTitle:@"Continent/Ocean" value:[info objectForKey:@"Continent/Ocean"]];
			if([info objectForKey:@"Country"])
				[self addSearchItemWithTitle:@"Country" value:[info objectForKey:@"Country"]];
			if([info objectForKey:@"State/Province"])
				[self addSearchItemWithTitle:@"State/Province" value:[info objectForKey:@"State/Province"]];
			if([info objectForKey:@"Locality"])
				[self addSearchItemWithTitle:@"Locality" value:[info objectForKey:@"Locality"]];
		}
	}
	
	[mapWindow close];
	mapWindow = nil;
}

@end