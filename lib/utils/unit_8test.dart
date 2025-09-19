import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

// Convert a base64 string to Uint8List
Uint8List base64ToUint8List(String base64String) {
  try {
    return base64Decode(base64String);
  } catch (e) {
    print('Error decoding base64 string: $e');
    return Uint8List(0); // Return an empty list in case of error
  }
}

Stream<List<int>> uint8ListToStream(Uint8List uint8List) async* {
  final controller = StreamController<List<int>>();

  // Add the Uint8List to the stream
  controller.add(uint8List);

  // Close the stream
  await controller.close();
}

String uint8ListToBase64(Uint8List uint8List) {
  return base64Encode(uint8List);
}

