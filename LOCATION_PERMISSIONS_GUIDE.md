# 📍 Location & Permissions Implementation Guide

## ✅ Implemented Features

### 1. Location Service (`lib/services/location_service.dart`)
Complete location handling service with:
- ✅ Check if location services are enabled
- ✅ Check and request location permissions
- ✅ Get current GPS coordinates
- ✅ Handle permission denial scenarios
- ✅ Calculate distance between coordinates
- ✅ Open app settings for permission management
- ✅ Timeout handling for location requests

### 2. Image Picker Service (`lib/services/image_picker_service.dart`)
Complete image handling service with:
- ✅ Pick image from camera
- ✅ Pick single image from gallery
- ✅ Pick multiple images (max 5)
- ✅ Image compression (max 1920x1080, 85% quality)
- ✅ Error handling

### 3. Upload Waste Screen Updates
Fully functional waste upload with:
- ✅ GPS location button with loading indicator
- ✅ Manual location entry option
- ✅ Show captured GPS coordinates confirmation
- ✅ Image picker modal (camera/gallery selection)
- ✅ Display selected images with remove option
- ✅ Maximum 5 images limit
- ✅ Image counter (e.g., "3/5 photos")
- ✅ Save latitude/longitude to database
- ✅ Save image file paths to database

## 📱 Android Permissions

### AndroidManifest.xml
Located at: `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Location Permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<!-- Camera Permission -->
<uses-permission android:name="android.permission.CAMERA"/>

<!-- Storage Permissions (Android 12 and below) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

<!-- Media Permissions (Android 13+) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" android:minSdkVersion="33"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" android:minSdkVersion="33"/>

<!-- Internet (for maps and cloud storage) -->
<uses-permission android:name="android.permission.INTERNET"/>
```

## 🍎 iOS Permissions

### Info.plist
Located at: `ios/Runner/Info.plist`

```xml
<!-- Location Permission -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to show nearby waste posts and help processors find your farm.</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs your location to show nearby waste posts and help processors find your farm.</string>

<!-- Camera Permission -->
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos of agricultural waste.</string>

<!-- Photo Library Permission -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images of your waste.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs permission to save photos to your library.</string>
```

## 🎯 How It Works

### Location Feature Flow

1. **User taps GPS button** (📍 icon in location field)
2. **Permission check:**
   - If location services disabled → Show alert to enable in settings
   - If permission denied → Request permission
   - If permission denied forever → Show snackbar with "Settings" button
3. **Get location:**
   - Fetch GPS coordinates with 10-second timeout
   - Show loading spinner in button
4. **Success:**
   - Display coordinates in location field (e.g., "23.4567, 78.9012")
   - Show green checkmark "GPS coordinates captured"
   - Store latitude/longitude in _latitude and _longitude variables
5. **Save to database:**
   - latitude and longitude columns in waste_posts table

### Image Picker Flow

1. **User taps "Add photos" area**
2. **Show modal bottom sheet** with options:
   - 📷 Camera
   - 🖼️ Gallery
3. **Camera option:**
   - Request camera permission if needed
   - Open camera
   - Capture photo
   - Show success message
   - Add to _selectedImages list
4. **Gallery option:**
   - Request storage permission if needed
   - Open gallery
   - Allow multiple selection (up to 5 total)
   - Show success message with count
   - Add to _selectedImages list
5. **Display selected images:**
   - Horizontal scrollable list
   - 100x100 thumbnail
   - Red X button to remove
   - Counter shows "3/5 photos"
6. **Save to database:**
   - File paths stored in image_url column

## 🛠️ Database Schema

