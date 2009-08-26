//
// SFTable.j
// XYZRadio
//
// Created by Alos on 10/2/08.
// Copyright __MyCompanyName__ 2008. All rights reserved.
//
 
@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
 
@implementation CASOutlineView : CPView
{
    /*Para las tablas*/
    CPCollectionView collectionView;
    CPArray model;
    /*Cosas para los titulos*/
    CPArray columnModel;
    /*Cosas para las celdas*/
    SFCell celdas;
    int pos=0;
}
 
-(void) initWithColumnModel:(CPArray)aColumnModel model:(CPArray)aModel frame:(CGRect)bounds{
    self = [super initWithFrame:bounds];
    [self setModel:aModel];
    //para nuestro grid
    collectionView = [[CPCollectionView alloc] initWithFrame: CGRectMake(0, 19, CGRectGetWidth(bounds), CGRectGetHeight(bounds)-19)];
    
    //los scrolls por si son muchos
    var scrollView = [[CPScrollView alloc] initWithFrame: CGRectMake(0, 19, CGRectGetWidth(bounds), CGRectGetHeight(bounds)-19-59)];
    [scrollView setAutohidesScrollers: NO];
    [scrollView setDocumentView: collectionView];
    [[scrollView contentView] setBackgroundColor: NULL];
    [scrollView setHasHorizontalScroller:NO];
    [scrollView setHasVerticalScroller:YES]
    [scrollView setAutoresizesSubviews:YES];
    [scrollView setAutoresizingMask: CPViewHeightSizable];
    //los items q representan los renglones
    var listItem = [[CPCollectionViewItem alloc] init];
    celdas = [[SFCell alloc] initWithFrame:CPRectCreateCopy([self bounds])];
    [listItem setView: celdas];
    
    [collectionView setItemPrototype: listItem];
    [collectionView setMaxNumberOfColumns:1];
    [collectionView setVerticalMargin:0.0];
    [collectionView setMinItemSize:CPSizeMake(CGRectGetWidth(bounds), 19)];
    [collectionView setMaxItemSize:CPSizeMake(CGRectGetWidth(bounds), 19)];
    [collectionView setContent: model];
    [collectionView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];
    [self addSubview:scrollView];
    
    
    //DELEGATE?
    [collectionView setDelegate: self];
        
    //la q esta arriba del Collectionview
    var borderArriba = [[CPView alloc] initWithFrame:CGRectMake(0, 19 , CGRectGetWidth(bounds), 0)];
        [borderArriba setBackgroundColor: [CPColor grayColor]];
        //[borderArriba setAutoresizingMask: CPViewWidthSizable];
        [self addSubview: borderArriba];
    //la de arriba
    var borderTop = [[CPView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bounds), 0)];
        [borderTop setBackgroundColor: [CPColor grayColor]];
        //[borderTop setAutoresizingMask: CPViewWidthSizable];
        [self addSubview: borderTop];
 
    [self setColumnModel:aColumnModel];
    
    //[self registerForDraggedTypes:[SongsDragType]];
    
    return self;
}
 
-(void)collectionViewDidChangeSelection:(CPCollectionView)view
{
    if (view == collectionView)
    {
        var listIndex = [[collectionView selectionIndexes] firstIndex],
            key = [collectionView content][listIndex];
            
        var url = model[listIndex]["url"];
        CPLog(url);
        var info = [CPDictionary dictionaryWithObject:model[listIndex] forKey:"song"];
   [[CPNotificationCenter defaultCenter] postNotificationName:"setSong" object:self userInfo:info];
   CPLog("posted notification");
 
    }
}
 
-(void)setColumnModel:(CPArray)aColumnModel{
    pos = 0;
    columnModel = aColumnModel;
    var oldWidth;
    for(var i=0; i<[columnModel count];i++){
        var thisColumn = [columnModel objectAtIndex:i];
        [self addSubview: thisColumn];
        if(i>0 && i<[columnModel count]){
            pos= pos+CGRectGetWidth([[columnModel objectAtIndex: i-1] bounds])+1;
            var border = [[CPView alloc] initWithFrame:CGRectMake(pos, 0, 1, CGRectGetHeight([self bounds]))];
            CPLog("Setting line at: %d",pos);
            [border setBackgroundColor: [CPColor grayColor]];
            [border setAutoresizingMask: CPViewHeightSizable];
            [self addSubview: border];
        }
        
    }
}
-(void)setModel:(CPArray)aModel{
    model = aModel;
    [collectionView setContent: model];
    [collectionView reloadContent];
}
/**
Adds an item to the table
@param the item to add to the table
*/
-(void)addItem:(CPObject)anItem{
    [model addObject:anItem];
// [collectionView setModel: model];
    [collectionView reloadContent];
}
/**
@param anIndex the value where the item you want t remove is
*/
-(void)removeItem:(int)anIndex{
    [model removeObjectAtIndex: anIndex];
    [collectionView reloadContent];
}
/**
Returns the item that is currently selected
@return
*/
-(int)getSelectedItem{
    return [[collectionView selectionIndexes] firstIndex];
}
-(id)objectAtIndex:(int)index
{
    return model[index];
}
/**
Removes selected items
*/
-(void)removeSelectedItems{
    CPLog("removeSelectedItems in SFTable got the msg");
    var indexes= [collectionView selectionIndexes];
    var a = [indexes firstIndex];
    [model removeObjectAtIndex: a];
    [collectionView reloadContent];
}
-(CPIndexSet)getSelectedItems{
    return [collectionView selectionIndexes];
}
 
