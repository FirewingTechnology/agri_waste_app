# 🚀 Implementation Checklist for Next Developer

## 🎯 Quick Start Guide

This document helps you complete the remaining Firebase integration and testing.

---

## 📋 PHASE 1: Firebase Setup (30 minutes)

### 1. Firebase Console Configuration

**Steps:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create/Select your project
3. Enable services:
   - [ ] Authentication (Email/Password)
   - [ ] Cloud Firestore
   - [ ] Cloud Messaging (for notifications)
   - [ ] Cloud Storage (optional, for images)

### 2. Download Configuration Files

**Android:**
```bash
# Download google-services.json
# Place in: android/app/google-services.json
```

**iOS:**
```bash
# Download GoogleService-Info.plist
# Place in: ios/Runner/GoogleService-Info.plist
```

### 3. Update Firebase Dependencies

Already in `pubspec.yaml`, just verify:
```yaml
dependencies:
  firebase_core: ^2.32.0
  firebase_auth: ^4.20.0
  cloud_firestore: ^4.17.5
```

### 4. Initialize Firebase in main.dart

```dart
// ALREADY DONE - Just uncomment when ready:
// import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Uncomment this:
  // await Firebase.initializeApp();
  
  await LocalStorageService().init();
  runApp(const AgriWasteApp());
}
```

---

## 📋 PHASE 2: Authentication Service (1 hour)

### File: `lib/services/auth_service.dart`

**TODO: Uncomment and complete**

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // UNCOMMENT AND TEST:
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      // 1. Create Firebase user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Create Firestore document
      await FirestoreService().createUser(
        UserModel(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          phone: phone,
          role: role,
          verified: false, // Needs admin approval
          rating: 0.0,
          ratingCount: 0,
          createdAt: DateTime.now(),
        ),
      );

      return {
        'success': true,
        'message': 'Account created successfully',
        'userId': userCredential.user!.uid,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
  
  // Similar for signIn(), signOut(), etc.
}
```

**Testing:**
- [ ] Register new user
- [ ] Login with credentials
- [ ] Logout
- [ ] Password reset

---

## 📋 PHASE 3: Firestore Service (2 hours)

### File: `lib/services/firestore_service.dart`

**TODO: Uncomment Firebase imports**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Example: Create User
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toJson());
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }
  
  // Example: Get Waste Posts
  Future<List<WasteModel>> getAvailableWastePosts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.wasteCollection)
          .where('status', isEqualTo: 'available')
          .where('isBiddingEnabled', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => WasteModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching waste posts: $e');
    }
  }
}
```

**Complete these methods:**
- [ ] `createUser()` ✓ (example above)
- [ ] `getUser()`
- [ ] `updateUser()`
- [ ] `createWastePost()`
- [ ] `getAvailableWastePosts()` ✓ (example above)
- [ ] `createBid()`
- [ ] `getBidsForWaste()`
- [ ] `createOrder()`
- [ ] `updateOrderStatus()`

---

## 📋 PHASE 4: Bid Service Integration (1 hour)

### File: `lib/services/bid_service.dart`

**Use the new BiddingEvaluationService:**

```dart
import 'bidding_evaluation_service.dart';

class BidService {
  final BiddingEvaluationService _evaluationService = BiddingEvaluationService();
  
  Future<void> placeBid(BidModel bid, UserModel manufacturer, WasteModel wastePost) async {
    // 1. Validate manufacturer eligibility
    if (!_evaluationService.isManufacturerEligibleToBid(manufacturer)) {
      throw Exception('Manufacturer not eligible to bid');
    }
    
    // 2. Validate bid amount
    if (!_evaluationService.isBidAmountValid(bid.bidAmount, wastePost)) {
      throw Exception('Bid amount out of valid range');
    }
    
    // 3. Save bid to Firestore
    await FirestoreService().createBid(bid);
    
    // 4. Update waste post bid count
    await FirestoreService().incrementBidCount(wastePost.id);
  }
  
  Future<List<BidWithScore>> getRankedBidsForWaste(String wastePostId) async {
    // 1. Get all bids for this waste post
    List<BidModel> bids = await FirestoreService().getBidsForWaste(wastePostId);
    
    // 2. Get manufacturer details for each bid
    Map<String, UserModel> manufacturers = {};
    for (var bid in bids) {
      UserModel? manufacturer = await FirestoreService().getUser(bid.bidderId);
      if (manufacturer != null) {
        manufacturers[bid.bidderId] = manufacturer;
      }
    }
    
    // 3. Get waste post
    WasteModel? wastePost = await FirestoreService().getWastePost(wastePostId);
    
    // 4. Evaluate and rank bids
    return await _evaluationService.evaluateAndRankBids(
      bids: bids,
      manufacturers: manufacturers,
      wastePost: wastePost!,
    );
  }
}
```

