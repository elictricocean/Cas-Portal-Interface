@import <AppKit/CPView.j>
@import "CASNode.j"

var LEFT_PANEL_WIDTH    = 176.0;
var SEARCH_URL			= @"something.asp"

@implementation CASOutlineView : CPView
{
    CPMutableArray      levelZeroItems;
	CPCollectionView    collectionView;
	CPScrollView		scrollView
	id 					delegate;
	int 				numberOfRows;
	CPURLConnection		searchConnection;
	CPMutableArray		content;
}

- (void)initWithFrame:(CGRect)aFrame
{
	self = [super initWithFrame:aFrame];
	
	if(self)
	{
		CPLog(@"woah here");
		searchItems = [[CPMutableArray alloc] init];

    	collectionView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, CPRectGetWidth(aFrame), CGRectGetHeight(aFrame))];
    	
    	var descriptorItem = [[CPCollectionViewItem alloc] init];
		var descriptorView = [[CASOutlineDescriptorCell alloc] initWithParent:collectionView];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(addRows:) name:@"AddedRows" object:nil];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRows:) name:@"RemovedRows" object:nil];
		[descriptorItem setView:descriptorView];
		
    	[collectionView setDelegate:self];
    	[collectionView setItemPrototype:descriptorItem];
    	[collectionView setMinItemSize:CGSizeMake(20.0, 18.0)];
    	[collectionView setMaxItemSize:CGSizeMake(10000000.0, 10000000.0)];
    	[collectionView setMaxNumberOfColumns:1];
    	[collectionView setContent:searchItems];
    	[collectionView setAutoresizingMask:CPViewWidthSizable];
    	[collectionView setVerticalMargin:0.0];
    	[collectionView setSelectable:YES];
    	[collectionView setFrameOrigin:CGPointMake(0.0, 20.0)];
    	//[collectionView setAutoresizingMask:CPViewWidthSizable];

    	scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, CPRectGetWidth(aFrame), CGRectGetHeight(aFrame))];
        var contentView = [scrollView contentView];

    	[scrollView setAutohidesScrollers:YES];
    	[scrollView setDocumentView:collectionView];

    	[contentView setBackgroundColor:[CPColor colorWithRed:212.0 / 255.0 green:221.0 / 255.0 blue:230.0 / 255.0 alpha:1.0]];
    	
    	[self addSubview:scrollView];

    	[collectionView setSelectionIndexes:[CPIndexSet indexSetWithIndex:0]];
		CPLog(@"woah her2");
		//var request = [[CPURLRequest alloc] initWithURL:[CPURL URLWithString:SEARCH_URL + @"?contentType=class"]];
		//searchConnection = [[CPURLConnection] initWithRequest:request delegate:self startImmediately:YES];
    }
    
    return self;
}

- (void)setDelegate:(id)aDelegate
{
	delegate = aDelegate;
}

- (void)setContent:(CPArray)anArray
{
	CPLog(@"add content is " + anArray);
	content = anArray;
	//[collectionView setMaxNumberOfRows:[searchItems count]];
	[collectionView setContent:content];
	[collectionView reloadContent];
	CPLog([content count]);
}

- (void)addContent:(CPDictionary)aDict
{
	CPLog(@"called again" + aDict);
	if(aDict)
	{
		CPLog(@"yee");
		[content addObject:aDict];
		CPLog(content);
		//[collectionView setMaxNumberOfRows:[searchItems count]];
		[collectionView reloadContent];
	}
}

-(void)addRows:(CPNotification)aNote
{
	CPLog(@"updating...");
	var rowValue = [[aNote userInfo] objectForKey:@"rowValue"];//Parent
	var parentIndex = [rowValue objectForKey:@"count"];
	var lowerLevelValues = [[aNote userInfo] objectForKey:@"lowerLevelValues"];//Children
	CPLog(@"row is " + [rowValue description]);
	CPLog(@"lower stuff is " + [lowerLevelValues description]);
	
	for(var i=0; i<[lowerLevelValues count]; i++)
	{
		[content insertObject:[lowerLevelValues objectAtIndex:i] atIndex:parentIndex + 1];
	}
	CPLog(@"content is " + content);
	//[collectionView setContent:content];
	
	[collectionView reloadContent];
	//[collectionView tile];
}