### waste_posts Table
```sql
CREATE TABLE waste_posts (
  id TEXT PRIMARY KEY,
  farmer_id TEXT NOT NULL,
  farmer_name TEXT NOT NULL,
  waste_type TEXT NOT NULL,
  quantity REAL NOT NULL,
  price_per_kg REAL,
  location TEXT NOT NULL,
  latitude REAL,              -- ✅ GPS latitude
  longitude REAL,             -- ✅ GPS longitude
  description TEXT,
  image_url TEXT,             -- ✅ Comma-separated file paths
  status TEXT DEFAULT 'available',
  created_at INTEGER NOT NULL,
  FOREIGN KEY (farmer_id) REFERENCES users (id)
)
```

## 🧪 Testing Checklist

### Location Testing
- [ ] Grant location permission → GPS works
- [ ] Deny location permission → Shows error with Settings button
- [ ] Location services disabled → Shows alert to enable
- [ ] GPS timeout (airplane mode) → Shows timeout error
- [ ] Manual location entry → Saves without GPS coordinates

### Image Testing
- [ ] Camera permission granted → Camera opens
- [ ] Camera permission denied → Shows error
- [ ] Select 1 image from gallery → Displays correctly
- [ ] Select 5 images → Shows "Maximum reached"
- [ ] Try to add 6th image → Blocked
- [ ] Remove image → Updates counter and list
- [ ] Upload with images → Saves paths to database

### Permissions on First Launch
- [ ] App requests location permission on first GPS tap
- [ ] App requests camera permission on first camera use
- [ ] App requests storage permission on first gallery use

## 🚀 Usage Example

```dart
// Get current location
final locationService = LocationService();
try {
  final position = await locationService.getCurrentLocation();
  print('Lat: ${position.latitude}, Lon: ${position.longitude}');
} catch (e) {
  print('Error: $e');
}

// Pick image from camera
final imageService = ImagePickerService();
try {
  final image = await imageService.pickFromCamera();
  if (image != null) {
    print('Image path: ${image.path}');
  }
} catch (e) {
  print('Error: $e');
}

// Pick multiple images
try {
  final images = await imageService.pickMultipleFromGallery(maxImages: 5);
  print('Selected ${images.length} images');
} catch (e) {
  print('Error: $e');
}
```

## 📦 Required Packages

All packages already added to `pubspec.yaml`:
```yaml
dependencies:
  geolocator: ^10.1.1           # ✅ Location services
  geocoding: ^2.2.2             # ✅ Address lookup
  google_maps_flutter: ^2.10.0  # ✅ Map display
  image_picker: ^1.1.2          # ✅ Camera & gallery
```

## ⚡ Key Features

1. **Smart Permission Handling**
   - Automatic permission requests
   - Clear error messages
   - Direct links to settings
   - Graceful fallbacks

2. **User-Friendly UI**
   - Loading indicators
   - Success confirmations
   - Image previews with remove option
   - Counter for image limits

3. **Robust Error Handling**
   - Location service disabled
   - Permission denied
   - GPS timeout
   - Image picker failures

4. **Production-Ready**
   - Timeout protection (10s for GPS)
   - Image compression
   - Database persistence
   - Cross-platform (Android + iOS)

## 🎨 UI Components

### Location Button States
- **Idle:** 📍 icon
- **Loading:** 🔄 spinner
- **Success:** ✅ checkmark + coordinates

### Image Picker States
- **Empty:** "Tap to add photos"
- **Partial:** "Tap to add photos (3/5)"
- **Full:** "Maximum 5 photos reached"

## 🔐 Security & Privacy

- Location only requested when user taps GPS button
- Images stored locally (not uploaded to cloud yet)
- Permissions requested at point of use (not on app launch)
- Clear explanation in permission dialogs

## 🎯 Next Steps (Optional Enhancements)

1. **Cloud Storage:** Upload images to Firebase Storage
2. **Geocoding:** Convert coordinates to address names
3. **Google Maps:** Show waste locations on map
4. **Nearby Waste:** Filter by distance from user
5. **Image Optimization:** Further compress before upload
6. **Offline Support:** Cache images for later upload

---

✅ **All location and permission features are now fully implemented and production-ready!**
