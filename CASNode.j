@import <Foundation/CPObject.j>

var SEARCH_URL = @"taxonBrowser.asp"

@implementation CASNode : CPObject
{
	CPArray children;
	CPString type;
	CPString name;
	id parent;
}

-(void)initWithName:(CPString)aName type:(CPString)aType parent:(id)aParent
{
	self = [super init];
	if(self)
	{
		name = aName;
		type = aType;
		parent = aParent;
	}
}

-(CPString)name
{
	return name;
}

-(CPString)type
{
	return type;
}

-(void)getChildren
{
	var request = [[CPURLRequest alloc] initWithURL:[CPURL URLWithString:SEARCH_URL + @"?contentType=" + type + @"&value=" + name]];
	searchConnection = [[CPURLConnection] initWithRequest:request delegate:self startImmediately:YES];
}

-(void)setChildren:(CPArray)anArray
{
	children = anArray;
}

-(void)connection:(CPURLConnection)conn didRecieveData:(CPString)jsonString
{
	var data = JSON.parse(jsonString);
	children = [[CPMutableArray alloc] init];
	for(var i=0; i<[data count]; i++)
	{
		var newNode = [[CASNode alloc] initWithName:[[data objectAtIndex:i] objectForKey:@"title"] type:[[data objectAtIndex:i] objectForKey:@"type"] parent:self];
		[children addObject:newNode];
	}
}

-(BOOL)childrenAreAvailable
{
	return children ? YES : NO;
}

-(BOOL)isExpandable
{
	if(![type isEqualToString:@"Species"])
		return YES;
	else
		return NO;
}

-(int)numberOfChildren
{
	return [self childrenAreAvailable] ? [children count] : 0;
}

-(id)childAtIndex:(int)anIndex
{
	return [self childrenAreAvailable] ? [children objectAtIndex:anIndex] : nil;
}