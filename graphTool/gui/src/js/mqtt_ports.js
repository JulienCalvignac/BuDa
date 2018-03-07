app.ports.mqttConnect.subscribe(function(word) {
  UpdateOptions(word);
  connectMQTT();
});

app.ports.mqttDisconnect.subscribe(function(word) {
  disconnectMQTT();
});

app.ports.sendNotification.subscribe(function(word) {
  sendDataToMQTT(word);
  return false;
});

function app_port_sendToElm(msg) {
  app.ports.fromJS.send(msg);
  return false;
}
