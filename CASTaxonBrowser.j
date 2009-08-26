@import <Foundation/CPURLRequest.j>
@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import "QueryBar.j"
 
@implementation CASTaxonBrowser : CPView
{
	CPArray types;
	int typeIndex;
	int typeCount;
	float width;
	float totalWidth;
	float height;
	float totalHeight;
	
    CPCollectionView classView;
    CPURLConnection classConnection;
	CPArray classes;
    
    CPCollectionView orderView;
    CPURLConnection orderConnection;
	ErrorView noOrderView;
    CPArray orders;
    
    CPCollectionView familyView;
    CPURLConnection familyConnection;
	ErrorView noFamilyView;
    CPArray families;
    CPScrollView familyScrollView;
    
    CPCollectionView genusView;
    CPURLConnection genusConnection;
	ErrorView noGenusView;
    CPArray genera;
    
    CPCollectionView speciesView;
    CPURLConnection speciesConnection;
	ErrorView noSpeciesView;
    CPArray species;
    
    CPButton doneButton;
    CPTextField filterButton;
    CPString selectedGenus;
    
    id _delegate;
    CPString startTaxon;
    
    QueryBar queryBar;
}

-(id)initWithTaxon:(CPString)aTaxon filters:(CPArray)someFilter delegate:(id)aDelegate
{
	return [self initWithTaxon:aTaxon filters:someFilter delegate:aDelegate onQueryBar:nil]
}
 
