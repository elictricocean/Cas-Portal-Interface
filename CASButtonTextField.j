@implementation CASButtonTextField : CPTextField
{
	
}

-(id)initWithFrame:(CGRect)aFrame
{
	self = [super initWithFrame:aFrame]
	if(self)
	{
		var button = [CPButton buttonWithTitle:@"List..."];
		[button setFont:[CPFont systemFontOfSize:8.0]];
		//[button sizeToFit];
		[button setBordered:NO];
		[button setTextColor:[CPColor blueColor]];
		[button setFrameOrigin:CGPointMake(CPRectGetWidth(aFrame)-CPRectGetWidth([button frame]), CPRectGetHeight(aFrame)/5)];
		[button setTarget:self];
		[button setAction:@selector(buttonClicked:)];
		[self addSubview:button];
		
		var textField = _DOMElement.children[0];
		textField.border-right = 0px;
		
	}
}