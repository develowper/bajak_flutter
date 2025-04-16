import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

Map getFromC() {
  final DynamicLibrary nativeAddLib = Platform.isAndroid
      ? DynamicLibrary.open("libsec.so")
      : DynamicLibrary.process();
  final getPointer = nativeAddLib
      .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>('get');
  final function =
      getPointer.asFunction<Pointer<Utf8> Function(Pointer<Utf8>)>();
// final getIVPointer =
//     nativeAddLib.lookup<NativeFunction<Pointer<Utf8> Function()>>('get_iv');
// final ivFunction = getIVPointer.asFunction<Pointer<Utf8> Function()>();

  String _appKey = (function("enc_key".toNativeUtf8())).toDartString();
  String _iv = (function("enc_iv".toNativeUtf8())).toDartString();

  Map res = {
    'key': _appKey,
    'iv': _iv,
  };
  return res;
}
