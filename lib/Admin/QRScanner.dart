import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:talentia/Admin/ScannedDetailsPage.dart';

class Qrscannerpage extends StatefulWidget {
  const Qrscannerpage({super.key});

  @override
  State<Qrscannerpage> createState() => _QrscannerpageState();
}

class _QrscannerpageState extends State<Qrscannerpage> with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    returnImage: false, // No need to return an image
    facing: CameraFacing.back,
    formats: [BarcodeFormat.qrCode],
  );

  late AnimationController _animationController;
  late Animation<double> _lineAnimation;

  bool isNavigating = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);

    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  void _processScannedData(String scannedData) {
    if (!isNavigating) {
      isNavigating = true;
      _controller.stop(); // Stop scanning
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegistrationDetailsPage(regID: scannedData),
        ),
      ).then((_) {
        isNavigating = false;
        _controller.start(); // Restart scanning when returning
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null && !isNavigating) {
                _processScannedData(barcodes.first.rawValue!);
              }
            },
          ),

          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _lineAnimation,
            builder: (_, __) {
              return Positioned(
                top: MediaQuery.of(context).size.height / 2 - 125 + (125 * _lineAnimation.value),
                left: MediaQuery.of(context).size.width / 2 - 125,
                child: Container(
                  width: 250,
                  height: 4,
                  color: Colors.blueAccent.withOpacity(0.6),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.start();
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