-(id)initWithTaxon:(CPString)aTaxon filters:(CPArray)someFilter delegate:(id)aDelegate onQueryBar:(QueryBar)aQueryBar
{
    self = [super initWithFrame:CGRectMakeZero()];
    
    if(self)
    {
    	_delegate = aDelegate;
    	startTaxon = aTaxon;
    	if(aQueryBar)
    		queryBar = aQueryBar;
    		
    	if([aTaxon rangeOfString:@"/"].location != CPNotFound)
    	{
    		aTaxon = [[aTaxon componentsSeparatedByString:@"/"] objectAtIndex:0];
    		CPLog(@"a taxon is now " + aTaxon);
    	}
    		
    	types = [@"Class", @"Order", @"Family", @"Genus", @"Species"];
    	typeCount = [types count] - [types indexOfObject:aTaxon];
    	typeIndex = [types indexOfObject:aTaxon];
    	CPLog(typeIndex);
    	width = 160.0;
    	totalWidth = width*typeCount;
    	CPLog(totalWidth);
    	
    	doneButton = [CPButton buttonWithTitle:@"Done"];
		
    	height = 500.0 - 10 - CPRectGetHeight([doneButton frame]);
    	CPLog(height);
    	totalHeight = 500.0;
    	[self setFrame:CGRectMake(0.0, 0.0, totalWidth, totalHeight+CPRectGetHeight([doneButton frame])+15)];
    	CPLog(@"window is %@", [self window]);
    	//[[self window] setFrame:CPRectCreateCopy([self frame])];
    	CPLog(@"set" + CPRectGetWidth([self frame]));
    	CPLog([types objectAtIndex:typeIndex]);
    	if([[types objectAtIndex:typeIndex] isEqualToString:@"Class"])
    	{
    		var classLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
    		[classLabel setStringValue:@"Class"];
    		[classLabel setFont:[CPFont systemFontOfSize:10.0]];
    		[classLabel sizeToFit];
    		[classLabel setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/tableHeaderSmall.png" size:CGSizeMake(2.0, 16.0)]]];
    		[classLabel setAlignment:CPCenterTextAlignment];
    		[classLabel setFrame:CGRectMake(0,0,width,CPRectGetHeight([classLabel frame]))];
    		[self addSubview:classLabel];
    	
    		var border = [[CPView alloc] initWithFrame:CGRectMake(CPRectGetMaxX([classLabel frame]), 0, 1, height+CPRectGetHeight([classLabel frame]))];
        	[border setBackgroundColor: [CPColor grayColor]];
        	[self addSubview: border];

        
    		var classScrollView = [[CPScrollView alloc] initWithFrame: CGRectMake(0, CPRectGetMaxY([classLabel frame]), width-1, height)];
    		[classScrollView setAutohidesScrollers:NO];
    		[classScrollView setHasHorizontalScroller:NO];
    		[classScrollView setAutoresizingMask:CPViewHeightSizable];
        
    		var classViewItem = [[CPCollectionViewItem alloc] init];
    		[classViewItem setView:[[ArtistTableCell alloc] initWithFrame:CGRectMake(1.0, 0.0, width-1, 19.0)]];
 			classes = [[CPArray alloc] init];
    		classView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0, 0, width-1, height)];
    		[classView setDelegate:self];
    		[classView setItemPrototype:classViewItem];
    		[classView setContent:classes];
    		[classView setMinItemSize:CPSizeMake(width, 19)];
    		[classView setMaxItemSize:CPSizeMake(width, 19)];
    		[classView setMaxNumberOfColumns:1];
    
    		[classView setVerticalMargin:0.0];
    		[classView setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
 
    		[classScrollView setDocumentView:classView];
    		
	 		[self addSubview: classScrollView];
 		}
 		if([[types objectAtIndex:typeIndex] isEqualToString:@"Order"] || 
 		   [[types objectAtIndex:typeIndex+1] isEqualToString:@"Order"])
    	{
    		var orderLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
    		[orderLabel setStringValue:@"Order"];
    		[orderLabel setFont:[CPFont systemFontOfSize:10.0]];
    		[orderLabel setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/tableHeaderSmall.png" size:CGSizeMake(2.0, 16.0)]]];
    		[orderLabel sizeToFit];
    		[orderLabel setAlignment:CPCenterTextAlignment];
    		[orderLabel setFrame:CGRectMake((classView ? width+1 : 0.0),0,width-1,CPRectGetHeight([orderLabel frame]))];
    		[self addSubview:orderLabel];
    	
    		border = [[CPView alloc] initWithFrame:CGRectMake(CPRectGetMaxX([orderLabel frame]), 0, 1, height+CPRectGetHeight([orderLabel frame]))];
        	[border setBackgroundColor: [CPColor grayColor]];
        	[self addSubview: border];
    
    		var orderScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake((classView ? width : 0.0), CPRectGetMaxY([orderLabel frame]), width-1, height)];
    		[orderScrollView setAutohidesScrollers:NO];
    		[orderScrollView setHasHorizontalScroller:NO];
    		[orderScrollView setAutoresizingMask: CPViewHeightSizable];
        
    		var orderViewItem = [[CPCollectionViewItem alloc] init];
    		[orderViewItem setView:[[ArtistTableCell alloc] initWithFrame:CGRectMake(1.0, 0.0, width-1, 19.0)]];
 
 			orders = [[CPArray alloc] init];
    		orderView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, width-1, height)];
 
    		[orderView setDelegate: self];
    		[orderView setItemPrototype: orderViewItem];
    		[orderView setContent:orders];
    		[orderView setMinItemSize:CPSizeMake(width, 19)];
    		[orderView setMaxItemSize:CPSizeMake(width, 19)];
    		[orderView setMaxNumberOfColumns:1];
    
    		[orderView setVerticalMargin:0.0];
    		[orderView setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
 
    		[orderScrollView setDocumentView:orderView];
    	 
    		[self addSubview: orderScrollView];
    
    		noOrderView = [[ErrorView alloc] initWithFrame:CPRectCreateCopy([orderScrollView frame]) message:@"Please select a class."];
    		[self addSubview:noOrderView];
    	}
    	if([[types objectAtIndex:typeIndex] isEqualToString:@"Family"] || 
 		   [[types objectAtIndex:typeIndex+1] isEqualToString:@"Family"] ||
 		   [[types objectAtIndex:typeIndex+2] isEqualToString:@"Family"])
 		{
    		var familyLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
    		[familyLabel setStringValue:@"Family"];
    		[familyLabel setFont:[CPFont systemFontOfSize:10.0]];
    		[familyLabel setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/tableHeaderSmall.png" size:CGSizeMake(2.0, 16.0)]]];
    		[familyLabel sizeToFit];
    		[familyLabel setAlignment:CPCenterTextAlignment];
    		var x;
    		if([[types objectAtIndex:typeIndex] isEqualToString:@"Family"])
    			x = 0.0;
    		else if([[types objectAtIndex:typeIndex+1] isEqualToString:@"Family"])
    			x = width+1;
    		else if([[types objectAtIndex:typeIndex+2] isEqualToString:@"Family"])
    			x = width*2+1;
    		[familyLabel setFrame:CGRectMake(x,0,width,CPRectGetHeight([familyLabel frame]))];
    		[self addSubview:familyLabel];
    	
    		border = [[CPView alloc] initWithFrame:CGRectMake(CPRectGetMaxX([familyLabel frame]), 0, 1, height+CPRectGetHeight([familyLabel frame]))];
        	[border setBackgroundColor: [CPColor grayColor]];
        	[self addSubview: border];
    
    		familyScrollView = [[CPScrollView alloc] initWithFrame: CGRectMake(x, CPRectGetMaxY([familyLabel frame]), width-1, height)];
    		[familyScrollView setAutohidesScrollers:NO];
    		[familyScrollView setHasHorizontalScroller:NO];
    		[familyScrollView setAutoresizingMask:CPViewHeightSizable];
        
        	families = [[CPArray alloc] init];
    		var familyViewItem = [[CPCollectionViewItem alloc] init];
    		[familyViewItem setView:[[ArtistTableCell alloc] initWithFrame:CGRectMake(1.0, 0.0, width-1, 19.0)]];
 
    		familyView = [[CPCollectionView alloc] initWithFrame: CGRectMake(0.0, 0.0, width-1, height)];//(CGRectGetWidth(aFrame)/5)*2, CPRectGetMaxY([familyLabel frame])
 
    		[familyView setDelegate: self];
    		[familyView setItemPrototype:familyViewItem];
    		//[familyView setContent:families];
    		[familyView setMinItemSize:CPSizeMake(width, 19)];
    		[familyView setMaxItemSize:CPSizeMake(width, 19)];
    		[familyView setMaxNumberOfColumns:1];
    		[familyView setVerticalMargin:0.0];
    		[familyView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];
 
    		[familyScrollView setDocumentView:familyView];
    	 
    		[self addSubview:familyScrollView];
    
    		noFamilyView = [[ErrorView alloc] initWithFrame:CPRectCreateCopy([familyScrollView frame]) message:@"Please select an order."];
    		[self addSubview:noFamilyView];
    	}
    	if([[types objectAtIndex:typeIndex] isEqualToString:@"Genus"] || 
 		   [[types objectAtIndex:typeIndex+1] isEqualToString:@"Genus"] ||
 		   [[types objectAtIndex:typeIndex+2] isEqualToString:@"Genus"] ||
 		   [[types objectAtIndex:typeIndex+3] isEqualToString:@"Genus"])
 		{
    		var genusLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
    		[genusLabel setStringValue:@"Genus"];
    		[genusLabel setFont:[CPFont systemFontOfSize:10.0]];
    		[genusLabel setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/tableHeaderSmall.png" size:CGSizeMake(2.0, 16.0)]]];
    		[genusLabel sizeToFit];
    		[genusLabel setAlignment:CPCenterTextAlignment];
    		var x;
    		if([[types objectAtIndex:typeIndex] isEqualToString:@"Genus"])
    			x = 0.0;
    		else if([[types objectAtIndex:typeIndex+1] isEqualToString:@"Genus"])
    			x = width+1;
    		else if([[types objectAtIndex:typeIndex+2] isEqualToString:@"Genus"])
    			x = width*2+1;
    		else if([[types objectAtIndex:typeIndex+3] isEqualToString:@"Genus"])
    			x = width*3+1;
    		[genusLabel setFrame:CGRectMake(x+1,0,width-1,CPRectGetHeight([genusLabel frame]))];
    		[self addSubview:genusLabel];
    	
    		border = [[CPView alloc] initWithFrame:CGRectMake(CPRectGetMaxX([genusLabel frame]), 0, 1, height+CPRectGetHeight([genusLabel frame]))];
        	[border setBackgroundColor: [CPColor grayColor]];
        	[self addSubview: border];
    	
    		var genusScrollView = [[CPScrollView alloc] initWithFrame: CGRectMake(x, CPRectGetMaxY([genusLabel frame]), width-1, height)];
    		[genusScrollView setAutohidesScrollers:NO];
    		[genusScrollView setHasHorizontalScroller:NO];
    		[genusScrollView setAutoresizingMask:CPViewHeightSizable];
        
        	genera = [[CPArray alloc] init];
    		var genusViewItem = [[CPCollectionViewItem alloc] init];
    		[genusViewItem setView:[[ArtistTableCell alloc] initWithFrame:CGRectMake(1.0, 0.0, width-1, 19.0)]];
 
    		genusView = [[CPCollectionView alloc] initWithFrame: CGRectMake(0.0, 0.0, width-1, height)];
 
    		[genusView setDelegate: self];
    		[genusView setItemPrototype:genusViewItem];
    		//[genusView setContent:genera];
    		[genusView setMinItemSize:CPSizeMake(width, 19)];
    		[genusView setMaxItemSize:CPSizeMake(width, 19)];
    		[genusView setMaxNumberOfColumns:1];
    
    		[genusView setVerticalMargin:0.0];
    		[genusView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];
 	
    		[genusScrollView setDocumentView:genusView];
    	 
    		[self addSubview:genusScrollView];
    
    		noGenusView = [[ErrorView alloc] initWithFrame:CPRectCreateCopy([genusScrollView frame]) message:@"Please select a family."];
    		[self addSubview:noGenusView];
    	}
    	if([[types objectAtIndex:typeIndex] isEqualToString:@"Species"] || 
 		   [[types objectAtIndex:typeIndex+1] isEqualToString:@"Species"] ||
 		   [[types objectAtIndex:typeIndex+2] isEqualToString:@"Species"] ||
 		   [[types objectAtIndex:typeIndex+3] isEqualToString:@"Species"] ||
 		   [[types objectAtIndex:typeIndex+4] isEqualToString:@"Species"])
 		{
    		var speciesLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
    		[speciesLabel setStringValue:@"Species"];
    		[speciesLabel setFont:[CPFont systemFontOfSize:10.0]];
    		[speciesLabel setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/tableHeaderSmall.png" size:CGSizeMake(2.0, 16.0)]]];
    		[speciesLabel sizeToFit];
    		[speciesLabel setAlignment:CPCenterTextAlignment];
    		var x;
    		if([[types objectAtIndex:typeIndex] isEqualToString:@"Species"])
    			x = 0.0;
    		else if([[types objectAtIndex:typeIndex+1] isEqualToString:@"Species"])
    			x = width+1;
    		else if([[types objectAtIndex:typeIndex+2] isEqualToString:@"Species"])
    			x = width*2+1;
    		else if([[types objectAtIndex:typeIndex+3] isEqualToString:@"Species"])
    			x = width*3+1;
    		else if([[types objectAtIndex:typeIndex+4] isEqualToString:@"Species"])
    			x = width*4+1;
    		[speciesLabel setFrame:CGRectMake(x+1,0,width-1,CPRectGetHeight([speciesLabel frame]))];
    		[self addSubview:speciesLabel];
    	
    		var speciesScrollView = [[CPScrollView alloc] initWithFrame: CGRectMake(x, CPRectGetMaxY([speciesLabel frame]), width, height)];
    		[speciesScrollView setAutohidesScrollers:NO];
    		[speciesScrollView setHasHorizontalScroller:NO];
    		[speciesScrollView setAutoresizingMask:CPViewHeightSizable];
        
        	species = [[CPArray alloc] init];
    		var speciesViewItem = [[CPCollectionViewItem alloc] init];
    		[speciesViewItem setView:[[ArtistTableCell alloc] initWithFrame:CGRectMake(1.0, 0.0, width-1, 19.0)]];
 
    		speciesView = [[CPCollectionView alloc] initWithFrame: CGRectMake(0.0, 0.0, width, height)];
 
    		[speciesView setDelegate: self];
    		[speciesView setItemPrototype:speciesViewItem];
    		//[speciesView setContent:species];
    		[speciesView setMinItemSize:CPSizeMake(width, 19)];
    		[speciesView setMaxItemSize:CPSizeMake(width, 19)];
    		[speciesView setMaxNumberOfColumns:1];
    
    		[speciesView setVerticalMargin:0.0];
    		[speciesView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];
 
    		[speciesScrollView setDocumentView:speciesView];
    	 
    		[self addSubview:speciesScrollView];
    
    		noSpeciesView = [[ErrorView alloc] initWithFrame:CPRectCreateCopy([speciesScrollView frame]) message:@"Please select a genus."];
    		[self addSubview:noSpeciesView];
		}
		
		border = [[CPView alloc] initWithFrame:CGRectMake(0, CPRectGetMaxY([speciesScrollView frame]), CPRectGetWidth([self frame]), 1)];
        [border setBackgroundColor: [CPColor grayColor]];
        [self addSubview: border];
		
		[doneButton setFrameOrigin:CGPointMake(CPRectGetMaxX([speciesScrollView frame])-CPRectGetWidth([doneButton frame])-5.0, CPRectGetMaxY([speciesScrollView frame])+3.0)];
		[doneButton setTarget:self];
		[doneButton setAction:@selector(saveTaxa:)];
		[self addSubview:doneButton];
		
		/*var filterButton = [[CPSearchField alloc] initWithFrame:CGRectMake(5.0, CPRectGetMaxX([speciesScrollView frame])-5.0, 150.0, 25.0)];
		[filterButton sizeToFit];
		[self addSubview:filterButton];*/
		
		filterButton = [CPTextField roundedTextFieldWithStringValue:@"" placeholder:@"Filter" width:totalWidth == 160.0 ? 100.0 : 150.0];
		[filterButton setFrameOrigin:CGPointMake(5.0, CPRectGetHeight([self frame]) - CPRectGetHeight([filterButton frame]) - 25.0)];
		[filterButton setDelegate:self];
		[self addSubview:filterButton];
		
		if(aTaxon)
		{
			if([aTaxon isEqualToString:@"Class"])
				classConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:@"./php/taxonBrowser.php?type=class"] delegate:self startImmediately:YES];
			if([aTaxon isEqualToString:@"Order"] || [aTaxon isEqualToString:@"Order/Suborder"])
				orderConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:@"./php/taxonBrowser.php?type=order"] delegate:self startImmediately:YES];
			if([aTaxon isEqualToString:@"Family"])
				familyConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:@"./php/taxonBrowser.php?type=family"] delegate:self startImmediately:YES];
			if([aTaxon isEqualToString:@"Genus"])
				genusConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:@"./php/taxonBrowser.php?type=genus"] delegate:self startImmediately:YES];
			if([aTaxon isEqualToString:@"Species"])
				speciesConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:@"./php/taxonBrowser.php?type=sp"] delegate:self startImmediately:YES];
		}
    }
    
    return self;
}
 
