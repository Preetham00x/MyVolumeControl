import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VolumeControlApp());
}

/// Overlay entry point - called when the overlay window is shown
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OverlayBubble(),
  ));
}

class VolumeControlApp extends StatelessWidget {
  const VolumeControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volume Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasPermission = false;
  bool _isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndStatus();
  }

  Future<void> _checkPermissionAndStatus() async {
    final hasPermission = await FlutterOverlayWindow.isPermissionGranted();
    final isActive = await FlutterOverlayWindow.isActive();
    setState(() {
      _hasPermission = hasPermission;
      _isOverlayVisible = isActive;
    });
  }

  Future<void> _requestPermission() async {
    final granted = await FlutterOverlayWindow.requestPermission();
    setState(() {
      _hasPermission = granted ?? false;
    });
  }

  Future<void> _showOverlay() async {
    if (!_hasPermission) return;
    
    await FlutterOverlayWindow.showOverlay(
      height: 200,
      width: 200,
      alignment: OverlayAlignment.centerRight,
      enableDrag: true,
      flag: OverlayFlag.focusPointer,
      positionGravity: PositionGravity.auto,
    );
    
    setState(() {
      _isOverlayVisible = true;
    });
  }

  Future<void> _closeOverlay() async {
    await FlutterOverlayWindow.closeOverlay();
    setState(() {
      _isOverlayVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Volume Control',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status indicator
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x0DFFFFFF),
                  border: Border.all(
                    color: _hasPermission
                        ? const Color(0x80673AB7)
                        : const Color(0x4D9E9E9E),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _hasPermission ? Icons.check_circle : Icons.warning_amber,
                  size: 64,
                  color: _hasPermission ? Colors.deepPurple : Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // Status text
              Text(
                _hasPermission
                    ? 'Overlay Permission Granted'
                    : 'Overlay Permission Required',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xE6FFFFFF),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _hasPermission
                    ? 'Tap to show the floating volume bubble'
                    : 'Tap below to enable "Display over other apps"',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0x80FFFFFF),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Action buttons
              if (!_hasPermission)
                _buildGlassButton(
                  onPressed: _requestPermission,
                  icon: Icons.settings,
                  label: 'Grant Permission',
                )
              else
                _buildGlassButton(
                  onPressed: _isOverlayVisible ? _closeOverlay : _showOverlay,
                  icon: _isOverlayVisible ? Icons.close : Icons.layers,
                  label: _isOverlayVisible ? 'Hide Bubble' : 'Show Bubble',
                  isPrimary: true,
                ),

              const SizedBox(height: 48),

              // Info text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0x08FFFFFF),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.touch_app, color: Color(0x66FFFFFF), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tap bubble → Show volume control',
                            style: TextStyle(fontSize: 12, color: Color(0x66FFFFFF)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.pan_tool, color: Color(0x66FFFFFF), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Drag bubble → Move anywhere',
                            style: TextStyle(fontSize: 12, color: Color(0x66FFFFFF)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.touch_app_outlined, color: Color(0x66FFFFFF), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Long press → Remove bubble',
                            style: TextStyle(fontSize: 12, color: Color(0x66FFFFFF)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0x99673AB7), Color(0x4D673AB7)],
                )
              : null,
          color: isPrimary ? null : const Color(0x1AFFFFFF),
          border: Border.all(
            color: isPrimary ? const Color(0x80673AB7) : const Color(0x1AFFFFFF),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The floating bubble overlay widget
class OverlayBubble extends StatefulWidget {
  const OverlayBubble({super.key});

  @override
  State<OverlayBubble> createState() => _OverlayBubbleState();
}

class _OverlayBubbleState extends State<OverlayBubble> {
  static const platform = MethodChannel('com.volumecontrol/volume');
  bool _showRemoveOption = false;

  Future<void> _triggerVolumeUI() async {
    try {
      await platform.invokeMethod('showVolumeUI');
    } catch (e) {
      log('Error triggering volume UI: $e');
    }
  }

  Future<void> _closeBubble() async {
    await FlutterOverlayWindow.closeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Main bubble
          GestureDetector(
            onTap: () {
              if (_showRemoveOption) {
                setState(() => _showRemoveOption = false);
              } else {
                _triggerVolumeUI();
              }
            },
            onLongPress: () {
              setState(() => _showRemoveOption = true);
            },
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // 50% opacity purple
                color: const Color(0x809C27B0),
                border: Border.all(
                  color: const Color(0x40FFFFFF),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Remove option popup (shows on long press)
          if (_showRemoveOption)
            Positioned(
              left: -60,
              top: 0,
              child: GestureDetector(
                onTap: _closeBubble,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xE6D32F2F),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Remove',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