-(void)removeRows:(CPNotification)aNote
{
	var rowValue = [[aNote userInfo] objectForKey:@"rowValue"];//Parent
	var parentIndex = [rowValue objectForKey:@"count"];
	var lowerLevelValues = [[aNote userInfo] objectForKey:@"lowerLevelValues"];//Children
	CPLog(@"removing");
	for(var i=0; i<[lowerLevelValues count]; i++)
	{
		//[content removeObject:[lowerLevelValues objectAtIndex:i]];
		var isExpanded = [[lowerLevelValues objectAtIndex:i] objectForKey:@"childrenExpanded"];
		var count = 0;
		while(isExpanded)
		{
			var index = [content indexOfObjectIdenticalTo:[lowerLevelValues objectAtIndex:i]]+count;
			isExpanded = [[content objectAtIndex:index] objectForKey:@"childrenExpanded"];
			if(!isParent)
				[content removeObjectAtIndex:index];
			count++;
		}
		[lowerLevelValues objectAtIndex:i]
	}
	CPLog(@"content is " + content);
	//[collectionView setContent:content];
	
	[collectionView reloadContent];
	//[collectionView tile];
}

- (void)collectionViewDidChangeSelection:(CPCollectionView)aCollectionView
{
    var index = [[aCollectionView selectionIndexes] firstIndex];
        
    if([delegate respondsToSelector:@selector(tableView:changedSelectionIndex:)])
    	[delegate tableView:self changedSelectionIndex:index];
}

-(void)connection:(CPURLConnection)conn didRecieveData:(CPString)jsonString
{
	var data = JSON.parse(jsonString);
	content = [[CPMutableArray alloc] init];
	
	for(var i=0; i<[data count]; i++)
	{
		var dictionary = [CPDictionary dictionaryWithObjectsAndKeys:[data objectAtIndex:i], @"title",
																    [CPNumber numberWithInt:0], @"level",
																    [CPNumber numberWithInt:i], @"count",
																    [CPNumber numberWithBool:YES], @"isParent"];
		[content addObject:dictionary];
	}
	[collectionView setContent:content];
}

@end

var SelectionColor = nil;

@implementation CASOutlineDescriptorCell : CPView
{
	CPDictionary rowValue;
	CPString _title;
	BOOL _isParent;
	CPCollectionView _parent;
	int _level;
	int _count;
    CPTextField _label;
    CPButton disclosureButton;
	CPArray levelNames;
	CPCollectionView collectionView;
	CPArray lowerLevelValues;
}

- (id)initWithParent:(CPCollectionView)parent
{
	self = [super init];
	if(self)
	{
		CPLog(@"descriptor");
		levelNames = [CPArray arrayWithObjects:@"Class", @"Order", @"Family", @"Genus", @"Species"];
		_parent = parent;
		CPLog(@"parent is " + _parent);
	}
	return self;
}

