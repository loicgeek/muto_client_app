import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadingController extends ChangeNotifier {
  bool _isLoading = false;
  String _loadingMessage = '';

  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;

  void showLoading({String message = 'Loading...'}) {
    _isLoading = true;
    _loadingMessage = message;
    notifyListeners();
  }

  void updateMessage(String message) {
    _loadingMessage = message;
    notifyListeners();
  }

  void hideLoading() {
    _isLoading = false;
    notifyListeners();
  }

  Future<T> wrapWithLoading<T>(
    Future<T> Function() task, {
    String message = 'Loading...',
  }) async {
    try {
      showLoading(message: message);
      final result = await task();
      return result;
    } catch (e) {
      hideLoading();
      rethrow;
    } finally {
      hideLoading();
    }
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;

  const LoadingOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingController>(
      builder: (context, loadingController, _) {
        return Material(
          color: Colors.black.withOpacity(0.5),
          child: Stack(
            children: [
              child,
              if (loadingController.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: GestureDetector(
                      onDoubleTap: () => loadingController.hideLoading(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            loadingController.loadingMessage,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
