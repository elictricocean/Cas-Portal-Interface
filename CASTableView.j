@import <AppKit/CPTheme.j>
@import <AppKit/CPView.j>

var LEFT_PANEL_WIDTH    = 176.0;

@implementation CASTableView : CPView
{
    CPMutableArray      searchItems;
	CPCollectionView    collectionView;
	CPScrollView		scrollView
	id 					delegate;
	int 				numberOfRows;
	BOOL 				canDeleteItems;
}

- (void)initWithFrame:(CGRect)aFrame deletableItems:(BOOL)_canDeleteItems
{
	self = [super initWithFrame:aFrame];
	
	if(self)
	{
		searchItems = [[CPMutableArray alloc] init];
		canDeleteItems = _canDeleteItems;
		var descriptorItem = [[CPCollectionViewItem alloc] init];
		var descriptorView = [[CASDescriptorCell alloc] initWithFrame:CGRectMake(0.0, 0.0, CPRectGetWidth(aFrame), 36.0) deletableItems:canDeleteItems];
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(removeItem:) name:@"RemovedItem" object:nil];
		[descriptorItem setView:descriptorView];

    	collectionView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, CPRectGetWidth(aFrame), CGRectGetHeight(aFrame))];
    	
    	[collectionView setDelegate:self];
    	[collectionView setItemPrototype:descriptorItem];
    	[collectionView setMinItemSize:CGSizeMake(20.0, 36.0)];
    	[collectionView setMaxItemSize:CGSizeMake(10000000.0, 36.0)];
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
    }
    
    return self;
}

- (void)setDelegate:(id)aDelegate
{
	delegate = aDelegate;
}

- (void)setContent:(CPArray)anArray
{
	searchItems = anArray;
	[collectionView setMaxNumberOfRows:[searchItems count]];
	[collectionView reloadContent];
}

- (void)addContent:(CPDictionary)aDict
{
	CPLog(@"called again" + aDict);
	if(aDict)
	{
		CPLog(@"yee");
		[searchItems addObject:aDict];
		CPLog(searchItems);
		[collectionView setMaxNumberOfRows:[searchItems count]];
		[collectionView reloadContent];
	}
}

- (void)setLabel:(CPString)aLabel
{
	if(aLabel && ![aLabel isEqualToString:@""])
	{
		var label = [CPTextField labelWithTitle:aLabel];

    	[label setFont:[CPFont boldSystemFontOfSize:11.0]];
    	[label setTextColor:[CPColor colorWithCalibratedRed:93.0 / 255.0 green:93.0 / 255.0 blue:93.0 / 255.0 alpha:1.0]];
    	[label setTextShadowColor:[CPColor colorWithCalibratedRed:225.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.7]];
    	[label setTextShadowOffset:CGSizeMake(0.0, 1.0)];
    	[label sizeToFit];
    	[label setFrameOrigin:CGPointMake(5.0, 4.0)];
    	
		[[scrollView contentView] addSubview:label];
	}
}

- (void)collectionViewDidChangeSelection:(CPCollectionView)aCollectionView
{
    var index = [[aCollectionView selectionIndexes] firstIndex];
        
    if([delegate respondsToSelector:@selector(tableView:changedSelectionIndex:)])
    	[delegate tableView:self changedSelectionIndex:index];
}

-(void)collectionView:(CPCollectionView)collectionView didDoubleClickOnItemAtIndex:(int)index
{
	if([delegate respondsToSelector:@selector(tableView:doubleClickedIndex:)])
    	[delegate tableView:self doubleClickedIndex:index];
}

- (void)removeItem:(CPNotification)aNote
{
	CPLog(@"called");
	var index = [searchItems indexOfObjectIdenticalTo:[[aNote userInfo] objectForKey:@"item"]];
	[searchItems removeObjectAtIndex:index];
	[collectionView setMaxNumberOfRows:[searchItems count]];
	[collectionView reloadContent];
		
	if([delegate respondsToSelector:@selector(tableView:didRemoveObjectAtIndex:)])
		[delegate tableView:self didRemoveObjectAtIndex:index];
}

- (void)removeItems
{
	[searchItems removeAllObjects];
	[collectionView reloadContent];
}

- (void)content
{
	return [collectionView content];
}

@end

var SelectionColor = nil;

