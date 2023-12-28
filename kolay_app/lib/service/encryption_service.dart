import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt.dart';

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
    return encrypted.base64;
  }

  String decryptText(String encryptedText) {
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
      return decrypted;
    } on Exception catch (e) {
      print('Error during decryption: $e');
      return ''; // Or handle the error as needed
    }
  }
}