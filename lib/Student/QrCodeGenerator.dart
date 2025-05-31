import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QRCodePage extends StatelessWidget {
  final String qrCode;

  const QRCodePage({super.key, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event QR Code")),
      body: Center(
        child: qrCode.isEmpty
            ? const Text("QR Code not available", style: TextStyle(fontSize: 18, color: Colors.red))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: PrettyQrView.data(
                      data: qrCode,
                      decoration: const PrettyQrDecoration(
                        image: PrettyQrDecorationImage(
                          image:  AssetImage("assets/talentia_logo.png"), 
                          scale: 0.15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Scan this QR code to verify registration",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
