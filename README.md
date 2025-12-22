# AUST Robotics Club Mobile Application

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-brightgreen?style=for-the-badge)

**The official mobile application for AUST Robotics Club**

*"Robotics for Building a Safer Future"*

</div>

---

## 📱 About

The AUST Robotics Club Mobile Application is the official digital platform for the **Ahsanullah University of Science and Technology (AUST) Robotics Club (AUSTRC)**. Established in Fall 2021, AUSTRC is dedicated to enriching knowledge in robotics and fostering innovation among students through educational programs, workshops, training sessions, and competitive events.

This cross-platform mobile application serves as a comprehensive hub for club members and robotics enthusiasts, providing seamless access to club activities, event information, resources, and community engagement features.

### Mission

To enrich knowledge in the field of Robotics and make a positive impact on the development of sustainable projects for a better future through educational programs, workshops, training, and competitions.

### Vision

To forge bonds with other clubs and activities at AUST and beyond, contributing to the development of AUST as an ideal model university in Bangladesh where students excel equally in technology and social behavior.

---

## ✨ Features

- **📅 Event Management**: Stay updated with upcoming workshops, competitions, and club activities
- **🔔 Push Notifications**: Receive real-time updates about club events and announcements
- **👥 Member Portal**: Access member-exclusive content and resources
- **📰 News & Updates**: Latest news, achievements, and announcements from the club
- **🏆 Competition Tracking**: Follow intra and inter-university robotics competitions
- **📚 Learning Resources**: Access educational materials, tutorials, and documentation
- **🤝 Community Engagement**: Connect with fellow robotics enthusiasts
- **📧 Contact & Support**: Direct communication channels with club executives
- **📊 Activity Dashboard**: Track club activities and participation

---

## 🛠️ Tech Stack

### Framework & Language
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language (97.8% of codebase)

### Supported Platforms
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Linux
- ✅ macOS
- ✅ Windows

### Additional Technologies
- C++ (1.1%)
- CMake (0.8%)
- Swift (0.1%)
- HTML (0.1%)

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable version)
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) (for mobile development)
- [Git](https://git-scm.com/)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Rafi12234/AUST-Robotics-Club-Mobile-Application.git
   cd AUST-Robotics-Club-Mobile-Application
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Gmail Setup** (if required)
   
   For email functionality, refer to the [Gmail Setup Guide](./GMAIL_SETUP_GUIDE.md) included in the repository.

4. **Run the application**
   ```bash
   # For development
   flutter run
   
   # For specific platform
   flutter run -d chrome        # Web
   flutter run -d android       # Android
   flutter run -d ios           # iOS (macOS only)
   ```

### Building for Production

#### Android
```bash
flutter build apk --release          # For APK
flutter build appbundle --release    # For Play Store
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

---

## 📁 Project Structure

```
AUST-Robotics-Club-Mobile-Application/
├── android/              # Android native code
├── ios/                  # iOS native code
├── web/                  # Web-specific files
├── lib/                  # Main application code
│   ├── models/          # Data models
│   ├── screens/         # UI screens
│   ├── widgets/         # Reusable widgets
│   ├── services/        # API and business logic
│   └── utils/           # Helper functions
├── assets/              # Images, fonts, and other assets
├── icons/               # App icons
├── test/                # Unit and widget tests
├── pubspec.yaml         # Package dependencies
└── README.md           # This file
```

---

## 📧 Email Configuration

The application includes email functionality for notifications and communications. To set up email services:

1. Review the [GMAIL_SETUP_GUIDE.md](./GMAIL_SETUP_GUIDE.md) file in the repository
2. Configure your Gmail credentials securely
3. Update the necessary environment variables or configuration files

**Security Note**: Never commit sensitive credentials to the repository. Use environment variables or secure configuration management.

---

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

1. **Fork the repository**
2. **Create your feature branch**
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. **Commit your changes**
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/AmazingFeature
   ```
5. **Open a Pull Request**

### Contribution Guidelines
- Follow Flutter and Dart best practices
- Write clear, commented code
- Test your changes thoroughly
- Update documentation as needed
- Ensure code passes lint checks: `flutter analyze`

---

## 🧪 Testing

Run the test suite:
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

---

## 📊 Development Status

- **Current Version**: Development Phase
- **Contributors**: 3 active contributors
- **Stars**: 1
- **Forks**: 1
- **Language Distribution**:
  - Dart: 97.8%
  - C++: 1.1%
  - CMake: 0.8%
  - Others: 0.3%

---

## 📱 About AUST Robotics Club

**AUST Robotics Club (AUSTRC)** is a premier student organization at Ahsanullah University of Science and Technology, focused on:

### Key Activities
- 🛠️ **Workshops**: Hands-on training in robotics, PCB design, 3D modeling, and more
- 🏆 **Competitions**: Intra and inter-university robotics competitions
- 📚 **Educational Programs**: Seminars, discussions, and knowledge-sharing sessions
- 🤖 **Project Development**: Innovative robotics projects and sustainable solutions
- 🌐 **Networking**: Collaboration with other clubs and organizations

### Membership
- Open to all AUST students
- One-time registration fee
- Access to all club rights, privileges, and resources
- Opportunities to participate in workshops, competitions, and projects

### Contact Information
- **Email**: austrc@aust.edu
- **Phone**: 01834861666
- **Website**: [https://aust.edu/austrc](https://aust.edu/austrc)
- **LinkedIn**: [AUST Robotics Club](https://www.linkedin.com/company/aust-robotics-club)
- **Instagram**: [@aust_robotics_club](https://www.instagram.com/aust_robotics_club/)

---

## 🏛️ Organizational Structure

The club is governed by an Executive Committee consisting of:
- President
- Vice President
- General Secretary
- Treasurer
- Joint Secretaries
- Executive Members

---

## 📄 License

This project is part of AUST Robotics Club. For licensing information, please contact the club administration.

---

## 🙏 Acknowledgments

- AUST Robotics Club Executive Committee
- All club members and contributors
- Ahsanullah University of Science and Technology
- Flutter and Dart communities

---

## 📞 Support

For support, questions, or feedback:

- Open an issue in the [GitHub Issues](https://github.com/Rafi12234/AUST-Robotics-Club-Mobile-Application/issues) section
- Contact the club at: austrc@aust.edu
- Reach out to the development team through GitHub

---

## 🔄 Changelog

For a detailed history of changes and updates, please refer to the [commit history](https://github.com/Rafi12234/AUST-Robotics-Club-Mobile-Application/commits/main).

---

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [AUST Robotics Club Official Website](https://aust.edu/austrc)
- [Gmail Setup Guide](./GMAIL_SETUP_GUIDE.md)

---

<div align="center">

**Made with ❤️ by AUST Robotics Club**

*Building the future, one line of code at a time*

[⭐ Star this repo](https://github.com/Rafi12234/AUST-Robotics-Club-Mobile-Application) | [🐛 Report Bug](https://github.com/Rafi12234/AUST-Robotics-Club-Mobile-Application/issues) | [✨ Request Feature](https://github.com/Rafi12234/AUST-Robotics-Club-Mobile-Application/issues)

</div>
