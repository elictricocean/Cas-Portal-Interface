@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import "QueryBar.j"
//@import "CASTaxonBrowser.j"
//@import "xml2array.js"
//http://pagesperso-orange.fr/cocoadev/SmartFolders/
@implementation TaxonSearchView : CPView
{
	CPArray _bars;
	CPArray labels;
	CPNotificationCenter nc;
	var simpleWarning;
	//CPArray txonXML;
	CPMenu typeAheadMenu;
	_CPMenuWindow typeAheadMenuWindow;
	CPURLConnection typeAheadConnection;
}

- (id)initWithFrame:(CGRect)aFrame 
{
    self = [super initWithFrame:aFrame];
    if(self)
    {
		//[self setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/searchBarBlue.png" size:CGSizeMake(1.0, 36.0)]]];
    	var title = [[CPTextField alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    	[title setObjectValue:@"Taxon (Name)"];
    	[title setFont:[CPFont boldSystemFontOfSize:14]];
    	[self addSubview:title];
        labels = [[CPArray alloc] initWithObjects:@"Class", @"Order/Suborder", @"Family", @"Genus", @"Species", @"Subspecies", @"Biological type"];
        var simpleLabels = [[CPArray alloc] initWithObjects:@"Name (Simple)", @"Class", @"Order/Suborder", @"Family", @"Genus", @"Species", @"Subspecies", @"Biological type"];
        var taxonQueryBar = [[QueryBar alloc] initWithFrame:CGRectMake(20, 26, 560, 26) identifier:@"Taxon" delegate:self];//(10, 27, 550, 26)
        [taxonQueryBar addPopUpButtonWithSelectLabel:@"Name (Simple)" inLabelArray:simpleLabels];
        [taxonQueryBar addIsContainsItem];
        [taxonQueryBar addLinkTextFieldItemWithDelegate:self];
        [taxonQueryBar addAddButtonEnabled:NO removeButtonEnabled:YES];
        [self addSubview:taxonQueryBar];
        //[self setNeedsDisplay:YES];
        _bars = [[CPArray alloc] initWithObjects:taxonQueryBar];
        simpleWarning = [[CPTextField alloc] initWithFrame:CGRectMake(20, CPRectGetMinY([taxonQueryBar frame])+CPRectGetHeight([taxonQueryBar frame])+5, 560, 40)];
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
	var item = [[QueryBar alloc] initWithFrame:frame identifier:@"Taxon" delegate:self];//(10, 27, 550, 26)
    [item addPopUpButtonWithSelectLabel:aTitle inLabelArray:labels];
	if([aTitle isEqualToString:@"Biological type"])
	{
		[item addIsIsNotItem];
		[item addPopUpButtonWithSelectLabel:@"Allotype" inLabels:@"Allotype", @"Holotype", @"Lectotype", @"Neotype", @"Paralectotype", @"Paratype", @"Syntype"];
	}
	else
	{ 
		[item addIsContainsItem];
        [item addLinkTextFieldItemWithDelegate:self];
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
	var taxonQueryBar = [[QueryBar alloc] initWithFrame:CGRectMake(20, y, 560, 26) identifier:@"Taxon" delegate:self];
    
    //var selectedTitle = [selectedTitleField objectValue];
    var newSelectedLabel;
    if([selectedTitle isEqualToString:@"Class"]) 
        newSelectedLabel = @"Order/Suborder";
    else if([selectedTitle isEqualToString:@"Order/Suborder"]) 
        newSelectedLabel = @"Family";
    else if([selectedTitle isEqualToString:@"Family"])
        newSelectedLabel = @"Genus";
    else if([selectedTitle isEqualToString:@"Genus"])
        newSelectedLabel = @"Species"; 
    else if([selectedTitle isEqualToString:@"Species"])   
        newSelectedLabel = @"Subspecies";
    else if([selectedTitle isEqualToString:@"Subspecies"])
        newSelectedLabel = @"Biological type";
	else if([selectedTitle isEqualToString:@"Biological type"])
		newSelectedLabel = @"Class";
    
   	[taxonQueryBar addPopUpButtonWithSelectLabel:newSelectedLabel inLabelArray:labels];
	if([newSelectedLabel isEqualToString:@"Biological type"])
	{
		[taxonQueryBar addIsIsNotItem];
		[taxonQueryBar addPopUpButtonWithSelectLabel:@"Allotype" inLabels:@"Allotype", @"Holotype", @"Lectotype", @"Neotype", @"Paralectotype", @"Paratype", @"Syntype"];
	}
	else
	{
    	[taxonQueryBar addIsContainsItem];
    	[taxonQueryBar addLinkTextFieldItemWithDelegate:self];
	}
    [taxonQueryBar addAddButtonEnabled:YES removeButtonEnabled:YES];
    [self addSubview:taxonQueryBar];
    [_bars addObject:taxonQueryBar];
    [self setFrameSize:CGSizeMake(560, CPRectGetHeight([self frame]) + CPRectGetHeight([taxonQueryBar frame]) + 1)];
    [nc postNotificationName:@"FrameChanged" object:self];
}

-(void)addSearchItemWithTitle:(CPString)aTitle value:(CPString)aValue
{
	CPLog([_bars count]);
	if([_bars count] == 1)
	{	
		CPLog([[_bars objectAtIndex:0] titleOfFirstItem]);	
		if([[_bars objectAtIndex:0] isTitleOfFirstItem:@"Name (Simple)"])
		{
			[[_bars objectAtIndex:0] removeFromSuperview];
			[_bars removeObjectAtIndex:0];
			[simpleWarning removeFromSuperview]
		}
		else
			[[_bars objectAtIndex:0] enableAddRemovebuttons];
	}
		
    var y = 27;
    if([_bars count] > 0)
    	y += CPRectGetMinY([[_bars lastObject] frame]);
    	
	var taxonQueryBar = [[QueryBar alloc] initWithFrame:CGRectMake(20, y, 560, 26) identifier:@"Taxon" delegate:self];
    
   	[taxonQueryBar addPopUpButtonWithSelectLabel:aTitle inLabelArray:labels];
	[taxonQueryBar addIsContainsItem];
    [taxonQueryBar addLinkTextFieldItemWithDelegate:self];
    [taxonQueryBar setStringValueForThirdItem:aValue];
    [taxonQueryBar addAddButtonEnabled:YES removeButtonEnabled:YES];
    [self addSubview:taxonQueryBar];
    [_bars addObject:taxonQueryBar];
    [self setFrameSize:CGSizeMake(560, CPRectGetHeight([self frame]) + CPRectGetHeight([taxonQueryBar frame]) + 1)];
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
	//if([_bars count] == 1)
		//[[_bars objectAtIndex:0] enableAddButton:YES removeButton:NO];
		
	[self setFrameSize:CGSizeMake(560, CPRectGetHeight([self frame]) - CPRectGetHeight([sender frame]) - 1)];
	[nc postNotificationName:@"FrameChanged" object:self];
}

-(id)searchValues
{
	var taxonQuery = [[CPArray alloc] init];
	for(var i = 0; i < [_bars count]; i++)
	{
		var currentBar = [_bars objectAtIndex:i];
		var qPart = [[CPArray alloc] init];
		if([currentBar isTitleOfFirstItem:@"Species"])
			[qPart addObject:@"Sp"];
		else if([currentBar isTitleOfFirstItem:@"Subspecies"])
			[qPart addObject:@"Ssp"];
		else
			[qPart addObject:[currentBar titleOfFirstItem]];
		[qPart addObject:[currentBar titleOfSecondItem]];
		[qPart addObject:[currentBar titleOfThirdItem]];
		if(![[currentBar titleOfThirdItem] isEqualToString:@""])
			[taxonQuery addObject:qPart];	
	}
	return taxonQuery;
}

-(void)controlTextDidChange:(id)aNote
{
	CPLog(@"typine..");
	queryBar = [aNote isKindOfClass:[CPNotification class]] ? [[aNote userInfo] objectForKey:@"queryBar"] : aNote;
	
	CPLog(@"query bar is %@", [queryBar titleOfFirstItem]);
	//set up request
	var field;
	if([queryBar isTitleOfFirstItem:@"Species"])
	{
		field = "Sp";
		CPLog(@"species");
	}
	else if([queryBar isTitleOfFirstItem:@"Subspecies"])
		field = "Ssp";
	else
	{
		CPLog(@"not species");
		field = [queryBar titleOfFirstItem];
	}
		
	var request = [[CPURLRequest alloc] initWithURL:@"./php/typeahead.php?field=" + field + @"&value=" + [queryBar titleOfThirdItem]];// + @"&filters=" + [CPString JSONFromObject:[self searchValues]]
	typeAheadConnection = [[CPURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	CPLog(@"request is %@", typeAheadConnection);
	//[self connection:searchConnection didRecieveData:@"Yeah"];
	//typeAheadMenuWindow = nil;
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)jsonString
{
	if(aConnection == typeAheadConnection)
	{
		CPLog(@"menu win is %@", typeAheadMenuWindow);
		if(typeAheadMenuWindow)
		{
			CPLog(@"menu win is %@", typeAheadMenuWindow);
			[_CPMenuWindow poolMenuWindow:typeAheadMenuWindow];
			typeAheadMenuWindow = nil;
			CPLog([queryBar titleOfThirdItem]);
			if(![queryBar titleOfThirdItem] || [[queryBar titleOfThirdItem] isEqualToString:@""])
				return;
		}
		CPLog(@"loaded");
		var data = JSON.parse(jsonString);
		
		if([data count] == 0)
			return;
			
		CPLog(@"data is %@", data);
		var typeAheadMenu = [[CPMenu alloc] initWithTitle:@"typeahead"];
		for(var i = 0; i < [data count]; i++)//[[queryBar titleOfThirdItem] length]
		{
			var item = [[CPMenuItem alloc] initWithTitle:[data objectAtIndex:i] action:@selector(typedAhead:) keyEquivalent:nil];//[CPString stringWithFormat:@"item %d", i]/*
			[item setTarget:self];
			[typeAheadMenu addItem:item];
		}
		CPLog(@"max Y is " + CPRectGetMaxY([queryBar frameOfThirdItem]));
		typeAheadMenuWindow = [QueryBar popUpContextMenu:typeAheadMenu 
											  atLocation:[self convertPoint:CPPointMake(CPRectGetMinX([queryBar frameOfThirdItem])+12, CPRectGetMaxY([queryBar frameOfThirdItem])*5+14) fromView:queryBar /*toView:[self superview]*/]
											     forView:self 
										  ofWindowNumber:[[self window] windowNumber]];
		CPLog(@"menu win is %@", typeAheadMenuWindow);
		//queryBar = nil;
	}
}

-(void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
	CPLog(@"failed with error %@", anError);
}

- (void)connectionDidFinishLoading:(CPURLConnection)aConnection
{
	CPLog(@"done");
}

-(void)typedAhead:(id)sender
{
	var string = [sender title];
	[queryBar setStringValueForThirdItem:string];
}

-(void)buttonClickedWithTitle:(CPString)aTitle onQueryBar:(QueryBar)queryBar
{
	CPLog(@"clicked with title" + aTitle);
	if([aTitle isEqualToString:@"Name (Simple)"])
		aTitle = @"Class";
		
	var browser = [[CPWindow alloc] initWithContentRect:CGRectMake(50, 125, 800, 600) styleMask:CPClosableWindowMask];
	var outlineView = [[CASTaxonBrowser alloc] initWithTaxon:aTitle filters:nil delegate:self onQueryBar:queryBar];//Frame:CGRectMake(0,0, CPRectGetWidth([[browser contentView] frame]), CPRectGetHeight([[browser contentView] frame])) t
	[[browser contentView] addSubview:outlineView];
	[outlineView resizeParent];
	[browser orderFront:self];
}

-(void)taxonBrowser:(CASTaxonBrowser)browser endedWithValues:(CPDictionary)aDict
{
	CPLog(@"ended");
	var keys = [aDict allKeys];
	CPLog([aDict objectForKey:[keys objectAtIndex:0]]);
	
	var queryBar = [browser queryBar];
	var startTaxon = [browser startTaxon];
	
	if([aDict count] == 2)// Genus/Species
	{
		var genus = [aDict objectForKey:@"Genus"];
		var species = [aDict objectForKey:@"Species"];
		
		if([queryBar isTitleOfFirstItem:@"Genus"])
		{
			[queryBar setStringValueForThirdItem:genus];
			[self addSearchItemWithTitle:@"Species" value:species];
		}
		else if([queryBar isTitleOfFirstItem:@"Species"])
		{
			[queryBar setStringValueForThirdItem:species];
			[self addSearchItemWithTitle:@"Genus" value:genus];
		}
		else
		{
			[self addSearchItemWithTitle:@"Genus" value:genus];
			[self addSearchItemWithTitle:@"Species" value:species];
			[self removeSearchItem:queryBar];
		}
	}
	else if([[aDict objectForKey:[keys objectAtIndex:0]] isKindOfClass:[CPString class]])
	{
		if([startTaxon isEqualToString:[queryBar titleOfFirstItem]] && [startTaxon isEqualToString:[keys objectAtIndex:0]])
		{
			[queryBar setStringValueForThirdItem:[aDict objectForKey:[keys objectAtIndex:0]]];
		}
		else
		{				
			[self addSearchItemWithTitle:[keys objectAtIndex:0] value:[aDict objectForKey:[keys objectAtIndex:0]]];
			[self removeSearchItem:queryBar];
		}
	}
	else
		CPLog(@"unknown combo: %@", aDict);
	
	[browser closeBrowser];
}

@end

        