# Dynamic Profile Ordering

## Architecture

This app follows the MVVM (Model-View-ViewModel) architecture pattern for clean separation of concerns.

## Project Structure

### App Entry Point

**`AppDelegate.swift`**
- Application entry point that sets up the window and initial view controller
- Creates the `ProfileViewModel` with dependency injection
- Configures the navigation controller with `DynamicProfileViewController` as the root

### Models

**`Models/Profile.swift`**
- Defines the `Profile` struct representing a user profile with fields like id, name, gender, photo, about, school, job, location, and age
- Includes `ProfilesResponse` struct for decoding the API response containing an array of profiles
- All fields except id, name, and gender are optional to match the API structure

**`Models/ProfileConfiguration.swift`**
- Defines the `ProfileConfiguration` struct containing the ordered list of field names
- Uses `CodingKeys` to map Swift's camelCase `fieldOrder` property to the API's snake_case `field_order` JSON key
- Includes `ProfileConfigurationResponse` struct for decoding the configuration API response

### Network Layer

**`Network/ProfileConfigurationFetcher.swift`**
- Handles all network requests using URLSession
- Fetches profiles from the `/users` endpoint
- Fetches profile configuration from the `/config` endpoint
- Defines `NetworkError` enum for error handling
- Uses a singleton pattern for shared access

### ViewModels

**`ViewModels/ProfileViewModel.swift`**
- Contains the business logic for managing profiles and configuration
- Manages the current profile index and navigation state
- Filters and orders field names based on configuration and profile data availability
- Implements `ProfileViewModelDelegate` protocol for communicating state changes to the view
- Handles loading profiles and configuration concurrently using DispatchGroup
- Provides computed properties for UI state (current profile, button titles, navigation state)

### Views

**`Views/DynamicProfileViewController.swift`**
- Main view controller responsible for UI presentation
- Displays profiles in a scrollable view with dynamically ordered fields
- Creates UI components (labels, text views, image views) based on field names from the view model
- Handles user interactions (next button) and delegates actions to the view model
- Implements `ProfileViewModelDelegate` to react to state changes
- Manages image loading from URLs for profile photos

## Features

- Displays user profiles one at a time
- Profile field order is controlled by a configuration object from an API
- Navigate through profiles with a "Next Profile" button
- Automatically filters out fields that don't exist in the current profile
- Extensible architecture for easy modification and testing

## Setup

1. Open `DynamicProfileOrdering.xcodeproj` in Xcode
2. Build and run on a simulator or device