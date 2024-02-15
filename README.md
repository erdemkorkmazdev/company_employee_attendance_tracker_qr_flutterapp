Employee Attendance Management System

This repository contains the source code for an application developed to manage the entry and exit controls of employees at the company I work for. The application allows each employee to scan a QR code upon entering and exiting the premises. The timestamp of each scan is recorded in a Firebase Firestore database using Firebase Authentication.

Features

QR Code Scanning: Employees can use the app to scan QR codes upon entry and exit.
Timestamp Logging: The timestamp of each scan is logged in the Firebase Firestore database.
User Roles:
Admin: Admin users can view the entry and exit records of all employees via an admin panel.
Regular Users: Regular users can only view their own entry and exit records in the format of day-month-year on the dashboard.
Security Measures

Encrypted QR Codes: Each QR code contains an encrypted password internally. The QR scanner page of the app only writes data to the database if it successfully decodes this password.
One-Time Login: The login page is only shown once to each user. After the initial login, access to this page is restricted.
Screenshots

Login page where users authenticate for the first time.

![Ekran Resmi 2024-01-12 13 20 21](https://github.com/erdemkorkmazdev/company_employee_attendance_tracker_qr_flutterapp/assets/98043504/982455c5-4a80-4ca7-b2be-f1fa3fc11d6a)

Entry / Quit selection page.

![Ekran Resmi 2024-01-12 13 20 42](https://github.com/erdemkorkmazdev/company_employee_attendance_tracker_qr_flutterapp/assets/98043504/ee0a8fde-c92c-4342-a576-bac9ebb6a965)

QR Scanner Pages for Entrance & Quit
![Ekran Resmi 2024-01-12 13 21 03](https://github.com/erdemkorkmazdev/company_employee_attendance_tracker_qr_flutterapp/assets/98043504/52469649-4981-48ae-9f6d-a5e9f954a30b)
![Ekran Resmi 2024-01-12 13 21 10](https://github.com/erdemkorkmazdev/company_employee_attendance_tracker_qr_flutterapp/assets/98043504/96e79634-81a9-4f78-b840-08ba20a1924d)


Admin panel displaying entry and exit records of all employees.

![Ekran Resmi 2024-01-12 13 25 30](https://github.com/erdemkorkmazdev/company_employee_attendance_tracker_qr_flutterapp/assets/98043504/11a58fd9-6868-44da-a977-da0cb938acff)

![Ekran Resmi 2024-01-12 13 25 14](https://github.com/erdemkorkmazdev/company_employee_attendance_tracker_qr_flutterapp/assets/98043504/6283a611-2a9f-442d-b438-f09ac13db861)

User dashboard showing personal entry and exit records.

Technologies Used

Flutter for cross-platform mobile app development.
Firebase Firestore for real-time database.
Firebase Authentication for user authentication.
Flutter qr_scanner library.
