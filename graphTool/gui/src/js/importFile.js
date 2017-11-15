var readImport = new FileReader();

readImport.onload = function(e) {
    var json = readImport.result;
    // console.log('loadmodel:' + json);
    app_port_sendImportModelToElm(json);

}


function importModelFromFile(loadModelId) {
  var target = document.getElementById("importModel");
  var files = target.files; // FileList object
  var file = files[0];

  readImport.readAsText(file);
  }
