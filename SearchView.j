@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import "TaxonSearchView.j"
@import "LocationSearchView.j"
@import "DateSearchView.j"
@import "CollectionSearchView.j"
@import "SpecimenSearchView.j"
//http://pagesperso-orange.fr/cocoadev/SmartFolders/
@implementation SearchView : CPView
{
	CPNotificationCenter notificationCenter;
	CPView searchSegment;
	CPView taxonSearchView;
	CPView locationSearchView;
	CPView dateSearchView;
	CPView collectionSearchView;
	CPView specimenSearchView;
	
	CPURLConnection searchConnection;
	CPString _operator;
	CPTextField noSearchParameters;
	CGRect originalFrame;
	CGRect currentFrame;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];//CGRectMake(0,0,575,500)];
    if(self)
    {
    	_operator = @"or";
        var searchBy = [[CPTextField alloc] initWithFrame:CGRectMake(10, 3, 100, 25)];
        [searchBy setStringValue:@"Search by:"];
        [searchBy sizeToFit];
        [self addSubview:searchBy];
        
        searchSegment = [[CPSegmentedControl alloc] initWithFrame:CGRectMake(CPRectGetWidth([searchBy frame]) + 15, 0, 4, 26)];
        [searchSegment setSegmentCount:5];
        [searchSegment setLabel:@"Taxon (Name)" forSegment:0];
        [searchSegment setLabel:@"Location" forSegment:1];
        [searchSegment setLabel:@"Date" forSegment:2];
        [searchSegment setLabel:@"Collection" forSegment:3];
        [searchSegment setLabel:@"Specimen" forSegment:4];
        //[searchSegment setLabel:@"Advanced" forSegment:5];
        [searchSegment setSelected:YES forSegment:0];
        [searchSegment setTrackingMode:CPSegmentSwitchTrackingSelectAny];
        [searchSegment setTarget:self];
        [searchSegment setAction:@selector(searchSegmentClicked:)];
        //var advancedMenu = [[CPMenu alloc] initWithTitle:@"Advanced"];
        //[advancedMenu addItemWithTitle:@"advanced search option..." action:@selector(clickedAdvancedMenuItem:) keyEquivalent:nil];
        //[searchSegment setMenu:advancedMenu forSegment:5];
        [self addSubview:searchSegment];
        
        taxonSearchView = [[TaxonSearchView alloc] initWithFrame:CGRectMake(10, 33, 560, 92)];
		[self addSubview:taxonSearchView];
        
        locationSearchView = [[LocationSearchView alloc] initWithFrame:CGRectMake(10, 33, 560, 92)];
		dateSearchView = [[DateSearchView alloc] initWithFrame:CGRectMake(10, 33, 560, 52)];
		collectionSearchView = [[CollectionSearchView alloc] initWithFrame:CGRectMake(10, 33, 560, 52)];
		specimenSearchView = [[SpecimenSearchView alloc] initWithFrame:CGRectMake(10, 33, 560, 52)];
		
		[self setFrameSize:CGSizeMake(CPRectGetWidth(aFrame), CPRectGetMaxY([taxonSearchView frame]))];
		originalFrame = CGRectCreateCopy(aFrame);
        
        notificationCenter = [CPNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(frameDidChange:) name:@"FrameChanged" object:taxonSearchView];
        [notificationCenter addObserver:self selector:@selector(frameDidChange:) name:@"FrameChanged" object:locationSearchView];
        [notificationCenter addObserver:self selector:@selector(frameDidChange:) name:@"FrameChanged" object:dateSearchView];
        [notificationCenter addObserver:self selector:@selector(frameDidChange:) name:@"FrameChanged" object:collectionSearchView];
        [notificationCenter addObserver:self selector:@selector(frameDidChange:) name:@"FrameChanged" object:specimenSearchView];
		
		noSearchParameters = [CPTextField labelWithTitle:@"Add a search parameter"];
		[noSearchParameters setFont:[CPFont boldSystemFontOfSize:14]];
		[noSearchParameters setTextColor:[CPColor grayColor]];
		[noSearchParameters sizeToFit];
		[noSearchParameters setCenter:[self center]];
	}
    return self;
}

-(void)searchSegmentClicked:(id)sender
{
	[self addNoSearchParametersView:NO];
    var selectedView;
    switch([sender selectedSegment])
    {
    	case 0:
    		selectedView = taxonSearchView;
    		break;
    	case 1:
    		selectedView = locationSearchView;
    		break;
    	case 2:
    		selectedView = dateSearchView;
    		break;
    	case 3:
    		selectedView = collectionSearchView;
    		break;
    	case 4:
    		selectedView = specimenSearchView;
    		break;
    	//case 5:
    		//return;
    		//break;
    }
    
	if([sender isSelectedForSegment:[sender selectedSegment]])
	{
		CPLog(@"add segment");
		if(![[self subviews] containsObject:selectedView])
        {
        	[selectedView setFrameOrigin:[self newPoint]];
            [self addSubview:selectedView];
            [self setFrameSize:CGSizeMake(570, CPRectGetMinY([[[self subviews] lastObject] frame]) +CPRectGetHeight([[[self subviews] lastObject] frame]))];
        }
	}   
	else
    {
    	CPLog(@"remove segment");
        [self searchWasRemoved:selectedView shouldDeselect:NO];
    } 
}

