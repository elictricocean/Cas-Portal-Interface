@import <AppKit/CPView.j>
@import "MKMapScene.j"
@import "MKMarker.j"

var _mapView;
var _gMap;
var searchedOverlays;
var addingPlace;

@implementation MKMapView : CPView
{
    CPString        _apiKey;
    DOMElement      _DOMMapElement;
    //JSObject        _gMap;               //@accessors(property=gMap);
    MKMapScene      _scene;              //@accessors(property=scene);
    BOOL            _mapReady;
    BOOL            _googleAjaxLoaded;
	BOOL			_willAddPoint;
	BOOL			_willAddRect;
	var 			rect;
	var 			startPt;
	var 			newPt;
	JSObject 		moveRect;
	CPMutableArray 	searchItems;
	id				delegate;
	var 			navLabel;
	CPJSONPConnection mapConn;
	var 			geocoder;
	var 			GEvent;
    var    			GMap2;
    var   			GLatLng;
    var    			GPoint;
}

- (id)initWithFrame:(CGRect)aFrame apiKey:(CPString)apiKey
{
    _apiKey = apiKey;
    if (self = [super initWithFrame:aFrame]) {
        _scene = [[MKMapScene alloc] initWithMapView:self];
        
        searchItems = [[CPMutableArray alloc] init];

        var bounds = [self bounds];
        _DOMMapElement = document.createElement('div');
        with (_DOMMapElement.style) {
            position = "absolute";
            left = "0px";
            top = "0px";
            width = "100%";
            height = "100%";
        }
        _DOMElement.appendChild(_DOMMapElement);

        // Piggy back on the CPJSONPConnection stuff to load in the Google AJAX loader.
        var url = 'http://www.google.com/jsapi?key=' + _apiKey;
        var request = [CPURLRequest requestWithURL:url];
        mapConn = [CPJSONPConnection sendRequest:request callback:"callback" delegate:self];
		_mapView = self;
		searchedOverlays = [[CPArray alloc] init];
		addinfPlace = NO;
    }
	return self;
}

- (void)setDelegate:(id)aDelegate
{
	delegate = aDelegate;
}

- (void)connection:(CPJSONPConnection)aConnection didReceiveData:(Object)data
{
    if(aConnection == mapConn)
	{
		_googleAjaxLoaded = YES;
	    //console.log("Google AJAX API has loaded");
	    // Google API has loaded, now load Google Maps API. The main reason for
	    // using this is to avoid polluting the global namespace with G* objects
	    function callback() {
	        if (_superview) {
	            [self createMap];
	        }
	    };
	    // Load Google Maps API v2.160
	    google.load('maps', '2.160', {callback: callback});
	}
}

