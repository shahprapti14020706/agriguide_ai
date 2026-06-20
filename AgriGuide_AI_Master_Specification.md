# AgriGuide AI

## AI-Powered Agriculture Intelligence Companion

---

# Project Overview

AgriGuide AI is a domain-specific Agriculture AI Agent designed to help farmers throughout the crop lifecycle.

Unlike generic chatbots powered entirely by Gemini or OpenAI, AgriGuide AI uses an Agriculture Intelligence Engine trained on crop information, disease databases, fertilizer recommendations, irrigation practices, weather advisory, market intelligence, and government schemes.

The system should answer only agriculture-related questions and provide highly personalized recommendations based on crop type, farm profile, crop stage, weather conditions, and farming history.

The goal is to build a production-ready Flutter application that acts as a digital farming assistant.

---

# Core Vision

Create a smart farming platform that enables farmers to:

- Manage farm information
- Track crop lifecycle
- Detect crop diseases
- Get fertilizer recommendations
- Get irrigation recommendations
- Receive weather-based advisory
- View market prices
- Access government schemes
- Ask agriculture-related questions
- Receive farming reminders
- Maintain farming records

---

# User Roles

## Farmer

The primary user.

Capabilities:

- Register account
- Create farm profile
- Add crops
- Upload crop images
- Ask farming questions
- Check weather
- View market prices
- Access schemes
- Receive reminders
- Maintain records

## Admin - Future Scope

Capabilities:

- Manage crop database
- Manage disease database
- Manage market prices
- Manage government schemes
- Manage knowledge base

---

# Technology Stack

Frontend: Flutter

Language: Dart

Backend: Firebase

Authentication: Firebase Authentication

Database: Cloud Firestore

Storage: Firebase Storage

Notifications: Firebase Cloud Messaging

State Management: Provider

Dependency Injection: GetIt

Local Storage: Shared Preferences

Analytics: Firebase Analytics

Crash Reporting: Firebase Crashlytics

Maps: Google Maps API

Weather: OpenWeather API

Market Data: Agmarknet API

Disease Detection: TensorFlow Lite

AI System: Agriculture RAG Agent

---

# Agriculture AI Agent Architecture

The AI system must not behave like a general chatbot.

It must act as a specialized Agriculture Expert.

## Supported Topics

- Crop diseases
- Pest attacks
- Fertilizers
- Irrigation
- Seeds
- Crop stages
- Harvesting
- Soil health
- Government schemes
- Market information
- Organic farming
- Weather advisory
- Farm management

## Unsupported Topics

If users ask unrelated questions, respond:

"I am AgriGuide AI and can only assist with agriculture and farming related topics."

---

# AI Workflow

Farmer Question

↓

Intent Detection

↓

Context Retrieval

↓

Agriculture Knowledge Base Search

↓

Response Generation

↓

Actionable Recommendation

---

# Agriculture Knowledge Base

The AI Agent must use structured agricultural datasets.

Knowledge Base Categories:

- Crop Information
- Crop Calendars
- Plant Diseases
- Pests
- Fertilizers
- Irrigation Practices
- Government Schemes
- Market Intelligence
- Soil Management
- Organic Farming
- Weather Recommendations

---

# Authentication Module

Features:

- Email Registration
- Email Login
- Forgot Password
- Remember Me
- Logout
- Profile Completion Tracking

---

# Farmer Profile Module

Store:

- Name
- Mobile Number
- Email
- Village
- District
- State
- Farm Size
- Soil Type
- Water Source
- Irrigation Method
- Preferred Language
- Profile Image

---

# Crop Management Module

Farmers can add multiple crops.

Each crop contains:

- Crop Name
- Variety
- Area Under Cultivation
- Sowing Date
- Expected Harvest Date
- Soil Type
- Irrigation Method
- Notes

System calculates:

- Crop Age
- Crop Stage
- Upcoming Activities

---

# Crop Stage Detection Engine

Automatically identify:

- Germination
- Seedling
- Vegetative
- Flowering
- Fruiting
- Maturity
- Harvesting

Inputs:

- Crop Type
- Sowing Date
- Crop Calendar Database

Outputs:

- Current Stage
- Stage Recommendations
- Upcoming Activities

---

# Disease Detection Module

Farmer uploads:

- Leaf image
- Stem image
- Fruit image
- Plant image

Workflow:

Image Upload

↓

Disease Detection Model

↓

Severity Analysis

↓

Recommendation Engine

Output:

- Disease Name
- Confidence Score
- Symptoms
- Causes
- Treatment
- Prevention
- Recommended Action