-(void)collectionView:(CPCollectionView)view didDoubleClickOnItemAtIndex:(int)index
{
	var key = [[view content] objectAtIndex:index];
    
    if(view == classView)
    {
        orderConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:@"./php/taxonBrowser.php?type=class&value=" + key] delegate:self startImmediately:YES];
    }
    else if(view == orderView)
    {
        familyConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:@"./php/taxonBrowser.php?type=order&value=" + key] delegate:self startImmediately:YES];
    }
    else if(view == familyView)
    {
        genusConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:@"./php/taxonBrowser.php?type=family&value=" + key] delegate:self startImmediately:YES];
    }
    else if(view == genusView)
    {
    	selectedGenus = key;
    	speciesConnection = [[CPURLConnection alloc] initWithRequest:[CPURLRequest requestWithURL:@"./php/taxonBrowser.php?type=genus&value=" + key] delegate:self startImmediately:YES];
    }
    else
    {
    	CPLog(@"Unknown view");
    }
}
 
- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)data
{
	CPLog(@"data is %@", data);
	if(!data || [data isEqualToString:@""] || [data isEqualToString:@" "] || [data isEqualToString:@"[]"])
		return;
		
    var newContent = [[CPMutableArray alloc] init];
    
    if (aConnection == classConnection)
    {
        try
        {
           var result = JSON.parse(data);
           CPLog(result);
           var i;
           for(i in data)
           {
    			[newContent addObject:[result objectAtIndex:i]]
           }
            [classView setContent:newContent];
            [classView reloadContent];
			[classView setNeedsDisplay:YES];
            classConnection = nil;
        }
        catch(e)
        {
            return [self connection:aConnection didFailWithError: e];
        }
    }
    else if (aConnection == orderConnection)
    {
        try
        {
           var result = JSON.parse(data);
           CPLog(result);
           var x;
           for(x in result)
            {
                [newContent addObject:x]
            }
            [orderView setContent:newContent];
            [orderView reloadContent];
            orderConnection = nil;
			[noOrderView removeFromSuperview];
        }
        catch(e)
        {
            return [self connection:aConnection didFailWithError: e];
        }
    }
    else if (aConnection == familyConnection)
    {
        try
        {
           var result = JSON.parse(data);
           CPLog([result className]);
           
			//[familyView setContent:nil];
			families = result;
			[familyView setContent:result];//[[CPArray alloc] initWithObjects:@"uno", @"dos", @"tres"]];
            [familyView setMaxNumberOfRows:[families count]];
			[familyView reloadContent];
			CPLog(@"height is %d", CPRectGetHeight([familyView frame]));
			//[familyScrollView setNeedsDisplay:YES];
			CPLog(@"content is %@", [familyView content]);
            //[familyView reloadContent];
            //familyConnection = nil;
			[noFamilyView removeFromSuperview];
        }
        catch(e)
        {
            return [self connection:aConnection didFailWithError: e];
        }
    }
    else if (aConnection == genusConnection)
    {
        try
        {
           var result = JSON.parse(data);
           CPLog(result);
            //[genusView setContent:newContent];
            //[genusView reloadContent];
            genera = result;
			[genusView setContent:result];//[[CPArray alloc] initWithObjects:@"uno", @"dos", @"tres"]];
            [genusView setMaxNumberOfRows:[genera count]];
			[genusView reloadContent];
            //genusConnection = nil;
			[noGenusView removeFromSuperview];
			[genusView setNeedsDisplay:YES];
        }
        catch(e)
        {
            return [self connection:aConnection didFailWithError: e];
        }
    }
    else if (aConnection == speciesConnection)
    {
        try
        {
           var result = JSON.parse(data);
           CPLog(result);
            //[speciesView setContent:newContent];
            //[speciesView reloadContent];
            species = result;
			[speciesView setContent:result];//[[CPArray alloc] initWithObjects:@"uno", @"dos", @"tres"]];
            [speciesView setMaxNumberOfRows:[species count]];
			[speciesView reloadContent];
            speciesConnection = nil;
			[noSpeciesView removeFromSuperview];
        }
        catch(e)
        {
            return [self connection:aConnection didFailWithError: e];
        }
    }
	else
    {
    	CPLog(@"Unknown connection");
    }
    [[CPRunLoop mainRunLoop] performSelectors];
}
 
- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    CPLog(anError);
    [self connectionDidFinishLoading:aConnection];
}
 
- (void)connectionDidFinishLoading:(CPURLConnection)aConnection
{
    if (aConnection == classConnection)
    {
        classConnection = nil;
    }
    if(aConnection == orderConnection)
    {
        orderConnection = nil;
    }
    if(aConnection == familyConnection)
    {
        familyConnection = nil;
    }
    if(aConnection == genusConnection)
    {
        genusConnection = nil;
    }
    if(aConnection == speciesConnection)
    {
        speciesConnection = nil;
    }
}

-(void)resizeParent
{
	[[self window] setFrameSize:CGSizeMake(totalWidth, totalHeight+CPRectGetHeight([doneButton frame])+15)];
	[[self window] setTitle:@"Taxon Browser"];
}

-(void)saveTaxa:(id)sender
{
	var dict;
	if(speciesView && [[speciesView selectionIndexes] count] > 0 && !genusView)
	{
		var selectedIndexes = [speciesView selectionIndexes];
		var combo = [species[[selectedIndexes firstIndex]] componentsSeparatedByString:@" "];
		dict = [CPDictionary dictionaryWithObjects:[[combo objectAtIndex:0], [combo objectAtIndex:1]] forKeys:[@"Genus", @"Species"]];
	}
	else if(speciesView && [[speciesView selectionIndexes] count] > 0 && genusView)
	{
		var selectedIndexes = [speciesView selectionIndexes];
		dict = [CPDictionary dictionaryWithObjects:[genera[[[genusView selectionIndexes] firstIndex]], species[[selectedIndexes firstIndex]]] forKeys:[@"Genus", @"Species"]];
	}
	else if(genusView && [[genusView selectionIndexes] count] > 0)
	{
		var selectedIndexes = [genusView selectionIndexes];
		//[[genusView selectionIndexes] getIndexes:&selectedIndexes max:[[genusView selectionIndexes] count] range:nil];
		//for(var i = 0; i<[selectedIndexes count]; i++)
		//{
			dict = [CPDictionary dictionaryWithObject:genera[[selectedIndexes firstIndex]] forKey:@"Genus"];
		//}
	}
	else if(familyView && [[familyView selectionIndexes] count] > 0)
	{
		CPLog(@"selected");
		var selectedIndexes = [familyView selectionIndexes];
		//[[familyView selectionIndexes] getIndexes:&selectedIndexes max:[[familyView selectionIndexes] count] range:nil];
		//for(var i = 0; i<[selectedIndexes count]; i++)
		//{
			dict = [CPDictionary dictionaryWithObject:families[[selectedIndexes firstIndex]] forKey:@"Family"];
		//}
		CPLog(@"dict is really %@", dict)
	}
	else if(orderView && [[orderView selectionIndexes] count] > 0)
	{
		var selectedIndexes = [orderView selectionIndexes];
		//[[orderView selectionIndexes] getIndexes:&selectedIndexes max:[[orderView selectionIndexes] count] range:nil];
		//for(var i = 0; i<[selectedIndexes count]; i++)
		//{
			dict = [CPDictionary dictionaryWithObject:orders[[selectedIndexes firstIndex]] forKey:@"Order/Suborder"];
		//}
	}
	else if(classView && [[genusView selectionIndexes] count] > 0)
	{
		var selectedIndexes = [classView selectionIndexes];
		//[[classView selectionIndexes] getIndexes:&selectedIndexes max:[[classView selectionIndexes] count] range:nil];
		//for(var i = 0; i<[selectedIndexes count]; i++)
		//{
			dict = [CPDictionary dictionaryWithObject:classes[[selectedIndexes firstIndex]] forKey:@"Class"];
		//}
	}
	
	CPLog(@"dict is %@", dict);
	
	if([_delegate respondsToSelector:@selector(taxonBrowser:endedWithValues:)])
		[_delegate taxonBrowser:self endedWithValues:dict];
	else
		CPLog(@"delegate is %@", _delegate);
}