- (void)createMap
{
    GEvent  = google.maps.Event;
    GMap2   = google.maps.Map2;
    GLatLng = google.maps.LatLng;
    GPoint  = google.maps.Point;

    //console.log("Creating map");
    _gMap = new GMap2(_DOMMapElement);
    //_gMap.addMapType(G_SATELLITE_3D_MAP);
    _gMap.setMapType(G_HYBRID_MAP);
	_gMap.removeMapType(G_PHYSICAL_MAP);
	_gMap.removeMapType(G_SATELLITE_MAP);
    _gMap.setUIToDefault();
    _gMap.setCenter(new GLatLng(11.86735091145932, -11.25), 1);//new GLatLng(52, -1), 8);
    _gMap.enableContinuousZoom();
	geocoder = new GClientGeocoder();
	//_gMap.addControl(new GSmallMapControl());
	//_gMap.addControl(new GMapTypeControl());
	//_gMap.setCenter(new GLatLng(37.4419, -122.1419), 13);


	//_gMap.addControl(new GLargeMapControl());
	//_gMap.addControl(new GMapTypeControl());
	//_gMap.addControl(new google.maps.LocalSearch(), new GControlPosition(G_ANCHOR_BOTTOM_RIGHT, new GSize(10,20)));
	//navLabel = new GNavLabelControl();
	//_gMap.addControl(navLabel);

    // Horrible hack to fix dragging of th emap
    function startDrag(ev)
    {
		if(_willAddPoint)
		{
			_willAddPoint = NO;
			CPLog(@"add point now");
			var mapPos = getElementPosition(_gMap.getContainer());
			//var marker = [[MKMarker alloc] initAtLocation:_gMap.fromContainerPixelToLatLng(new GPoint(ev.clientX-mapPos.left, ev.clientY-mapPos.top))];
			//CPLog(marker._gMarker);
			//[self addMarkerAtLocation:_gMap.fromContainerPixelToLatLng(new GPoint(ev.clientX-mapPos.left, ev.clientY-mapPos.top))];
			//[marker addToMapView:self];
			//http://esa.ilmari.googlepages.com/circle.htm
			var markerOptions = {draggable:true};
			var marker = new GMarker(_gMap.fromContainerPixelToLatLng(new GPoint(ev.clientX-mapPos.left, ev.clientY-mapPos.top)), markerOptions);
			GEvent.addListener(marker, 'dragend', function() { [self updateMarker:marker]; });
			_gMap.addOverlay(marker);
            var point = marker.getLatLng();
            var center = point;
            var radius = 5;

      		//convert kilometers to miles-diameter
        	var radius = radius*1.609344;
        	var latOffset = 0.01;
        	var lonOffset = 0.01;
        	var latConv = center.distanceFrom(new GLatLng(center.lat()+0.1, center.lng()))/100;
        	var lngConv = center.distanceFrom(new GLatLng(center.lat(), center.lng()+0.1))/100;

        	// nodes = number of points to create circle polygon
        	var nodes = 40;
        	//Loop
        	var points = [];
        	var step = parseInt(360/nodes)||10;
        	for(var i=0; i<=360; i+=step)
        	{
            	var pint = new GLatLng(center.lat() + (radius/latConv * Math.cos(i* Math.PI/180)), center.lng() + (radius/lngConv * Math.sin(i *Math.PI/180)));
                // push pints into points array
                points.push(pint);
        	}

    		var polygon = new GPolygon(points, "#f33f00", 1, 1, "#ff0000", 0.1);
    		_gMap.addOverlay(polygon); 
    		var pointSearchDict = [CPDictionary dictionaryWithObjectsAndKeys:@"{" + [[CPNumber numberWithFloat:ev.clientX-mapPos.left] stringValue] + @", " + [[CPNumber numberWithFloat:ev.clientY-mapPos.top] stringValue] + @", " + parseInt(radius) + @"}", @"title", @"Point/Radius", @"type", [CPNumber numberWithFloat:ev.clientX-mapPos.left], @"startLat", [CPNumber numberWithFloat:ev.clientY-mapPos.top], @"startLon", marker, @"overlay", polygon, @"overlay2", @"Resources/marker.png", @"image"];
			[searchItems addObject:pointSearchDict];
			if([delegate respondsToSelector:@selector(addedSearchItem:)])
    			[delegate addedSearchItem:pointSearchDict];
    		else
    			NSLog(@"huh");
			_gMap.getDragObject().setDraggableCursor("hand");
			endDrag(ev);
			return;
		}
		else if(_willAddRect)
		{
			CPLog(@"add rect");
			var mapPos = getElementPosition(_gMap.getContainer());
			
			startPt = _gMap.fromContainerPixelToLatLng(new GPoint(ev.clientX-mapPos.left, ev.clientY-mapPos.top));
			//var rectBounds = new GLatLngBounds(startPoint, new GLatLng(startPoint.lat+5.0, startPoint.lng+5.0));
			var bounds = _gMap.getBounds();
			var southWest = bounds.getSouthWest();
			var northEast = bounds.getNorthEast();
			var lngDelta = (northEast.lng() - southWest.lng()) / 4;
			var latDelta = (northEast.lat() - southWest.lat()) / 4;
			var rectBounds = new GLatLngBounds(
    			startPt,//new GLatLng(southWest.lat() + latDelta, southWest.lng() + lngDelta),
    			startPt);//new GLatLng(northEast.lat() - latDelta, northEast.lng() - lngDelta));

			rect = new Rectangle(rectBounds, 2, "#ff0000");
			_gMap.addOverlay(rect);
			/*r1=new GLatLng(ev.clientX + 
      (document.documentElement.scrollLeft ? document.documentElement.scrollLeft : document.body.scrollLeft), ev.clientY + 
      (document.documentElement.scrolltop ? document.documentElement.scrollTop : document.body.scrollTop));
        	rect=null;
        	dragRectangle=true;*/
        	 _gMap._dragging = true;
			_gMap._draggingHandlers = [
            GEvent.addDomListener(document.body, 'mousemove', doDrag),
            GEvent.addDomListener(document.body, 'mouseup', endDrag)
        ];
			return;
		}
		
        if (_gMap._dragging) {
            return;
        }
        _gMap._dragging = true;
        _gMap._draggingHandlers = [
            GEvent.addDomListener(document.body, 'mousemove', doDrag),
            GEvent.addDomListener(document.body, 'mouseup', endDrag)
        ];
        _gMap._dragStartLocation = new GPoint(ev.clientX, ev.clientY);
        _gMap._dragStartCenter   = _gMap.fromLatLngToDivPixel(_gMap.getCenter());
    }
    function doDrag(ev)
    {
    	if(_willAddRect)
    	{
    		if (!_gMap._dragging) 
    		{
            	endDrag(ev);
            	return;
        	}
    		var mapPos = getElementPosition(_gMap.getContainer());
    		newPt = _gMap.fromContainerPixelToLatLng(new GPoint(ev.clientX-mapPos.left, ev.clientY-mapPos.top));
    		var oldPt = startPt;
    		/*if(newPt.lat() < startPt.lat() && newPt.lng() < startPt.lng())
    		{
    			startPt = newPt;
    			newPt = oldPt;
    		}*/
    		//else if(newPt.lat() < startPt.lat())
    		//{
    		//	startPt = new GLatLng(startPt.lat() - newPt.lat(), startPt.lng());
    		//}
    		//var divPt = _gMap.fromLatLngToDivPixel(newPt);
    		moveRect = _gMap.getPane(G_MAP_MAP_PANE).lastChild;
    		CPLog(@"newPt.lat is " + newPt.lat());
    		CPLog(parseInt(moveRect.style.width));
    		//var newWidth = divPixel.x;//(ev.clientX-mapPos.left);// + mapPos.left;
    		//var newHeight = divPixel.y;//(ev.clientY-mapPos.top);// + mapPos.top;//parseInt(moveRect.style.top) + 
     		//moveRect.style.width = newWidth + "px";
    		//moveRect.style.height = newHeight + "px";
    		CPLog(@"width = " + moveRect.style.width + @" height = " + moveRect.style.height);
    		//CPLog(_gMap.getPane(G_MAP_MAP_PANE).firtChild);
    		//if(_gMap.getPane(G_MAP_MAP_PANE).lastChild == rect) CPLog(@"yes");
    		//_gMap.getPane(G_MAP_MAP_PANE).lastChild.getBounds().extend(newPt);
    		var c1 = _gMap.fromLatLngToDivPixel(new GLatLngBounds(startPt, newPt).getSouthWest());
      		var c2 = _gMap.fromLatLngToDivPixel(new GLatLngBounds(startPt, newPt).getNorthEast());

      		// Now position our DIV based on the DIV coordinates of our bounds
      		moveRect.style.width = Math.abs(c2.x - c1.x) + "px";
      		moveRect.style.height = Math.abs(c2.y - c1.y) + "px";
      		moveRect.style.left = (Math.min(c2.x, c1.x) - 2) + "px";
      		moveRect.style.top = (Math.min(c2.y, c1.y) - 2) + "px";
        	return;
    	}       
        
	
        if (!_gMap._dragging) {
            endDrag(ev);
            return;
        }

        var currentLocation = new GPoint(ev.clientX, ev.clientY);
        var x_diff = currentLocation.x - _gMap._dragStartLocation.x;
        var y_diff = currentLocation.y - _gMap._dragStartLocation.y;
        var x = _gMap._dragStartCenter.x - x_diff;
        var y = _gMap._dragStartCenter.y - y_diff;
        
        var newCenter = new GPoint(x, y);
        var destination = _gMap.fromDivPixelToLatLng(newCenter);
		
        _gMap.setCenter(destination);
        _gMap._dragStartLocation = currentLocation;
        _gMap._dragStartCenter   = _gMap.fromLatLngToDivPixel(_gMap.getCenter());
    }
    function endDrag(ev)
    {
    	if(_willAddRect)
    	{
    		_willAddRect = NO;
    		dragRectangle=false;
    		var newBounds = new GLatLngBounds(startPt, newPt);
    		var newRect = new Rectangle(newBounds, 2, "#ff0000");
    		_gMap.addOverlay(newRect);
    		_gMap.removeOverlay(rect);
    		var startLat = startPt.lat();
    		var startLon = startPt.lng();
    		var searchDict = [CPDictionary dictionaryWithObjectsAndKeys:@"{" + [[CPNumber numberWithFloat:startLat] stringValue] + @", " + [[CPNumber numberWithFloat:startLon] stringValue] + @", " + [[CPNumber numberWithFloat:newPt.lat()] stringValue] + @", " + [[CPNumber numberWithFloat:newPt.lng()] stringValue] + @"}", @"title", @"Bounding Box", @"type", [CPNumber numberWithFloat:startLat], @"startLat", [CPNumber numberWithFloat:startLon], @"startLon", [CPNumber numberWithFloat:newPt.lat()], @"endLat", [CPNumber numberWithFloat:newPt.lng()], @"endLon", newRect, @"overlay", @"Resources/boundingBox.png", @"image"];
    		[searchItems addObject:searchDict];
    		if([delegate respondsToSelector:@selector(addedSearchItem:)])
    			[delegate addedSearchItem:searchDict];
    		else
    			CPLog(@"whaa");
			_gMap.getDragObject().setDraggableCursor("hand");
    	}
        if (_gMap._draggingHandlers) {
            for (var i=0; i<_gMap._draggingHandlers.length; i++) {
                GEvent.removeListener(_gMap._draggingHandlers[i]);
            }
            delete _gMap._draggingHandlers;
        }
        if (_gMap._dragging) {
            delete _gMap._dragging;
        }
    }
    
    function Rectangle(bounds, opt_weight, opt_color) {
      this.bounds_ = bounds;
      this.weight_ = opt_weight || 2;
      this.color_ = opt_color || "#888888";
    }
    Rectangle.prototype = new GOverlay();

    // Creates the DIV representing this rectangle.
    Rectangle.prototype.initialize = function(_gMap) {
      // Create the DIV representing our rectangle
      //CPLog(map);
      CPLog(@"called");
      var div = document.createElement("div");
      div.style.border = this.weight_ + "px solid " + this.color_;
      div.style.position = "absolute";
	  CPLog(this.weight_ + "px solid " + this.color_);
      // Our rectangle is flat against the map, so we add our selves to the
      // MAP_PANE pane, which is at the same z-index as the map itself (i.e.,
      // below the marker shadows)
      _gMap.getPane(G_MAP_MAP_PANE).appendChild(div);

      this.div_ = div;
      //this.id = "overlay";
    }

    // Remove the main DIV from the map pane
    Rectangle.prototype.remove = function() {
      this.div_.parentNode.removeChild(this.div_);
    }

    // Copy our data to a new Rectangle
    Rectangle.prototype.copy = function() {
      return new Rectangle(this.bounds_, this.weight_, this.color_,
                           this.backgroundColor_, this.opacity_);
    }
    
    // Redraw the rectangle based on the current projection and zoom level
    Rectangle.prototype.redraw = function(force) {
      // We only need to redraw if the coordinate system has changed
      if (!force) return;

      // Calculate the DIV coordinates of two opposite corners of our bounds to
      // get the size and position of our rectangle
      var c1 = _gMap.fromLatLngToDivPixel(this.bounds_.getSouthWest());
      var c2 = _gMap.fromLatLngToDivPixel(this.bounds_.getNorthEast());

      // Now position our DIV based on the DIV coordinates of our bounds
      this.div_.style.width = Math.abs(c2.x - c1.x) + "px";
      this.div_.style.height = Math.abs(c2.y - c1.y) + "px";
      this.div_.style.left = (Math.min(c2.x, c1.x) - this.weight_) + "px";
      this.div_.style.top = (Math.min(c2.y, c1.y) - this.weight_) + "px";
    }
    
    var getElementPosition = function (h) {
    var posX = h.offsetLeft;
    var posY = h.offsetTop;
    var parent = h.offsetParent;
    // Add offsets for all ancestors in the hierarchy
    while (parent !== null) {
      // Adjust for scrolling elements which may affect the map position.
      //
      // See http://www.howtocreate.co.uk/tutorials/javascript/browserspecific
      //
      // "...make sure that every element [on a Web page] with an overflow
      // of anything other than visible also has a position style set to
      // something other than the default static..."
      if (parent !== document.body && parent !== document.documentElement) {
        posX -= parent.scrollLeft;
        posY -= parent.scrollTop;
      }
      posX += parent.offsetLeft;
      posY += parent.offsetTop;
      parent = parent.offsetParent;
    }
    return {
      left: posX,
      top: posY
    };
  };
  
  var getMousePosition = function (e) {
    var posX = 0, posY = 0;
    e = e || window.event;
    if (typeof e.pageX !== "undefined") {
      posX = e.pageX;
      posY = e.pageY;
    } else if (typeof e.clientX !== "undefined") {
      posX = e.clientX +
      (typeof document.documentElement.scrollLeft !== "undefined" ? document.documentElement.scrollLeft : document.body.scrollLeft);
      posY = e.clientY +
      (typeof document.documentElement.scrollTop !== "undefined" ? document.documentElement.scrollTop : document.body.scrollTop);
    }
    return {
      left: posX,
      top: posY
    };
  };



    var dragNode = _DOMMapElement.firstChild.firstChild;
    GEvent.addDomListener(dragNode, 'mousedown', startDrag);

    // Hack to get mouse up event to work
    GEvent.addDomListener(document.body, 'mouseup', function() { GEvent.trigger(window, 'mouseup'); });

    _mapReady = YES;
}

