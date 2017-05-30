var defaults_cola_options = {
  animate: true, // whether to show the layout as it's running
  refresh: 1, // number of ticks per frame; higher is faster but more jerky
  maxSimulationTime: 4000, // max length in ms to run the layout
  ungrabifyWhileSimulating: false, // so you can't drag nodes during layout
  fit: true, // on every layout reposition of nodes, fit the viewport
  padding: 30, // padding around the simulation
  boundingBox: undefined, // constrain layout bounds; { x1, y1, x2, y2 } or { x1, y1, w, h }

  // layout event callbacks
  ready: function(){}, // on layoutready
  stop: function(){}, // on layoutstop

  // positioning options
  randomize: false, // use random node positions at beginning of layout
  avoidOverlap: true, // if true, prevents overlap of node bounding boxes
  handleDisconnected: true, // if true, avoids disconnected components from overlapping
  nodeSpacing: function( node ){ return 10; }, // extra spacing around nodes
  flow: undefined, // use DAG/tree flow layout if specified, e.g. { axis: 'y', minSeparation: 30 }
  alignment: undefined, // relative alignment constraints on nodes, e.g. function( node ){ return { x: 0, y: 1 } }

  // different methods of specifying edge length
  // each can be a constant numerical value or a function like `function( edge ){ return 2; }`
  edgeLength: undefined, // sets edge length directly in simulation
  edgeSymDiffLength: undefined, // symmetric diff edge length in simulation
  edgeJaccardLength: undefined, // jaccard edge length in simulation

  // iterations of cola algorithm; uses default values on undefined
  unconstrIter: undefined, // unconstrained initial layout iterations
  userConstIter: undefined, // initial layout iterations with user-specified constraints
  allConstIter: undefined, // initial layout iterations with all constraints including non-overlap

  // infinite layout options
  infinite: false // overrides all other options for a forces-all-the-time mode
};

var dataElements = {
    nodes: [
      { data: { id: 'a', name: 'a' }
        // , position: { x: 100, y: 100 }
      }
      , { data: { id: 'b', name: 'b', parent: 'a' }
        // , position: { x: 110, y: 110 }
      }
      , { data: { id: 'c', name: 'c' }
        // , position: { x: 110, y: 110 }
      }
      , { data: { id: 'd', name: 'd' }
        // , position: { x: 110, y: 110 }
      }
      , { data: { id: 'e', name: 'e' }
        // , position: { x: 110, y: 110 }
      }
      , { data: { id: 'f', name: 'f' }
        // , position: { x: 110, y: 110 }
      }
    ]
    , edges: [
      { data: { id: 'ad', source: 'a', target: 'b' } }
    ]
};

var elements = dataElements;


var simpleStyle = [
      {
        selector: 'node',
        style: {
          shape: 'hexagon',
          'background-color': 'red',
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
          'background-opacity': 0.333
          , shape: 'hexagon'
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

var stylesheet = simpleStyle;


var simpleStyle2 = 	  [
	    {
	      selector: 'node',
	      css: {
	        'content': 'data(name)',
					'font-size': '0.5em',
	        'width': '0.5em',
	        'height': '0.5em',
          'color': 'blue',
	        'text-valign': 'center',
	        'text-halign': 'center'
	      }
	    },
	    {
	      selector: '$node > node',
	      css: {
	        'padding-top': '0.2em',
	        'padding-left': '0.2em',
	        'padding-bottom': '0.2em',
	        'padding-right': '0.2em',
	        'text-valign': 'top',
	        'text-halign': 'center',
	        'background-color': '#bbb'
	      }
	    },
	    {
	      selector: 'edge',
	      css: {
	        'target-arrow-shape': 'triangle'
	      }
	    },
	    {
	      selector: ':selected',
	      css: {
	        'background-color': 'black',
	        'line-color': 'black',
	        'target-arrow-color': 'black',
	        'source-arrow-color': 'black'
	      }
	    }
	  ];
