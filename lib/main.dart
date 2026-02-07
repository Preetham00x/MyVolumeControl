import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:volume_controller/volume_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VolumeControlApp());
}

/// Overlay entry point - this is called when the overlay window is shown
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: VolumeOverlayWidget(),
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
    _checkPermission();
    _setupOverlayListener();
  }

  Future<void> _checkPermission() async {
    final bool? status = await SystemAlertWindow.checkPermissions(
      prefMode: SystemWindowPrefMode.OVERLAY,
    );
    setState(() {
      _hasPermission = status ?? false;
    });
  }

  void _setupOverlayListener() {
    SystemAlertWindow.overlayListener.listen((event) {
      log("Overlay Event: $event");
    });
  }

  Future<void> _requestPermission() async {
    await SystemAlertWindow.requestPermissions(
      prefMode: SystemWindowPrefMode.OVERLAY,
    );
    await _checkPermission();
  }

  Future<void> _showOverlay() async {
    await SystemAlertWindow.showSystemWindow(
      height: 300,
      width: 80,
      gravity: SystemWindowGravity.TRAILING,
      prefMode: SystemWindowPrefMode.OVERLAY,
    );
    setState(() {
      _isOverlayVisible = true;
    });
  }

  Future<void> _closeOverlay() async {
    await SystemAlertWindow.closeSystemWindow();
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
                  color: const Color(0x0DFFFFFF), // white 5%
                  border: Border.all(
                    color: _hasPermission
                        ? const Color(0x80673AB7) // deepPurple 50%
                        : const Color(0x4D9E9E9E), // grey 30%
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
                  color: Color(0xE6FFFFFF), // white 90%
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _hasPermission
                    ? 'You can now use the floating volume control'
                    : 'Tap below to enable "Display over other apps"',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0x80FFFFFF), // white 50%
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
                  color: const Color(0x08FFFFFF), // white 3%
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0x66FFFFFF), // white 40%
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The bubble will stay on top of other apps. Tap it to control volume.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0x66FFFFFF), // white 40%
                        ),
                      ),
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
                  colors: [
                    Color(0x99673AB7), // deepPurple 60%
                    Color(0x4D673AB7), // deepPurple 30%
                  ],
                )
              : null,
          color: isPrimary ? null : const Color(0x1AFFFFFF), // white 10%
          border: Border.all(
            color: isPrimary
                ? const Color(0x80673AB7) // deepPurple 50%
                : const Color(0x1AFFFFFF), // white 10%
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

/// The overlay widget that appears on top of other apps
class VolumeOverlayWidget extends StatefulWidget {
  const VolumeOverlayWidget({super.key});

  @override
  State<VolumeOverlayWidget> createState() => _VolumeOverlayWidgetState();
}

class _VolumeOverlayWidgetState extends State<VolumeOverlayWidget> {
  bool _isExpanded = false;
  double _currentVolume = 0.5;

  @override
  void initState() {
    super.initState();
    _initVolume();
  }

  Future<void> _initVolume() async {
    try {
      final volume = await VolumeController.instance.getVolume();
      setState(() {
        _currentVolume = volume;
      });
    } catch (e) {
      log("Error getting volume: $e");
    }

    // Listen for volume changes
    VolumeController.instance.addListener((volume) {
      setState(() {
        _currentVolume = volume;
      });
    });
  }

  @override
  void dispose() {
    VolumeController.instance.removeListener();
    super.dispose();
  }

  Future<void> _setVolume(double value) async {
    setState(() {
      _currentVolume = value;
    });
    await VolumeController.instance.setVolume(value);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 60,
          height: _isExpanded ? 250 : 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: const Color(0x4D000000), // black 30%
            border: Border.all(
              color: const Color(0x66673AB7), // deepPurple 40%
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33673AB7), // deepPurple 20%
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                // Frosted glass effect background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x26FFFFFF), // white 15%
                        Color(0x0DFFFFFF), // white 5%
                      ],
                    ),
                  ),
                ),
                // Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isExpanded) ...[
                      const SizedBox(height: 16),
                      // Volume slider
                      Expanded(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16,
                              ),
                              activeTrackColor: Colors.deepPurple,
                              inactiveTrackColor:
                                  const Color(0x33FFFFFF), // white 20%
                              thumbColor: Colors.white,
                              overlayColor:
                                  const Color(0x33673AB7), // deepPurple 20%
                            ),
                            child: Slider(
                              value: _currentVolume,
                              onChanged: _setVolume,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Bubble indicator (always visible)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0x99673AB7), // deepPurple 60%
                            Color(0x33673AB7), // deepPurple 20%
                          ],
                        ),
                      ),
                    ),
                    if (_isExpanded) const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
