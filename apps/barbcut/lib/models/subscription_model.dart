import 'package:equatable/equatable.dart';

class SubscriptionModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currencyCode;
  final String billingPeriod;
  final bool isActive;
  final DateTime? expirationDate;

  const SubscriptionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currencyCode,
    required this.billingPeriod,
    required this.isActive,
    this.expirationDate,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    price,
    currencyCode,
    billingPeriod,
    isActive,
    expirationDate,
  ];

  SubscriptionModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? currencyCode,
    String? billingPeriod,
    bool? isActive,
    DateTime? expirationDate,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currencyCode: currencyCode ?? this.currencyCode,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      isActive: isActive ?? this.isActive,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }
}

class CustomerInfo extends Equatable {
  final String customerId;
  final List<SubscriptionModel> subscriptions;
  final bool hasActiveSubscription;
  final DateTime? requestDate;

  const CustomerInfo({
    required this.customerId,
    required this.subscriptions,
    required this.hasActiveSubscription,
    this.requestDate,
  });

  @override
  List<Object?> get props => [
    customerId,
    subscriptions,
    hasActiveSubscription,
    requestDate,
  ];
}

class PackageModel extends Equatable {
  final String identifier;
  final String title;
  final String description;
  final double price;
  final String currencyCode;
  final String introPrice;
  final String billingPeriod;

  const PackageModel({
    required this.identifier,
    required this.title,
    required this.description,
    required this.price,
    required this.currencyCode,
    required this.introPrice,
    required this.billingPeriod,
  });

  @override
  List<Object?> get props => [
    identifier,
    title,
    description,
    price,
    currencyCode,
    introPrice,
    billingPeriod,
  ];
}
