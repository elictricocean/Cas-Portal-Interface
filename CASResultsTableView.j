@import <AppKit/AppKit.j>
//@import <AppKit/CPTableView.j>
@import "CASColumnButton.j"

@implementation CASResultsTableView : CPView
{
	CPView selectedButton;
	CPScrollView scrollView;
	id delegate;
}

-(id)initWithFrame:(CGRect)aFrame delegate:(id)aDelegate
{
	self = [super initWithFrame:aFrame];
	if(self)
	{
		delegate = aDelegate;
		var catNoButton = [[CASColumnButton alloc] initWithFrame:CGRectMake(0,0,175.0, 19)];
		[catNoButton setTarget:self];
		[catNoButton setAction:@selector(click:)];
		[catNoButton setStringValue:@"Catalog Number"];
		[catNoButton setNextState];
		selectedButton = catNoButton;
		[self addSubview:catNoButton];
		
		var border = [[CPView alloc] initWithFrame:CGRectMake(CPRectGetMaxX([catNoButton frame]), 0.0, 1.0, CPRectGetHeight(aFrame))];
		[border setBackgroundColor:[CPColor grayColor]];
		[self addSubview:border];
		
		var familyButton = [[CASColumnButton alloc] initWithFrame:CGRectMake(CPRectGetMaxX([catNoButton frame]),0,142.0, 19)];
		[familyButton setTarget:self];
		[familyButton setAction:@selector(click:)];
		[familyButton setStringValue:@"Family"];
		
		var genusButton = [[CASColumnButton alloc] initWithFrame:CGRectMake(CPRectGetMaxX([familyButton frame]),0,105.0, 19)];
		[genusButton setTarget:self];
		[genusButton setAction:@selector(click:)];
		[genusButton setStringValue:@"Genus"];
		
		var speciesButton = [[CASColumnButton alloc] initWithFrame:CGRectMake(CPRectGetMaxX([genusButton frame]),0,105.0, 19)];
		[speciesButton setTarget:self];
		[speciesButton setAction:@selector(click:)];
		[speciesButton setStringValue:@"Species"];
		
		var subspeciesButton = [[CASColumnButton alloc] initWithFrame:CGRectMake(CPRectGetMaxX([speciesButton frame]),0,100.0, 19)];
		[subspeciesButton setTarget:self];
		[subspeciesButton setAction:@selector(click:)];
		[subspeciesButton setStringValue:@"Subspecies"];
		
		var countryButton = [[CASColumnButton alloc] initWithFrame:CGRectMake(CPRectGetMaxX([subspeciesButton frame]),0,110.0, 19)];
		[countryButton setTarget:self];
		[countryButton setAction:@selector(click:)];
		[countryButton setStringValue:@"Country"];
		
		var stateButton = [[CASColumnButton alloc] initWithFrame:CGRectMake(CPRectGetMaxX([countryButton frame]),0,160.0, 19)];
		[stateButton setTarget:self];
		[stateButton setAction:@selector(click:)];
		[stateButton setStringValue:@"State"];
		
		var countyButton = [[CASColumnButton alloc] initWithFrame:CGRectMake(CPRectGetMaxX([stateButton frame]),0,CPRectGetWidth(aFrame)-CPRectGetMaxX([stateButton frame])-19.0, 19)];
		[countyButton setTarget:self];
		[countyButton setAction:@selector(click:)];
		[countyButton setStringValue:@"County"];
		[countyButton setAutoresizingMask:CPViewWidthSizable];
		
		scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, CPRectGetWidth(aFrame), CPRectGetHeight(aFrame))];
		[scrollView setHasHorizontalScroller:NO];
		//[scrollView setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/tableBackground.png" size:CGSizeMake(1.0, 38.0)]]];
		
		window.resultsTable = [[CPTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, CPRectGetWidth(aFrame), CPRectGetHeight(aFrame))];
	    [resultsTable setAllowsColumnReordering:YES];
		[resultsTable setUsesAlternatingRowBackgroundColors:NO];
		[resultsTable setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/tableBackground.png" size:CGSizeMake(1.0, 38.0)]]];
	    [resultsTable setAllowsMultipleSelection:NO];
		[resultsTable setRowHeight:19.0];
		[resultsTable setIntercellSpacing:CGSizeMake(0.0, 0.0)];
		[resultsTable setAutoresizingMask:CPViewWidthSizable];

	    var catNoColumn = [[CPTableColumn alloc] initWithIdentifier:@"CatNo"];
		//[[catNoColumn headerView] setStringValue:@"CatNo"];
		//[[catNoColumn headerView] setAlignment:CPCenterTextAlignment];
		[catNoColumn setHeaderView:catNoButton];
		[catNoColumn setWidth:175.0];
		[window.resultsTable addTableColumn:catNoColumn];

		var familyColumn = [[CPTableColumn alloc] initWithIdentifier:@"Family"];
		//[[familyColumn headerView] setStringValue:@"Family"];
		//[[familyColumn headerView] setAlignment:CPCenterTextAlignment];
		[familyColumn setHeaderView:familyButton];
		[familyColumn setWidth:142.0];
		[window.resultsTable addTableColumn:familyColumn];

		var genusColumn = [[CPTableColumn alloc] initWithIdentifier:@"Genus"];
		//[[genusColumn headerView] setStringValue:@"Genus"];
		//[[genusColumn headerView] setAlignment:CPCenterTextAlignment];
		[genusColumn setHeaderView:genusButton];
		[genusColumn setWidth:105.0];
		[window.resultsTable addTableColumn:genusColumn];

		var speciesColumn = [[CPTableColumn alloc] initWithIdentifier:@"Species"];
		//[[speciesColumn headerView] setStringValue:@"Species"];
		//[[speciesColumn headerView] setAlignment:CPCenterTextAlignment];
		[speciesColumn setHeaderView:speciesButton];
		[speciesColumn setWidth:105.0];
		[window.resultsTable addTableColumn:speciesColumn];

		var subspeciesColumn = [[CPTableColumn alloc] initWithIdentifier:@"Subspecies"];
		//[[subspeciesColumn headerView] setStringValue:@"Subspecies"];
		//[[subspeciesColumn headerView] setAlignment:CPCenterTextAlignment];
		[subspeciesColumn setHeaderView:subspeciesButton];
		[subspeciesColumn setWidth:100.0];
		[window.resultsTable addTableColumn:subspeciesColumn];

		var countryColumn = [[CPTableColumn alloc] initWithIdentifier:@"Country"];
		//[[countryColumn headerView] setStringValue:@"Country"];
		//[[countryColumn headerView] setAlignment:CPCenterTextAlignment];
		[countryColumn setHeaderView:countryButton];
		[countryColumn setWidth:110.0];
		[window.resultsTable addTableColumn:countryColumn];

		var stateColumn = [[CPTableColumn alloc] initWithIdentifier:@"State"];
		//[[stateColumn headerView] setStringValue:@"State"];
		//[[stateColumn headerView] setAlignment:CPCenterTextAlignment];
		[stateColumn setHeaderView:stateButton];
		[stateColumn setWidth:160.0];
		[window.resultsTable addTableColumn:stateColumn];

		var countyColumn = [[CPTableColumn alloc] initWithIdentifier:@"County"];
		//[[countyColumn headerView] setStringValue:@"County"];
		//[[countyColumn headerView] setAlignment:CPCenterTextAlignment];
		[countyColumn setHeaderView:countyButton];
		[[countyColumn headerView] setAutoresizingMask:CPViewWidthSizable];
		[countyColumn setWidth:CPRectGetWidth(aFrame)-CPRectGetMaxX([stateButton frame])];
		[window.resultsTable addTableColumn:countyColumn];

		//[window.resultsTable tile];
	    [scrollView setDocumentView:resultsTable];
		[self addSubview:scrollView];
		[resultsTable setDataSource:self];
		[resultsTable setDelegate:self];
		[resultsTable setTarget:self];
		[resultsTable setAction:@selector(tableViewSelectionDidChange:)]

	    //[window.resultsTable setFrame:CGRectMake(0.0, 0.0, CPRectGetWidth([window.resultsTable frame]), CPRectGetHeight(aFrame))];
		//CPLog(@"table is %@", [[[[window.resultsTable tableColumns] objectAtIndex:0] headerView] backgroundColor]);
		CPLog([resultsTable subviews]);
		
		var border = [[CPView alloc] initWithFrame:CGRectMake(CPRectGetMaxX([catNoButton frame]), 0.0, 1.0, CPRectGetHeight(aFrame))];
		[border setBackgroundColor:[CPColor grayColor]];
		[self addSubview:border];
		
		border = [[CPView alloc] initWithFrame:CGRectMake(CPRectGetMaxX([familyButton frame]), 0.0, 1.0, CPRectGetHeight(aFrame))];
		[border setBackgroundColor:[CPColor grayColor]];
		[self addSubview:border];
		
		border = [[CPView alloc] initWithFrame:CGRectMake(CPRectGetMaxX([genusButton frame]), 0.0, 1.0, CPRectGetHeight(aFrame))];
		[border setBackgroundColor:[CPColor grayColor]];
		[self addSubview:border];
		
		border = [[CPView alloc] initWithFrame:CGRectMake(CPRectGetMaxX([speciesButton frame]), 0.0, 1.0, CPRectGetHeight(aFrame))];
		[border setBackgroundColor:[CPColor grayColor]];
		[self addSubview:border];
		
		border = [[CPView alloc] initWithFrame:CGRectMake(CPRectGetMaxX([subspeciesButton frame]), 0.0, 1.0, CPRectGetHeight(aFrame))];
		[border setBackgroundColor:[CPColor grayColor]];
		[self addSubview:border];
		
		border = [[CPView alloc] initWithFrame:CGRectMake(CPRectGetMaxX([countryButton frame]), 0.0, 1.0, CPRectGetHeight(aFrame))];
		[border setBackgroundColor:[CPColor grayColor]];
		[self addSubview:border];
		
		border = [[CPView alloc] initWithFrame:CGRectMake(CPRectGetMaxX([stateButton frame]), 0.0, 1.0, CPRectGetHeight(aFrame))];
		[border setBackgroundColor:[CPColor grayColor]];
		[self addSubview:border];
	}
	return self;
}

