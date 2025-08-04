import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/utils/constants.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/pest_result_card.dart';
import '../widgets/treatment_recommendation_card.dart';

class PestDetectionScreen extends StatefulWidget {
  const PestDetectionScreen({super.key});

  @override
  State<PestDetectionScreen> createState() => _PestDetectionScreenState();
}

class _PestDetectionScreenState extends State<PestDetectionScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isAnalyzing = false;
  File? _capturedImage;
  List<dynamic>? _detectionResults;
  String? _selectedPest;
  Map<String, dynamic>? _treatmentRecommendation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _loadModel() async {
    try {
      // Load TensorFlow Lite model for pest detection
      // This would be a custom trained model for African crop pests
      await Tflite.loadModel(
        model: "assets/ml_models/pest_detection_model.tflite",
        labels: "assets/ml_models/pest_labels.txt",
      );
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_isCameraInitialized) return;

    try {
      setState(() {
        _isAnalyzing = true;
      });

      final XFile image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = File(image.path);
      });

      await _analyzeImage();
    } catch (e) {
      debugPrint('Error capturing image: $e');
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      setState(() {
        _isAnalyzing = true;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });
        await _analyzeImage();
      } else {
        setState(() {
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_capturedImage == null) return;

    try {
      // Convert image to bytes for TensorFlow Lite
      final Uint8List imageBytes = await _capturedImage!.readAsBytes();
      
      // Run inference on the image
      final List<dynamic>? results = await Tflite.runModelOnBinary(
        binary: imageBytes,
        numResults: 5,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      if (results != null && results.isNotEmpty) {
        setState(() {
          _detectionResults = results;
          _selectedPest = results[0]['label'];
        });

        // Get treatment recommendations
        await _getTreatmentRecommendation(_selectedPest!);
      }
    } catch (e) {
      debugPrint('Error analyzing image: $e');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _getTreatmentRecommendation(String pestName) async {
    // This would typically call an API to get treatment recommendations
    // For now, we'll use mock data
    final Map<String, Map<String, dynamic>> treatmentData = {
      'Aphids': {
        'severity': 'Medium',
        'treatments': [
          {
            'name': 'Neem Oil Spray',
            'description': 'Natural insecticide made from neem tree',
            'application': 'Spray every 7-10 days',
            'cost': 'Low',
            'effectiveness': 'High',
          },
          {
            'name': 'Ladybug Release',
            'description': 'Biological control using beneficial insects',
            'application': 'Release 1000 ladybugs per hectare',
            'cost': 'Medium',
            'effectiveness': 'Very High',
          },
        ],
        'prevention': [
          'Plant companion crops like marigolds',
          'Use reflective mulch',
          'Regular monitoring and early detection',
        ],
      },
      'Spider Mites': {
        'severity': 'High',
        'treatments': [
          {
            'name': 'Horticultural Oil',
            'description': 'Suffocates mites by coating them',
            'application': 'Spray thoroughly, especially under leaves',
            'cost': 'Low',
            'effectiveness': 'High',
          },
          {
            'name': 'Predatory Mites',
            'description': 'Natural enemies of spider mites',
            'application': 'Release 5000 predatory mites per hectare',
            'cost': 'High',
            'effectiveness': 'Very High',
          },
        ],
        'prevention': [
          'Maintain proper humidity levels',
          'Avoid over-fertilization',
          'Regular plant inspection',
        ],
      },
    };

    setState(() {
      _treatmentRecommendation = treatmentData[pestName] ?? {
        'severity': 'Unknown',
        'treatments': [],
        'prevention': [],
      };
    });
  }

  void _resetDetection() {
    setState(() {
      _capturedImage = null;
      _detectionResults = null;
      _selectedPest = null;
      _treatmentRecommendation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Pest Detection'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to detection history
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera Preview Section
          if (_capturedImage == null) ...[
            Expanded(
              flex: 2,
              child: _isCameraInitialized
                  ? CameraPreviewWidget(
                      cameraController: _cameraController!,
                      onCapture: _captureImage,
                      onGalleryPick: _pickImageFromGallery,
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ] else ...[
            // Captured Image Section
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.file(
                        _capturedImage!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      if (_isAnalyzing)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Analyzing image...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _resetDetection,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                // Share detection results
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Results Section
          if (_detectionResults != null) ...[
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Detection Results
                    Text(
                      'Detection Results',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Top Detection Result
                    if (_selectedPest != null)
                      PestResultCard(
                        pestName: _selectedPest!,
                        confidence: _detectionResults![0]['confidence'],
                        severity: _treatmentRecommendation?['severity'] ?? 'Unknown',
                        onTap: () {
                          // Show detailed pest information
                        },
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Other Detections
                    if (_detectionResults!.length > 1) ...[
                      Text(
                        'Other Possible Matches',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._detectionResults!.skip(1).map((result) => 
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              '${(result['confidence'] * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          title: Text(result['label']),
                          subtitle: Text(
                            'Confidence: ${(result['confidence'] * 100).toStringAsFixed(1)}%',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            setState(() {
                              _selectedPest = result['label'];
                            });
                            _getTreatmentRecommendation(_selectedPest!);
                          },
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Treatment Recommendations
                    if (_treatmentRecommendation != null) ...[
                      Text(
                        'Treatment Recommendations',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TreatmentRecommendationCard(
                        recommendation: _treatmentRecommendation!,
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Save detection to history
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Save Detection'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Share with agronomist
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Instructions Section
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 64,
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Point your camera at the affected plant',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Make sure the pest or damage is clearly visible in the frame',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 