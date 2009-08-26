@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import "QueryBar.j"
//http://pagesperso-orange.fr/cocoadev/SmartFolders/

//TODO: add "Egg" and "Eggs" and remove "Egg(s)" in Lifestage
@implementation SpecimenSearchView : CPView
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
    	var title = [[CPTextField alloc] initWithFrame:CGRectMake(0, 0, 155, 25)];
    	[title setObjectValue:@"Specimen"];
    	[title setFont:[CPFont boldSystemFontOfSize:14]];
    	[self addSubview:title];
        labels = [[CPArray alloc] initWithObjects:@"Sex", @"Lifestage", @"Preservative", @"Tissues taken"];
        var specimenQueryBar = [[QueryBar alloc] initWithFrame:CGRectMake(20, 26, 560, 26) identifier:@"Specimen" delegate:self];//(10, 27, 550, 26)
        [specimenQueryBar addPopUpButtonWithSelectLabel:@"Sex" inLabelArray:labels];
        [specimenQueryBar addLimitedPopUpButtonWithSelectLabel:@"is Male" inLabels:@"is Male", @"is Female"];
        [specimenQueryBar addAddButtonEnabled:YES removeButtonEnabled:YES];
        [self addSubview:specimenQueryBar];
        //[self setNeedsDisplay:YES];
        _bars = [[CPArray alloc] initWithObjects:specimenQueryBar];
        //[self setPostsFrameChangedNotifications:YES];
        nc = [CPNotificationCenter defaultCenter];
    }
    return self;
}

-(void)switchedFirstPopUpItem:(id)sender toTitle:(CPString)aTitle
{
	var frame = [sender frame];
	//[sender removeFromSuperview];
	
	var item = [[QueryBar alloc] initWithFrame:frame identifier:@"Specimen" delegate:self];//(10, 27, 550, 26)
    [item addPopUpButtonWithSelectLabel:aTitle inLabelArray:labels];
	if([aTitle isEqualToString:@"Sex"])
	{
		[item addLimitedPopUpButtonWithSelectLabel:@"is Male" inLabels:@"is Male", @"is Female"];
	}
	else if([aTitle isEqualToString:@"Lifestage"])
	{ 
		[item addIsIsNotItem];
		[item addPopUpButtonWithSelectLabel:@"Egg" inLabels:@"Egg", @"Eggs", @"Embryo", @"Larva", @"Juvenile", @"Juvenile/Adult", @"Adult"];
	}
	else if([aTitle isEqualToString:@"Preservative"])
	{
		[item addIsIsNotItem];
		[item addPopUpButtonWithSelectLabel:@"Alcohol (ethonol)" inLabels:@"Alcohol (ethonol)", @"Cleared and stained", @"Dried skin or skeletal material", @"Formalin"];
	}
	else if([aTitle isEqualToString:@"Tissues taken"])
	{
		[item addLimitedPopUpButtonWithSelectLabel:@"is YES" inLabels:@"is YES", @"is NO"];
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
	var frame = CGRectMake(20, y, 560, 26);
    
	var newSelectedLabel;
    if([selectedTitle isEqualToString:@"Sex"]) 
        newSelectedLabel = @"Lifestage";
    else if([selectedTitle isEqualToString:@"Lifestage"]) 
        newSelectedLabel = @"Preservative";
    else if([selectedTitle isEqualToString:@"Preservative"])
        newSelectedLabel = @"Tissues taken";
    else if([selectedTitle isEqualToString:@"Tissues taken"])
        newSelectedLabel = @"Sex"; 

	var specimenQueryBar = [[QueryBar alloc] initWithFrame:frame identifier:@"Specimen" delegate:self];//(10, 27, 550, 26)
    [specimenQueryBar addPopUpButtonWithSelectLabel:newSelectedLabel inLabelArray:labels];
	if([newSelectedLabel isEqualToString:@"Sex"])
	{
		[specimenQueryBar addLimitedPopUpButtonWithSelectLabel:@"is Male" inLabels:@"is Male", @"is Female"];
	}
	else if([newSelectedLabel isEqualToString:@"Lifestage"])
	{ 
		[specimenQueryBar addIsIsNotItem];
		[specimenQueryBar addPopUpButtonWithSelectLabel:@"Egg" inLabels:@"Egg", @"Eggs", @"Embryo", @"Larva", @"Juvenile", @"Juvenile/Adult", @"Adult"];
	}
	else if([newSelectedLabel isEqualToString:@"Preservative"])
	{
		[specimenQueryBar addIsIsNotItem];
		[specimenQueryBar addPopUpButtonWithSelectLabel:@"Alcohol (ethonol)" inLabels:@"Alcohol (ethonol)", @"Cleared and stained", @"Dried skin or skeletal material", @"Formalin"];
	}
	else if([newSelectedLabel isEqualToString:@"Tissues taken"])
	{
		[specimenQueryBar addLimitedPopUpButtonWithSelectLabel:@"is YES" inLabels:@"is YES", @"is NO"];
	}
	[self addSubview:specimenQueryBar];
	[_bars addObject:specimenQueryBar];
	[specimenQueryBar addAddButtonEnabled:YES removeButtonEnabled:YES];
    [self setFrameSize:CGSizeMake(560, CPRectGetHeight([self frame]) + CPRectGetHeight([specimenQueryBar frame]) + 1)];
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
	var specimenQuery = [[CPArray alloc] init];
	for(var i = 0; i < [_bars count]; i++)
	{
		var currentBar = [_bars objectAtIndex:i];
		var qPart = [[CPArray alloc] initWithObjects:[currentBar titleOfFirstItem]];
		
		//[qPart addObject:[components objectAtIndex:0]];
		if([[currentBar titleOfFirstItem] isEqualToString:@"Sex"])
		{
			var components = [[currentBar titleOfSecondItem] componentsSeparatedByString:@" "];
			[qPart addObject:@"is"];
			[qPart addObject:[[components objectAtIndex:1] substringToIndex:1]];
		}
		else if([[currentBar titleOfFirstItem] isEqualToString:@"Lifestage"])
		{
			if([[currentBar titleOfThirdItem] isEqualToString:@"Embryo"])
			{
				[qPart addObject:@"Emb"];
			}
			else if([[currentBar titleOfThirdItem] isEqualToString:@"Juvenile"])
			{
				[qPart addObject:@"Juv"];
			}
			else if([[currentBar titleOfThirdItem] isEqualToString:@"Juvenile/Adult"])
			{
				[qPart addObject:@"J/A"];
			}
			else
			{
				[qPart addObject:[currentBar titleOfThirdItem]];
			}
		}
		else if([[currentBar titleOfFirstItem] isEqualToString:@"Preservative"])
		{
			if([[currentBar titleOfThirdItem] isEqualToString:@"Alcohol (ethonol)"])
			{
				[qPart addObject:@"Alc"];
			}
			else if([[currentBar titleOfThirdItem] isEqualToString:@"Cleared and stained"])
			{
				[qPart addObject:@"C&S"];
			}
			else if([[currentBar titleOfThirdItem] isEqualToString:@"Dried skin or skeletal material"])
			{
				[qPart addObject:@"Dry"];
			}
			else if([[currentBar titleOfThirdItem] isEqualToString:@"Formalin"])
			{
				[qPart addObject:@"Form"];
			}
		}
		else
		{			
			var components = [[currentBar titleOfSecondItem] componentsSeparatedByString:@" "];
			[qPart addObject:[components objectAtIndex:1]];
		}
			
		if(![[currentBar titleOfThirdItem] isEqualToString:@""])
			[specimenQuery addObject:qPart];	
	}
	return specimenQuery;
}
@end       
        