**Testing:**
- [ ] Place bid as manufacturer
- [ ] View bids as farmer
- [ ] See bid scores
- [ ] Accept top bid

---

## 📋 PHASE 5: Admin Dashboard Integration (1 hour)

### File: `lib/admin/admin_dashboard.dart`

**Complete User Verification:**

```dart
// In _UserVerificationTabState:

Future<void> _loadPendingUsers() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Get unverified users from Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .where('verified', isEqualTo: false)
        .get();
    
    _pendingUsers = snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();

    setState(() {
      _isLoading = false;
    });
  } catch (e) {
    // Handle error
  }
}

Future<void> _verifyUser(UserModel user, bool approve) async {
  try {
    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .update({
          'verified': approve,
          'updatedAt': DateTime.now().toIso8601String(),
        });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve ? 'User approved ✅' : 'User rejected ❌'),
          backgroundColor: approve ? Colors.green : Colors.red,
        ),
      );
      _loadPendingUsers();
    }
  } catch (e) {
    // Handle error
  }
}
```

**Testing:**
- [ ] View pending users
- [ ] Approve user
- [ ] Reject user
- [ ] User can access system after approval

---

## 📋 PHASE 6: Location & Distance (30 minutes)

### File: `lib/delivery/delivery_service.dart`

**Already has basic structure, just integrate:**

```dart
import 'package:geolocator/geolocator.dart';
import '../services/bidding_evaluation_service.dart';

class DeliveryService {
  final BiddingEvaluationService _evaluationService = BiddingEvaluationService();
  
  Future<double> calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    // Use Geolocator to calculate distance
    double distanceInMeters = Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
    
    return distanceInMeters / 1000; // Convert to km
  }
  
  Future<double> calculateDeliveryCharge(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    double distance = await calculateDistance(startLat, startLng, endLat, endLng);
    return _evaluationService.calculateDeliveryCharge(distance);
  }
}
```

**Testing:**
- [ ] Calculate distance between two locations
- [ ] Calculate delivery charge
- [ ] Handle max distance exceeded

---

## 📋 PHASE 7: Order State Management (1 hour)

### Create Order State Service

**New File: `lib/services/order_state_service.dart`**

```dart
import '../models/order_model.dart';
import '../core/constants/app_constants.dart';
import 'firestore_service.dart';

class OrderStateService {
  final FirestoreService _firestoreService = FirestoreService();
  
  Future<void> acceptOrder(String orderId) async {
    await _updateOrderStatus(orderId, AppConstants.orderAccepted);
  }
  
  Future<void> pickupOrder(String orderId) async {
    await _updateOrderStatus(orderId, AppConstants.orderPicked);
  }
  
  Future<void> deliverOrder(String orderId) async {
    await _updateOrderStatus(orderId, AppConstants.orderDelivered);
  }
  
  Future<void> completeOrder(String orderId, double rating) async {
    // 1. Update order status
    await _updateOrderStatus(orderId, AppConstants.orderCompleted);
    
    // 2. Update manufacturer rating
    // (fetch order, get manufacturer, update rating)
  }
  
  Future<void> cancelOrder(String orderId) async {
    await _updateOrderStatus(orderId, AppConstants.orderCancelled);
  }
  
  Future<void> _updateOrderStatus(String orderId, String status) async {
    await _firestoreService.updateOrder(orderId, {
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
  
  bool canTransitionTo(String currentStatus, String newStatus) {
    // Define valid state transitions
    const validTransitions = {
      AppConstants.orderPosted: [AppConstants.orderAccepted, AppConstants.orderCancelled],
      AppConstants.orderAccepted: [AppConstants.orderPicked, AppConstants.orderCancelled],
      AppConstants.orderPicked: [AppConstants.orderDelivered],
      AppConstants.orderDelivered: [AppConstants.orderCompleted],
    };
    
    return validTransitions[currentStatus]?.contains(newStatus) ?? false;
  }
}
```

**Testing:**
- [ ] Create order (Posted)
- [ ] Accept order (Accepted)
- [ ] Pickup order (Picked)
- [ ] Deliver order (Delivered)
- [ ] Complete order (Completed)
- [ ] Test invalid transitions

---

## 📋 PHASE 8: Notifications (Optional - 2 hours)

