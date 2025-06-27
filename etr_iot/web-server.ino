#include <WiFi.h>
#include <WebServer.h>
#include <HTTPClient.h>
#include <SoftwareSerial.h>
#include <ArduinoJson.h>
#include <TinyGPS++.h>

const char* ssid = "";         //This is a login and password for test purposes
const char* password = "";     //Since GSM module does not work 

#define LOCATION_RX 16
#define LOCATION_TX 17
#define GPS_BAUD 9600

HardwareSerial gpsSerial(2);


#define LOCK_PIN 5

WebServer server(80);

TinyGPSPlus gps;
HTTPClient http;

const char* api_endpoint = "localhost:8080/api/register";
String deviceId = "sample_id"; // Change in each device

void setup() {
  Serial.begin(115200);
  delay(100);

  Serial.println("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);
  Serial.print("Starting...");

  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(WiFi.status());
  }
  Serial.println("");
  Serial.println("WiFi connected..!");
  Serial.print("Got IP: ");  Serial.println(WiFi.localIP());

  String deviceAddress = WiFi.localIP().toString();

  if (WiFi.status() == WL_CONNECTED) {
    http.begin(api_endpoint); 
    http.addHeader("Content-Type", "application/json"); 

    StaticJsonDocument<200> doc;
    doc["deviceId"] = deviceId;
    doc["deviceAddress"] = deviceAddress;

    String json;
    serializeJson(doc, json);
    
    int httpResponseCode = http.POST(json);

    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("HTTP Response code: " + String(httpResponseCode));
      Serial.println("Response: " + response);
    } else {
      Serial.println("Error on sending POST: " + String(httpResponseCode));
    }
  } else {
    Serial.println("WiFi not connected, cannot send JSON");
  }

  server.begin();
  Serial.println("HTTP server started");


  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  server.handleClient();
  server.on("/", handle_OnConnect);
  server.on("/location", handle_getLocation);
  server.on("/block", handle_block);
  server.on("/unblock", handle_unblock);
}

void handle_OnConnect() {
  Serial.println("Connection set!");
  server.send(200, "text/html",  "Hello world!");
}

void handle_getLocation(){
  double latitude = 0.0;
   double longitude = 0.0;
  getLocation(latitude, longitude);

  StaticJsonDocument<200> doc;
  doc["latitude"] = latitude;
  doc["longitude"] = longitude;
  
  String json;
  serializeJson(doc, json);

  server.send(200, "text/html", json);
}

void getLocation(double &lat, double &lon) {
  if(gpsSerial.available()) {
    char gpsData = gpsSerial.read();
    gps.encode(gpsData);
    if (gps.location.isValid()) {
      lat = gps.location.lat();
      lon = gps.location.lng();
    }
  }
}

void handle_block() {
  digitalWrite(LOCK_PIN, LOW);
}

void handle_unblock() {
  digitalWrite(LOCK_PIN, HIGH); 
}

