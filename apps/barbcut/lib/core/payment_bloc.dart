import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:barbcut/models/subscription_model.dart';
import 'package:barbcut/services/revenuecat_service.dart';

// Payment Events
abstract class PaymentBlocEvent extends Equatable {
  const PaymentBlocEvent();

  @override
  List<Object?> get props => [];
}

class InitializePaymentEvent extends PaymentBlocEvent {
  const InitializePaymentEvent();
}

class FetchPackagesEvent extends PaymentBlocEvent {
  const FetchPackagesEvent();
}

class FetchCustomerInfoEvent extends PaymentBlocEvent {
  const FetchCustomerInfoEvent();
}

class PurchasePackageEvent extends PaymentBlocEvent {
  final PackageModel package;

  const PurchasePackageEvent(this.package);

  @override
  List<Object?> get props => [package];
}

class RestorePurchasesEvent extends PaymentBlocEvent {
  const RestorePurchasesEvent();
}

// Payment States
abstract class PaymentBlocState extends Equatable {
  const PaymentBlocState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentBlocState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentBlocState {
  const PaymentLoading();
}

class PaymentInitialized extends PaymentBlocState {
  final List<PackageModel> packages;
  final CustomerInfo? customerInfo;

  const PaymentInitialized({required this.packages, this.customerInfo});

  @override
  List<Object?> get props => [packages, customerInfo];
}

class PurchaseSuccess extends PaymentBlocState {
  final String message;

  const PurchaseSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PurchaseFailure extends PaymentBlocState {
  final String error;

  const PurchaseFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class RestorePurchasesSuccess extends PaymentBlocState {
  final CustomerInfo customerInfo;

  const RestorePurchasesSuccess(this.customerInfo);

  @override
  List<Object?> get props => [customerInfo];
}

class RestorePurchasesFailure extends PaymentBlocState {
  final String error;

  const RestorePurchasesFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// Payment Bloc
class PaymentBloc extends Bloc<PaymentBlocEvent, PaymentBlocState> {
  final RevenuecatService _revenuecatService = RevenuecatService();

  PaymentBloc() : super(const PaymentInitial()) {
    on<InitializePaymentEvent>(_onInitialize);
    on<FetchPackagesEvent>(_onFetchPackages);
    on<FetchCustomerInfoEvent>(_onFetchCustomerInfo);
    on<PurchasePackageEvent>(_onPurchasePackage);
    on<RestorePurchasesEvent>(_onRestorePurchases);
  }

  Future<void> _onInitialize(
    InitializePaymentEvent event,
    Emitter<PaymentBlocState> emit,
  ) async {
    try {
      emit(const PaymentLoading());

      if (!_revenuecatService.isInitialized) {
        await _revenuecatService.initialize();
      }

      final packages = await _revenuecatService.fetchAvailablePackages();
      final customerInfo = await _revenuecatService.fetchCustomerInfo();

      emit(PaymentInitialized(packages: packages, customerInfo: customerInfo));
    } catch (e) {
      emit(PurchaseFailure('Failed to initialize: $e'));
    }
  }

  Future<void> _onFetchPackages(
    FetchPackagesEvent event,
    Emitter<PaymentBlocState> emit,
  ) async {
    try {
      emit(const PaymentLoading());
      final packages = await _revenuecatService.fetchAvailablePackages();
      final customerInfo = state is PaymentInitialized
          ? (state as PaymentInitialized).customerInfo
          : null;

      emit(PaymentInitialized(packages: packages, customerInfo: customerInfo));
    } catch (e) {
      emit(PurchaseFailure('Failed to fetch packages: $e'));
    }
  }

  Future<void> _onFetchCustomerInfo(
    FetchCustomerInfoEvent event,
    Emitter<PaymentBlocState> emit,
  ) async {
    try {
      final customerInfo = await _revenuecatService.fetchCustomerInfo();
      final packages = state is PaymentInitialized
          ? (state as PaymentInitialized).packages
          : [];

      emit(PaymentInitialized(packages: packages, customerInfo: customerInfo));
    } catch (e) {
      emit(PurchaseFailure('Failed to fetch customer info: $e'));
    }
  }

  Future<void> _onPurchasePackage(
    PurchasePackageEvent event,
    Emitter<PaymentBlocState> emit,
  ) async {
    try {
      emit(const PaymentLoading());
      await _revenuecatService.purchasePackage(event.package);
      emit(const PurchaseSuccess('Purchase completed successfully!'));

      // Refresh customer info
      final customerInfo = await _revenuecatService.fetchCustomerInfo();
      emit(
        PaymentInitialized(
          packages: (state as PaymentInitialized).packages,
          customerInfo: customerInfo,
        ),
      );
    } catch (e) {
      emit(PurchaseFailure('Purchase failed: $e'));
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchasesEvent event,
    Emitter<PaymentBlocState> emit,
  ) async {
    try {
      emit(const PaymentLoading());
      await _revenuecatService.restorePurchases();
      final customerInfo = await _revenuecatService.fetchCustomerInfo();

      emit(RestorePurchasesSuccess(customerInfo));
    } catch (e) {
      emit(RestorePurchasesFailure('Failed to restore purchases: $e'));
    }
  }
}
