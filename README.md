# Balik Kampung Mode

A Flutter application for household monitoring and township security coordination.

## 1. Overview

Balik Kampung Mode is a mobile and web application designed to help residents monitor household conditions while away from home and improve coordination with township management and security guards.

The application provides a centralised platform for managing Holiday Mode, viewing household water and electricity usage, reviewing security alerts, assigning security tasks and generating reports.

It consists of three main interfaces:

- Resident
- Township Management
- Security Guard

## 2. Key Features

### Holiday Mode
- Activate or deactivate Holiday Mode.
- Select a festive occasion.
- Set departure and return dates.
- Configure alert preferences.
- Complete a Before Departure Checklist.

### Household Monitoring
- View household water usage charts and records.
- View household electricity usage charts and records.
- Review household monitoring information.

### Rule-Based Anomaly Detection
The application uses rule-based analysis to identify simulated unusual household conditions, including:

- Possible water leakage.
- Unusual electricity usage.
- Possible forced-entry incidents.

Generated alerts include incident details and severity levels for review.

### Alert and Notification Management
- View household alerts and notifications.
- Review incident details and severity levels.
- Allow Township Management to review and resolve alerts.
- Display relevant alerts to residents and management.

### Security Task Management
- Create and assign security tasks.
- Select the responsible security guard.
- Set task priority, zone and instructions.
- Monitor task progress.
- Track Pending, In Progress and Done statuses.

### Security Guard Checkpoint Recording
- View assigned security tasks.
- Accept assigned tasks.
- Record patrol checkpoints manually.
- Update task progress.
- Mark completed tasks as Done.

### Report Generation
- View household and township activity summaries.
- Review Open Alerts and Closed Alerts.
- View Completed Tasks and Holiday Mode Homes.
- Export reports as PDF.
- Preview, print or save generated reports.

## 3. Application Workflow

### 3.1 Resident Workflow

1. Sign in using the resident account.
2. Open Holiday Mode.
3. Select the festive occasion and enter departure and return dates.
4. Configure alert preferences.
5. Complete the Before Departure Checklist.
6. Save the Holiday Mode settings.
7. Open Home Monitoring to view water and electricity usage.
8. Open Notifications to review household alerts and incident details.

### 3.2 Township Management Workflow

1. Sign in using the Township Management account.
2. View the management dashboard.
3. Review Holiday Mode Homes, Open Alerts, Water Anomalies and Tasks Outstanding.
4. Register security guard accounts.
5. Open Home Monitoring to review household usage and alerts.
6. Review incident details and resolve alerts when appropriate.
7. Create security tasks by entering the title, zone, instructions and priority.
8. Assign tasks to registered security guards.
9. Monitor task statuses, including Pending, In Progress and Done.
10. Open Reports to review township activity summaries.
11. Export reports as PDF.

### 3.3 Security Guard Workflow

1. Sign in using the registered Security Guard account.
2. Open My Assigned Tasks.
3. Review assigned task information, including title, zone, priority and status.
4. Accept an assigned task to change its status to In Progress.
5. Record a patrol checkpoint manually, including its date, time and location.
6. Complete the assigned task.
7. The task status changes to Done.
8. Township Management can review the completed task and checkpoint information.

## 4. Example of an End-to-End Workflow

The following example illustrates how the three interfaces work together.

1. A resident activates Holiday Mode before travelling.
2. Rule-based analysis identifies a simulated unusual water usage scenario.
3. The application generates an alert for review.
4. Township Management reviews the alert details.
5. Management creates a security task and assigns it to a registered guard.
6. The security guard signs in and accepts the assigned task.
7. The guard records a manual patrol checkpoint.
8. After completing the task, the guard updates its status to Done.
9. Management reviews the completed task and updates the township activity records.

## 5. Technologies Used

| Technology | Purpose |
|---|---|
| Flutter | Application development framework |
| Dart | Programming language |
| Visual Studio Code | Development environment |
| fl_chart | Charts and data visualisation |
| pdf | PDF document generation |
| printing | PDF preview and printing |
| GitHub | Source code hosting and version control |

## 6. Project Structure

```text
Balik_Kampung_Mode_Application/
│
├── android/                  # Android platform files
├── ios/                      # iOS platform files
├── lib/
│   └── main.dart             # Main application source code
├── test/                     # Testing files
├── web/                      # Web platform files
├── windows/                  # Windows platform files
│
├── .gitignore                # Git exclusion settings
├── .metadata                 # Flutter project metadata
├── analysis_options.yaml     # Dart analysis configuration
├── pubspec.yaml              # Project configuration and dependencies
├── pubspec.lock              # Dependency version information
└── README.md                 # Project documentation
```

## 7. Installation and Setup

### Prerequisites

Install the following before running the application:

- Flutter SDK
- Dart SDK
- Visual Studio Code
- Google Chrome (for web execution)

### Step 1. Clone the Repository

```bash
git clone https://github.com/nurhazirahhamidi-04/Balik_Kampung_Mode_Application.git
```

### Step 2. Navigate to the Project Folder

```bash
cd Balik_Kampung_Mode_Application
```

### Step 3. Install Dependencies

```bash
flutter pub get
```

### Step 4. Check Flutter Environment

```bash
flutter doctor
```

### Step 5. Run the Application

To run the application in Google Chrome:

```bash
flutter run -d chrome
```

### Step 6. Build the Web Application

To create a web release build:

```bash
flutter build web --release
```

The generated web application files will be available in:

```text
build/web/
```

## 8. Prototype Scope and Limitations

- Household water and electricity readings are simulated for prototype demonstration.
- The application does not currently integrate physical monitoring sensors.
- Rule-based analysis demonstrates possible water leakage, unusual electricity usage and forced-entry scenarios.
- Generated incident alerts are illustrative and do not confirm actual incidents.
- Security checkpoint recording is manual and does not verify physical presence through GPS.
- The current prototype uses local application authentication and in-memory application state. It is not connected to a production authentication server or centralised cloud database.

## 9. Future Enhancements

Possible future improvements include:

- Integration with physical household monitoring devices.
- Improved anomaly detection and alert accuracy.
- Secure centralised database and authentication services.
- Additional privacy and security controls.
- Enhanced security task management and evidence recording.
- Improved reporting and data visualisation.

## 10. Repository

**GitHub Repository:**  
https://github.com/nurhazirahhamidi-04/Balik_Kampung_Mode_Application

---

**Balik Kampung Mode** provides a centralised application for household monitoring, security alert management and coordination between residents, township management and security guards.
