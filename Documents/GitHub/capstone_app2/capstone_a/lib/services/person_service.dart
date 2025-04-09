import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/person.dart';

class PersonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'people';

  // Get a stream of people filtered by type and userId
  Stream<List<Person>> getPeopleStream(PersonType type, String userId, String organType) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type.toString())
        .where('organType', isEqualTo: organType)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Person.fromFirestore(doc)).toList();
    });
  }

  // Get people as a one-time list
  static Future<List<Person>> getPeople({
    String? userId, 
    String? organType,
    PersonType? personType
  }) async {
    try {
      Query query = FirebaseFirestore.instance.collection('people');
      
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      
      if (organType != null) {
        query = query.where('organType', isEqualTo: organType);
      }
      
      if (personType != null) {
        query = query.where('type', isEqualTo: personType.toString());
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Person.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get people: $e');
    }
  }

  // Get patients as a one-time list
  static Future<List<Person>> getPatients({String? userId, String? organType}) async {
    try {
      Query query = FirebaseFirestore.instance.collection('people')
          .where('type', isEqualTo: PersonType.patient.toString());
      
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      
      if (organType != null) {
        query = query.where('organType', isEqualTo: organType);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Person.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get patients: $e');
    }
  }

  // Add a new person
  Future<void> addPerson(Person person) async {
    try {
      final docRef = await _firestore.collection(_collection).add(person.toFirestore());
      // Update the document with its ID
      await docRef.update({'id': docRef.id});
    } catch (e) {
      throw Exception('Failed to add person: $e');
    }
  }

  // Update an existing person
  Future<void> updatePerson(Person person) async {
    try {
      if (person.id == null) {
        throw Exception('Person ID is required for update');
      }
      await _firestore.collection(_collection).doc(person.id).update(person.toFirestore());
    } catch (e) {
      throw Exception('Failed to update person: $e');
    }
  }

  // Delete a person
  Future<void> deletePerson(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete person: $e');
    }
  }

  // Get a single person by ID
  Future<Person?> getPersonById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Person.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get person: $e');
    }
  }
} 