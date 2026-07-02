# Flutter Task Manager

A responsive, cleanly designed task manager web app built with Flutter.

## Features
- **Responsive Layout**: Adapts gracefully to mobile, tablet, and desktop screens.
- **Task Management**: Create, edit, and delete tasks.
- **Task Status**: Mark tasks as pending or completed with a single click.
- **Filtering**: View 'All', 'Pending', or 'Completed' tasks.
- **Priority Labels**: Assign Low, Medium, or High priority to tasks.
- **State Management**: Built using `provider` for robust and scalable state.
- **Modern UI**: Clean typography (Google Fonts) and smooth hover animations.

## Project Structure
- `lib/models/`: Contains the `Task` data model.
- `lib/providers/`: Contains `TaskProvider` for state management and business logic.
- `lib/screens/`: Contains the `HomeScreen` which handles responsive layouts.
- `lib/widgets/`: Reusable UI components like `TaskCard`, `FilterBar`, and `TaskFormDialog`.
- `lib/theme/`: Centralized theme configuration in `AppTheme`.

## Getting Started

Because this project was generated manually in an environment without Flutter installed, you'll need to generate the platform-specific files before running it for the first time.

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine.
- A modern web browser (e.g., Chrome).

### Setup and Run
1. Open a terminal and navigate to this project folder.
2. Run the following command to generate the web platform files and fetch dependencies:
   ```bash
   flutter create . --platforms web
   ```
3. Run the application on Chrome:
   ```bash
   flutter run -d chrome
   ```

## Author
Built by Antigravity IDE.
