# 🎭 Talentia - College Fest Registration App

Welcome to **Talentia**, a college fest event registration app built using **Flutter** and **Firebase**. This app streamlines the registration, management, and attendance processes for college festivals, enabling both students and administrators to interact in a seamless digital environment.

---

## 📱 Features

### For Students:
- 🔒 Login via official college Gmail accounts (Firebase Auth)
- 📚 Browse events categorized into Performing Arts, Fine Arts, and Literary Arts
- 📝 Register for events and receive a unique QR code for each
- 🔔 Receive event notifications and updates in real-time
- 🎫 QR-based digital entry pass
- 📅 View registered and upcoming events

### For Admins:
- ➕ Create, update, and delete events
- ✅ Scan and verify QR codes to authenticate participants
- 📈 Track attendance in real time
- 📣 Send push notifications for announcements and updates

---

## 🧰 Technologies Used

| Component               | Technology                     |
|------------------------|---------------------------------|
| UI/UX                  | Flutter (Dart)                  |
| Authentication         | Firebase Authentication         |
| Database               | Cloud Firestore (NoSQL)         |
| Storage                | Firebase Storage                |
| Notifications          | Firebase Cloud Messaging (FCM)  |
| QR Code Generator      | PrettyQrView                    |
| QR Code Scanner        | QR Scanner Plugin               |
| IDE                    | Android Studio                  |

---

## 🔄 System Overview

### User Roles:
- **Student**: Login, register for events, view QR codes.
- **Admin**: Manage events, scan QR codes, send notifications.

### Key Modules:
- Login/Signup with college email
- Event Management Dashboard (Admin only)
- QR Code Generation & Scanning
- Real-time Firestore Sync
- Push Notifications via FCM

---

## 📊 Diagrams & Architecture

- **Use Case Diagram** – Defines interactions between student, admin, and system.
- **Activity Diagram** – Shows workflows for login, event registration, and verification.
- **Database Schema** – NoSQL collections for users, events, registrations, and notifications.
- **Sequence Diagram** – Visualizes request flow from login to QR scanning.
- **Deployment Diagram** – Architecture involving Firebase services and client app.

---

## ✅ Test Cases

All core functionalities have been tested and verified.

| Test Case | Scenario                        | Result |
|-----------|----------------------------------|--------|
| TC_01     | Login with valid credentials     | ✅ Pass |
| TC_03     | Register for an event            | ✅ Pass |
| TC_05     | Generate and view QR Code        | ✅ Pass |
| TC_07     | Scan invalid QR Code             | ✅ Pass |
| TC_08     | Admin creates a new event        | ✅ Pass |
| ...       | More test cases in documentation | ✅ Pass |

---

## 📸 Screenshots

- Onboarding & Login  
- Student and Admin Dashboards  
- Event Listings  
- QR Code Generation & Scanner  
- Registration Forms

> 📁 Check the `/screenshots/` directory for images.


---

## 📖 References

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase for Flutter (FlutterFire)](https://firebase.flutter.dev/)
- [QR Flutter Package](https://pub.dev/packages/qr_flutter)
- [Firebase Functions](https://firebase.google.com/docs/functions)

---

## 📌 Future Enhancements

- Add event reminders with calendar integration
- Live leaderboard and results announcements
- Admin analytics dashboard

---

## 🙌 Acknowledgements

This project was developed by **Ankit Ashok Prajapati** as part of the B.Sc. Computer Science final year submission at **V.E.S. College of Arts, Science, and Commerce, Mumbai** under the guidance of **Mrs. Priya Daniel**.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


