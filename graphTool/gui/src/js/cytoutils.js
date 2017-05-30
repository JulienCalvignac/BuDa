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
          shape: 'ellipse',
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

cy.on("click", function(e){
	try {
		// var log = document.getElementById('log');
		// cur_position = e.cyPosition;
		// // cur_position = e.cyRenderedPosition;
		// log.value = 'x: ' + cur_position.x.toFixed(2) + ', y: ' + cur_position.y.toFixed(2);

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
			// console.log('selection: ' + selected[0].id());
			var msg = [ JSON.stringify ({id: parseInt(selected[0].id())}) ];
			_sendSelectionToElm_(msg);
		}
});


}); // end of document.addEventListener


function _sendSelectionToElm_(msg) {
	app_port_sendSelectionToElm(msg);
}

function _sendModelToElm_() {
	var cy = getCyReference();
	var eles = cy.nodes();
	var index;

	// construction des nodes
	var nodesLst = [];
	var edgesLst = [];
	var n;
	var elesMsg;

	for (index = 0; index < eles.length; index++) {
    //console.log(eles[index]["data"]("id"));

		parent = eles[index]["data"]("parent");
		if(parent==null)
		{
			n = { data: { id: parseInt(eles[index]["data"]("id")), name: eles[index]["data"]("name"), parent: null } };
		}
		else
		{
			n = { data: {id: parseInt(eles[index]["data"]("id")), name: eles[index]["data"]("name"), parent: parseInt(eles[index]["data"]("parent"))} };
		}
		nodesLst.push(n);
	}

	// construction des liens
	eles = cy.edges();
	for (index = 0; index < eles.length; index++) {
    //console.log(eles[index]["data"]("id"));

		parent = eles[index]["data"]("parent");
		n = { data: {id: parseInt(eles[index]["data"]("id")), source: parseInt(eles[index]["data"]("source")), target: parseInt(eles[index]["data"]("target"))} };
		edgesLst.push(n);
	}

	elesMsg = { nodes: nodesLst, edges: edgesLst };
	var msg = JSON.stringify (elesMsg);
	// var msg = '' + { nodes: nodesLst, edges: edgesLst } + '';
	app_port_sendModelToElm(msg);
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

// function _deleteElement_() {
// 	getSelectedEls().remove();
// }

function _layout_dagre () {
	var cy = getCyReference();
	cy.layout(dagre_layout);
	// cy.layout(arbor_layout);

}

function _layout_cola () {
	var cy = getCyReference();
	cy.layout(cola_layout);
}

// function _createNode_() {
// 	var cy = getCyReference();
// 	var selected = getSelectedNode();
// 	var input = document.getElementById('input');
// 	var name = input.value;
// 	var newId = getIdentifer();
//
// 	if(selected.length > 0)
// 	{
//
// 		cy.add( [ { group: "nodes", data: { id: newId, name: name, parent: selected[0].id() }, position: { x: cur_position.x, y: cur_position.y }  }]);
// 	}
// 	else
// 	{
// 		cy.add( [ { group: "nodes", data: { id: newId, name: name, position : { x: cur_position.x, y: cur_position.y } } } ]);
// 	}
// }


// function _createEdge_() {
// 	var cy = getCyReference();
// 	var selected = getSelectedNode();
//
// 	if(selected.length > 1)
// 	{
// 		var edgeId = getIdentifer();
// 		cy.add([
// 			{ data : { id: edgeId
// 							, source: selected[0].id()
// 							, target: selected[1].id()
// 							}
// 		}
// 		]);
// 		// cy.add([ { data: { id: selected[0].id() ++ selected[1].id(), source: selected[0].id(), target: selected[1].id() } } ]);
// 	}
//
// }

// function _renameNode_() {
// 	var cy = getCyReference();
// 	var input = document.getElementById('input');
// 	var selected = getSelectedNode();
//
// 	if(selected.length > 0)
// 	{
// 		selected[0].data('name', input.value);
// 	}
// }
