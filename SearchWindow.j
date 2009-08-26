@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import "SearchView.j"
//http://pagesperso-orange.fr/cocoadev/SmartFolders/
@implementation SearchWindow : CPWindow
{
	CPView contentView;
	CPWebView _webView;
	CPView searchView;
}

- (id)initWithWebView:(CPWebView)webView
{
    self = [super initWithContentRect:CGRectMake(50,50,575,500) styleMask:CPClosableWindowMask];
    if(self)
    {
    	_webView = webView;
		contentView = [self contentView];
		searchView = [[SearchView alloc] initWithWebView:_webView];
		[contentView addSubview:searchView];
		var searchButton = [[CPButton alloc] initWithFrame:CGRectMakeZero()];
		[searchButton setTitle:@"search"];
		[searchButton setTarget:searchView];
		[searchButton setAction:@selector(search:)];
		[searchButton sizeToFit];
		[searchButton setFrameOrigin:CGPointMake(CPRectGetWidth([contentView frame]) - CPRectGetWidth([searchButton frame]) -5, CPRectGetHeight([contentView frame]) - CPRectGetHeight([searchButton frame]) -5)];
		[contentView addSubview:searchButton];
    }
    return self;
}



@end