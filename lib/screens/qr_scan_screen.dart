import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    torchEnabled: false,
  );

  final AudioPlayer _player = AudioPlayer();

  bool _detected = false;
  bool _torchOn = false;
  CameraFacing _facing = CameraFacing.back;

  Future<void> _playBeep() async {
    await _player.setPlaybackRate(3);
    await _player.play(AssetSource('audio/beep.wav'), volume: 1.0);
  }

  void _onDetect(String value) async {
    if (_detected) return;
    _detected = true;

    await _playBeep();
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;
    Navigator.pop(context, value);
  }

  void _toggleTorch() {
    _controller.toggleTorch();
    setState(() {
      _torchOn = !_torchOn;
    });
  }

  void _switchCamera() {
    _controller.switchCamera();
    setState(() {
      _facing = _facing == CameraFacing.back
          ? CameraFacing.front
          : CameraFacing.back;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'torch') {
                _toggleTorch();
              } else if (value == 'camera') {
                _switchCamera();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'torch',
                child: Row(
                  children: [
                    Icon(_torchOn ? Icons.flash_on : Icons.flash_off, size: 20),
                    const SizedBox(width: 8),
                    Text(_torchOn ? 'Torch OFF' : 'Torch ON'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'camera',
                child: Row(
                  children: [
                    const Icon(Icons.cameraswitch, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _facing == CameraFacing.back
                          ? 'Kamera Depan'
                          : 'Kamera Belakang',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: (barcode) {
          final value = barcode.barcodes.first.rawValue;
          if (value == null || value.isEmpty) return;
          _onDetect(value);
        },
      ),
    );
  }
}
