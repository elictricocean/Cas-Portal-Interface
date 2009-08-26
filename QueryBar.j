@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import "CASButton.j"
@import "DCLinkTextField.j"
//http://pagesperso-orange.fr/cocoadev/SmartFolders/
@implementation QueryBar : CPView
{
	CPString _identifier;
	CPArray _items;
	id _delegate;
	id _textFieldDelegate;
	BOOL addAddRemoveButtonsShown;
	
	var addButton;
	var subtractButton;
}

- (id)initWithFrame:(CGRect)aFrame identifier:(CPString)identifier delegate:(id)delegate
{
	self = [super initWithFrame:aFrame];
	if(self)
	{
	    _identifier = identifier;
		_delegate = delegate;
		
		_items = [[CPArray alloc] init];
		
		addButton = [[CASButton alloc] initWithFrame:CGRectMakeZero()];
		//[addButton setTitle:@"+"];
		[addButton setImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/CPImageNameAddTemplate.png" size:CGSizeMake(8.0, 8.0)]];
		[addButton setValue:CPImageOnly forThemeAttribute:@"image-position"];
		[addButton setImageDimsWhenDisabled:YES];
		[addButton sizeToFit];
		[addButton setTarget:self];
		[addButton setAction:@selector(addSearchItemAfterSearchItem:)];
		
		subtractButton = [[CPButton alloc] initWithFrame:CGRectMakeZero()];
		//[subtractButton setTitle:@"-"];
		[subtractButton setImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/CPImageNameRemoveTemplate.png" size:CGSizeMake(8.0, 8.0)]];
		[subtractButton setValue:CPImageOnly forThemeAttribute:@"image-position"];
		[subtractButton setImageDimsWhenDisabled:YES];
		[subtractButton sizeToFit];
		[subtractButton setTarget:self];
		[subtractButton setAction:@selector(removeSearchItem:)];
		
		addAddRemoveButtonsShown = NO;
	}
	return self;
}

-(void)addTextWithLabel:(CPString)aString
{
    var newX = [self newX];    
    var item = [[CPTextField alloc] initWithFrame:CGRectMake(newX, 0, 150, 25)];
    [item setObjectValue:aString];
	if([_items count] == 0)
    	[item setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
	else
		[item sizeToFit];
    [_items addObject:item]
    [self addSubview:item];
}

-(void)addPopUpButtonWithSelectLabel:(CPString)aSelectedString inLabels:(CPString)aString, ...
{
    var newX = [self newX]; 
    var item = [[CPPopUpButton alloc] initWithFrame:CGRectMake(newX, 0, 150, 25)];
    for (var i = 3; i < arguments.length; i++) {
        [item addItemWithTitle:arguments[i]];
		if([arguments[2] isEqualToString:arguments[i]])
            [item selectItemAtIndex:i-3];
	}
	if([_items count] == 0)
	{
	   [item setTarget:self];
	   [item setAction:@selector(switchedFirstPopUpItem:)];
    }
    if([_items count] == 1)
    {
        [item setTarget:self];
        [item setAction:@selector(switchedSecondPopUpItem:)];
    }
    [_items addObject:item];
    [self addSubview:item];
}

-(void)addPopUpButtonWithSelectLabel:(CPString)aSelectedString inLabelArray:(CPArray)inLabels
{
    var newX = [self newX]; 
    var item = [[CPPopUpButton alloc] initWithFrame:CGRectMake(newX, 0, 150, 25)];
    for (var i = 0; i < [inLabels count]; i++) {
        [item addItemWithTitle:[inLabels objectAtIndex:i]];
		if([aSelectedString isEqualToString:[inLabels objectAtIndex:i]])
            [item selectItemAtIndex:i];
	}
	if([_items count] == 0)
	{
	   [item setTarget:self];
	   [item setAction:@selector(switchedFirstPopUpItem:)];
    }
    if([_items count] == 1)
    {
        [item setTarget:self];
        [item setAction:@selector(switchedSecondPopUpItem:)];
    }
    [_items addObject:item];
    [self addSubview:item];
}

-(void)addIsContainsItem
{
    [self addPopUpButtonWithSelectLabel:@"is" inLabels:@"is",@"contains",@"is not", @"does not contain"];
}

-(void)addIsIsNotItem
{
    [self addPopUpButtonWithSelectLabel:@"is" inLabels:@"is",@"is not"];
}

-(void)addIsBetweenItemWithSelectedLabel:(CPString)aLabel
{
    [self addPopUpButtonWithSelectLabel:aLabel inLabels:@"is",@"is between",@"is not", @"is not between"];
}

-(void)addTextFieldItemWithDelegate:(id)aDelegate
{
    var frame = CGRectMake([self newX],0, 150, 25); 
	if(CPRectGetMinX(frame) < 300)
		frame = CGRectMake([self newX],-5, 470-[self newX], 25); 
    var item = [[CPTextField alloc] initWithFrame:frame];
	//[item sizeToFit];
    [item setEditable:YES];
    //[item setBordered:YES];
    [item setBezeled:YES];
    [item setSelectable:YES];
	[item setDrawsBackground:YES];
    [item sizeToFit];
    ///[item setFrame:CGRectMake(CPRectGetMinX([item frame]), CPRectGetMinY([item frame]), CPRectGetHeight([item frame]), CPRectGetWidth(frame))];
    [_items addObject:item];
    [self addSubview:item];
    
    if(aDelegate)
    {
		_textFieldDelegate = aDelegate;
    	[item setDelegate:self];
    }
}

-(void)addTextFieldItemWithPlaceholder:(CPString)aPlaceholder
{
	var frame = CGRectMake([self newX],0, 150, 25); 
	if(CPRectGetMinX(frame) < 300)
		frame = CGRectMake([self newX],-5, 470-[self newX], 25); 
    var item = [[CPTextField alloc] initWithFrame:frame];
	//[item sizeToFit];
	[item setPlaceholderString:aPlaceholder];
    [item setEditable:YES];
    //[item setBordered:YES];
    [item setBezeled:YES];
    [item setSelectable:YES];
	[item setDrawsBackground:YES];
    [item sizeToFit];
    ///[item setFrame:CGRectMake(CPRectGetMinX([item frame]), CPRectGetMinY([item frame]), CPRectGetHeight([item frame]), CPRectGetWidth(frame))];
    [_items addObject:item];
    [self addSubview:item];
}

-(void)addLinkTextFieldItemWithDelegate:(id)aDelegate
{
    var frame = CGRectMake([self newX],0, 150, 25); 
	if(CPRectGetMinX(frame) < 300)
		frame = CGRectMake([self newX],-5, 470-[self newX], 25); 
    var item = [[DCLinkTextField alloc] initWithFrame:frame delegate:self];
	//[item setHTML:@"<a href='javascript:showMore()'><font size=1>List...</font></a>"];
    [item setEditable:YES];
    //[item setBordered:YES];
    [item setBezeled:YES];
    [item setSelectable:YES];
	[item setDrawsBackground:YES];
    [item sizeToFit];
    ///[item setFrame:CGRectMake(CPRectGetMinX([item frame]), CPRectGetMinY([item frame]), CPRectGetHeight([item frame]), CPRectGetWidth(frame))];
    [_items addObject:item];
    [self addSubview:item];
    
    if(aDelegate)
    {
		_textFieldDelegate = aDelegate;
    	[item setDelegate:self];
    }
}

-(void)addTextFieldsSeperatedByLabel:(CPString)aLabel
{
    var newX = [self newX]; 
    var textField1 = [[CPTextField alloc] initWithFrame:CGRectMake(newX, 0, 50, 25)];
    [textField1 setEditable:YES];
    [textField1 setBordered:YES];
    [textField1 setBezeled:YES];
    [textField1 setDrawsBackground:YES];
    [textField1 sizeToFit];
    [_items addObject:textField1];
    [self addSubview:textField1];
    
    var separatorLabel = [[CPTextField alloc] initWithFrame:CGRectMake(newX+50, 0, 50, 25)];
    [separatorLabel setObjectValue:aLabel];
    [separatorLabel setValue:CPCenterTextAlignment forThemeAttribute:@"alignment"];
    [_items addObject:separatorLabel]
    [self addSubview:separatorLabel];
    
    var textField2 = [[CPTextField alloc] initWithFrame:CGRectMake(newX+100, 0, 50, 25)];
    [textField2 setEditable:YES];
    [textField2 setBordered:YES];
    [textField2 setBezeled:YES];
    [textField2 setDrawsBackground:YES];
    [textField2 sizeToFit];
    [_items addObject:textField2];
    [self addSubview:textField2];
}

-(void)addTextFieldsSeperatedByLabel:(CPString)aLabel widthOfFirstTextField:(int)aWidth
{
    var newX = [self newX]; 
    var textField1 = [[CPTextField alloc] initWithFrame:CGRectMake(newX, 0, aWidth, 25)];
    [textField1 setEditable:YES];
    [textField1 setBordered:YES];
    [textField1 setBezeled:YES];
    [_items addObject:textField1];
    [self addSubview:textField1];
    
    var separatorLabel = [[CPTextField alloc] initWithFrame:CGRectMake(newX+aWidth, 0, 50, 25)];
    [separatorLabel setObjectValue:aLabel];
    [separatorLabel sizeToFit];
    [_items addObject:separatorLabel]
    [self addSubview:separatorLabel];
    
    var textField2 = [[CPTextField alloc] initWithFrame:CGRectMake(newX+aWidth+CPRectGetWidth([separatorLabel frame]), 0, 394 - newX+aWidth+CPRectGetWidth([separatorLabel frame]), 25)];
    [textField2 setEditable:YES];
    [textField2 setBordered:YES];
    [textField2 setBezeled:YES];
    [_items addObject:textField2];
    [self addSubview:textField2];
}

-(void)addLimitedPopUpButtonWithSelectLabel:(CPString)aSelectedString inLabels:(CPString)aString, ...
{
    var newX = [self newX]; 
    var item = [[CPPopUpButton alloc] initWithFrame:CGRectMake(newX, 0, 310, 25)];
    for (var i = 3; i < arguments.length; i++) {
        [item addItemWithTitle:arguments[i]];
		if([arguments[2] isEqualToString:arguments[i]])
            [item selectItemAtIndex:i-3];
	}
	if([_items count] == 1)
    {
        [item setTarget:self];
        [item setAction:@selector(switchedSecondPopUpItem:)];
    }
    [_items addObject:item];
    [self addSubview:item];
}

-(void)addAddButtonEnabled:(BOOL)addEnabled removeButtonEnabled:(BOOL)removeEnabled
{
    var newX = [self newX]; 	
    
	[subtractButton setFrame:CGRectMake(newX, 0, 25, 25)];
	if(!removeEnabled) 
	   [subtractButton setEnabled:NO]; 
    [self addSubview:subtractButton];
    [addButton setFrame:CGRectMake(newX+30, 0, 25, 25)];
    if(!addEnabled)
        [addButton setEnabled:NO];
	[self addSubview:addButton];
	addAddRemoveButtonsShown = YES;
}

-(void)enableAddRemovebuttons
{
    [subtractButton setEnabled:YES];
    [addButton setEnabled:YES]; 
}

-(void)disableAddRemovebuttons
{
    [subtractButton setEnabled:NO];
    [addButton setEnabled:NO]; 
}

-(void)enableAddButton:(BOOL)aEnable removeButton:(BOOL)rEnable
{
    [subtractButton setEnabled:rEnable];
    [addButton setEnabled:aEnable]; 
}

-(BOOL)addAddRemoveButtonsEnabled
{
    return ([addButton isEnabled] && [subtractButton isEnabled]);
}

-(void)addSearchItemAfterSearchItem:(id)sender
{
	if([_delegate respondsToSelector:@selector(addSearchItemAfterSearchItem:)])
		[_delegate addSearchItemAfterSearchItem:[[_items objectAtIndex:0] titleOfSelectedItem]];
}

-(void)removeSearchItem:(id)sender
{
	if([_delegate respondsToSelector:@selector(removeSearchItem:)])
		[_delegate removeSearchItem:self];
}

-(void)switchedFirstPopUpItem:(id)sender
{
    if([_delegate respondsToSelector:@selector(switchedFirstPopUpItem:toTitle:)])
		[_delegate switchedFirstPopUpItem:self toTitle:[[_items objectAtIndex:0] titleOfSelectedItem]];
}

-(void)switchedSecondPopUpItem:(id)sender
{
    if([_delegate respondsToSelector:@selector(switchedSecondPopUpItem:toTitle:)])
		[_delegate switchedSecondPopUpItem:self toTitle:[[_items objectAtIndex:1] titleOfSelectedItem]];
}

-(BOOL)isTitleOfFirstItem:(CPString)aTitle
{
	if([[[_items objectAtIndex:0] titleOfSelectedItem] isEqualToString:aTitle])
		return YES;
	return NO;
}


-(CPString)titleOfFirstItem
{
	return [[_items objectAtIndex:0] titleOfSelectedItem];
}

-(CPString)titleOfSecondItem
{
	return [[_items objectAtIndex:1] titleOfSelectedItem];
}

-(CPString)titleOfThirdItem
{
	CPLog(@"items count is " + [_items count]);
	if([_items count] == 7)
	{		
		if([[_items objectAtIndex:2] stringValue] == nil || [[_items objectAtIndex:4] stringValue] == nil)
			return nil;
		return [CPString stringWithFormat:@"%@-%@", [[_items objectAtIndex:2] stringValue], [[_items objectAtIndex:4] stringValue]];
	}
	return [[_items objectAtIndex:2] stringValue];
}

-(CGRect)frameOfThirdItem
{
	return [[_items objectAtIndex:2] frame];
}

-(void)setStringValueForThirdItem:(CPString)aString
{
	[[_items objectAtIndex:2] setStringValue:aString];
}

-(int)newX
{
    var newX = 0;
    if([[self subviews] lastObject])
        newX = CPRectGetMinX([[[self subviews] lastObject] frame]) + CPRectGetWidth([[[self subviews] lastObject] frame]) + 10;
        
    return newX;
}

-(CPString)identifier
{
	return identifier;
}

-(CPString)description
{
    return [[self subviews] description];
}

-(void)controlTextDidBeginEditing:(CPNotification)aNote
{
	if(_textFieldDelegate && [_textFieldDelegate respondsToSelector:@selector(controlTextDidBeginEditing:)])
		[_textFieldDelegate controlTextDidBeginEditing:self];
}

-(void)controlTextDidChange:(CPNotification)aNote
{
	CPLog(@"real typing..");
	CPLog(@"del is %@ and %@", _textFieldDelegate, _delegate);
	if(_delegate && [_textFieldDelegate respondsToSelector:@selector(controlTextDidChange:)])
		[_delegate controlTextDidChange:self];
	else
		CPLog(@"ha nope");
}

-(void)controlTextDidEndEditing:(CPNotification)aNote
{
	if(_textFieldDelegate && [_textFieldDelegate respondsToSelector:@selector(controlTextDidEndEditing:)])
		[_textFieldDelegate controlTextDidEndEditing:self];
}

-(void)buttonClicked:(id)sender
{	
	CPLog(@"suery bar link field clicked");
	if(_textFieldDelegate && [_textFieldDelegate respondsToSelector:@selector(buttonClickedWithTitle:onQueryBar:)])
		[_textFieldDelegate buttonClickedWithTitle:[self titleOfFirstItem] onQueryBar:self];
}

+ (_CPMenuWindow)popUpContextMenu:(CPMenu)aMenu atLocation:(CPPoint)aPoint forView:(CPView)aView ofWindowNumber:(int)windowNumber
{
    var delegate = [aMenu delegate];
    
    if ([delegate respondsToSelector:@selector(menuWillOpen:)])
        [delegate menuWillOpen:aMenu];
    
    var aFont = [CPFont systemFontOfSize:12.0];

    var theWindow = [aView window],
        menuWindow = [_CPMenuWindow menuWindowWithMenu:aMenu font:aFont];

    [menuWindow setDelegate:self];
    [menuWindow setBackgroundStyle:_CPMenuWindowPopUpBackgroundStyle];

	var newEvent = [CPEvent keyEventWithType:CPKeyDown
    								location:aPoint
    						   modifierFlags:nil
								   timestamp:0
								windowNumber:windowNumber
									 context:nil
								  characters:nil
				 charactersIgnoringModifiers:nil
								   isARepeat:NO
									 keyCode:nil];

    [menuWindow setFrameOrigin:[[newEvent window] convertBaseToBridge:aPoint]];

    [menuWindow orderFront:self];
    
    [menuWindow beginTrackingWithEvent:newEvent	sessionDelegate:self didEndSelector:@selector(_menuWindowDidFinishTracking:highlightedItem:)];
    
    CPLog(@"menu window is %@", menuWindow);
    
    return menuWindow;
}

+ (void)_menuWindowDidFinishTracking:(_CPMenuWindow)aMenuWindow highlightedItem:(CPMenuItem)aMenuItem
{
    var menu = [aMenuWindow menu];

    [_CPMenuWindow poolMenuWindow:aMenuWindow];

    var delegate = [menu delegate];

    if ([delegate respondsToSelector:@selector(menuDidClose:)])
        [delegate menuDidClose:menu];

    if([aMenuItem isEnabled])
        [CPApp sendAction:[aMenuItem action] to:[aMenuItem target] from:aMenuItem];
}

@end

