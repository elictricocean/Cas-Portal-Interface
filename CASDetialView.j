@import <AppKit/AppKit.j>

@implementation CASDetailView : CPView
{
	CPTextField title;
	CPTextField date;
	
	//Location
	CPTextField country;
	CPTextField state;
	CPTextField county;
	CPTextField islands;
	CPTextField locality;
	CPTextField statedLocality;
	CPTextField lat;
	CPTextField lon;
	CPTextField latLonError;
	CPTextField elevation;
	
	//Specimen
	CPTextField sex;
	CPTextField lifestage;
	CPTextField preservative;
	CPTextField habitat;
	CPTextField identifier;
	
	//Collector
	CPTextField collectors;
	CPTextField collectorFieldNumber;
	CPTextField coordSource;
	CPTextField georefBy;
	CPTextField georefRemarks;
	CPTextField fieldNotes;
	CPTextField remarks;
	
}

-(id)initWithFrame:(CGRect)aFrame
{
	self = [super initWithFrame:aFrame];
	if(self)
	{
		[self setBackgroundColor:[CPColor colorWithRed:212.0 / 255.0 green:221.0 / 255.0 blue:230.0 / 255.0 alpha:1.0]];
		
		title = [[CPTextField alloc] initWithFrame:CGRectMake(10.0, 10.0, CPRectGetWidth(aFrame)-50, 25.0)];
		[title setStringValue:@"Nothing Selected"];
		[self addSubview:title];
		
		var tabView = [[CPTabView alloc] initWithFrame:CGRectMake(0.0, CPRectGetMaxY([title frame]), CPRectGetWidth(aFrame), 250.0)];
		[tabView setBackgroundColor:[CPColor colorWithRed:212.0 / 255.0 green:221.0 / 255.0 blue:230.0 / 255.0 alpha:1.0]];
		
		var locationTabViewItem = [[CPTabViewItem alloc] initWithIdentifier:@"location"];
		[locationTabViewItem setLabel:@"Location"];
		
		var locationView = [[CPView alloc] initWithFrame:CGRectCreateCopy([tabView frame])];
		
		var countryLabel = [CPTextField labelWithTitle:@"Country:"];
		[countryLabel setFrameOrigin:CGPointMake(5.0, 5.0)];
		
		country = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([countryLabel frame]) + 5.0, CPRectGetMinY([countryLabel frame]), CPRectGetWidth([locationView frame]) - CPRectGetWidth([countryLabel frame]) - 5.0, CPRectGetHeight([locationView frame]))];
		[locationView addSubview:countryLabel];
		[locationView addSubview:country];
		
		var stateLabel = [CPTextField labelWithTitle:@"State:"];
		[stateLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([countryLabel frame]))];
		
		state = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([stateLabel frame]) + 5.0, CPRectGetMinY([stateLabel frame]), CPRectGetWidth([locationView frame]) - CPRectGetWidth([stateLabel frame]) - 5.0, CPRectGetHeight([stateLabel frame]))];
		[locationView addSubview:stateLabel];
		[locationView addSubview:state];
		
		var countyLabel = [CPTextField labelWithTitle:@"County:"];
		[countyLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([stateLabel frame]))];
		county = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([countyLabel frame]) + 5.0, CPRectGetMinY([countyLabel frame]), CPRectGetWidth([locationView frame]) - CPRectGetWidth([countyLabel frame]) - 5.0, CPRectGetHeight([countyLabel frame]))];
		[locationView addSubview:countyLabel];
		[locationView addSubview:county];
		
		var islandLabel = [CPTextField labelWithTitle:@"Island(s):"];
		[islandLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([countyLabel frame]))];
		islands = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([islandLabel frame]) + 5.0, CPRectGetMinY([islandLabel frame]), CPRectGetWidth([locationView frame]) - CPRectGetWidth([islandLabel frame]) - 5.0, CPRectGetHeight([islandLabel frame]))];
		[locationView addSubview:islandLabel];
		[locationView addSubview:islands];
		
		var localityLabel = [CPTextField labelWithTitle:@"Locality:"];
		[localityLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([islandLabel frame]))];
		locality = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([localityLabel frame]) + 5.0, CPRectGetMinY([localityLabel frame]), CPRectGetWidth([locationView frame]) - CPRectGetWidth([localityLabel frame]) - 5.0, CPRectGetHeight([localityLabel frame]))];
		[locationView addSubview:localityLabel];
		[locationView addSubview:locality];
		
		var statedLocalityLabel = [CPTextField labelWithTitle:@"Stated Locality:"];
		[statedLocalityLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([localityLabel frame]))];
		statedLocality = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([statedLocalityLabel frame]) + 5.0, CPRectGetMinY([statedLocalityLabel frame]), CPRectGetWidth([locationView frame]) - CPRectGetWidth([statedLocalityLabel frame]) - 5.0, CPRectGetHeight([statedLocalityLabel frame]))];
		[locationView addSubview:statedLocalityLabel];
		[locationView addSubview:statedLocality];
		
		var latLabel = [CPTextField labelWithTitle:@"Latitude:"];
		[latLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([statedLocalityLabel frame]))];
		lat = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([latLabel frame]) + 5.0, CPRectGetMinY([latLabel frame]), CPRectGetWidth([locationView frame]) - CPRectGetWidth([latLabel frame]) - 5.0, CPRectGetHeight([latLabel frame]))];
		[locationView addSubview:latLabel];
		[locationView addSubview:lat];
		
		var lonLabel = [CPTextField labelWithTitle:@"Longitude:"];
		[lonLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([latLabel frame]))];
		lon = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([lonLabel frame]) + 5.0, CPRectGetMinY([lonLabel frame]), CPRectGetWidth([locationView frame]) - CPRectGetWidth([lonLabel frame]) - 5.0, CPRectGetHeight([lonLabel frame]))];
		[locationView addSubview:lonLabel];
		[locationView addSubview:lon];
		
		var latLonErrorLabel = [CPTextField labelWithTitle:@"Max. Lat/Long Error:"];
		[latLonErrorLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([lonLabel frame]))];
		latLonError = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([latLonErrorLabel frame]) + 5.0, CPRectGetMinY([latLonErrorLabel frame]), CPRectGetWidth([locationView frame]) - CPRectGetWidth([latLonErrorLabel frame]) - 5.0, CPRectGetHeight([latLonErrorLabel frame]))];
		[locationView addSubview:latLonErrorLabel];
		[locationView addSubview:latLonError];
		
		var elevationLabel = [CPTextField labelWithTitle:@"Max. Lat/Long Error:"];
		[elevationLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([lonLabel frame]))];
		elevation = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([elevationLabel frame]) + 5.0, CPRectGetMinY([elevationLabel frame]), CPRectGetWidth([locationView frame]) - CPRectGetWidth([elevationLabel frame]) - 5.0, CPRectGetHeight([elevationLabel frame]))];
		[locationView addSubview:elevationLabel];
		[locationView addSubview:elevation];
		
		[locationTabViewItem setView:locationView];
		[tabView addTabViewItem:locationTabViewItem];
		
		var specimenTabViewItem = [[CPTabViewItem alloc] initWithIdentifier:@"specimen"];
		[specimenTabViewItem setLabel:@"Specimen"];
		
		var specimenView = [[CPView alloc] initWithFrame:CGRectCreateCopy([tabView frame])];
		
		var sexLabel = [CPTextField labelWithTitle:@"Sex:"];
		[sexLabel setFrameOrigin:CGPointMake(5.0, 5.0)];
		
		sex = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([sexLabel frame]) + 5.0, CPRectGetMinY([sexLabel frame]), CPRectGetWidth([specimenView frame]) - CPRectGetWidth([sexLabel frame]) - 5.0, CPRectGetHeight([sexLabel frame]))];
		[specimenView addSubview:sexLabel];
		[specimenView addSubview:sex];
		
		var lifestageLabel = [CPTextField labelWithTitle:@"Lifestage:"];
		[lifestageLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([sexLabel frame]))];
		
		lifestage = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([lifestageLabel frame]) + 5.0, CPRectGetMinY([lifestageLabel frame]), CPRectGetWidth([specimenView frame]) - CPRectGetWidth([lifestageLabel frame]) - 5.0, CPRectGetHeight([lifestageLabel frame]))];
		[specimenView addSubview:lifestageLabel];
		[specimenView addSubview:lifestage];
		
		var preservativeLabel = [CPTextField labelWithTitle:@"Preservative:"];
		[preservativeLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([lifestageLabel frame]))];
		
		preservative = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([lifestageLabel frame]) + 5.0, CPRectGetMinY([preservativeLabel frame]), CPRectGetWidth([specimenView frame]) - CPRectGetWidth([preservativeLabel frame]) - 5.0, CPRectGetHeight([preservativeLabel frame]))];
		[specimenView addSubview:preservativeLabel];
		[specimenView addSubview:preservative];
		
		var habitatLabel = [CPTextField labelWithTitle:@"Habitat:"];
		[habitatLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([preservativeLabel frame]))];
		
		habitat = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([habitatLabel frame]) + 5.0, CPRectGetMinY([habitatLabel frame]), CPRectGetWidth([specimenView frame]) - CPRectGetWidth([habitatLabel frame]) - 5.0, CPRectGetHeight([habitatLabel frame]))];
		[specimenView addSubview:habitatLabel];
		[specimenView addSubview:habitat];
		
		var identifierLabel = [CPTextField labelWithTitle:@"Identifier:"];
		[identifierLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([habitatLabel frame]))];
		
		identifier = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([identifierLabel frame]) + 5.0, CPRectGetMinY([identifierLabel frame]), CPRectGetWidth([specimenView frame]) - CPRectGetWidth([identifierLabel frame]) - 5.0, CPRectGetHeight([identifierLabel frame]))];
		[specimenView addSubview:identifierLabel];
		[specimenView addSubview:identifier];
		
		[specimenTabViewItem setView:specimenView];
		[tabView addTabViewItem:specimenTabViewItem];
		
		var collectorTabViewItem = [[CPTabViewItem alloc] initWithIdentifier:@"Collector"];
		[collectorTabViewItem setLabel:@"Collector"];
		
		var collectorView = [[CPView alloc] initWithFrame:CGRectCreateCopy([tabView frame])];
		
		var collectorLabel = [CPTextField labelWithTitle:@"Collector(s):"];
		[collectorLabel setFrameOrigin:CGPointMake(5.0, 5.0)];
		
		collectors = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([collectorLabel frame]) + 5.0, CPRectGetMinY([collectorLabel frame]), CPRectGetWidth([collectorView frame]) - CPRectGetWidth([collectorLabel frame]) - 5.0, CPRectGetHeight([collectorLabel frame]))];
		[collectorView addSubview:collectorLabel];
		[collectorView addSubview:collectors];
		
		var fieldNumLabel = [CPTextField labelWithTitle:@"Field #:"];
		[fieldNumLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([collectorLabel frame]))];
		
		collectorFieldNumber = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([fieldNumLabel frame]) + 5.0, CPRectGetMinY([fieldNumLabel frame]), CPRectGetWidth([collectorView frame]) - CPRectGetWidth([fieldNumLabel frame]) - 5.0, CPRectGetHeight([fieldNumLabel frame]))];
		[collectorView addSubview:fieldNumLabel];
		[collectorView addSubview:collectorFieldNumber];
		
		var coordSourceLabel = [CPTextField labelWithTitle:@"Coord. Source:"];
		[coordSourceLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([fieldNumLabel frame]))];
		
		coordSource = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([coordSourceLabel frame]) + 5.0, CPRectGetMinY([coordSourceLabel frame]), CPRectGetWidth([collectorView frame]) - CPRectGetWidth([coordSourceLabel frame]) - 5.0, CPRectGetHeight([coordSourceLabel frame]))];
		[collectorView addSubview:coordSourceLabel];
		[collectorView addSubview:coordSource];
		
		var georefByLabel = [CPTextField labelWithTitle:@"Georef. By:"];
		[georefByLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([coordSourceLabel frame]))];
		
		georefBy = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([georefByLabel frame]) + 5.0, CPRectGetMinY([georefByLabel frame]), CPRectGetWidth([collectorView frame]) - CPRectGetWidth([georefByLabel frame]) - 5.0, CPRectGetHeight([georefByLabel frame]))];
		[collectorView addSubview:georefByLabel];
		[collectorView addSubview:georefBy];
		
		var georefRemarksLabel = [CPTextField labelWithTitle:@"Georef. Remarks:"];
		[georefRemarksLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([georefByLabel frame]))];
		
		georefRemarks = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([georefRemarksLabel frame]) + 5.0, CPRectGetMinY([georefRemarksLabel frame]), CPRectGetWidth([collectorView frame]) - CPRectGetWidth([georefRemarksLabel frame]) - 5.0, CPRectGetHeight([georefRemarksLabel frame]))];
		[collectorView addSubview:georefRemarksLabel];
		[collectorView addSubview:georefRemarks];
		
		var fieldNotesLabel = [CPTextField labelWithTitle:@"Field Notes:"];
		[fieldNotesLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([georefRemarksLabel frame]))];
		
		fieldNotes = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([fieldNotesLabel frame]) + 5.0, CPRectGetMinY([fieldNotesLabel frame]), CPRectGetWidth([collectorView frame]) - CPRectGetWidth([fieldNotesLabel frame]) - 5.0, CPRectGetHeight([fieldNotesLabel frame]))];
		[collectorView addSubview:fieldNotesLabel];
		[collectorView addSubview:fieldNotes];
		
		var remarksLabel = [CPTextField labelWithTitle:@"Remarks:"];
		[remarksLabel setFrameOrigin:CGPointMake(5.0, CPRectGetMaxY([fieldNotesLabel frame]))];
		
		remarks = [[CPTextField alloc] initWithFrame:CGRectMake(CPRectGetMaxX([remarksLabel frame]) + 5.0, CPRectGetMinY([remarksLabel frame]), CPRectGetWidth([collectorView frame]) - CPRectGetWidth([remarksLabel frame]) - 5.0, CPRectGetHeight([remarksLabel frame]))];
		[collectorView addSubview:fieldNotesLabel];
		[collectorView addSubview:remarks];
		
		[collectorTabViewItem setView:collectorView];
		[tabView addTabViewItem:collectorTabViewItem];
		
		[self addSubview:tabView];
		
		var border = [[CPView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, CPRectGetHeight(aFrame))];
		[border setBackgroundColor:[CPColor blackColor]];
		[self addSubview:border];		
	}
	return self;
}

-(void)setData:(CPArray)data
{
	[title setStringValue:data["Genus"]+" "+data["Sp"]+" "+data["Ssp"]];
	[date setStringValue:data["date"]];
	
	//Location
	[country setStringValue:data["Country"]];
	[state setStringValue:data["State"]];
	[county setStringValue:data["County"]];
	[islands setStringValue:data["Island"]];
	[locality setStringValue:data["Locality"]];
	[statedLocality setStringValue:data["statedLocality"]];
	[lat setStringValue:data["lat"]];
	[lon setStringValue:data["lon"]];
	[latLonError setStringValue:data["latLonError"]];
	[elevation setStringValue:data["elevation"]];
}

@end