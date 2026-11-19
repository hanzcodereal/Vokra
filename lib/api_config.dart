const String serverHost = "panellipzprivate.lightsecret.my.id";
const int serverPort = 11088;
const bool serverUseHttps = false;

String get apiScheme => serverUseHttps ? "https" : "http";
String get wsScheme => serverUseHttps ? "wss" : "ws";

String get apiBaseUrl => "$apiScheme://$serverHost:$serverPort";
String get wsBaseUrl => "$wsScheme://$serverHost:$serverPort";
