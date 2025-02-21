import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // Get available cameras
  runApp(MaterialApp(home: FaceDetectionApp()));
}

class FaceDetectionApp extends StatefulWidget {
  @override
  State<FaceDetectionApp> createState() => _FaceDetectionAppState();
}

class _FaceDetectionAppState extends State<FaceDetectionApp> {
  CameraController? _cameraController; // Use nullable type
  bool _isDetecting = false;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(minFaceSize: 0.1),
  );
  List<Face> _faces = [];
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // ✅ Initialize the camera properly
  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      print("No cameras found");
      return;
    }

    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      _startFaceDetection();
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  // ✅ Face detection function
  void _startFaceDetection() {
    if (_cameraController == null) return;

    _cameraController!.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final WriteBuffer allBytes = WriteBuffer();
        for (final Plane plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();

        final InputImage inputImage = InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: InputImageRotation.rotation0deg,
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );

        final List<Face> faces = await _faceDetector.processImage(inputImage);
        if (mounted) {
          setState(() {
            _faces = faces;
          });
        }
      } catch (e) {
        print("Error detecting faces: $e");
      } finally {
        _isDetecting = false;
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Real-Time Face Detection")),
      body: (_isCameraInitialized && _cameraController != null)
          ? Stack(
        children: [
          CameraPreview(_cameraController!),
          ..._faces.map((face) {
            final left = face.boundingBox.left;
            final top = face.boundingBox.top;
            final width = face.boundingBox.width;
            final height = face.boundingBox.height;
            return Positioned(
              left: left,
              top: top,
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                ),
              ),
            );
          }).toList(),
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