-(void)controlTextDidChange:(CPNotification)aNote
{
	var text = [filterButton stringValue];
	CPLog(text);
	if(classView)
	{
		if(![text isEqualToString:@""])
		{
			var contents = [classView content];
			var newArray = [[CPArray alloc] init];
			for(var i = 0; i < [contents count]; i++)
			{
				if([[contents objectAtIndex:i] rangeOfString:text options:CPCaseInsensitiveSearch].location != CPNotFound)
				{
					[newArray addObject:[contents objectAtIndex:i]]
				}
			}
			[classView setContent:newArray];
		}
		else
			[classView setContent:classes];
	}
	if(orderView)
	{
		if(![text isEqualToString:@""])
		{
			var contents = [orderView content];
			var newArray = [[CPArray alloc] init];
			for(var i = 0; i < [contents count]; i++)
			{
				if([[contents objectAtIndex:i] rangeOfString:text options:CPCaseInsensitiveSearch].location != CPNotFound)
				{
					[newArray addObject:[contents objectAtIndex:i]]
				}
			}
			[orderView setContent:newArray];
		}
		else
			[orderView setContent:orders];
	}
	if(familyView)
	{
		if(![text isEqualToString:@""])
		{
			var contents = [familyView content];
			var newArray = [[CPArray alloc] init];
			for(var i = 0; i < [contents count]; i++)
			{
				if([[contents objectAtIndex:i] rangeOfString:text options:CPCaseInsensitiveSearch].location != CPNotFound)
				{
					[newArray addObject:[contents objectAtIndex:i]]
				}
			}
			[familyView setContent:newArray];
			CPLog(@"new array si %@", newArray);
		}
		else
			[familyView setContent:families];
	}
	if(genusView)
	{
		if(![text isEqualToString:@""])
		{
			var contents = [genusView content];
			var newArray = [[CPArray alloc] init];
			for(var i = 0; i < [contents count]; i++)
			{
				if([[contents objectAtIndex:i] rangeOfString:text options:CPCaseInsensitiveSearch].location != CPNotFound)
				{
					[newArray addObject:[contents objectAtIndex:i]]
				}
			}
			[genusView setContent:newArray];
		}
		else
			[genusView setContent:genera];
	}
	if(speciesView)
	{
		if(![text isEqualToString:@""])
		{
			var contents = [speciesView content];
			var newArray = [[CPArray alloc] init];
			for(var i = 0; i < [contents count]; i++)
			{
				if([[contents objectAtIndex:i] rangeOfString:text options:CPCaseInsensitiveSearch].location != CPNotFound)
				{
					[newArray addObject:[contents objectAtIndex:i]]
				}
			}
			[speciesView setContent:newArray];
		}
		else
			[speciesView setContent:species];
	}
}

