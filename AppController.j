/*
 * AppController.j
 * NewApplication
 *
 * Created by You on May 21, 2009.
 * Copyright 2009, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import "MainWindowSearchView.j"
@import "CASResultsTableView.j"
@import "CASDetialView.j"
@import "QueryBar.j"
@import "CASTableView.j"
@import "CASTaxonBrowser.j"

var Logo = "Logo";
var Title = "Title";
var FilterItem = @"FilterItem";
var InfoItem = @"InfoItem";
var SearchField = @"SearchField";
var SearchItem = @"SearchItem";

@implementation AppController : CPObject
{
	CPView contentView;
	CPScrollView resultsScrollView;
	MainWindowSearchView searchView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    CPLogRegister(CPLogConsole);
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
    contentView = [theWindow contentView];
    window.theContentView = contentView;
    
    var toolbar = [[CPToolbar alloc] initWithIdentifier:"CAS"];
    
    resultsScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0.0, CPRectGetMinY([contentView frame]), CPRectGetWidth([contentView frame]), CPRectGetHeight([contentView frame]) - 60)]; 
    [resultsScrollView setAutohidesScrollers:YES];
    [resultsScrollView setHasHorizontalScroller:YES];
    [resultsScrollView setHasVerticalScroller:NO]; 
    
    var mainTableView = [[CASResultsTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, CPRectGetWidth([contentView frame])-250.0, CPRectGetHeight([contentView frame]) - 60) delegate:self];
    
    [resultsScrollView setDocumentView:mainTableView];
    [contentView addSubview:resultsScrollView]; 
    
    window.isFiltering = NO;
    
    window.detailView = [[CASDetailView alloc] initWithFrame:CGRectMake(CPRectGetWidth([contentView frame])-250.0, 0.0, 250.0, CPRectGetHeight([contentView frame]) - 60)];
    [contentView addSubview: window.detailView];
    CPLog(window.detailView);
    	
    [toolbar setDelegate:self];
    [toolbar setVisible:true];
    [toolbar setDisplayMode:CPToolbarDisplayModeIconOnly];
    [theWindow setToolbar:toolbar];
    
    [theWindow orderFront:self];
    
    //[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewSelectionDidChange:) name:CPTableViewSelectionDidChangeNotification object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(closeSearch:) name:@"CloseSearch" object:nil];
}


- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return [Logo, Title, CPToolbarFlexibleSpaceItemIdentifier, FilterItem, InfoItem, CPToolbarFlexibleSpaceItemIdentifier, SearchField, SearchItem];
}
 
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return [self toolbarAllowedItemIdentifiers:aToolbar];
}
 
- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier: anItemIdentifier];
    
    if(anItemIdentifier == Logo)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:"Resources/logo.png" size:CPSizeMake(25, 25)];
        [toolbarItem setImage: image];
        [toolbarItem setMinSize:CGSizeMake(25, 25)];
        [toolbarItem setMaxSize:CGSizeMake(25, 25)];
    }
    else if(anItemIdentifier == Title)
    {
        var textField = [[CPTextField alloc] initWithFrame:CGRectMake(15,0,150,42)];
        [textField setObjectValue:@"Research"];
        [textField setFont:[CPFont boldSystemFontOfSize: 25.0]];
        [toolbarItem setView:textField];
        [toolbarItem setMinSize:CGSizeMake(150, 42)];
        [toolbarItem setMaxSize:CGSizeMake(150, 42)];
    }
    else if(anItemIdentifier == FilterItem)
    {
    	var button = [CPButton buttonWithTitle:@"Filter"];
 
        [toolbarItem setView:button];
        [toolbarItem setTarget:nil];
        [toolbarItem setAction:@selector(filter:)];
 
        var width = CGRectGetWidth([button frame]);
 
        [toolbarItem setMinSize:CGSizeMake(width, 32.0)];
        [toolbarItem setMaxSize:CGSizeMake(width, 32.0)];
    }
    else if(anItemIdentifier == InfoItem)
    {
    	var button = [CPButton buttonWithTitle:@"Info Window"];
    	[button setDefaultButton:YES];
 
        [toolbarItem setView:button];
        [toolbarItem setTarget:nil];
        [toolbarItem setAction:@selector(toggleInfoWindow:)];
 
        var width = CGRectGetWidth([button frame]);
 
        [toolbarItem setMinSize:CGSizeMake(width, 32.0)];
        [toolbarItem setMaxSize:CGSizeMake(width, 32.0)];
    }
    else if(anItemIdentifier == SearchField)
    {
    	var search = [CPTextField roundedTextFieldWithStringValue:@"" placeholder:@"Search" width:150.0];
 
        [toolbarItem setView:search];
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(basicSearch:)];
 
        [toolbarItem setMinSize:CGSizeMake(150.0, 32.0)];
        [toolbarItem setMaxSize:CGSizeMake(150.0, 32.0)];
    }
    else if(anItemIdentifier == SearchItem)
    {
    	var button = [CPButton buttonWithTitle:@"Advanced Search"];
 
        [button setDefaultButton:YES];
 
        [toolbarItem setView:button];
        [toolbarItem setTarget:nil];
        [toolbarItem setAction:@selector(search:)];
 
        var width = CGRectGetWidth([button frame]);
 
        [toolbarItem setMinSize:CGSizeMake(width, 32.0)];
        [toolbarItem setMaxSize:CGSizeMake(width, 32.0)];
    }
    else
    {
        return nil;
    }
    
    return toolbarItem;
}

-(void)search:(id)sender
{
    if([[contentView subviews] containsObject:searchView])
	{
		if(window.isFiltering && sender)
		{
			var exit = confirm("Cancel filter and begin search?")
			if(!exit)
				return;
			[searchView switchType];
		}
		else
			return;
	}

	if(!searchView)
		searchView = [[MainWindowSearchView alloc] initWithFrame:CGRectMake(CPRectGetMinX([contentView frame]), 0.0, 575.0 + 17, 	CPRectGetHeight([contentView frame])) type:(window.isFiltering?@"Filter":@"Search")];	
	else
		[searchView switchType];
	[contentView addSubview:searchView];
	[resultsScrollView setFrame:CGRectMake(575.0 + 17,0.0, CPRectGetWidth([contentView frame]) - CPRectGetWidth([searchView frame]) - ([[contentView subviews] containsObject:window.detailView]?250.0:0.0), CPRectGetHeight([contentView frame]))];
	//[resultsScrollView setFrameOrigin:CPPointMake(575.0 + 17, 0.0)];
	CPLog(@"frame is %@", CPStringFromRect([resultsScrollView frame]));
	[resultsScrollView setNeedsDisplay:YES];
}

-(void)filter:(id)sender
{
	if(window.isFiltering)
		return;
		
	if([[contentView subviews] containsObject:searchView] && !window.isFiltering)
	{
		var exit = confirm("Cancel search and begin filter?")
		if(!exit)
			return;
		[searchView switchType];
	}
	window.isFiltering = YES;
	[self search:nil];
}

-(void)toggleInfoWindow:(id)sender
{
	if([[contentView subviews] containsObject:window.detailView])
	{
		[sender setDefaultButton:NO];
		[window.detailView removeFromSuperview];
		[resultsScrollView setFrame:CGRectMake(CPRectGetMinX([resultsScrollView frame]),CPRectGetMinY([resultsScrollView frame]),CPRectGetWidth([resultsScrollView frame])+CPRectGetWidth([window.detailView frame]),CPRectGetHeight([resultsScrollView frame]))];
	}
	else
	{
		[sender setDefaultButton:YES];
		[contentView addSubview:window.detailView];
		[resultsScrollView setFrame:CGRectMake(CPRectGetMinX([resultsScrollView frame]),CPRectGetMinY([resultsScrollView frame]),CPRectGetWidth([resultsScrollView frame])-CPRectGetWidth([window.detailView frame]),CPRectGetHeight([resultsScrollView frame]))];
	}
	[resultsScrollView setNeedsDisplay:YES];
	[resultsScrollView resizeSubviewsWithOldSize:nil];
	[[resultsScrollView documentView] resizeWithRect:CGRectCreateCopy([resultsScrollView frame])];
	console.log(CPStringFromRect([resultsScrollView frame]));
}

-(void)tableViewSelectionDidChange:(CPNotification)aNote
{
	var data = window.results[[[window.resultsTable selectedRowIndexes] firstIndex]];
	[window.detailView setData:data];
}

-(void)closeSearch:(CPNotification)aNote
{
	[resultsScrollView setFrame:CGRectMake(0.0, 0.0, CPRectGetWidth([contentView frame]) - ([[contentView subviews] containsObject:window.detailView]?250.0:0.0), CPRectGetHeight([contentView frame]))];
	[[resultsScrollView documentView] resizeWithRect:CGRectCreateCopy([resultsScrollView frame])];
	if([[[aNote userInfo] objectForKey:@"type"] isEqualToString:@"cancel"])
		searchView = nil;
	window.isFiltering = NO;
}

-(void)addSearch:(CPNotification)aNote
{
	var userInfo = [aNote userInfo];
	CPLog(@"user info is " + [userInfo description]);
	CPLog(@"searches are " + [searches description]);
	[[userInfo objectForKey:@"searchView"] removeFromSuperview];
	CPLog(@"here");
	//[webView setFrame:CGRectMake(CPRectGetMaxX([table frame]), 0.0, CPRectGetWidth([contentView frame])-176.0, CPRectGetHeight([contentView frame]))];
}

-(void)cancelSearch:(CPNotification)aNote
{
	var userInfo = [aNote userInfo];
	[[userInfo objectForKey:@"searchView"] removeFromSuperview];
	[resultsScrollView setFrame:CGRectMake(0.0,0.0, CPRectGetWidth([contentView frame]) - 250.0, CPRectGetHeight([contentView frame]))];
}

@end