### File: `lib/services/notification_service.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  Future<void> initialize() async {
    // Request permission
    await _fcm.requestPermission();
    
    // Get FCM token
    String? token = await _fcm.getToken();
    print('FCM Token: $token');
    
    // Save token to user document in Firestore
    
    // Listen for messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground notifications
    });
  }
  
  Future<void> sendBidNotification(String farmerId, BidModel bid) async {
    // Send notification to farmer about new bid
  }
  
  Future<void> sendOrderNotification(String userId, String orderId, String status) async {
    // Send notification about order status change
  }
}
```

---

## 📋 PHASE 9: Testing Checklist

### User Registration & Login
- [ ] Register as Farmer
- [ ] Register as Manufacturer
- [ ] Register as Admin
- [ ] Login with each role
- [ ] Logout

### Farmer Flow
- [ ] Post waste (with location)
- [ ] View bids on waste post
- [ ] See bid rankings
- [ ] Accept a bid
- [ ] Browse fertilizers
- [ ] Buy fertilizer
- [ ] View history

### Manufacturer Flow
- [ ] Browse available waste
- [ ] Place bid on waste
- [ ] View bid status
- [ ] Accept waste order
- [ ] Post fertilizer
- [ ] View orders
- [ ] Track deliveries

### Admin Flow
- [ ] View pending users
- [ ] Approve user
- [ ] Reject user
- [ ] View bidding logs
- [ ] View payment logs
- [ ] View notification logs

### Bidding System
- [ ] Multiple manufacturers bid on same waste
- [ ] Bids are scored correctly
- [ ] Farmer sees ranked bids
- [ ] Recommendations make sense
- [ ] Only verified manufacturers can bid

### Order States
- [ ] Order goes Posted → Accepted
- [ ] Order goes Accepted → Picked
- [ ] Order goes Picked → Delivered
- [ ] Order goes Delivered → Completed
- [ ] Order can be Cancelled (before Picked)

### Delivery Charges
- [ ] Distance calculated correctly
- [ ] Minimum charge applied (₹50)
- [ ] Per-km charge correct (₹15/km)
- [ ] Max distance enforced (100 km)

### Language Selection
- [ ] Switch to Hindi
- [ ] Switch to Marathi
- [ ] Switch to English
- [ ] Language persists on restart

---

## 📋 PHASE 10: Production Deployment

### Pre-Deployment Checklist
- [ ] All TODO comments addressed
- [ ] Firebase fully integrated
- [ ] All features tested
- [ ] Error handling in place
- [ ] Loading states implemented
- [ ] Images optimized
- [ ] App icon updated
- [ ] Splash screen customized

### Build & Release
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

### App Store Preparation
- [ ] Screenshots (5-10 per platform)
- [ ] App description
- [ ] Privacy policy
- [ ] Terms of service
- [ ] Support email

---

## 🎯 PRIORITY ORDER

If short on time, implement in this order:

1. **Firebase Setup** (MUST HAVE)
2. **Authentication Service** (MUST HAVE)
3. **Firestore Service** (MUST HAVE)
4. **Bid Service** (MUST HAVE)
5. **Order States** (SHOULD HAVE)
6. **Admin Verification** (SHOULD HAVE)
7. **Location/Distance** (NICE TO HAVE)
8. **Notifications** (NICE TO HAVE)

---

## 📞 QUICK REFERENCE

### Important Files to Edit:

```
Priority 1 (Firebase Integration):
✓ lib/main.dart (initialize Firebase)
✓ lib/services/auth_service.dart
✓ lib/services/firestore_service.dart

Priority 2 (Core Features):
✓ lib/services/bid_service.dart
✓ lib/admin/admin_dashboard.dart
✓ lib/services/order_state_service.dart (new)

Priority 3 (Polish):
✓ lib/delivery/delivery_service.dart
✓ lib/services/notification_service.dart (new)
```

---

## 🐛 Common Issues & Solutions

### Issue: Firebase not initialized
**Solution**: Uncomment `await Firebase.initializeApp()` in main.dart

### Issue: Cannot read from Firestore
**Solution**: Check Firestore security rules, ensure user is authenticated

### Issue: Location permission denied
**Solution**: Add permissions to AndroidManifest.xml and Info.plist

### Issue: Build fails
**Solution**: Run `flutter clean` then `flutter pub get`

---

## ✅ COMPLETION CHECKLIST

- [ ] Firebase fully integrated
- [ ] Authentication working
- [ ] Database CRUD working
- [ ] Bidding system functional
- [ ] Admin can verify users
- [ ] Orders track states
- [ ] Delivery charges calculate
- [ ] All tests passing
- [ ] App builds successfully
- [ ] Documentation updated

---

**Estimated Total Time**: 8-10 hours  
**Difficulty**: Intermediate  
**Prerequisites**: Flutter, Firebase basics  

---

*Good luck! You've got this! 🚀*
