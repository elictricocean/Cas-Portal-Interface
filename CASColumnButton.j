@implementation CASColumnButton : CPTableHeaderView//CPView
{
	int state;
	id target;
	SEL selector;
	CPTextField textField;
	CPView contentView;
	CPImageView arrowView;
	CPImage upArrow;
	CPImage downArrow;
}

-(id)initWithFrame:(CGRect)aFrame
{
	self = [super initWithFrame:aFrame];
	if(self)
	{
		[self setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/tableHeader.png" size:CGSizeMake(2.0, 19.0)]]];
		textField = [[CPTextField alloc] initWithFrame:CGRectMake(5.0, 1.0, CPRectGetWidth(aFrame)-7, 19.0)];
		[self addSubview:textField];
		state = 0;
		contentView = [self layoutEphemeralSubviewNamed:@"content-view"
												 positioned:CPWindowOut
							relativeToEphemeralSubviewNamed:@"bezel-view"];
		arrowView = [[CPImageView alloc] initWithFrame:CGRectMake(CPRectGetWidth(aFrame)-15.0, CPRectGetHeight(aFrame)/2.0-5.5, 12.0, 11.0)];
		[arrowView setAutoresizingMask:CPViewMinXMargin];
		upArrow = [[CPImage alloc] initWithContentsOfFile:@"Resources/CASColumnArrowUp.png" size:CGSizeMake(12.0, 11.0)];
		downArrow = [[CPImage alloc] initWithContentsOfFile:@"Resources/CASColumnArrowDown.png" size:CGSizeMake(12.0, 11.0)];
	}
	return self;
}

-(void)setTarget:(id)aTarget
{
	target = aTarget;
}

-(void)setAction:(SEL)aSelector
{
	selector = aSelector;
}

-(void)setStringValue:(CPString)aString
{
	[textField setStringValue:aString];
}

-(void)mouseDown:(CPEvent)anEvent
{
	[CPApp sendAction:selector to:target from:self];
}

-(int)state
{
	return state;
}

-(void)setState:(int)aState
{
	CPLog(@"set state %d", aState);
	switch(aState)
	{
		case 0:
			[self setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/tableHeader.png" size:CGSizeMake(2.0, 19.0)]]];
			[arrowView removeFromSuperview];
			break;
		case 1:
			[self setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/tableHeaderSelected.png" size:CGSizeMake(2.0, 19.0)]]];
			[arrowView setImage:upArrow];
			[self addSubview:arrowView];
			break;
		case 2:
			[self setBackgroundColor:[CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/tableHeaderSelected.png" size:CGSizeMake(2.0, 19.0)]]];
			[arrowView setImage:downArrow];
			[self addSubview:arrowView];
			break;
	}
	[self setNeedsDisplay:YES];
}

-(void)setNextState
{
	if(state < 2)
		state++;
	else
		state = 1;
	[self setState:state];
}

-(void)resizeArrow
{
	[arrowView setFrameOrigin:CPPointMake(CPRectGetWidth([self frame])-15.0, CPRectGetHeight([self frame])/2.0-5.5)];
}

@end
