import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QrScanner extends StatefulWidget {
  final String entryType;
  final String userId;

  const QrScanner({Key? key, required this.entryType, required this.userId}) : super(key: key);

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? returnedQrData;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('${widget.entryType} QR Okuyucu'),
      centerTitle: true,
    ),
    body: QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderRadius: 10,
        borderLength: 20,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
      ),
    ),
  );

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((barcode) {
      handleScannedData(barcode);
    });
  }

  void handleScannedData(Barcode barcode) async {
    setState(() {
      returnedQrData = barcode;
      print('found data = ${returnedQrData!.code}');

      // Check if the scanned QR code matches the specified value
      if (returnedQrData != null && returnedQrData!.code == 'fFemZQ@4AaSq|s\'q-3fLN43X{CcZ%h4?A2') {
        // Giriş veya Çıkış işlemi burada yapılır
        if (widget.entryType == 'Giriş') {
          logEntry();
        } else if (widget.entryType == 'Çıkış') {
          logExit();
        }

        // Pop-up
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('QR Başarıyla Okundu'),
              actions: [
                TextButton(
                  onPressed: () {
                    // Pop-up kapatıldığında Home sayfasına geri dön
                    Navigator.pop(context);
                    Navigator.pop(context); // Home sayfasına geri dön
                  },
                  child: Text('Tamam'),
                ),
              ],
            );
          },
        );

        // QR Scanner'ı kapat
        controller!.stopCamera();
      }
    });
  }


  // Giriş işlemi için Firestore'a veri ekleme fonksiyonu
  Future<void> logEntry() async {
    final DateTime now = DateTime.now();
    final String formattedDate = '${now.year}-${now.month}-${now.day}';
    final String formattedDateTime =
        '${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}';

    // CollectionReference 'Date'
    final CollectionReference dateCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('Date');

    // DocumentReference belirli bir tarih için
    final DocumentReference dateDocument = dateCollection.doc(formattedDate);

    // Belge var mı kontrol et
    final DocumentSnapshot dateSnapshot = await dateDocument.get();

    // Eğer belge yoksa oluştur
    if (!dateSnapshot.exists) {
      await dateDocument.set({
        'giriş': [], // veya boş bir array
        'çıkış': [], // veya boş bir array
      });
    }

    // 'giriş' alanına timestamp ekleyip güncelle
    await dateDocument.update({
      'giriş': FieldValue.arrayUnion([formattedDateTime]),
    });
  }

  Future<void> logExit() async {
    final DateTime now = DateTime.now();
    final String formattedDate = '${now.year}-${now.month}-${now.day}';
    final String formattedDateTime =
        '${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}';

    // CollectionReference 'Date'
    final CollectionReference dateCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('Date');

    // DocumentReference belirli bir tarih için
    final DocumentReference dateDocument = dateCollection.doc(formattedDate);

    // Belge var mı kontrol et
    final DocumentSnapshot dateSnapshot = await dateDocument.get();

    // Eğer belge yoksa oluştur
    if (!dateSnapshot.exists) {
      await dateDocument.set({
        'giriş': [], // veya boş bir array
        'çıkış': [], // veya boş bir array
      });
    }

    // 'çıkış' alanına timestamp ekleyip güncelle
    await dateDocument.update({
      'çıkış': FieldValue.arrayUnion([formattedDateTime]),
    });
  }
}
