import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class FullScreenCameraPage extends StatefulWidget {
  const FullScreenCameraPage({Key? key}) : super(key: key);

  @override
  State<FullScreenCameraPage> createState() => _FullScreenCameraPageState();
}

class _FullScreenCameraPageState extends State<FullScreenCameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraReady = false;
  bool _isTakingPicture = false;
  bool _isFrontCamera = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Set preferred orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Allow all orientations again
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes to properly manage camera resources
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() {
        _isCameraReady = false;
      });
      return;
    }

    // Select front camera as this is for selfie
    final CameraDescription camera = cameras.firstWhere(
      (camera) => camera.lensDirection == 
          (_isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.high, // High quality for profile photo
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      setState(() {
        _isCameraReady = true;
      });
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isTakingPicture) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      // Play shutter sound or show visual feedback here
      
      final XFile file = await _controller!.takePicture();
      
      // Return the captured image file to the previous screen
      Navigator.pop(context, File(file.path));
    } catch (e) {
      print('Failed to take picture: $e');
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  void _switchCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isCameraReady = false;
    });
    
    await _controller?.dispose();
    _controller = null;
    await _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    // Full immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview that fills the entire screen
          if (_controller != null && _isCameraReady)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            ),
          
          // Loading indicator
          if (!_isCameraReady)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          
          // Guidance overlay for face positioning
          if (_isCameraReady)
            Positioned.fill(
              child: CustomPaint(
                painter: FaceOverlayPainter(),
              ),
            ),
          
          // Top control bar
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  
                  // Camera flip button
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios, color: AppColors.white, size: 28),
                    onPressed: _switchCamera,
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom controls and instructions
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Capture button
                GestureDetector(
                  onTap: _isCameraReady ? _takePicture : null,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                    ),
                    child: Center(
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Instructions text
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Position your face within the circle and look straight ahead',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Face overlay helper
class FaceOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint guidelinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw a circle in the center for face positioning
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.4; // Large enough for a face
    
    // Draw guiding circle
    canvas.drawCircle(Offset(centerX, centerY), radius, guidelinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}