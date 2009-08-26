@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>

@implementation CASButton : CPButton
{
	CPMenu _menu;
	CPTimer timer;
}

-(void)initWithFrame:(CGRect)aRect
{
	self = [super initWithFrame:aRect];
	if(self)
	{
		CPLog(@"not here");
		_menu = [[CPMenu alloc] initWithTitle:@"Operand menu"];
		//[_menu setTarget:self];
		var item1 = [[CPMenuItem alloc] initWithTitle:@"AND" action:@selector(clickedMenuItem:) keyEquivalent:nil];
		[item1 setTarget:self];
		[_menu addItem:item1];
		var item2 = [[CPMenuItem alloc] initWithTitle:@"OR" action:@selector(clickedMenuItem:) keyEquivalent:nil];
		[item2 setTarget:self];
		[_menu addItem:item2];
	}
	return self;
}

-(void)mouseDown:(CPEvent)anEvent
{
	[super mouseDown:anEvent];
	timer = [CPTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showMenu:) userInfo:anEvent repeats:NO];
}

-(void)showMenu:(CPTimer)aTimer
{
	if([self isHighlighted] && timer)
	{
		var mutableEvent = [aTimer userInfo];
		//[mutableEvent setLocationInWindow:CGPointMake(0.0, CPRectGetHeight([self frame])+1)]
		[CPMenu popUpContextMenu:_menu withEvent:[CPEvent keyEventWithType:[mutableEvent type] 
																  location:[self convertPoint:CGPointMake(0.0, 31 +CPRectGetHeight([self frame]) + CPRectGetHeight([self frame])) toView:[[[CPApplication sharedApplication] windowWithWindowNumber:[[mutableEvent window] windowNumber]] contentView]]
															 modifierFlags:[mutableEvent modifierFlags]
																 timestamp:[mutableEvent timestamp]
															  windowNumber:[[mutableEvent window] windowNumber]
																   context:nil
																characters:nil
											   charactersIgnoringModifiers:nil
																 isARepeat:NO
																   keyCode:nil] forView:self];
	}
}

- (void)mouseUp:(CPEvent)anEvent
{
	[super mouseUp:anEvent];
	[self setHighlighted:NO];
	[timer invalidate];
	timer = nil;
	CPLog(@"Up");
}

-(void)clickedMenuItem:(id)sender
{
	[self setHighlighted:NO];
	[self sendAction:[self action] to:[self target]];
}

@end