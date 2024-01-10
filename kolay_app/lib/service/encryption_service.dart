import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

class EncryptionService {
  final encrypt.Key key = encrypt.Key.fromUtf8('my 32 length key................');
  final encrypt.IV iv = encrypt.IV.fromUtf8('your-16-chars-IV');

  // Singleton instance
  static final EncryptionService _instance = EncryptionService._internal();

  factory EncryptionService() {
    return _instance;
  }

  // Private constructor
  EncryptionService._internal();

  // Encrypts the text
  String encryptText(String text) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(text, iv: iv);
    
    // Base64 encode and then URL encode
    String encodedUrl = Uri.encodeComponent(base64.encode(encrypted.bytes));
    
    return encodedUrl;
  }

  String decryptText(String encryptedText) {
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      
      // URL decode and then Base64 decode
      final decrypted = encrypter.decrypt64(Uri.decodeComponent(encryptedText), iv: iv);
      
      return decrypted;
    } on Exception catch (e) {
      print('Error during decryption: $e');
      return ''; // Or handle the error as needed
    }
  }
}
