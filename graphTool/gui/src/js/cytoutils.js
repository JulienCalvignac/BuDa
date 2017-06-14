'use strict';

var options = { cyreference : null };

// var cy_reference = null;
var cola_layout = { name: 'cola', fit: true, maxSimulationTime: 1000, };
var dagre_layout = { name: 'dagre' };
var arbor_layout = { name: 'arbor' };

var dataElements = {
		nodes: [
			// { data: { id: 99, name: 'a' } }
			// , { data: { id: 100, name: 'b' } }
	]
		, edges: [
			// { data: { id: 101, source: 99, target: 100 } }
		]
};

var idx = 0;


var cur_position = { x: 0, y: 0 };


var stylesheet = [
      {
        selector: 'node',
        style: {
          shape: 'rectangle',
          'background-color': 'blue',
          // 'width': 'mapData(bar, 0, 10, 10, 50)',
          // 'height': 'mapData(bar, 0, 10, 10, 50)',
          label: 'data(name)'
        }
      }
      , {
        selector: ':selected',
        style: {
          'border-width': 4,
          'border-color': 'purple'
        }
      }
      , {
        selector: ':parent',
        style: {
          'background-opacity': 0.1
          , shape: 'ellipse'

        }
      }
      , {
				selector: 'edge',
				style: {
					// 'target-arrow-shape': 'triangle'
           'curve-style': 'haystack'
				}
			}
];

function getIdentifer() {
	var res = idx;
	idx = idx + 1;
	return res;
}


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
			// , layout: dagre
			, layout : arbor

		});
		options.cyreference = cy;
	}

	return options.cyreference;
}

document.addEventListener("DOMContentLoaded", function() {

var cy = getCyReference();

var tappedBefore;
var tappedTimeout;

cy.on("click", function(e){
	try {
		var selected = getSelectedEls();
		if(selected.length == 0)
		{
			console.log('no selection');
			var msg = [];
			_sendSelectionToElm_(msg);

		}
	}
	catch(err){
	// cur_position =
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
        // window["selectedNodes"] = cy.$('node:selected');
		var selected = getSelectedEls();
		if(selected.length > 1)
		{
			var s = 'selection: ' + selected[0].id() + ':' + selected[1].id();
			console.log(s);
			var msg = [ JSON.stringify ({id: parseInt(selected[0].id())}), JSON.stringify ({ id: parseInt(selected[1].id())})];
			_sendSelectionToElm_(msg);

		}
		else if(selected.length > 0)
		{
			console.log('selection: ' + selected[0].id());
			var msg = [ JSON.stringify ({id: parseInt(selected[0].id())}) ];
			_sendSelectionToElm_(msg);
		}
});


}); // end of document.addEventListener


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


function _sendDataModel_ (obj) {
	var cy = getCyReference();
	var nodes = cy.filter('node'); // a cached copy of nodes
	var selector = nodes.select();
	getCyReference().remove(selector);
	getCyReference().add(obj);
}

function _layout_dagre () {
	var cy = getCyReference();
	cy.layout(dagre_layout);
	// cy.layout(arbor_layout);

}

function _layout_cola () {
	var cy = getCyReference();
	cy.layout(cola_layout);
}
