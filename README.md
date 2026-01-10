# DailyTodoList: AI-Powered Aggregator

## Overview
DailyTodoList is a next-generation personal assistant designed to aggregate fragmented data from Work (Calendar), Health (Fitness/Diet), and Life. It uses an AI Agent to interpret natural language and turn intent into actionable schedule items.

## Key Features
- **AI Intent Recognition**: State-aware processing (e.g., identifies if a user forgot to mention a time for a meeting).
- **Service-Oriented Integration**: Decoupled modules for HealthKit, Apple Calendar, and local notifications.
- **Unified Action Protocol**: Treats diverse data types as a single `DailyAction` for consistent UI rendering.

## Architecture: Service-Oriented MVVM-C
The project utilizes **MVVM** for UI logic, **Services** for data/AI processing, and the **Coordinator Pattern** for navigation flow. This ensures the app remains testable and scalable as more data sources are added.

## Future Roadmap
- [ ] **Inbody OCR**: Scan physical fitness printouts to update health metrics automatically.
- [ ] **Smart DND**: Automatically trigger "Do Not Disturb" during AI-scheduled deep work sessions.
- [ ] **Subscription Model**: Premium tier for advanced LLM reasoning capabilities.