- (void)setFrameSize:(CGSize)aSize
{
    [super setFrameSize:aSize];
    var bounds = [self bounds];
    if (_gMap) {
        _gMap.checkResize();
    }
}

- (void)viewDidMoveToSuperview
{
    if (!_mapReady && _googleAjaxLoaded) {
        [self createMap];
    }
    [super viewDidMoveToSuperview];
}

- (MKMarker)addMarker:(MKMarker)marker atLocation:(GLatLng)location
{
    if (_mapReady) {
        var gMarker = [marker gMarker];
        gMarker.setLatLng(location);
        _gMap.addOverlay(gMarker);
    } else {
        // TODO some sort of queue?
    }
    return marker;
}

- (void)addMarkerAtLocation:(GLatLng)location
{
    if (_mapReady) {
    	var marker = [[MKMarker alloc] initAtLocation:location];
        var gMarker = [marker gMarker];
        //gMarker.setLatLng(location);
        _gMap.addOverlay(gMarker);
    } else {
        // TODO some sort of queue?
    }
}

- (void)addMapItem:(MKMapItem)mapItem
{
    [mapItem addToMapView:self];
}

-(void)setWillAddPoint:(BOOL)willAddPoint
{
	CPLog(@"add point soon");
	_willAddPoint = willAddPoint;
	_gMap.getDragObject().setDraggableCursor("crosshair");
}

