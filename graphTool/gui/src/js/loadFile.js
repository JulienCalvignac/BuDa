var reader = new FileReader();

reader.onload = function(e) {

  var content = reader.result;

    if(window.fileType == "json"){
      app_port_sendModelToElm(content);
    }
    else if(window.fileType == "csv") {
      var json = reader.result;
      app_port_sendCsvModelToElm(content);
    }

}


function loadModelFromFile(loadModelId) {
  var target = document.getElementById(loadModelId);
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


  reader.readAsText(file);


  }