Save report in history.

---

# Fertilizer Recommendation Engine

Inputs:

- Crop Type
- Crop Stage
- Soil Type
- Weather

Outputs:

- Fertilizer Type
- Dosage
- Application Timing
- Precautions
- Organic Alternatives

---

# Irrigation Recommendation Engine

Inputs:

- Crop Type
- Crop Stage
- Soil Type
- Weather
- Temperature
- Humidity
- Rain Forecast

Outputs:

- Irrigation Required
- Suggested Timing
- Water Quantity Guidance
- Risk Warnings

---

# Weather Advisory Module

Display:

- Temperature
- Humidity
- Wind Speed
- Rain Probability
- UV Index

Generate:

- Irrigation Advisory
- Spraying Advisory
- Fertilizer Advisory
- Harvest Advisory
- Weather Alerts

---

# Agriculture AI Chat

Features:

- Context Aware Responses
- Chat History
- Suggested Questions
- Future Voice Support
- Multilingual Ready

Response Format:

1. Problem Summary
2. Possible Causes
3. Suggested Action
4. Preventive Measures
5. Expert Consultation Advice

---

# Market Intelligence Module

Features:

- Crop Search
- Nearby Market Prices
- Price Trends
- Historical Data
- Selling Recommendations

Display:

- Market Name
- Minimum Price
- Maximum Price
- Average Price
- Last Updated Date

---

# Government Scheme Module

Recommend schemes based on:

- State
- Crop
- Farm Size
- Farmer Category

Display:

- Eligibility
- Benefits
- Required Documents
- Application Process
- Deadlines

Examples:

- PM Kisan
- Crop Insurance
- Soil Health Card
- Irrigation Subsidy
- Farm Equipment Subsidy

---

# Reminder Module

Generate reminders for:

- Irrigation
- Fertilizer Application
- Pest Monitoring
- Disease Inspection
- Spraying
- Harvesting

Features:

- Push Notifications
- Task Completion Tracking
- Snooze Reminder

---

# Farm History Module

Store:

- Crop History
- Disease Reports
- AI Conversations
- Irrigation Records
- Fertilizer Records
- Harvest Records
- Reminder Activity

---

# Home Dashboard

Display:

- Weather Summary
- Active Crops
- Current Crop Stage
- Pending Reminders
- AI Insights
- Disease Alerts
- Market Snapshot
- Scheme Recommendations

---

# Screens

## Authentication

- Splash Screen
- Onboarding
- Login
- Register
- Forgot Password

## Farmer

- Farmer Profile
- Dashboard
- Crop List
- Add Crop
- Crop Details

## AI

- AI Chat
- Suggested Questions

## Disease

- Upload Image
- Disease Report

## Advisory

- Weather Screen
- Fertilizer Advisor
- Irrigation Advisor

## Market

- Market Prices
- Price Trends

## Schemes

- Government Schemes
- Scheme Details

## Records

- Reminders
- Notifications
- Farm History

## Settings

- Profile Settings
- Language Settings
- Help Center
- About App

---

# Firestore Collections

- users
- crops
- cropStages
- chatHistory
- diseaseReports
- fertilizerRecommendations
- irrigationRecommendations
- weatherData
- marketPrices
- schemes
- reminders
- notifications
- knowledgeBase

---

# Recommended Folder Structure

```text
lib/
  core/
    config/
    constants/
    theme/
    routes/
  models/
  services/
  repositories/
  providers/
  screens/
  widgets/
  utils/
assets/
  images/
  icons/
  translations/
```

---

# Non Functional Requirements

- Responsive UI
- Clean Architecture
- Secure Authentication
- Firestore Security Rules
- Offline Caching
- Fast Loading
- Production Ready
- Modular Design
- Scalable Codebase

---

# Future Scope

- Voice-Based Farmer Assistant
- Regional Language AI
- Expert Consultation
- Community Forum
- Yield Prediction
- Soil Analysis
- IoT Integration
- Drone Monitoring
- Satellite Monitoring
- Crop Insurance Assistance
- Agricultural Marketplace

---

# Codex Instructions

Read this entire specification.

Build the complete Flutter application.

Generate:

- Complete folder structure
- Firebase setup
- Authentication flow
- Firestore schema
- Models
- Repositories
- Services
- Providers
- Navigation
- Responsive UI
- AI Agent Architecture
- Disease Detection Workflow
- Weather Module
- Market Module
- Government Scheme Module
- Reminder System

Do not generate placeholders.

Generate production-ready code following clean architecture principles.