-(void)setWillAddRect:(BOOL)willAddRect
{
	_willAddRect = willAddRect;
	_gMap.getDragObject().setDraggableCursor("crosshair");
}

-(void)addCurrentLocation
{
	//http://mapsapi.googlepages.com/reversegeo.htm
	//reverse geocode with navLabel
	
	function showAddress(response) {
	  if (!response || response.Status.code != 200) {
	    alert("Status Code:" + response.Status.code);
	  } else {
	    var placemark = response.Placemark[0];
	    console.log(placemark);
		
		var p = placemark.Point.coordinates;
		var point = new GLatLng(p[1],p[0]);
		var marker = new GMarker(point);
		_gMap.setCenter(point,14); 
		_gMap.addOverlay(marker);
		[searchedOverlays addObject:[CPDictionary dictionaryWithObjects:[marker, placemark] forKeys:[@"marker", @"placemark"]]];
		var lastIndex = [searchedOverlays count]-1;
		marker.openInfoWindowHtml(
		    '<b>lat/lng:</b>' + p[1] + "," + p[0] + '<br>' +
		    '<b>Address:</b>' + placemark.address + '<br>' +
		    '<div align="right"><input type="submit" value="Cancel" onclick="removePlace();"/> ' +
			'<input type="submit" value="Search Location" onclick="addPlace();"/></div>');
		GEvent.addDomListener(marker, 'infowindowclose', removePlace);
		
		/*if(eval(place.AddressDetails.Country.AdministrativeArea.Locality.PostalCode.PostalCodeNumber)) 
			var zip = place.AddressDetails.Country.AdministrativeArea.Locality.PostalCode.PostalCodeNumber; 
		    //try to use the yahoo lib to check existence 
		    if(eval(place.AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.Locality.PostalCode.PostalCodeNumber)) 
		    	var zip = place.AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.Locality.PostalCode.PostalCodeNumber; 
		    var address = place.address; 
		    //call the local function addLocation to add the point to the map 
		    var marker = addLocation(point, zip, address); 
		 }*/
	  }
	}
	
	geocoder.getLocations(_gMap.getCenter(), showAddress);
}

