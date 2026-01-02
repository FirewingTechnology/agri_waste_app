// App-wide constants for configuration
// Delivery charges, API keys, Firebase collections

class AppConstants {
  // App Info
  static const String appName = 'Agri Waste to Fertilizer';
  static const String appVersion = '1.0.0';
  
  // Delivery Charges
  static const double deliveryChargePerKm = 15.0; // ₹15 per km
  static const double minDeliveryCharge = 50.0; // Minimum ₹50
  static const double maxDeliveryDistance = 100.0; // Max 100 km
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String wasteCollection = 'waste_posts';
  static const String fertilizerCollection = 'fertilizers';
  static const String ordersCollection = 'orders';
  static const String chatsCollection = 'chats';
  
  // Waste Types
  static const List<String> wasteTypes = [
    'Crop Residue',
    'Animal Manure',
    'Food Processing Waste',
    'Garden Waste',
    'Fruit & Vegetable Waste',
    'Other Organic Waste',
  ];
  
  // Fertilizer Types
  static const List<String> fertilizerTypes = [
    'Compost',
    'Vermicompost',
    'Organic Manure',
    'Bio-fertilizer',
    'Mixed Organic Fertilizer',
  ];
  
  // User Roles
  static const String farmerRole = 'Farmer';
  static const String manufacturerRole = 'Manufacturer'; // Renamed from Processor
  static const String processorRole = 'Manufacturer'; // Backward compatibility
  static const String adminRole = 'Admin';
  
  // Order States
  static const String orderPosted = 'Posted';
  static const String orderAccepted = 'Accepted';
  static const String orderPicked = 'Picked';
  static const String orderDelivered = 'Delivered';
  static const String orderCompleted = 'Completed';
  static const String orderCancelled = 'Cancelled';
  
  // Firestore Collections - Additional
  static const String bidsCollection = 'bids';
  static const String logsCollection = 'logs';
  static const String ratingsCollection = 'ratings';
  
  // SharedPreferences Keys
  static const String keyLanguage = 'selected_language';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyIsLoggedIn = 'is_logged_in';
}
