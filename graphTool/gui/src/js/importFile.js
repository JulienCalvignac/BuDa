var readImport = new FileReader();

readImport.onload = function(e) {
  var content = readImport.result;
    // console.log('loadmodel:' + json);

    if(window.fileType == "json"){
      app_port_sendImportModelToElm(content);
    }
    else if(window.fileType == "csv") {
      app_port_sendImportCsvModelToElm(content);
    }
}


function importModelFromFile(loadModelId) {
  var target = document.getElementById("importModel");
  var files = target.files; // FileList object
  var file = files[0];

  if(file.type == "application/json")
  {
    window.fileType = "json"
  }
  else if(file.type == "text/csv")
  {
    window.fileType = "csv"
  }


  readImport.readAsText(file);
  }