-(void)search:(CPString)aSearch
{
	// ====== Setup the Geocoding // Actually called at end of method ====== 
	var reasons = [];
	reasons[G_GEO_SUCCESS]            = "Success";
    reasons[G_GEO_MISSING_ADDRESS]    = "Missing Address: The address was either missing or had no value.";
	reasons[G_GEO_UNKNOWN_ADDRESS]    = "Unknown Address:  No corresponding geographic location could be found for the specified address.";
	reasons[G_GEO_UNAVAILABLE_ADDRESS]= "Unavailable Address:  The geocode for the given address cannot be returned due to legal or contractual reasons.";
	reasons[G_GEO_BAD_KEY]            = "Bad Key: The API key is either invalid or does not match the domain for which it was given";
	reasons[G_GEO_TOO_MANY_QUERIES]   = "Too Many Queries: The daily geocoding quota for this site has been exceeded.";
	reasons[G_GEO_SERVER_ERROR]       = "Server error: The geocoding request could not be successfully processed.";

    function showSearchAddress(result)
	{
	      //map.clearOverlays(); 
	    if (result.Status.code == G_GEO_SUCCESS) {
			// ===== If there was more than one result, "ask did you mean" on them all =====
			if (result.Placemark.length > 1) { 
				CPLog(@"MANY!!");
		  		var menu = [[CPMenu alloc] initWithTitle:@"DidYouMean"];
				var didYouMeanItem = [[CPMenuItem alloc] initWithTitle:@"Did you mean:" action:nil keyEquivalent:nil];
				[didYouMeanItem setState:CPOffState];
				[menu addItem:didYouMeanItem];
		  		// Loop through the results
		  		for (var i=0; i<result.Placemark.length; i++) 
				{
		    		var item = [[CPMenuItem alloc] initWithTitle:result.Placemark[i].address action:@selector(addLocationToMap:) keyEquivalent:nil];
					[item setRepresentedObject:result.Placemark[i]];
					[item setIndentationLevel:1];
					[item setTarget:self];
					[menu addItem:item];
		  		}
				[[CPNotificationCenter defaultCenter] postNotificationName:@"DidYouMean" object:self userInfo:[CPDictionary dictionaryWithObjectsAndKeys:menu, @"menu"]];
			}
			// ===== If there was a single marker, is the returned address significantly different =====
			else 
			{
		  		if ([self addressDiffers:aSearch address:result.Placemark[0].address]) 
				{
					CPLog(@"address differ");
		    		var menu = [[CPMenu alloc] initWithTitle:@"DidYouMean"];
					var didYouMeanItem = [[CPMenuItem alloc] initWithTitle:@"Did you mean:" action:nil keyEquivalent:nil];
					[didYouMeanItem setState:CPOffState];
					[menu addItem:didYouMeanItem];
					var item = [[CPMenuItem alloc] initWithTitle:result.Placemark[0].address action:@selector(addLocationToMap:) keyEquivalent:nil];
					[item setRepresentedObject:result.Placemark[0]];
					[item setIndentationLevel:1];
					[item setTarget:self];
					[menu addItem:item];
					[[CPNotificationCenter defaultCenter] postNotificationName:@"DidYouMean" object:self userInfo:[CPDictionary dictionaryWithObjectsAndKeys:menu, @"menu"]];
		  		} 
				else 
				{
		    		CPLog(@"one result");
		    		[self addLocationToMap:[[CPValue alloc] initWithJSObject:result.Placemark[0]]];
		  		}
			}
		}
		// ====== Decode the error status ======
		else 
		{
			var reason="Code "+result.Status.code;
			if (reasons[result.Status.code])
		  		reason = reasons[result.Status.code];
			alert('Could not find "'+aSearch+ '" ' + reason);
		}
	}
	
	// ====== Perform the Geocoding ======        
	geocoder.getLocations(aSearch, showSearchAddress);
}