@implementation CASDescriptorCell : CPView
{
	CPDictionary searchValue;
    CPTextField _label;
    CPButton closeButton;
    CPImageView imageView;
    BOOL canDeleteItems;
    var frame;
}

- (id)initWithFrame:(CGRect)aFrame deletableItems:(BOOL)_canDeleteItems
{
	self = [super init];
	if(self)
	{
		frame = aFrame;
		canDeleteItems = _canDeleteItems;
	}
	return self;
}

+ (CPImage)selectionColor
{
    if (!SelectionColor)
        SelectionColor = [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/selection.png" size:CGSizeMake(1.0, 36.0)]];

    return SelectionColor;
}

- (void)setRepresentedObject:(CPDictionary)aSearchValue
{
	if([aSearchValue objectForKey:@"image"] && !imageView)
	{
		imageView = [[CPImageView alloc] initWithFrame:CGRectMake(10.0, CPRectGetHeight([self frame])/2+6, 25.0, 25.0)];
		[self addSubview:imageView];
	}
	
    if (!_label)
    {
        _label = [CPTextField labelWithTitle:@"hello"];

        [_label setFont:[CPFont systemFontOfSize:11.0]];
        [_label setFrame:CGRectMake(imageView ? CPRectGetMaxX([imageView frame]) : 10.0, 0.0, CGRectGetWidth([self bounds]) - 20.0, CGRectGetHeight([self bounds]))];

        [_label setVerticalAlignment:CPCenterVerticalTextAlignment];
        [_label setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

        [self addSubview:_label];
    }
        
    if(canDeleteItems)
    {
        closeButton = [[CPButton alloc] initWithFrame:CGRectMake(CPRectGetWidth(frame)-20.0, CPRectGetHeight(frame)/4, 16.0, 16.0)];
        [closeButton setBordered:NO];
        [closeButton setValue:CPImageOnly forThemeAttribute:@"image-position"];
        [closeButton setImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/CPWindowStandardCloseButton.png" size:CPSizeMake(16, 16)]];
		[closeButton setAlternateImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/CPWindowStandardCLoseButtonHighlighted.png" size:CPSizeMake(16, 16)]];
		[closeButton setEnabled:YES];
		[closeButton setTarget:self];
		[closeButton setAction:@selector(removeItem:)];
		[self addSubview:closeButton];
    }
    if([aSearchValue objectForKey:@"image"] && imageView)
	{
		CPLog(@"image is %@", [aSearchValue objectForKey:@"image"]);
    	[imageView setImage:[[CPImage alloc] initWithContentsOfFile:[aSearchValue objectForKey:@"image"] size:CGSizeMake(25.0,25.0)]];
		CPLog(@"filename is %@", [[imageView image] filename])
	}
    CPLog(@"search val is " + [aSearchValue objectForKey:@"title"]);
    searchValue = aSearchValue;
    [_label setStringValue:[aSearchValue objectForKey:@"title"]];
}

- (void)setSelected:(BOOL)isSelected
{
    [self setBackgroundColor:isSelected ? [[self class] selectionColor] : nil];

    [_label setTextShadowOffset:isSelected ? CGSizeMake(0.0, 1.0) : CGSizeMakeZero()];
    [_label setTextShadowColor:isSelected ? [CPColor blackColor] : nil];
    [_label setFont:isSelected ? [CPFont boldSystemFontOfSize:11.0] : [CPFont systemFontOfSize:11.0]];
    [_label setTextColor:isSelected ? [CPColor whiteColor] : [CPColor blackColor]];
}

- (void)removeItem:(id)sender
{
	CPLog(@"notif called");
	[[CPNotificationCenter defaultCenter] postNotificationName:@"RemovedItem" object:self userInfo:[CPDictionary dictionaryWithObject:searchValue forKey:@"item"]];
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
	[super encodeWithCoder:aCoder];
	[aCoder encodeRect:frame forKey:@"Frame"];
	[aCoder encodeObject:[CPNumber numberWithBool:canDeleteItems] forKey:@"Delete"];
}

- (void)initWithCoder:(CPCoder)aCoder
{
	self = [super initWithCoder:aCoder];
	if(self)
	{
		frame = [aCoder decodeRectForKey:@"Frame"];
		canDeleteItems = [[aCoder decodeObjectForKey:"Delete"] boolValue];
	}
	return self;
}

@end
