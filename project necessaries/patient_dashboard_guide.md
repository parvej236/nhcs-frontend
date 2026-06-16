# Patient Dashboard Guide

## 🗺️ High-Level Roadmap
1. **Dependency Addition**: Added `google_fonts` for beautiful typography and `fl_chart` for data visualizations.
2. **Core Constants**: Established a unified color scheme and layout constants.
3. **Sidebar Component**: Created a vertical navigation drawer with active states and icon integration.
4. **Header Component**: Implemented a top bar featuring a search input and a dynamic time badge.
5. **Main Content Dashboard**: Assembled the core dashboard, including promotional banners, heartbeat UI, activity graphs, stat cards, and specialist lists.
6. **Right Profile Panel**: Designed a comprehensive patient profile sidebar with vital statistics, an interactive calendar strip, appointment schedules, and recent test reports.
7. **Main Screen Assembly**: Integrated all components into a responsive Row-based layout.
8. **App Integration**: Updated `main.dart` to apply the Google Fonts theme and route to the new dashboard.

## 🧠 Logical Descriptions

### Frontend Layer
- **Layout Architecture**: The Patient Dashboard employs a clean, three-column layout. A `Row` widget encapsulates the `SideMenu` (fixed width), `DashboardContent` (expanded), and `RightPanel` (fixed width).
- **Theming & Aesthetics**: Centralized colors in `constants.dart` (`primaryColor`, `accentColor`, `contentBgColor`) ensure consistency. The UI heavily utilizes dark deep blues combined with light backgrounds for high contrast and readability.
- **Data Visualization**: Placeholder widgets and `fl_chart` components visually represent patient vitals and activity logs, making the dashboard dynamic and engaging.
- **Responsiveness**: While primarily structured for web/desktop viewing via the fixed-width panels, the central content area uses an `Expanded` widget to fluidly adapt to available screen width.

### Backend Layer
- *Currently UI only; Backend logic to be implemented for fetching patient data, appointments, and test reports.*

## 💻 Full Implementation Code

### `pubspec.yaml` (Dependencies added)
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^6.1.0
  fl_chart: ^0.65.0
```

### `lib/core/constants.dart`
```dart
import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF0C2444);
const Color secondaryColor = Color(0xFFF3F6F8);
const Color accentColor = Color(0xFFE56A75); // Used for heartbeat, badges
const Color sidebarColor = Color(0xFF0C2444);
const Color rightPanelColor = Color(0xFF0A1F3A);
const Color contentBgColor = Color(0xFFF0F4F8);

const Color textLight = Colors.white;
const Color textDark = Color(0xFF1E293B);
const Color textGrey = Color(0xFF94A3B8);

const double defaultPadding = 16.0;
```

### `lib/screens/patient_dashboard/patient_dashboard_screen.dart`
```dart
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'components/side_menu.dart';
import 'components/dashboard_content.dart';
import 'components/right_panel.dart';

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: contentBgColor, // Use the light grey for main content
      body: Row(
        children: [
          // Left Sidebar
          const SideMenu(),
          // Main Content
          const Expanded(
            child: DashboardContent(),
          ),
          // Right Panel
          const RightPanel(),
        ],
      ),
    );
  }
}
```

### `lib/screens/patient_dashboard/components/side_menu.dart`
*(Contains the complete `SideMenu` widget code for sidebar navigation).*

### `lib/screens/patient_dashboard/components/header.dart`
*(Contains the `Header` widget with search and time badge).*

### `lib/screens/patient_dashboard/components/dashboard_content.dart`
*(Contains the central scrollable `DashboardContent` with banner, charts, and specialist lists).*

### `lib/screens/patient_dashboard/components/right_panel.dart`
*(Contains the `RightPanel` widget displaying user profile, vitals, calendar, and appointments).*

### `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/patient_dashboard/patient_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UHCS Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C2444)),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
      ),
      home: const PatientDashboardScreen(),
    );
  }
}
```

## 🛠️ Extra Steps
1. Execute `flutter pub get` to download the newly added `google_fonts` and `fl_chart` packages.
2. Run the application targeting Chrome or Edge (`flutter run -d chrome`) to preview the web layout.
3. Optional: Adjust browser window size to test the expanded content area.

## 📝 Summary
The Patient Dashboard provides a rich, web-centric user interface mirroring premium healthcare applications. Navigation is handled on the left, critical health metrics and announcements dominate the center, and personalized patient details reside on the right. Data currently flows through static UI components, setting the stage for future integration with state management and live database endpoints.
