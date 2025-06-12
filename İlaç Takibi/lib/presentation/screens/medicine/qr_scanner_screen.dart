import 'package:flutter/cupertino.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_theme.dart';

class QRScannerScreen extends StatefulWidget {
  final Function(String) onQRCodeScanned;

  const QRScannerScreen({
    super.key,
    required this.onQRCodeScanned,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isScanning = true;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('QR Kod Tara'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.xmark),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: _buildQRView(),
            ),
            Expanded(
              flex: 1,
              child: _buildControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRView() {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: AppColors.primaryBlue,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 250,
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'QR kodu tarayın',
            style: AppTheme.headline3.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlaç bilgilerini otomatik olarak dolduracak',
            style: AppTheme.body2.copyWith(
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoButton(
                onPressed: () async {
                  await controller?.toggleFlash();
                },
                child: const Icon(
                  CupertinoIcons.lightbulb,
                  size: 24,
                  color: AppColors.primaryBlue,
                ),
              ),
              CupertinoButton(
                onPressed: () async {
                  await controller?.flipCamera();
                },
                child: const Icon(
                  CupertinoIcons.camera_rotate,
                  size: 24,
                  color: AppColors.primaryBlue,
                ),
              ),
              CupertinoButton(
                onPressed: () {
                  setState(() {
                    _isScanning = !_isScanning;
                  });
                  if (_isScanning) {
                    controller?.resumeCamera();
                  } else {
                    controller?.pauseCamera();
                  }
                },
                child: Icon(
                  _isScanning 
                      ? CupertinoIcons.pause
                      : CupertinoIcons.play,
                  size: 24,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        _handleScannedCode(scanData.code!);
      }
    });
  }

  void _handleScannedCode(String code) {
    // QR kod formatı: MEDICINE|name|dosage|dosageUnit|frequency|category
    try {
      final parts = code.split('|');
      if (parts.length >= 6 && parts[0] == 'MEDICINE') {
        final medicineData = {
          'name': parts[1],
          'dosage': parts[2],
          'dosageUnit': parts[3],
          'frequency': parts[4],
          'category': parts[5],
        };
        
        widget.onQRCodeScanned(code);
        Navigator.of(context).pop();
      } else {
        _showErrorDialog('Geçersiz QR kod formatı');
      }
    } catch (e) {
      _showErrorDialog('QR kod okunamadı: $e');
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('Tamam'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
} 