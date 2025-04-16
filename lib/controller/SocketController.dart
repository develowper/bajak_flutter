import 'package:games/controller/SettingController.dart';
import 'package:games/controller/UserController.dart';
import 'package:games/helper/helpers.dart';
import 'package:games/helper/variables.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class SocketController {
  SettingController setting = Get<SettingController>();
  UserController userController = Get<UserController>();
  Helper helper = Get<Helper>();
  IO.Socket? socket;
  bool _isInitialized = false;

  SocketController() {}

  isConnected() {
    return socket?.connected;
  }

  once(String event, handler) {
    socket?.once(event, handler);
  }

  on(String event, handler) {
    socket?.on(event, handler);
  }

  onConnect(handler) {
    socket?.onConnect((_) {
      handler(_);
    });
  }

  onReconnect(handler) {
    socket?.onReconnect((_) {
      handler(_);
    });
  }

  onDisconnect(handler) {
    socket?.onDisconnect((_) {
      handler(_);
    });
  }

  void emit(String event, data) {
    // print("emit ${event}");
    socket?.emit(event, data);
  }

  void emitWithAck(String event, data, Function(dynamic data) callback) {
    // print("emitWithAck ${event}");
    socket?.emitWithAck(event, data, ack: (data) {
      // print("Ack ${event}");
      callback(data);
    });
  }

// socket.emitWithAck(event, data, ack: (data) {
//   print('ack $data');
//   if (data != null) {
//     print('from server $data');
//   }
// });

  IO.Socket? init({params}) {
    // if (!_isInitialized) {
    print('*****socket start init ${setting.appInfo!.socketLink}');

    socket = IO.io(
        setting.appInfo!.socketLink,
        OptionBuilder()
            .setTransports(
                /*kIsWeb
                ? ['websocket', 'polling']
                :*/
                ['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .disableForceNewConnection()
            // .disableReconnection()
            // .setUpgrade(false)
            .enableReconnection()
            .setQuery(params ?? {})
            .setExtraHeaders(params ?? {})
            .setAuth({'token': "${userController.ACCESS_TOKEN}"})
            .build());
    if (params != null) {
      socket?.io.options?['extraHeaders'] = params;
      socket?.io.options?['query'] = params;
    }
    // _isInitialized = true;
    // }
    socket?.onConnect((_) {
      print('connected ${socket?.id}');
      // print(socket?.id);
      // socket?.emit('join-room');
    });

    return socket;
  }

  connect() {
    print('*****socket start connection*');

    // socket.onConnect((_) {
    //   print('connected');
    //   print(socket.id);
    //   socket.emit('join-room')
    // });
    // socket?.onDisconnect((_) => print('*socket**disconnect******'));
    // socket?.onReconnect((_) => print('*socket**reconnect******'));

    print("socket connecting to ${setting.appInfo!.socketLink}");

    // socket.io.options?['extraHeaders'] = {
    //   'foo': 'bar'
    // }; // Update the extra headers.
    // socket.io
    //   ..disconnect()
    //   ..connect(); // Reconnect the socket manually.
    // socket.emit('hi');
    // socket?.onAny((_, d) => {
    //       print('onAny******'),
    //           print(_),
    //           print(d),
    //           print('***onAny******'),
    //     });
    if (!(socket?.connected ?? false)) socket?.connect();
  }

  bool connected() {
    return socket?.connected ?? false;
  }

  void disconnect() {
    if (socket?.connected ?? false) {
      socket?.dispose();
    }
  }
}
