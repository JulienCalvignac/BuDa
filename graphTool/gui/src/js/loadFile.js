var reader = new FileReader();

reader.onload = function(e) {
    var json = reader.result;
    // console.log('loadmodel:' + json);
    app_port_sendModelToElm(json);

}


function loadModelFromFile(loadModelId) {
  var target = document.getElementById(loadModelId);
  var files = target.files; // FileList object
  var file = files[0];

  reader.readAsText(file);
  }