-(void)reload
{
    [collectionView reloadContent];
}
/*-(CPArray)collectionView:(CPCollectionView)collectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices{
return [SongsDragType];
}*/
 
- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indexes forType:(CPString)aType
{
    var index = CPNotFound,
        content = [aCollectionView content],
        songs = [];
 
    while ((index = [indexes indexGreaterThanIndex:index]) != CPNotFound)
        songs.push(content[index]);
    
    return [CPKeyedArchiver archivedDataWithRootObject:songs];
}
 
@end
 
@implementation CASOutlineCell : CPView
{
	CPButton disclosureButton;
    CPTextField aTextField;
	BOOL isDisclosureOpen;
    CPString _parentName;
    int _level;
    BOOL _isParent;
	CPCollectionView childTableView;
}
 
- (void)setRepresentedObject:(CPDictionary)itemDict
{
	_parentName = [itemDict objectForKey:@"parentName"];
	_isParent = [itemDict objectForKey:@"isParent"];
	_level = [itemDict objectForKey:@"level"];
	levelString = @"";
	for(var i = 0; i<_level*8; i++)
		levelString += @" ";
		
	if(isParent && !disclosureButton)
	{
		disclosureButton = [[CPButton alloc] init];
		[disclosureButton setImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/CPDisclosureButtonClosed.png" size:CGSizeMake(8.0, 8.0)]];
		[disclosureButton setValue:CPImageOnly forThemeAttribute:@"image-position"];];
		[disclosureButton setBordered:NO];
		[disclosureButton setTarget:self];
		[disclosureButton setAction:@selector(toggleDisclosure:)];
		[self addSubview:disclosureButton];
		isDisclosureOpen = NO;
		
		childTableView = [[CPCollectionView alloc] initWithFrame:CGRectMakeZero()];
		var listItem = [[CPCollectionViewItem alloc] init];
	    var cell = [[CASOutlineCell alloc] initWithFrame:CPRectCreateCopy([self bounds])];
	    [listItem setView: cell];

	    [childTableView setItemPrototype: listItem];
	    [childTableView setMaxNumberOfColumns:1];
	    [childTableView setVerticalMargin:0.0];
	    [childTableView setContent: model];
	    [childTableView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];
	}
	
    if(!aTextField)
    {
        aTextField = [[CPTextField alloc] initWithFrame:CGRectInset( [self bounds], 0, 0)];
        [aTextField setFont: [CPFont systemFontOfSize: 12.0]];
        [aTextField setTextColor: [CPColor blackColor]];
        [self addSubview: aTextField];
    }
    [aTextField setStringValue:levelString + [itemDict objectForKey:@"title"]];
    [aTextField setAutoresizingMask: CPViewWidthSizable | CPViewMinXMargin | CPViewMaxXMargin];
    [aTextField sizeToFit];
    [aTextField setFrameOrigin: CGPointMake(5,0.0)];
     
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
        [self addSubview:highlightView positioned:CPWindowBelow relativeTo: titleView];
        [aTextField setTextColor: [CPColor whiteColor]];
        
    }
    else
    {
        [highlightView removeFromSuperview];
        [aTextField setTextColor: [CPColor blackColor]];
 
    }
}

-(void)toggeDisclosure:(id)sender
{
	if(!isDisclosureOpen)
	{
		[disclosureButton setImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/CPDisclosureButtonOpen.png" size:CGSizeMake(8.0, 8.0)]];
		isDisclosureOpen = YES;
		
		childTableView = [[CPCollectionView alloc] initWithFrame:CGRectMakeZero()];
		
		var request = [[CPURLRequest alloc] initWithURL:[CPURL URLWithString:@"something.asp?newLevel=" + (_level + 1)+ @"&" + parentName + @"=" + [aTextField stringValue]];
		searchConnection = [[CPURLConnection] initWithRequest:request delegate:self startImmediately:YES];
	}
	else
	{
		[disclosureButton setImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/CPDisclosureButtonClosed.png" size:CGSizeMake(8.0, 8.0)]];
		isDisclosureOpen = NO;
	}
}
 
@end