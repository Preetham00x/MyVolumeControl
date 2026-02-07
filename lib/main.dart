import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:system_alert_window/system_alert_window.dart';

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
      gravity: SystemWindowGravity.RIGHT,
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
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: _hasPermission
                        ? Colors.deepPurple.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.3),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _hasPermission
                    ? 'You can now use the floating volume control'
                    : 'Tap below to enable "Display over other apps"',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Action buttons
              if (!_hasPermission) ...[
                _buildGlassButton(
                  onPressed: _requestPermission,
                  icon: Icons.settings,
                  label: 'Grant Permission',
                ),
              ] else ...[
                _buildGlassButton(
                  onPressed: _isOverlayVisible ? _closeOverlay : _showOverlay,
                  icon: _isOverlayVisible ? Icons.close : Icons.layers,
                  label: _isOverlayVisible ? 'Hide Bubble' : 'Show Bubble',
                  isPrimary: true,
                ),
              ],
              
              const SizedBox(height: 48),
              
              // Info text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.03),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white.withOpacity(0.4),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The bubble will stay on top of other apps. Tap it to control volume.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.4),
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
              ? LinearGradient(
                  colors: [
                    Colors.deepPurple.withOpacity(0.6),
                    Colors.deepPurple.withOpacity(0.3),
                  ],
                )
              : null,
          color: isPrimary ? null : Colors.white.withOpacity(0.1),
          border: Border.all(
            color: isPrimary
                ? Colors.deepPurple.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
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
    // Volume controller will be initialized in the overlay
    // For now, we start with a default value
    setState(() {
      _currentVolume = 0.5;
    });
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
            borderRadius: BorderRadius.circular(_isExpanded ? 30 : 30),
            color: Colors.black.withOpacity(0.3),
            border: Border.all(
              color: Colors.deepPurple.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.2),
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
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
                              inactiveTrackColor: Colors.white.withOpacity(0.2),
                              thumbColor: Colors.white,
                              overlayColor: Colors.deepPurple.withOpacity(0.2),
                            ),
                            child: Slider(
                              value: _currentVolume,
                              onChanged: (value) {
                                setState(() {
                                  _currentVolume = value;
                                });
                                // Volume control would be applied here
                                // VolumeController.instance.setVolume(value);
                              },
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.deepPurple.withOpacity(0.6),
                            Colors.deepPurple.withOpacity(0.2),
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
