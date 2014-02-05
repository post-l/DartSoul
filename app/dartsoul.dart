import 'dart:async';
import 'dart:html';
import 'package:chrome/chrome_app.dart' as chrome;

int boundsChange = 100;
Client client;

void main() {
  ButtonElement connectBtn = querySelector("#connectBtn") as ButtonElement;
  connectBtn.onClick.listen(logMeIn);
  connectBtn.disabled = true;
  client = new Client(onCreate: () => connectBtn.disabled = false);
}

void logMeIn(MouseEvent event) {
  chrome.AppWindow appWindow = chrome.app.window.current();
  String login = (querySelector("#loginInput") as InputElement).value;
  String password = (querySelector("#passwordInput") as InputElement).value;
  client.connect();
}

class Client {
  String    _hostname = "ns-server.epita.fr";
  int       _port = 4242;
  int       _socketId = -1;
  bool      _isConnected = false;

  Client({onCreate}) {
    chrome.socket.create(chrome.SocketType.TCP).then((createInfo) {
      _socketId = createInfo.socketId;
      if (onCreate != null) {
        onCreate();
      }
    });
  }

  void connect() {
    if (_socketId != -1 && !_isConnected) {
      chrome.socket.connect(_socketId, _hostname, _port).then((_) {
        _isConnected = true;
        chrome.socket.read(_socketId).then(handleDataEvent);
       });
    }
  }

  void disconnect() {
    if (_isConnected) {
      chrome.socket.disconnect(_socketId);
      _isConnected = false;
    }
  }

  void handleDataEvent(chrome.SocketReadInfo readInfo) {
    if (readInfo.resultCode < 0) {
      disconnect();
      return ;
    }
    String data = new String.fromCharCodes(readInfo.data.getBytes());
    print("data: $data");
    chrome.socket.read(_socketId).then(handleDataEvent);
  }

  Future<chrome.SocketWriteInfo> send(String message) {
    return chrome.socket.write(_socketId,
        new chrome.ArrayBuffer.fromString(message));
  }

  bool get isConnected => _isConnected;
}
