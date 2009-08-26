@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import <MapKit/MKMapView.j>
@import "CASTableView.j"
//@import "CPButtonBar.j"
//http://pagesperso-orange.fr/cocoadev/SmartFolders/

var Point = "Point", Rect = "Rect", CurrentLocation = "CurrentLocation", SearchMap = "SearchMap";

@implementation CASMapWindow : CPWindow
{
	CASTableView table;
	MKMapView _mapView;
	CPView mapWindowContentView;
	id delegate;
}

- (id)initWithDelegate:(id)aDelegate
{
    self = [super initWithContentRect:CGRectMake(50, 125, 776, 480) styleMask:CPHUDBackgroundWindowMask | CPClosableWindowMask];
    if(self)
    {
    	CPLog(@"here now");
    	delegate = aDelegate;
		[self setTitle:@"Map"];
		mapWindowContentView = [self contentView];
		
		var toolbar = [[CPToolbar alloc] initWithIdentifier:"Map"];
		[toolbar setDelegate:self];
    	[toolbar setVisible:true];
    	[toolbar setDisplayMode:CPToolbarDisplayModeDefault];
    	[self setToolbar:toolbar];
	
		table = [[CASTableView alloc] initWithFrame:CGRectMake(4.0, 5.0, 176.0, CPRectGetHeight([mapWindowContentView frame])-40) deletableItems:YES];
    	[table setDelegate:self];
    	[table setLabel:@"SEARCH PARAMETERS"];
    	
    	[mapWindowContentView addSubview:table];
	
		_mapView = [[MKMapView alloc] initWithFrame:CGRectMake(180, 5.0, CPRectGetWidth([mapWindowContentView frame])-8-176, CPRectGetHeight([mapWindowContentView frame])-40) apiKey:@"ABQIAAAAprm4ybADpC-nwIZK9chByBS_BVwxir0gKg6lo6CbxRIYWdTPQBSlJPNgKdCAuw1nhNSw7Afml3ZdAQ"];
		[_mapView setDelegate:self];
		[_mapView setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
	    [mapWindowContentView addSubview:_mapView];
	    
	    var doneButton = [CPButton buttonWithTitle:@"Add to Search"];
	    [doneButton setFrameOrigin:CGPointMake(CPRectGetWidth([self frame])-CPRectGetWidth([doneButton frame])-5.0, CPRectGetHeight([_mapView frame])+10.0)];
	    [doneButton setBezelStyle:CPHUDBezelStyle];
	    [doneButton setTarget:self];
	    [doneButton setAction:@selector(done:)];
	    [mapWindowContentView addSubview:doneButton];
	
		[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(showDidYouMeanMenu:) name:@"DidYouMean" object:_mapView];
    }
    return self;
}

-(void)addPoint:(id)sender
{
	[_mapView setWillAddPoint:YES];
}

-(void)addRect:(id)sender
{
	[_mapView setWillAddRect:YES];
}

-(void)addCurrentLocation:(id)sender
{
	[_mapView addCurrentLocation];
}

-(void)search:(id)sender
{
	[_mapView search:[sender stringValue]];
}

-(void)addedSearchItem:(CPDictionary)anItem
{
	CPLog(@" I am Called");
	[table addContent:anItem];
}

-(void)showDidYouMeanMenu:(CPNotification)aNote
{
	var menu = [[aNote userInfo] objectForKey:@"menu"];
	var searchBar = [[[[self toolbar] items] lastObject] view];
	var aPoint = [mapWindowContentView convertPoint:CPPointMake(5.0, CPRectGetMaxY([searchBar frame])*3) fromView:searchBar]//CPRectGetMinX([searchBar frame])
	var anEvent = [CPEvent keyEventWithType:0
    				 			   location:aPoint
    						  modifierFlags:nil
					              timestamp:0
				               windowNumber:[self windowNumber]
					                context:nil
				                 characters:nil
                charactersIgnoringModifiers:nil
					              isARepeat:NO
					                keyCode:nil];
	[CPMenu popUpContextMenu:menu withEvent:anEvent forView:searchBar];
}

-(void)tableView:(CASTableView)tableView didRemoveObjectAtIndex:(int)index
{
	[_mapView removeObjectAtIndex:index];
}

-(void)done:(id)sender
{
	CPLog(@"called here");
	var items = [CPArray arrayWithArray:[table content]];
	if([items count] == 0)
	{
		var exit = confirm("There are no search parameters. Pleas click cancel to add to add some by using the toolbar or click OK to close.")
		if(!exit)
			return;
	}
	[table removeItems];
	[_mapView removeItems];
	
	if([delegate respondsToSelector:@selector(mapEndedWithValues:)])
		[delegate mapEndedWithValues:items];
	
	CPLog(@"items are %@", items);
	//[self close];
}

- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return [Point, Rect, CurrentLocation, CPToolbarFlexibleSpaceItemIdentifier, SearchMap];
}
 
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return [Point, Rect, CurrentLocation, CPToolbarFlexibleSpaceItemIdentifier, SearchMap];
 }
 
- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier: anItemIdentifier];
    
    if(anItemIdentifier == Point)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:"Resources/marker.png" size:CPSizeMake(20, 34)];
        [toolbarItem setImage: image];
        [toolbarItem setLabel:@"Point"];
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(addPoint:)];
        [toolbarItem setMinSize:CGSizeMake(20, 34)];
        [toolbarItem setMaxSize:CGSizeMake(20, 34)];
    }
    else if(anItemIdentifier == Rect)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:"Resources/boundingBox.png" size:CPSizeMake(39, 25)];
        var selectedImage = [[CPImage alloc] initWithContentsOfFile:"Resources/boundingBoxSelected.png" size:CPSizeMake(39, 25)];
        [toolbarItem setImage: image];
        [toolbarItem setLabel:@"Bounding Box"];
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(addRect:)];
        [toolbarItem setMinSize:CGSizeMake(39, 25)];
        [toolbarItem setMaxSize:CGSizeMake(39, 25)];
    }
    else if(anItemIdentifier == CurrentLocation)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:"Resources/logo.png" size:CPSizeMake(25, 25)];
        [toolbarItem setImage: image];
        [toolbarItem setLabel:@"Current Location on map"];
		[toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(addCurrentLocation:)];
        [toolbarItem setMinSize:CGSizeMake(25, 25)];
        [toolbarItem setMaxSize:CGSizeMake(25, 25)];
    }
    else if(anItemIdentifier == SearchMap)
    {
    	var textfield = [CPTextField roundedTextFieldWithStringValue:@"" placeholder:@"Search" width:150.0];
    	[textfield setTarget:self];
        [textfield setAction:@selector(search:)];
    	[toolbarItem setView:textfield];
        [toolbarItem setLabel:@"Search Map"];
        [toolbarItem setMinSize:CGSizeMake(CPRectGetWidth([textfield frame]), CPRectGetHeight([textfield frame]))];
        [toolbarItem setMaxSize:CGSizeMake(CPRectGetWidth([textfield frame]), CPRectGetHeight([textfield frame]))];
    }
    else
    {
        return nil;
    }
    
    return toolbarItem;
}

@end