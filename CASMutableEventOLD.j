@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>

@implementation CASMutableEvent : CPEvent
{
	CGPoint _point;
}

-(void)setLocationInWindow:(CGPoint)aPoint
{
	_location = CPPointCreateCopy(aPoint);	
}