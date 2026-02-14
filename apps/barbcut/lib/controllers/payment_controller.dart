import 'package:flutter/foundation.dart';
import 'package:barbcut/services/revenuecat_service.dart';
import 'package:barbcut/models/subscription_model.dart';

class PaymentController extends ChangeNotifier {
  final RevenuecatService _revenuecatService = RevenuecatService();

  List<PackageModel> _availablePackages = [];
  CustomerInfo? _customerInfo;
  bool _isLoading = false;
  String? _error;

  List<PackageModel> get availablePackages => _availablePackages;
  CustomerInfo? get customerInfo => _customerInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveSubscription =>
      _customerInfo?.hasActiveSubscription ?? false;

  PaymentController() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Initialize RevenueCat
      if (!_revenuecatService.isInitialized) {
        await _revenuecatService.initialize();
      }

      // Fetch customer info and available packages
      await Future.wait([_fetchCustomerInfo(), _fetchAvailablePackages()]);

      _error = null;
    } catch (e) {
      _error = 'Failed to initialize payment system: $e';
      debugPrint('Initialization error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchCustomerInfo() async {
    try {
      _customerInfo = await _revenuecatService.fetchCustomerInfo();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching customer info: $e');
    }
  }

  Future<void> _fetchAvailablePackages() async {
    try {
      _availablePackages = await _revenuecatService.fetchAvailablePackages();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching packages: $e');
    }
  }

  Future<bool> purchasePackage(PackageModel package) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _revenuecatService.purchasePackage(package);

      // Refresh customer info after purchase
      await _fetchCustomerInfo();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Purchase failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _revenuecatService.restorePurchases();
      await _fetchCustomerInfo();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Restore purchases failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _revenuecatService.logout();
      _customerInfo = null;
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: $e';
      notifyListeners();
    }
  }

  Future<void> refreshCustomerInfo() async {
    await _fetchCustomerInfo();
  }
}