+ (CPImage)selectionColor
{
    if (!SelectionColor)
        SelectionColor = [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/selection.png" size:CGSizeMake(1.0, 36.0)]];

    return SelectionColor;
}

- (void)setRepresentedObject:(CASNode)aNode
{
	isParent = [aNode isExpandable];
	_title = [aNode name];
	_level = [levelNames indexOfObject:[aNode type]];
	
	
	CPLog(@"item is " + itemDict);
	rowValue = itemDict;
	_title = [itemDict objectForKey:@"title"];
	_isParent = [[itemDict objectForKey:@"isParent"] boolValue];
	_level = [[itemDict objectForKey:@"level"] intValue];
	_count = [[itemDict objectForKey:@"count"] intValue];
	levelString = @"";
	for(var i = 0; i<_level*6; i++)
		levelString += @" ";
	_title = levelString + _title;
	
	CPLog(@"is parent?" + [itemDict objectForKey:@"isParent"]);
	
    if (!_label)
    {
        _label = [CPTextField labelWithTitle:@"hello"];

        [_label setFont:[CPFont systemFontOfSize:11.0]];
        [_label setFrame:CGRectMake(25.0, 0.0, CGRectGetWidth([self bounds]) - 20.0, CGRectGetHeight([self bounds]))];

        [_label setVerticalAlignment:CPCenterVerticalTextAlignment];
        [_label setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

        [self addSubview:_label];
    }
    
	if(_isParent && !disclosureButton)
	{
		disclosureButton = [[CPButton alloc] init];
		[disclosureButton setImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/CPDisclosureButtonClosed.png" size:CGSizeMake(11.0, 12.0)]];
		[disclosureButton setValue:CPImageOnly forThemeAttribute:@"image-position"];
		[disclosureButton setBordered:NO];
		[disclosureButton sizeToFit];
		[disclosureButton setFrame:CGRectMake(_level*11.0+10.0, 2.5, 11.0, 12.0)];
		[disclosureButton setTarget:self];
		[disclosureButton setAction:@selector(toggleDisclosure:)];
		[self addSubview:disclosureButton];
		isDisclosureOpen = NO;
		[rowValue setObject:[CPNumber numberWithBool:YES] forKey:@"childrenExpanded"];
		/*collectionView = [[CPCollectionView alloc] initWithFrame:CGRectMake(40.0, CPRectGetMaxY([_label frame]), CPRectGetWidth([self frame]), CGRectGetHeight([self frame]))];
		
		var descriptorItem = [[CPCollectionViewItem alloc] init];
		var descriptorView = [[[self class] alloc] initWithParent:collectionView];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSize:) name:@"UpdatedSize" object:nil];
		[descriptorItem setView:descriptorView];
    	
    	[collectionView setDelegate:self];
    	[collectionView setItemPrototype:descriptorItem];
    	[collectionView setMinItemSize:CGSizeMake(20.0, 18.0)];
    	[collectionView setMaxItemSize:CGSizeMake(10000000.0, 18.0)];
    	[collectionView setMaxNumberOfColumns:1];
    	[collectionView setAutoresizingMask:CPViewWidthSizable];
    	[collectionView setVerticalMargin:0.0];
    	[collectionView setSelectable:YES];
    	[collectionView setFrameOrigin:CGPointMake(0.0, 40.0)];*/
	}
    
    [_label setStringValue:_title];
    //[self sizeToFit];
}

- (void)setSelected:(BOOL)isSelected
{
    [self setBackgroundColor:isSelected ? [[self class] selectionColor] : nil];

    [_label setTextShadowOffset:isSelected ? CGSizeMake(0.0, 1.0) : CGSizeMakeZero()];
    [_label setTextShadowColor:isSelected ? [CPColor blackColor] : nil];
    [_label setFont:isSelected ? [CPFont boldSystemFontOfSize:11.0] : [CPFont systemFontOfSize:11.0]];
    [_label setTextColor:isSelected ? [CPColor whiteColor] : [CPColor blackColor]];
}

-(void)toggleDisclosure:(id)sender
{
	if(!isDisclosureOpen)
	{
		[disclosureButton setImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/CPDisclosureButtonOpen.png" size:CGSizeMake(11.0, 12.0)]];
		isDisclosureOpen = YES;
		
		if(!lowerLevelValues)
		{
			//var request = [[CPURLRequest alloc] initWithURL:[CPURL URLWithString:SEARCH_URL + @"?contentType=" + [levelNames objectAtIndex:_level+1] + @"&value=" + _title]];
			//searchConnection = [[CPURLConnection] initWithRequest:request delegate:self startImmediately:YES];
			lowerLevelValues = [CPArray arrayWithObjects:[CPDictionary dictionaryWithObjectsAndKeys:@"test1", @"title",
																   [CPNumber numberWithInt:_level + 1], @"level",
																   [CPNumber numberWithInt:_count+1], @"count",
																   [CPNumber numberWithBool:NO], @"isParent"],
													  [CPDictionary dictionaryWithObjectsAndKeys:@"test2", @"title",
																   [CPNumber numberWithInt:_level + 1], @"level",
																   [CPNumber numberWithInt:_count+2], @"count",
																   [CPNumber numberWithBool:NO], @"isParent"]];//_level == 0 ? YES : NO
			//[collectionView setContent:lowerLevelValues];
			CPLog(@"lower level = " + lowerLevelValues);
			[rowValue setObject:[CPNumber numberWithBool:YES] forKey:@"childrenExpanded"];
			[rowValue setObject:[CPNumber numberWithInt:[lowerLevelValues count]] forKey:@"childrenCount"];
			[[CPNotificationCenter defaultCenter] postNotificationName:@"AddedRows" object:self userInfo:[CPDictionary dictionaryWithObjectsAndKeys:rowValue, @"rowValue", lowerLevelValues, @"lowerLevelValues"]];
			
		}
		else
		{
			//[collectionView setContent:lowerLevelValues];
			CPLog(@"exis");
			[[CPNotificationCenter defaultCenter] postNotificationName:@"AddedRows" object:self userInfo:[CPDictionary dictionaryWithObjectsAndKeys:rowValue, @"rowValue", lowerLevelValues, @"lowerLevelValues"]];
		}
		//[self addSubview:collectionView];
		//if([[self subviews] containsObject:collectionView])
			//CPLog(@"in");
	}
	else
	{
		[disclosureButton setImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/CPDisclosureButtonClosed.png" size:CGSizeMake(11.0, 12.0)]];
		isDisclosureOpen = NO;
		[[CPNotificationCenter defaultCenter] postNotificationName:@"RemovedRows" object:self userInfo:[CPDictionary dictionaryWithObjectsAndKeys:rowValue, @"rowValue", lowerLevelValues, @"lowerLevelValues"]];
		//[collectionView removeFromSuperview];
	}
	
	//[self updateSize];
}

/*-(void)updateSize:(CPNotification)aNot
{
	
	CPLog(@"height is " + CPRectGetHeight([self frame]));
	if(!isDisclosureOpen)
		[self setFrameSize:CGSizeMake(CPRectGetWidth([self frame]), 18.0 + CPRectGetHeight([collectionView frame]))];
	else
		[self setFrameSize:CGSizeMake(CPRectGetWidth([self frame]), 18.0)];
	CPLog(@"height is " + CPRectGetHeight([self frame]));
	
	/*CPLog(@"parent is " + _parent);
	/*[self setNeedsDisplay:YES];	
	[collectionView reloadContent];
	[_parent reloadContent];
	[_parent tile];
	//var index = [[_parent items] indexOfObjectIdenticalTo:self];
	//[[[_parent items] objectAtIndex:index] resetFrame];
}

-(void)resetFrame
{
	if(!isDisclosureOpen)
		[self setFrameSize:CGSizeMake(CPRectGetWidth([self frame]), 18.0 + CPRectGetHeight([collectionView frame]))];
	else
		[self setFrameSize:CGSizeMake(CPRectGetWidth([self frame]), 18.0)];
}*/

-(void)connection:(CPURLConnection)conn didRecieveData:(CPString)jsonString
{
	var data = JSON.parse(jsonString);
	lowerLevelValues = [[CPArray alloc] init];
	for(var i=0; i<[data count]; i++)
	{
		var dictionary = [CPDictionary dictionaryWithObjectsAndKeys:[data objectAtIndex:i], @"title",
																   [CPNumber numberWithInt:_level+1], @"level",
																   [CPNumber numberWithInt:_count+i], @"count",
																   [CPNumber numberWithBool:(_level < [levelNames count]-1)], @"isParent"];
		[lowerLevelValues addObject:dictionary];
	}
	[rowValue setobject:[CPNumber numberWithInt:[lowerLevelValues count]] forKey:@"childrenCount"];
	[[CPNotificationCenter defaultCenter] postNotificationName:@"AddedRows" object:self userInfo:[CPDictionary dictionaryWithObjectsAndKeys:rowValue, @"rowValue",
							 lowerLevelValues, @"lowerLevelValues"]];
	//[collectionView setContent:lowerLevelValues];
	//[self sizeToFit];
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:levelNames forKey:@"levelNames"];
	[aCoder encodeObject:_parent forKey:@"parent"];
}

- (void)initWithCoder:(CPCoder)aCoder
{
	self = [super initWithCoder:aCoder];
	if(self)
	{
		levelNames = [aCoder decodeObjectForKey:@"levelNames"];
		_parent = [aCoder decodeObjectForKey:"parent"];
	}
	return self;
}


@end