-(CPString)startTaxon
{
	return startTaxon;
}

-(QueryBar)queryBar
{
	return queryBar;
}

-(void)closeBrowser
{
	[[self window] close];
}
 
@end
    
@implementation ArtistTableCell : CPView
{
    CPTextField _label;
    CPView highlightView;
}
 
- (void)setRepresentedObject:(CPString)aString
{
    CPLog("The item is: " + aString);
    CPLog(@"frame is " + CPRectGetHeight([self frame]));
    //if(label || anObject == nil) label= nil;
	if(!_label)
    {
    
        _label = [CPTextField labelWithTitle:@"hello"];

        [_label setFont:[CPFont systemFontOfSize:11.0]];
        [_label setFrame:CGRectMake(10.0, 0.0, CGRectGetWidth([self bounds]) - 20.0, CGRectGetHeight([self bounds]))];

        [_label setVerticalAlignment:CPCenterVerticalTextAlignment];
        [_label setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

        [self addSubview:_label];
        
    }
    
    [_label setStringValue:aString];
    //[_label sizeToFit];
 
    //[_label setFrameOrigin: CGPointMake(CPRectGetWidth([self bounds])+10,0.0)];
}
 
- (void)setSelected:(BOOL)flag
{
    if(!highlightView)
    {
        highlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
        [highlightView setBackgroundColor: [CPColor blueColor]];
    }
 
    if(flag)
    {
        [self addSubview:highlightView positioned:CPWindowBelow relativeTo:_label];
        [_label setTextColor: [CPColor whiteColor]];
    }
    else
    {
        [highlightView removeFromSuperview];
        [_label setTextColor: [CPColor blackColor]];
    }
}
 
@end

@implementation ErrorView : CPView
{
}

-(id)initWithFrame:(CGRect)aFrame message:(CPString)aMessage
{
	self = [super initWithFrame:aFrame];
	if(self)
	{
		var label = [CPTextField labelWithTitle:aMessage];
		[label setFrameOrigin:CGRectMake(CPRectGetWidth(aFrame)/3, CPRectGetHeight(aFrame) - CPRectGetHeight([label frame]) / 2)];
		[self addSubview:label];
	}
	return self;
}

@end




