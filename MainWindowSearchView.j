@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import "SearchView.j"
//http://pagesperso-orange.fr/cocoadev/SmartFolders/
@implementation MainWindowSearchView : CPView
{
	CPView contentView;
	CPView searchView;
	CPButton searchButton;
	CPPopUpButton searchOperatorPopUpButton;
}

- (id)initWithFrame:(CGRect)aFrame type:(CPString)aType
{
	self = [super initWithFrame:aFrame];
    if(self)
    {
    	[self setBackgroundColor:[CPColor colorWithRed:212.0 / 255.0 green:221.0 / 255.0 blue:230.0 / 255.0 alpha:1.0]];
		
		searchOperatorPopUpButton = [[CPPopUpButton alloc] initWithFrame:CGRectMake(10.0, 8.0, 75.0, 25.0)];
		[searchOperatorPopUpButton addItemWithTitle:@"Any"];
		[searchOperatorPopUpButton addItemWithTitle:@"All"];
		[searchOperatorPopUpButton selectItemAtIndex:0];
		[searchOperatorPopUpButton setTarget:self];
	    [searchOperatorPopUpButton setAction:@selector(setSearchOperator:)];
	    [self addSubview:searchOperatorPopUpButton];
	    
	    var ofTheFolowingString = [CPTextField labelWithTitle:@"of the following is true"];
	    [ofTheFolowingString setFrameOrigin:CPPointMake(CPRectGetMaxX([searchOperatorPopUpButton frame])+2.0, 10.0)];
	    [self addSubview:ofTheFolowingString];
    	
		searchButton = [[CPButton alloc] initWithFrame:CGRectMakeZero()];
		[searchButton setTitle:aType];
		[searchButton setTarget:self];
		[searchButton setAction:@selector(search:)];
		[searchButton sizeToFit];
		[searchButton setFrameOrigin:CGPointMake(CPRectGetWidth(aFrame) - CPRectGetWidth([searchButton frame]) - 5, CPRectGetHeight(aFrame) - CPRectGetHeight([searchButton frame]) - 5)];
		[self addSubview:searchButton];
		
		var cancelButton = [[CPButton alloc] initWithFrame:CGRectMakeZero()];
		[cancelButton setTitle:@"Cancel"];
		[cancelButton setTarget:self];
		[cancelButton setAction:@selector(cancel:)];
		[cancelButton sizeToFit];
		[cancelButton setFrameOrigin:CGPointMake(5.0, CPRectGetHeight(aFrame) - CPRectGetHeight([searchButton frame]) -5)];
		[self addSubview:cancelButton];
		
		var frame = CGRectMake(0.0, CPRectGetMaxY([searchOperatorPopUpButton frame])+5.0, CPRectGetWidth(aFrame), CPRectGetHeight(aFrame)- CPRectGetHeight([searchButton frame]) - CPRectGetHeight([searchOperatorPopUpButton frame]) - 25);
		var scrollView = [[CPScrollView alloc] initWithFrame:frame];
		[scrollView setAutohidesScrollers:YES];
    	[scrollView setHasHorizontalScroller:NO];
    	[scrollView setAutoresizingMask:CPViewHeightSizable];
		searchView = [[SearchView alloc] initWithFrame:CGRectMake(0.0, 0.0, CPRectGetWidth(aFrame), CPRectGetHeight(aFrame)- CPRectGetHeight([searchButton frame]))];
		//var clipView = [[CPClipView alloc] initWithFrame:frame];
		[scrollView setDocumentView:searchView];
		//[scrollView setContentView:clipView];
		[self addSubview:scrollView];
		
		var border = [[CPView alloc] initWithFrame:CGRectMake(CPRectGetMaxX(aFrame)-1.0, 0.0, 1.0, CPRectGetHeight(aFrame))];
		[border setBackgroundColor:[CPColor blackColor]];
		[self addSubview:border];
		
    }
    return self;
}

-(void)setSearchOperator:(id)sender
{
	var selectedOperator = [[searchOperatorPopUpButton selectedItem] title];
	[searchView setOperator:([selectedOperator isEqualToString:@"Any"] ? @"or" : @"and")];
}

-(void)search:(id)sender
{
	CPLog(@"will search");
	if([searchView search:nil] && !window.isFiltering)
		[self removeFromSuperview];
}

-(void)cancel:(id)sender
{
	[self removeFromSuperview];
	[[CPNotificationCenter defaultCenter] postNotificationName:@"CloseSearch" object:self userInfo:[CPDictionary dictionaryWithObjectsAndKeys:@"cancel", @"type"]];
}

-(void)switchType
{
	[searchButton setTitle:(window.isFiltering?@"Filter":@"Search")];
	[searchButton sizeToFit];
}

@end