-(void)click:(id)sender
{
	CPLog(@"here");
	if(sender == selectedButton)
	{
		CPLog(@"same");
		[sender setNextState];
	}
	else
	{
		CPLog(@"diff");
		if(selectedButton)
		{
			CPLog(@"changing the state of %@", selectedButton);
			[selectedButton setState:0];
			CPLog(@"old button state is now %@", [selectedButton state])
		}
		else
			CPLog(@"no sel");
		[sender setNextState];
		selectedButton = sender;
	}
}

-(void)resizeWithRect:(CGRect)aRect
{
    [window.resultsTable setFrame:CGRectMake(0.0, 0.0, (CPRectGetWidth(aRect) > (CPRectGetWidth([window.theContentView frame])-250.0)?CPRectGetWidth(aRect):CPRectGetWidth([window.theContentView frame])-250.0), CPRectGetHeight(aRect))];
    [scrollView setFrame:CGRectMake(0.0, 0.0, CPRectGetWidth(aRect), CPRectGetHeight(aRect))];
    console.log(CPStringFromRect([window.resultsTable frame]));
    console.log(CPStringFromRect([self frame]));
    [self setFrame:CGRectMake(0.0, 0.0, CPRectGetWidth(aRect), CPRectGetHeight(aRect))];
    [window.resultsTable sizeLastColumnToFit];
	[[[[window.resultsTable tableColumns] lastObject] headerView] resizeArrow];
}

-(int)numberOfRowsInTableView:(CPTableView)aTableView
{
	if(window.results)
		return window.results.length;
	return 0;
}

-(id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aColumn row:(int)row
{
	if(window.results)
	{
		var data = window.results[row];
		CPLog(data);
		for(key in data)
		{
			if([[aColumn identifier] isEqualToString:key])
				return data[key];
			else if([[aColumn identifier] isEqualToString:@"Catalog Number"] && [key isEqualToString:@"CatalogNo"])
				return data[key];
			else if([[aColumn identifier] isEqualToString:@"Species"] && [key isEqualToString:@"Sp"])
				return data[key];
			else if([[aColumn identifier] isEqualToString:@"Subspecies"] && [key isEqualToString:@"Ssp"])
				return data[key];
		}
	}
	return nil;
}

-(void)tableViewSelectionDidChange:(id)sender
{
	CPLog(@"slected");
	var data = window.results[[[window.resultsTable selectedRowIndexes] firstIndex]];
	[window.detailView setData:data];
}