-(void)addLocationToMap:(id)placemarkHolder
{
	var isMenuItem = NO;
	
	if([placemarkHolder isKindOfClass:[CPMenuItem class]])
	{
		var placemark = [placemarkHolder representedObject];
		isMenuItem = YES;
	}
	else
		var placemark = [placemarkHolder JSObject];
		
	var p = placemark.Point.coordinates;
	var point = new GLatLng(p[1],p[0]);
	var marker = new GMarker(point);
	_gMap.setCenter(point,14); 
	_gMap.addOverlay(marker);
	[searchedOverlays addObject:[CPDictionary dictionaryWithObjects:[marker, placemark] forKeys:[@"marker", @"placemark"]]];
	var lastIndex = [searchedOverlays count]-1;
	marker.openInfoWindowHtml(
		    '<b>lat/lng:</b>' + p[1] + "," + p[0] + '<br>' +
		    '<b>Address:</b>' + placemark.address + '<br>' +
		    '<div align="right"><input type="submit" value="Cancel" onclick="removePlace();"/> ' +
			'<input type="submit" value="Search Location" onclick="addPlace();"/></div>');
	GEvent.addDomListener(marker, 'infowindowclose', removePlace);//_DOMMapElement
}

-(BOOL)addressDiffers:(CPString)a address:(CPString)b
{
	// only interested in the bit before the first comma in the reply
  	var c = b.split(",");
  	b = c[0];
  	// convert to lower case
  	a = a.toLowerCase();
  	b = b.toLowerCase();
  	// remove apostrophies
  	a = a.replace(/'/g ,"");
  	b = b.replace(/'/g ,"");
  	// replace all other punctuation with spaces
  	a = a.replace(/\W/g," ");
  	b = b.replace(/\W/g," ");
  	// replace all multiple spaces with a single space
  	a = a.replace(/\s+/g," ");
  	b = b.replace(/\s+/g," ");
  	// split into words
  	awords = a.split(" ");
  	bwords = b.split(" ");
  	// perform the comparison
  	var reply = NO;
  	for (var i=0; i<bwords.length; i++) {
    	//GLog.write (standardize(awords[i])+"  "+standardize(bwords[i]))
    	if (standardize(awords[i]) != standardize(bwords[i])) 
			reply = YES;
  	}
  	//GLog.write(reply);
  	return reply;
}

-(void)addPlacemark:(id)placemark marker:(id)marker
{
	//decode placemark
	CPLog(@"will add placemark after its decoded");
	console.log(placemark);
	addingPlace = YES;
	marker.closeInfoWindow();
	try
	{
		var searchDict;
		if(placemark.AddressDetails.Country)
		{
			var country = placemark.AddressDetails.Country.CountryName;
			if(placemark.AddressDetails.Country.AdministrativeArea)
			{
				var stateProv = placemark.AddressDetails.Country.AdministrativeArea.AdministrativeAreaName;
				if(placemark.AddressDetails.Country.AdministrativeArea.Locality)
				{
					var locality = placemark.AddressDetails.Country.AdministrativeArea.Locality.LocalityName;
					searchDict = [CPDictionary dictionaryWithObjects:[placemark.address, @"location", country, stateProv, locality, marker, @"Resources/marker.png"] forKeys:[@"title", @"type", @"Country", @"State/Province", @"Locality", @"overlay", @"image"]];
				}
				else if(placemark.AddressDetails.Country.AdministrativeArea.SubAdministrativeArea)
				{
					if(placemark.AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.Locality)
					{
						var locality = placemark.AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.Locality.LocalityName;
						searchDict = [CPDictionary dictionaryWithObjects:[placemark.address, @"location", country, stateProv, locality, marker, @"Resources/marker.png"] forKeys:[@"title", @"type", @"Country", @"State/Province", @"Locality", @"overlay", @"image"]];
					}
					else if(placemark.AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.SubAdministrativeAreaName)
					{
						var locality = placemark.AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.SubAdministrativeAreaName;
						searchDict = [CPDictionary dictionaryWithObjects:[placemark.address, @"location", country, stateProv, locality, marker, @"Resources/marker.png"] forKeys:[@"title", @"type", @"Country", @"State/Province", @"Locality", @"overlay", @"image"]];
					}
					else
						CPLog(@"unkown location");
				}
				else
					searchDict = [CPDictionary dictionaryWithObjects:[placemark.address, @"location", country, stateProv, marker, @"Resources/marker.png"] forKeys:[@"title", @"type", @"Country", @"State/Province", @"overlay", @"image"]];
			}
			else
				searchDict = [CPDictionary dictionaryWithObjects:[placemark.address, @"location", country, marker, @"Resources/marker.png"] forKeys:[@"title", @"type", @"Country", @"overlay", @"image"]];
		}
		else if(placemark.AddressDetails.AddressLine)
		{
			var continentOcean = placemark.AddressDetails.AddressLine;
			searchDict = [CPDictionary dictionaryWithObjects:[placemark.address, @"location", continentOcean, marker, @"Resources/marker.png"] forKeys:[@"title", @"type", @"Continent/Ocean", @"overlay", @"image"]];
		}
		CPLog(searchDict);
		[searchItems addObject:searchDict];
		if([delegate respondsToSelector:@selector(addedSearchItem:)])
			[delegate addedSearchItem:searchDict];
	}
	catch(error)
	{
		CPLog(error);
	}
	addingPlace = NO;
}

- (void)removeItems
{
	[searchItems removeAllObjects];
	_gMap.clearOverlays();
}

-(void)removeObjectAtIndex:(int)index
{
	var overlay = [[searchItems objectAtIndex:index] objectForKey:@"overlay"];
	_gMap.removeOverlay(overlay);
	
	CPLog([[searchItems objectAtIndex:index] objectForKey:@"type"]);
	if([[[searchItems objectAtIndex:index] objectForKey:@"type"] isEqualToString:@"point"])
	{
		CPLog(@"heeeeeeeeeheee");
		var overlay2 = [[searchItems objectAtIndex:index] objectForKey:@"overlay2"];
		_gMap.removeOverlay(overlay2);
	}
	[searchItems removeObjectAtIndex:index];
}

-(void)updateMarker:(GMarker)_marker
{
	var index = [seachItems indexOfObject:_marker];
	[searchItems objectAtIndex:index].setLatLng(_marker.getLatLng());
}	

-(MKMapView)gMap
{
	return _gMap;
}

@end

function addPlace()
{
	console.log(@"adding place....");
	[_mapView addPlacemark:[[searchedOverlays lastObject] objectForKey:@"placemark"] marker:[[searchedOverlays lastObject] objectForKey:@"marker"]];;
}

function removePlace(sender)
{
	if(addingPlace)
		return;
	console.log(@"removing place....");
	_gMap.removeOverlay([[searchedOverlays lastObject] objectForKey:@"marker"]);
}

function standardize(a) {
	var standards = [["road","rd"],   
	                 ["street","st"], 
	                 ["avenue","ave"], 
	                 ["av","ave"], 
	                 ["drive","dr"],
                     ["saint","st"], 
                     ["north","n"],   
                     ["south","s"],    
                     ["east","e"], 
                     ["west","w"],
                     ["expressway","expy"],
                     ["parkway","pkwy"],
                     ["terrace","ter"],
                     ["turnpike","tpke"],
                     ["highway","hwy"],
                     ["lane","ln"]];

	for (var i=0; i<standards.length; i++) {
    	if (a == standards[i][0])
			a = standards[i][1];
  	}
  	return a;
}




