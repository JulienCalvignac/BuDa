'use strict';

var options = { cyreference : null };

var dagre_layout = { name: 'dagre' };

var dataElements = {
		nodes: []
		, edges: []
};

var preset_layout = {
  name: 'preset',

  positions: undefined, // map of (node id) => (position obj); or function(node){ return somPos; }
  zoom: undefined, // the zoom level to set (prob want fit = false if set)
  pan: undefined, // the pan level to set (prob want fit = false if set)
  fit: true, // whether to fit to viewport
  padding: 30, // padding on fit
  animate: false, // whether to transition the node positions
  animationDuration: 500, // duration of animation in ms if enabled
  animationEasing: undefined, // easing of animation if enabled
  animateFilter: function ( node, i ){ return true; }, // a function that determines whether the node should be animated.  All nodes animated by default on animate enabled.  Non-animated nodes are positioned immediately when the layout starts
  ready: undefined, // callback on layoutready
  stop: undefined, // callback on layoutstop
  transform: function (node, position ){ return position; } // transform a given node position. Useful for changing flow direction in discrete layouts
};

var styleP = $.ajax({
	url: 'mainstyle.css',
	type: 'GET',
	dataType: 'text'
});
var stylesheet = styleP;


function getCyReference() {

	if (options.cyreference == null)
	{
		cy = window.cy = cytoscape({
		  container: document.getElementById('cy')
		  , boxSelectionEnabled: true
		  , autounselectify: false
			, elements : dataElements
			, style: stylesheet
			// , layout: concentricOptions
			// , layout: cola_layout
			, layout: dagre
			// , layout : arbor

		});
		options.cyreference = cy;
	}

	return options.cyreference;
}

document.addEventListener("DOMContentLoaded", function() {

var cy = getCyReference();

var tappedBefore;
var tappedTimeout;
var mustUpdatepositionstoElm=false;
var hasNodeClicked = false;
var hasNodeMoving = false;


cy.on("click", function(e){
	try {
		var selected = getSelectedEls();
		if(selected.length == 0)
		{
			// console.log('no selection');
			var msg = [];
			_sendSelectionToElm_(msg);

		}
	}
	catch(err){
	// cur_position =
	}
});

cy.on('mousedown', 'node', function(e){
	// console.log('mousedown node event');
	hasNodeClicked=true;
});

cy.on('mouseup', 'node', function(e){
	// console.log('mouseup node event');

	if(hasNodeMoving == true){
		mustUpdatepositionstoElm=true;
	}

	if(mustUpdatepositionstoElm == true){
		// console.log("mustUpdatepositionstoElm to send");
		_setNodesPositionsToElm_();
	}

	hasNodeClicked=false;
	hasNodeMoving=false;
	mustUpdatepositionstoElm=false;

});

cy.on('mousemove', function(e){
	// console.log('mousemove event');

	if(hasNodeClicked==true){
		hasNodeMoving = true;
	}
});

cy.on('tap', function(event) {
  var tappedNow = event.cyTarget;
  if (tappedTimeout && tappedBefore) {
    clearTimeout(tappedTimeout);
  }
  if(tappedBefore === tappedNow) {
    tappedNow.trigger('doubleTap');
    tappedBefore = null;
  } else {
    tappedTimeout = setTimeout(function(){ tappedBefore = null; }, 300);
    tappedBefore = tappedNow;
  }
});

cy.on('doubleTap', 'node', function(event) {

	var selected = getSelectedEls();

	if(selected.length > 0)
	{
		var msg = JSON.stringify ({id: parseInt(selected[0].id())});
		_sendDoubleClickToElm_(msg);
	}


});

cy.on('select', function(event){
		var selected = getSelectedEls();
		if(selected.length > 0)
		{
			var msg = [];
			selected.forEach(function (s)
			{
				msg.push ( JSON.stringify ({id: parseInt(s.id())}) );
			});

			_sendSelectionToElm_(msg);

		}
});


}); // end of document.addEventListener

function _setNodesPositionsToElm_() {
	var cy = getCyReference();
	var ns = cy.nodes();
	var msg = [];

	ns.forEach(function (s)
	{
		var pos = s.position();
			msg.push (
				{ id: parseInt(s.id())
				, position: {x:pos.x, y:pos.y}
				}
			);
	});

	msg = JSON.stringify ( msg );

	// console.log (msg);

	app_port_sendNodesPositionToElm(msg);
}


function _sendSelectionToElm_(msg) {
	app_port_sendSelectionToElm(msg);
}

function _sendDoubleClickToElm_(msg) {
	app_port_sendDoubleClickToElm(msg);
}

function getSelectedNode() {
	var cy = getCyReference();
	return cy.nodes(':selected');
}

function getSelectedEls() {
	var cy = getCyReference();
	return cy.elements(':selected');
}

function setPBSStyle() {
	var cy = getCyReference();
	// cy.setStyle (stylesheetPBS);
}

function setBullesStyle() {
	var cy = getCyReference();
	// cy.setStyle (stylesheetBubble);
}

function _sendDataSimpleModel_ (obj) {
	var cy = getCyReference();
	cy.remove (cy.elements());
	cy.add(obj);
}


function _sendDataModel_ (obj) {
	var cy = getCyReference();
	cy.remove (cy.elements());

	var ns = obj.nodes;
	ns.forEach(function (s)
	{
		cy.add({
		    group: "nodes",
		    data: { id: s.data.id, parent: s.data.parent, name: s.data.name, highLighted: s.data.highLighted }
				, position: {x: s.data.position.x, y: s.data.position.y }
		});
	});

	var eds = obj.edges;
	eds.forEach(function (s)
	{
		cy.add({
		    group: "edges",
		    data: { id: s.data.id, source: s.data.source, target: s.data.target, highLighted: s.data.highLighted}
		});
	});
}

function _layout_dagre () {
	var cy = getCyReference();
	cy.layout(dagre_layout);
}

function _layout_preset() {
	var cy = getCyReference();
	cy.layout(preset_layout);

}

function _updateBullesLayoutAndPos(obj) {
	_sendDataSimpleModel_(obj);
	_layout_dagre();
	_setNodesPositionsToElm_();
}

function _saveAsSvg_ (svgName) {
  // demo your core ext
	var cy = getCyReference();
  var svgContent = cy.svgConvertor( {scale : 3, full : true} );
  var svgBlob = new Blob([ svgContent ]
  , { type: 'application/javascript;charset=utf-8' });
  saveAs(svgBlob, svgName + '.svg');
}

function _saveAsPng_ (pngName) {
	var cy = getCyReference();
  var pngContent = cy.png({scale : 3, full : true});
  var b64data = pngContent.substr(pngContent.indexOf(",") + 1);
  var imgBlob = base64ToBlob( b64data, 'image/png' );
  saveAs( imgBlob, pngName + '.png' );
}

function saveToImage (imgName) {
	_saveAsSvg_ (imgName);
	_saveAsPng_ (imgName);
}

