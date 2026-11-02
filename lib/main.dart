import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF0f1b2e),
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const QatarApp());
}

class QatarApp extends StatelessWidget {
  const QatarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2ndQatar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0f1b2e),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ─── SPLASH SCREEN ───────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.75, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f1b2e),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: '2',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFf5d97a),
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: 'nd',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 48,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: 'Qatar',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFd4a017),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 120,
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      Color(0xFFd4a017),
                      Colors.transparent,
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'بيع واشتري في قطر',
                  style: TextStyle(
                    color: Color(0xFFaabbcc),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFd4a017),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── MAIN SCREEN (WebView) ────────────────────────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isOnline = true;
  late StreamSubscription<ConnectivityResult> _connSub;

  static const String _homeUrl = 'https://2ndqatar.com/';

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connSub = Connectivity().onConnectivityChanged.listen((result) {
      final online = result != ConnectivityResult.none;
      if (mounted) {
        setState(() => _isOnline = online);
        if (online && _hasError) _reload();
      }
    });
    _initWebView();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() => _isOnline = result != ConnectivityResult.none);
    }
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0f1b2e))
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() { _isLoading = true; _hasError = false; });
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _isLoading = false);
        },
        onWebResourceError: (err) {
          if (err.isForMainFrame == true) {
            if (mounted) setState(() { _isLoading = false; _hasError = true; });
          }
        },
        onNavigationRequest: (req) {
          // open external links in browser
          final uri = Uri.tryParse(req.url);
          if (uri != null &&
              !req.url.contains('2ndqatar.com') &&
              !req.url.contains('fonts.googleapis.com') &&
              !req.url.contains('fonts.gstatic.com')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(_homeUrl));
  }

  void _reload() {
    setState(() { _hasError = false; _isLoading = true; });
    _controller.reload();
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _connSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final canGoBack = await _controller.canGoBack();
          if (canGoBack) {
            await _controller.goBack();
          } else {
            if (context.mounted) {
              SystemNavigator.pop();
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0f1b2e),
        body: SafeArea(
          child: Stack(
            children: [
              // WebView
              if (!_hasError)
                WebViewWidget(controller: _controller),

              // No internet screen
              if (_hasError || !_isOnline)
                _buildErrorScreen(),

              // Loading bar
              if (_isLoading && !_hasError)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    color: const Color(0xFFd4a017),
                    minHeight: 3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Container(
      color: const Color(0xFF0f1b2e),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📡', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 20),
              const Text(
                'لا يوجد اتصال بالإنترنت',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'تحقق من اتصالك وحاول مرة أخرى',
                style: TextStyle(color: Color(0xFFaabbcc), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _reload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFd4a017),
                  foregroundColor: const Color(0xFF0f1b2e),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
