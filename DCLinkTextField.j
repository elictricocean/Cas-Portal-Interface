/*
 * DCLinkTextField.j
 *
 * Created by David Cann on __Date__.
 * Copyright 2008 __MyCompanyName__. All rights reserved.
 */
 
@import <Foundation/CPObject.j>
 
@implementation DCLinkTextField : CPTextField {
	CPColor _oldTextColor;
	CPString HTML @accessors;
	id HTMLElement @accessors;
	id _delegate;
}
 
- (id)initWithFrame:(CGRect)aFrame delegate:(id)aDelegate
{
	self = [super initWithFrame:aFrame];
	if (self) {
		CPLog(@"not here");
		_delegate = aDelegate;
		var contentView = [self layoutEphemeralSubviewNamed:@"content-view"
												 positioned:CPWindowOut
							relativeToEphemeralSubviewNamed:@"bezel-view"];
 
		HTMLElement = document.createElement("div");
		HTMLElement.style.width = "100%";
		HTMLElement.style.height = "100%";
		contentView._DOMElement.appendChild(HTMLElement);
		
		var button = [[CPButton alloc] initWithFrame:CGRectMakeZero()];
		//[button setFont:[CPFont systemFontOfSize:16.0]];
		//[button sizeToFit];
		[button setImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/addMore.png" size:CGSizeMake(18, 18)]];
		[button setAlternateImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/addMorePressed.png" size:CGSizeMake(18, 18)]];
		[button setAlignment:CPImageOnly];
		[button sizeToFit];
		CPLog(@"size is " + CPRectGetWidth([button frame]));
		[button setBordered:NO];
		[button setTextColor:[CPColor blueColor]];
		[button setFrameOrigin:CGPointMake(CPRectGetWidth(aFrame)-CPRectGetWidth([button frame])-12, 6)];
		[button setFrameSize:CGSizeMake(18.0, 18.0)];
		[button setTarget:self];
		[button setAction:@selector(buttonClicked:)];
		[self addSubview:button];
	}
	return self;
}
 
- (void)setHTML:(CPString)theHTML 
{
	HTMLElement.innerHTML = theHTML;
}
 
- (void)HTML 
{
	return HTMLElement.innerHTML;
}

-(void)buttonClicked:(id)sender
{
	CPLog(@"was clicked");
	if([_delegate respondsToSelector:@selector(buttonClicked:)])
	{
		[_delegate buttonClicked:self];
	}
	else
	{
		CPLog(@"nopw %@", [_delegate className]);
	}
}

@end