-(void)searchWasRemoved:(id)aSearchView shouldDeselect:(BOOL)shouldDeselect
{
	var index = [[self subviews] indexOfObject:aSearchView];
	var height = CPRectGetHeight([aSearchView frame]);
	[aSearchView removeFromSuperview];
	for(var i = index; i < [[self subviews] count]; i++)
	{
		var newOrigin = CPPointMake(CPRectGetMinX([[[self subviews] objectAtIndex:i] frame]), CPRectGetMinY([[[self subviews] objectAtIndex:i] frame]) - height - 10);
		[[[self subviews] objectAtIndex:i] setFrameOrigin:newOrigin];
	}
	[self setFrameSize:CGSizeMake(570, CPRectGetMinY([[[self subviews] lastObject] frame]) +CPRectGetHeight([[[self subviews] lastObject] frame]))];
	
	if(shouldDeselect)
	{
		var segment;
		if(aSearchView == taxonSearchView)
			segment = 0;
		else if(aSearchView == locationSearchView)
			segment = 1;
		else if(aSearchView == dateSearchView)
			segment = 2;
		else if(aSearchView == collectionSearchView)
			segment = 3;
		else if(aSearchView == specimenSearchView)
			segment = 4;
		[searchSegment setSelected:NO forSegment:segment];	
	}
	
	if([self numberOfSelectedSegments] == 0)
	{
		currentFrame = CGRectCreateCopy([self frame]);
		[self addNoSearchParametersView:YES];
	}
}

-(void)frameDidChange:(CPNotification)aNote
{
	var object = [aNote object];
	if(![[self subviews] containsObject:object] )
		return;
		
	//CPRectGetMinY([[[self subviews] objectAtIndex:i-1] frame]) + CPRectGetHeight([[[self subviews] objectAtIndex:i-1] frame])	+ 10
	if([[self subviews] count] >= 2)
	{
		var index = [[self subviews] indexOfObject:object];
		for(var i = index + 1; i < [[self subviews] count]; i++)
		{
			var newOrigin = CPPointMake(CPRectGetMinX([[[self subviews] objectAtIndex:i] frame]), CPRectGetMinY([[[self subviews] objectAtIndex:i-1] frame]) + CPRectGetHeight([[[self subviews] objectAtIndex:i-1] frame]) + 10);
			[[[self subviews] objectAtIndex:i] setFrameOrigin:newOrigin];
		}
	}
	CPLog(@"height is " + CPRectGetHeight([[[self subviews] lastObject] frame]));
	[self setFrameSize:CGSizeMake(570, CPRectGetMinY([[[self subviews] lastObject] frame]) +CPRectGetHeight([[[self subviews] lastObject] frame]))];
		
	CPLog(CPRectGetHeight([self frame]));
}

-(CGPoint)newPoint
{
	var newPoint = CGPointMake(20,0);
	if([[self subviews] count] > 0)
		newPoint = CGPointMake(10, CPRectGetMinY([[[self subviews] lastObject] frame]) + CPRectGetHeight([[[self subviews] lastObject] frame]) + 10);
		
	return newPoint;
}

-(void)addNoSearchParametersView:(BOOL)shouldAdd
{
	if(!currentFrame)
		return;
	
	CPLog(@"original frame is %@", originalFrame);
	if(shouldAdd)
	{
		
		[self setFrame:CGRectMake(CPRectGetMinX(originalFrame), CPRectGetMinY(originalFrame), CPRectGetWidth(originalFrame), CPRectGetHeight(originalFrame)-100.0)];
		[self addSubview:noSearchParameters];
	}
	else
	{
		[self setFrame:currentFrame];
		[noSearchParameters removeFromSuperview];
	}
}

-(int)numberOfSelectedSegments
{
	var num = 0;
	for(var i = 0; i < [searchSegment segmentCount]; i++)
	{
		if([searchSegment isSelectedForSegment:i])
			num++;
	}
	return num;
}

-(void)setOperator:(CPString)anOperator
{
	_operator = anOperator;
}

-(BOOL)search:(id)sender
{
	if([[self subviews] count] <= 2)
	{
		alert(@"No search parameters");
		return;
	}
	
	if(!window.isFiltering)
	{
		[[CPNotificationCenter defaultCenter] postNotificationName:@"CloseSearch" object:self userInfo:[CPDictionary dictionaryWithObjectsAndKeys:@"search", @"type"]];
	}
	
	CPLog([taxonSearchView searchValues]);
	var searchValues = [[CPArray alloc] init];
	for(var i = 2; i < [[self subviews] count]; i++)
	{
		CPLog(i);
		CPLog([[self subviews] objectAtIndex:i]);
		var items = [[[self subviews] objectAtIndex:i] searchValues];
		if(items == [CPNull null])
			return NO;
		else
			CPLog(@"items are %@", items)
		CPLog(@"items are " + [items count]);
		for(var j = 0; j < [items count]; j++)
		{
			CPLog(@"class is %@", [[items objectAtIndex:j] className]);
			[searchValues addObject:[items objectAtIndex:j]];
		}
	}
	
	CPLog(@"search vals are " + searchValues);
	
	if(!window.isFiltering)
	{
		//var postString = [CPString stringWithFormat:@"query=%@", [CPString JSONFromObject:searchValues]];
		//var postData = [CPData dataWithString:postString];
		//var postLength = [CPString stringWithFormat:@"%d", [postData length]];
		var request = [[CPURLRequest alloc] initWithURL:@"./php/search.php?query="+[CPString JSONFromObject:searchValues]+@"&operator="+_operator];
		//[request setHTTPMethod:@"POST"];
		//[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
		//[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
		//[request setHTTPBody:postData];
		searchConnection = [[CPURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	}
	else
	{
		//loop thorugh array?
	}
	
	return YES;
}

-(void)connection:(CPURLConnection)urlConnection didReceiveData:(CPString)aString
{
	if(urlConnection == searchConnection)
	{
		CPLog(aString);
		window.results = [aString objectFromJSON];
		[window.resultsTable reloadData];
	}
}

-(void)clickedAdvancedMenuItem:(id)sender
{
}

@end