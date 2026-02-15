import 'package:dartz/dartz.dart';
import 'package:barbcut/models/subscription_model.dart';
import 'package:barbcut/services/revenuecat_service.dart';

abstract class PaymentRepository {
  Future<Either<String, void>> initialize();
  Future<Either<String, CustomerInfo>> fetchCustomerInfo();
  Future<Either<String, List<PackageModel>>> fetchAvailablePackages();
  Future<Either<String, void>> purchasePackage(PackageModel package);
  Future<Either<String, void>> restorePurchases();
  Future<Either<String, void>> logout();
}

class PaymentRepositoryImpl implements PaymentRepository {
  final RevenuecatService _revenuecatService = RevenuecatService();

  @override
  Future<Either<String, void>> initialize() async {
    try {
      await _revenuecatService.initialize();
      return const Right(null);
    } catch (e) {
      return Left('Failed to initialize payment: $e');
    }
  }

  @override
  Future<Either<String, CustomerInfo>> fetchCustomerInfo() async {
    try {
      final customerInfo = await _revenuecatService.fetchCustomerInfo();
      return Right(customerInfo);
    } catch (e) {
      return Left('Failed to fetch customer info: $e');
    }
  }

  @override
  Future<Either<String, List<PackageModel>>> fetchAvailablePackages() async {
    try {
      final packages = await _revenuecatService.fetchAvailablePackages();
      return Right(packages);
    } catch (e) {
      return Left('Failed to fetch packages: $e');
    }
  }

  @override
  Future<Either<String, void>> purchasePackage(PackageModel package) async {
    try {
      await _revenuecatService.purchasePackage(package);
      return const Right(null);
    } catch (e) {
      return Left('Purchase failed: $e');
    }
  }

  @override
  Future<Either<String, void>> restorePurchases() async {
    try {
      await _revenuecatService.restorePurchases();
      return const Right(null);
    } catch (e) {
      return Left('Failed to restore purchases: $e');
    }
  }

  @override
  Future<Either<String, void>> logout() async {
    try {
      await _revenuecatService.logout();
      return const Right(null);
    } catch (e) {
      return Left('Logout failed: $e');
    }
  }
}
