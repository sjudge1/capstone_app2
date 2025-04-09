import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

enum PersonType {
  patient,
  donor,
}

class Person {
  final String? id;
  final String name;
  final int? age;
  final double? weight;
  final double? height;
  final String? gender;
  final String? address;
  final String? contactNumber;
  final String? email;
  final String? bloodType;
  final String? notes;
  final String organType;
  final PersonType type;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? predictedTotalLungCapacity;
  final double? predictedLeftVentricularMass;
  final double? predictedRightVentricularMass;
  final double? predictedTotalHeartMass;

  Person({
    this.id,
    required this.name,
    this.age,
    this.weight,
    this.height,
    this.gender,
    this.address,
    this.contactNumber,
    this.email,
    this.bloodType,
    this.notes,
    required this.organType,
    required this.type,
    required this.userId,
    DateTime? createdAt,
    required this.updatedAt,
    this.predictedTotalLungCapacity,
    this.predictedLeftVentricularMass,
    this.predictedRightVentricularMass,
    this.predictedTotalHeartMass,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculate predicted values based on gender, height, weight, and age
  static double? calculatePredictedTotalLungCapacity(String gender, double heightInMeters) {
    if (gender.toLowerCase() == 'male') {
      return (7.99 * heightInMeters) - 7.08;
    } else if (gender.toLowerCase() == 'female') {
      return (6.60 * heightInMeters) - 5.79;
    }
    return null;
  }

  static double? calculatePredictedLeftVentricularMass(String gender, double heightInMeters, double weightInKg) {
    final a = gender.toLowerCase() == 'female' ? 6.82 : 8.25;
    return a * pow(heightInMeters, 0.54) * pow(weightInKg, 0.61);
  }

  static double? calculatePredictedRightVentricularMass(String gender, int age, double heightInMeters, double weightInKg) {
    final a = gender.toLowerCase() == 'female' ? 10.59 : 11.25;
    return a * pow(age.toDouble(), -0.32) * pow(heightInMeters, 1.135) * pow(weightInKg, 0.315);
  }

  // Create a new Person with calculated predictions
  factory Person.create({
    required String name,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? address,
    String? contactNumber,
    String? email,
    String? bloodType,
    String? notes,
    required String organType,
    required PersonType type,
    required String userId,
  }) {
    final now = DateTime.now();
    double? pTLC;
    double? pLVM;
    double? pRVM;
    double? pTHM;

    // Calculate predictions if we have all required values
    if (gender != null && height != null) {
      final heightInMeters = height / 100; // Convert cm to meters
      if (organType == 'lung') {
        pTLC = calculatePredictedTotalLungCapacity(gender, heightInMeters);
      } else if (organType == 'heart' && weight != null && age != null) {
        pLVM = calculatePredictedLeftVentricularMass(gender, heightInMeters, weight);
        pRVM = calculatePredictedRightVentricularMass(gender, age, heightInMeters, weight);
        pTHM = (pLVM ?? 0) + (pRVM ?? 0);
      }
    }

    return Person(
      id: '', // Will be set by Firestore
      name: name,
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      address: address,
      contactNumber: contactNumber,
      email: email,
      bloodType: bloodType,
      notes: notes,
      organType: organType,
      type: type,
      userId: userId,
      createdAt: now,
      updatedAt: now,
      predictedTotalLungCapacity: pTLC,
      predictedLeftVentricularMass: pLVM,
      predictedRightVentricularMass: pRVM,
      predictedTotalHeartMass: pTHM,
    );
  }

  // Create a Person from Firestore data
  factory Person.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Person(
      id: doc.id,
      name: data['name'] ?? '',
      age: data['age'],
      weight: data['weight']?.toDouble(),
      height: data['height']?.toDouble(),
      gender: data['gender'],
      address: data['address'],
      contactNumber: data['contactNumber'],
      email: data['email'],
      bloodType: data['bloodType'],
      notes: data['notes'],
      organType: data['organType'] ?? '',
      type: PersonType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => PersonType.patient,
      ),
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      predictedTotalLungCapacity: data['predictedTotalLungCapacity']?.toDouble(),
      predictedLeftVentricularMass: data['predictedLeftVentricularMass']?.toDouble(),
      predictedRightVentricularMass: data['predictedRightVentricularMass']?.toDouble(),
      predictedTotalHeartMass: data['predictedTotalHeartMass']?.toDouble(),
    );
  }

  // Convert Person to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'address': address,
      'contactNumber': contactNumber,
      'email': email,
      'bloodType': bloodType,
      'notes': notes,
      'organType': organType,
      'type': type.toString(),
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'predictedTotalLungCapacity': predictedTotalLungCapacity,
      'predictedLeftVentricularMass': predictedLeftVentricularMass,
      'predictedRightVentricularMass': predictedRightVentricularMass,
      'predictedTotalHeartMass': predictedTotalHeartMass,
    };
  }

  // Create a copy of this Person with some fields replaced
  Person copyWith({
    String? id,
    String? name,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? address,
    String? contactNumber,
    String? email,
    String? bloodType,
    String? notes,
    String? organType,
    PersonType? type,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? predictedTotalLungCapacity,
    double? predictedLeftVentricularMass,
    double? predictedRightVentricularMass,
    double? predictedTotalHeartMass,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      bloodType: bloodType ?? this.bloodType,
      notes: notes ?? this.notes,
      organType: organType ?? this.organType,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      predictedTotalLungCapacity: predictedTotalLungCapacity ?? this.predictedTotalLungCapacity,
      predictedLeftVentricularMass: predictedLeftVentricularMass ?? this.predictedLeftVentricularMass,
      predictedRightVentricularMass: predictedRightVentricularMass ?? this.predictedRightVentricularMass,
      predictedTotalHeartMass: predictedTotalHeartMass ?? this.predictedTotalHeartMass,
    );
  }

  // Validate required fields based on organ type
  bool isValid() {
    if (name.isEmpty) return false;
    if (organType.isEmpty) return false;
    if (userId.isEmpty) return false;
    
    if (organType == 'heart') {
      // For heart patients/donors: name, age, weight, height, gender are required
      return age != null && weight != null && height != null && gender != null && gender!.isNotEmpty;
    } else if (organType == 'lung') {
      // For lung patients/donors: name, gender, height are required
      return gender != null && gender!.isNotEmpty && height != null;
    }
    
    return false;
  }

  // Get validation error message
  String? getValidationError() {
    if (name.isEmpty) return 'Name is required';
    if (organType.isEmpty) return 'Organ type is required';
    if (userId.isEmpty) return 'User ID is required';
    
    if (organType == 'heart') {
      if (age == null) return 'Age is required for heart patients/donors';
      if (weight == null) return 'Weight is required for heart patients/donors';
      if (height == null) return 'Height is required for heart patients/donors';
      if (gender == null || gender!.isEmpty) return 'Gender is required for heart patients/donors';
    } else if (organType == 'lung') {
      if (gender == null || gender!.isEmpty) return 'Gender is required for lung patients/donors';
      if (height == null) return 'Height is required for lung patients/donors';
    }
    
    return null;
  }
} 