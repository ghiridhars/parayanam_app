# HOW THIS WORKS - Parayanam Reading Management App

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Data Models](#data-models)
4. [Application Flow](#application-flow)
5. [Screen-by-Screen Breakdown](#screen-by-screen-breakdown)
6. [Data Persistence](#data-persistence)
7. [Key Features](#key-features)
8. [Technical Implementation](#technical-implementation)

---

## Overview

The **Parayanam Reading Management App** is a Flutter-based mobile application designed to manage and coordinate reading assignments for religious texts like Bhagavatam, Sivapuranam, and Ramayanam. The app facilitates organized group reading sessions by tracking reader assignments, managing daily reading limits, and maintaining session-based configurations.

### Purpose
- **Coordinate group reading** of religious texts during specific time periods
- **Track multiple reading sessions** with calendar-based visualization
- **Assign readers** with customizable categories and line/paragraph limits
- **Monitor daily progress** with dual tracking (lines and paragraphs)
- **Maintain historical records** of all reading assignments

### Target Users
- Religious organizations coordinating group scripture readings
- Temple administrators managing reading schedules
- Community leaders organizing Parayanam sessions
- Individual users tracking their reading groups

---

## Architecture

### Technology Stack
- **Framework**: Flutter 3.9.2+
- **Language**: Dart
- **State Management**: StatefulWidget (built-in Flutter state management)
- **Data Persistence**: SharedPreferences (local key-value storage)
- **UI Components**: Material Design 3
- **Calendar**: table_calendar 3.1.2
- **Date Formatting**: intl 0.19.0

### Application Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── book.dart               # Book entity (Bhagavatam, etc.)
│   ├── reader.dart             # Reader assignment model
│   ├── reader_category.dart    # Category configuration (A, B, C, D)
│   ├── reading_session.dart    # Session model
│   ├── day_configuration.dart  # Daily limit configuration
│   ├── day_status.dart         # Day completion tracking
│   └── user_profile.dart       # User profile model
├── screens/                     # UI screens
│   ├── login_screen.dart       # User authentication
│   ├── book_selection_screen.dart  # Book catalog
│   ├── sessions_screen.dart    # Calendar view of sessions
│   ├── create_session_screen.dart  # Session creation
│   ├── day_planning_screen.dart    # Day-by-day planning
│   ├── reader_assignment_screen.dart # Reader management
│   └── profile_screen.dart     # Settings and profile
└── services/
    └── data_service.dart       # Data persistence layer
```

### Design Patterns
1. **Repository Pattern**: DataService acts as a single source of truth for all data operations
2. **Model-View Pattern**: Clean separation between data models and UI screens
3. **Stateful Widgets**: Each screen manages its own state independently
4. **Factory Pattern**: Models have `fromJson` factory constructors for deserialization

---

## Data Models

### 1. Book
Represents a religious text available for reading sessions.

**Properties:**
- `id`: Unique identifier (e.g., "bhagavatam")
- `name`: Internal name
- `displayName`: User-facing name
- `totalDays`: Reading cycle duration (7 days for Bhagavatam)
- `isActive`: Whether the book is available for selection
- `backgroundImage`: Optional background image path

**Available Books:**
- Bhagavatam (7 days) - Active
- Ramayanam (9 days) - Coming soon
- Sivapuranam (11 days) - Coming soon

### 2. ReadingSession
Represents a scheduled reading period for a book.

**Properties:**
- `id`: Unique session identifier
- `name`: User-defined session name (e.g., "Bhagavatam December 2025")
- `bookId`: Reference to the book being read
- `startDate`: Session start date
- `endDate`: Session end date
- `userProfileId`: Creator's profile ID
- `readerIds`: List of reader IDs in this session
- `colorCode`: Hex color for calendar visualization

**Status Methods:**
- `isActive()`: Returns true if current date is within session dates
- `isUpcoming()`: Returns true if session hasn't started
- `isCompleted()`: Returns true if session has ended

**Available Colors:**
10 predefined colors for visual differentiation on the calendar (Red, Teal, Blue, Salmon, Mint, Yellow, Purple, Sky Blue, Orange, Green)

### 3. Reader
Represents an individual reader assignment.

**Properties:**
- `id`: Unique reader ID
- `name`: Reader's name
- `categoryId`: Category assignment (A, B, C, or D)
- `punchInTime`: Timestamp of assignment
- `startLine`: Starting line number
- `endLine`: Ending line number
- `startParagraph`: Starting paragraph number
- `endParagraph`: Ending paragraph number
- `startChapter`: Starting chapter number
- `endChapter`: Ending chapter number
- `bookId`: Book reference
- `dayNumber`: Day of reading (1-7 for Bhagavatam)

**Computed Properties:**
- `totalLines`: endLine - startLine + 1
- `totalParagraphs`: endParagraph - startParagraph + 1
- `totalChapters`: endChapter - startChapter + 1

### 4. ReaderCategory
Defines reading capacity categories for readers.

**Default Categories:**
- **Category A**: 100 lines, 10 paragraphs, 5 chapters (High capacity readers)
- **Category B**: 70 lines, 7 paragraphs, 3 chapters (Medium-high capacity)
- **Category C**: 50 lines, 5 paragraphs, 2 chapters (Medium capacity)
- **Category D**: 30 lines, 3 paragraphs, 1 chapter (Lower capacity)

**Properties:**
- `id`: Category identifier (A, B, C, D)
- `name`: Display name
- `description`: Category description
- `lineCount`: Default lines per reader
- `paragraphCount`: Default paragraphs per reader
- `chapterCount`: Default chapters per reader

**Color Coding in UI:**
- Category A: Green
- Category B: Blue
- Category C: Orange
- Category D: Red

### 5. DayConfiguration
Defines daily reading limits for a specific day.

**Properties:**
- `dayNumber`: Day number (1-7 for Bhagavatam)
- `maxLines`: Maximum lines allowed for the day
- `maxParagraphs`: Maximum paragraphs allowed for the day
- `maxChapters`: Maximum chapters allowed for the day

**Default Values:**
- maxLines: 1000 lines per day
- maxParagraphs: 100 paragraphs per day
- maxChapters: 50 chapters per day

### 6. DayStatus
Tracks completion status of each day in a session.

**Properties:**
- `dayNumber`: Day number
- `isDone`: Completion flag
- `completedAt`: Timestamp of completion (optional)

### 7. UserProfile
Stores user authentication and profile information.

**Properties:**
- `id`: Unique user ID
- `name`: User's full name
- `email`: User's email address
- `createdAt`: Account creation timestamp

---

## Application Flow

### Initial Launch Flow

```
App Launch (main.dart)
    ↓
LoginScreen
    ↓
Check SharedPreferences for existing profile
    ↓
┌─────────────────┴─────────────────┐
│                                   │
Profile Found                    No Profile
    ↓                                ↓
Auto-login to                   Display Login Form
BookSelectionScreen                  ↓
                              User enters name/email
                                     ↓
                              Save to SharedPreferences
                                     ↓
                              Navigate to BookSelectionScreen
```

### Main Application Flow

```
BookSelectionScreen (Home)
    │
    ├── Sessions Icon → SessionsScreen
    │                       ↓
    │                   Calendar View
    │                       ↓
    │                   Select Date/Session
    │                       ↓
    │                   DayPlanningScreen
    │                       ↓
    │                   Select Day → ReaderAssignmentScreen
    │
    ├── Profile Icon → ProfileScreen
    │                       ↓
    │                   Configure Categories
    │                       ↓
    │                   Configure Day Limits
    │                       ↓
    │                   Logout Option
    │
    └── Select Book → SessionsScreen (filtered by book)
                            ↓
                        Create New Session
                            ↓
                        CreateSessionScreen
                            ↓
                        Configure Session
                            ↓
                        Return to SessionsScreen
```

### Reader Assignment Flow

```
ReaderAssignmentScreen
    ↓
Load existing readers for selected day
    ↓
Calculate current line/paragraph position
    ↓
Display reader input form
    ↓
User enters reader name
    ↓
User selects category (A/B/C/D)
    ↓
Calculate assignment:
  - Start Line = Current Line
  - End Line = Current Line + Category Line Count - 1
  - Start Paragraph = Current Paragraph
  - End Paragraph = Current Paragraph + Category Paragraph Count - 1
    ↓
Check day limits:
  - Lines used vs maxLines
  - Paragraphs used vs maxParagraphs
    ↓
┌─────────────────┴─────────────────┐
│                                   │
Within Limits                   Limit Reached
    ↓                                ↓
Save Reader                     Prompt to move
Update Current Position          to next day
Display Success Message              ↓
    ↓                           User confirms
Add to Reader List                   ↓
                              Reset to Day N+1
                              Line 1, Paragraph 1
```

---

## Screen-by-Screen Breakdown

### 1. LoginScreen

**Purpose**: User authentication and profile management

**Functionality:**
- **Auto-login**: Checks for existing user profile on launch
- **Profile Creation**: First-time users enter name and email
- **Validation**: Ensures both fields are filled
- **Data Persistence**: Saves profile to SharedPreferences

**User Flow:**
1. App checks for existing profile
2. If found, auto-navigates to BookSelectionScreen
3. If not found, displays login form
4. User enters credentials
5. Profile saved locally
6. Navigate to BookSelectionScreen

**UI Elements:**
- Name text field
- Email text field
- Sign In button
- Loading indicator during auto-login check

---

### 2. BookSelectionScreen

**Purpose**: Central hub for selecting books and accessing features

**Functionality:**
- **Book Catalog**: Displays available books with status badges
- **Sessions Access**: Top-right calendar icon
- **Profile Access**: Top-right user avatar icon
- **Background Images**: Each book can have custom background
- **Active/Inactive Status**: Coming soon books are disabled

**Navigation Options:**
1. **Sessions Icon**: Opens SessionsScreen (all sessions)
2. **Profile Icon**: Opens ProfileScreen (settings)
3. **Select Active Book**: Opens SessionsScreen (filtered by book)

**UI Elements:**
- AppBar with title "Reading Management"
- Sessions icon button (event_note)
- Profile avatar button (user initial)
- Book cards with:
  - Book name
  - Day count
  - Status badge (Active/Coming Soon)
  - Background image
  - Tap gesture

**Book Card Display:**
```
┌─────────────────────────────┐
│   [Background Image]        │
│                             │
│   Bhagavatam               │
│   7 days                   │
│   [Active Badge]           │
└─────────────────────────────┘
```

---

### 3. SessionsScreen

**Purpose**: Calendar-based view of all reading sessions

**Functionality:**
- **Calendar Display**: Table calendar showing all days
- **Session Markers**: Colored dots on dates with sessions
- **Session Filtering**: 
  - All sessions (from book selection sessions icon)
  - Book-specific sessions (from book card)
- **Session Status**: Visual badges (Active/Upcoming/Completed)
- **Session Management**: Create, view, and delete sessions

**Key Features:**
1. **Color-coded Dots**: Each session has a unique color
2. **Date Selection**: Tap any date to see sessions
3. **Session Details**:
   - Session name
   - Book name
   - Date range
   - Status badge
   - Reader count
4. **Action Buttons**:
   - "New Session" (floating action button)
   - "View Planning" (on session card)
   - Delete icon (on session card)

**Calendar View:**
```
        December 2025
Su  Mo  Tu  We  Th  Fr  Sa
 1   2   3   4   5   6   7
 8   9  10• 11• 12• 13• 14
15  16  17  18  19  20  21

• = Session active on this day
```

**Session Card:**
```
┌─────────────────────────────┐
│ Bhagavatam Dec 2025  [Active]│
│ Bhagavatam                  │
│ Dec 10 - Dec 16             │
│ 15 readers                  │
│ [View Planning]      [🗑️]   │
└─────────────────────────────┘
```

**Status Logic:**
- **Active**: startDate ≤ today ≤ endDate (green badge)
- **Upcoming**: today < startDate (blue badge)
- **Completed**: today > endDate (grey badge)

---

### 4. CreateSessionScreen

**Purpose**: Create and configure new reading sessions

**Functionality:**
- **Basic Info**: Name, book, dates, color
- **Day Configuration**: Set max lines/paragraphs for each day
- **Category Configuration**: Customize category limits
- **Validation**: Ensures all required fields are filled
- **Default Loading**: Loads defaults from profile settings

**Configuration Sections:**

**1. Session Details:**
- Session name (text input)
- Book selection (dropdown)
- Start date (date picker)
- End date (date picker)
- Color selection (color grid)

**2. Day Configuration:**
- Expandable section for each day (1-7 for Bhagavatam)
- Max lines input per day
- Max paragraphs input per day
- Visual representation:
```
Day 1
├── Max Lines: [1000]
└── Max Paragraphs: [100]
```

**3. Category Configuration:**
- Expandable section for each category (A, B, C, D)
- Line count input
- Paragraph count input
- Visual representation:
```
Category A - High capacity readers
├── Lines: [100]
└── Paragraphs: [10]
```

**Create Flow:**
1. User enters session name
2. Selects book (auto-fills if coming from book card)
3. Picks start and end dates
4. Chooses calendar color
5. Reviews/modifies day configurations
6. Reviews/modifies category settings
7. Clicks "Create Session"
8. Validates all fields
9. Saves session and configurations
10. Returns to SessionsScreen

**Validation Rules:**
- Session name must not be empty
- Book must be selected
- Start date must be selected
- End date must be after or equal to start date
- All day configurations must have positive values
- All category configurations must have positive values

---

### 5. DayPlanningScreen

**Purpose**: Day-by-day overview and navigation for a session

**Functionality:**
- **Day List**: Shows all days for the session (1-7)
- **Day Status**: Indicates completion status
- **Reader Count**: Shows assigned readers per day
- **Progress Tracking**: Visual indicators of completion
- **Day Navigation**: Tap to open ReaderAssignmentScreen

**Day Card Display:**
```
┌─────────────────────────────┐
│ Day 1 - Dec 10, 2025       │
│ ✓ Done                      │
│ 25 readers assigned         │
│ 950/1000 lines             │
│ 95/100 paragraphs          │
│ [View Assignments]          │
└─────────────────────────────┘
```

**Status Indicators:**
- **Not Started**: Grey, no checkmark
- **In Progress**: Blue, reader count shown
- **Done**: Green checkmark, locked for new assignments

**Actions:**
1. **Mark as Done**: Checkbox to complete a day
2. **View Assignments**: Navigate to ReaderAssignmentScreen
3. **Unmark Done**: Remove completion status (with confirmation)

**Day Status Logic:**
```
Day not started → Add readers → In progress
                              ↓
                   Mark as done → Day completed
                              ↓
                   Unmark done → In progress
```

---

### 6. ReaderAssignmentScreen

**Purpose**: Manage reader assignments for a specific day

**Functionality:**
- **Reader Input**: Name and category selection
- **Automatic Assignment**: Calculates line/paragraph ranges
- **Progress Tracking**: Dual progress bars (lines & paragraphs)
- **Reader List**: Shows all assigned readers
- **Individual Deletion**: Remove specific readers
- **Bulk Clear**: Reset entire day

**Header Information:**
```
Day 1 of 7
━━━━━━━━━━━━━━━━━━━━━━━━━━
Lines: 500/1000 ▓▓▓▓▓░░░░░ 50%
Paragraphs: 50/100 ▓▓▓▓▓░░░░░ 50%
```

**Add Reader Form:**
```
┌─────────────────────────────┐
│ Reader Name: [_________]    │
│ Category: [▼ Category A]    │
│          (100 lines, 10 ¶)  │
│ [Add Reader]                │
└─────────────────────────────┘
```

**Reader Card:**
```
┌─────────────────────────────┐
│ John Doe              [🗑️]  │
│ [A] Category A             │
│ Lines: 1-100 (100 total)   │
│ Paragraphs: 1-10 (10 ¶)    │
│ 2:30 PM, Dec 10, 2025      │
└─────────────────────────────┘
```

**Assignment Logic:**
1. User enters reader name
2. Selects category (A/B/C/D)
3. App calculates:
   ```
   startLine = currentLine
   endLine = currentLine + category.lineCount - 1
   startParagraph = currentParagraph
   endParagraph = currentParagraph + category.paragraphCount - 1
   ```
4. Checks both day limits:
   ```
   totalLinesUsed = sum of all readers' totalLines
   totalParagraphsUsed = sum of all readers' totalParagraphs
   
   if (totalLinesUsed > maxLines || totalParagraphsUsed > maxParagraphs) {
     prompt to move to next day
   }
   ```
5. Saves reader assignment
6. Updates current line/paragraph position
7. Updates progress bars

**Delete Reader Logic:**
1. User clicks delete icon on reader card
2. Confirmation dialog appears
3. If confirmed:
   - Remove reader from list
   - Recalculate all subsequent readers' positions
   - Update current line/paragraph counters
   - Refresh progress bars

**Clear All Logic:**
1. User clicks trash icon in AppBar
2. Confirmation dialog appears
3. If confirmed:
   - Remove all readers for current day
   - Reset to Day 1, Line 1, Paragraph 1
   - Clear progress bars

**Progress Bar Colors:**
- Green: < 80% capacity
- Orange: 80-99% capacity
- Red: ≥ 100% capacity (over limit)

---

### 7. ProfileScreen

**Purpose**: User settings and default configurations

**Functionality:**
- **User Info Display**: Name, email, join date
- **Default Day Configurations**: Per-book day limits
- **Default Categories**: Per-book category settings
- **Logout**: Clear profile and return to login

**Profile Section:**
```
┌─────────────────────────────┐
│      [J]                    │
│   John Doe                  │
│   john@example.com          │
│   Member since Dec 1, 2025  │
└─────────────────────────────┘
```

**Book Configuration (Expandable):**
```
▼ Bhagavatam Settings
  ┌─────────────────────────┐
  │ Default Day Configuration│
  │                         │
  │ Day 1                   │
  │ Max Lines: [1000]       │
  │ Max Paragraphs: [100]   │
  │ ... (Days 2-7)          │
  │                         │
  │ [Save Day Config]       │
  └─────────────────────────┘
  
  ┌─────────────────────────┐
  │ Default Reader Categories│
  │                         │
  │ Category A              │
  │ Lines: [100]            │
  │ Paragraphs: [10]        │
  │ ... (Categories B-D)    │
  │                         │
  │ [Save Categories]       │
  └─────────────────────────┘
```

**Configuration Scope:**
- **Profile Defaults**: Used as templates for new sessions
- **Session-Specific**: Can be customized during session creation
- **Independence**: Each session maintains its own configuration

**Settings Flow:**
1. User navigates to Profile
2. Expands book section (e.g., Bhagavatam)
3. Modifies day configurations or categories
4. Clicks "Save" button
5. Settings saved to SharedPreferences
6. Success message displayed
7. New sessions will use these as defaults

**Logout Flow:**
1. User clicks "Logout" button
2. Confirmation dialog appears
3. If confirmed:
   - Clear user profile from SharedPreferences
   - Navigate to LoginScreen
   - Clear navigation stack

---

## Data Persistence

### Storage Technology: SharedPreferences

**SharedPreferences** is a key-value storage system that persists data locally on the device. The app uses it to store all application data without requiring a backend server.

### Data Storage Keys

| Key Pattern | Description | Example Value |
|------------|-------------|---------------|
| `categories_{bookId}` | Reader categories for a book | JSON array of ReaderCategory objects |
| `readers_{bookId}` | All readers for a book | JSON array of Reader objects |
| `current_line_{bookId}` | Current line number | Integer (1-99999) |
| `current_paragraph_{bookId}` | Current paragraph number | Integer (1-9999) |
| `user_profile` | Current user profile | JSON object of UserProfile |
| `day_config_{bookId}` | Day configurations for a book | JSON array of DayConfiguration objects |
| `current_day_{bookId}` | Current day number | Integer (1-7) |
| `sessions` | All reading sessions | JSON array of ReadingSession objects |
| `active_session_{bookId}` | Current active session ID | String |
| `session_categories_{sessionId}` | Categories for a session | JSON array |
| `session_day_config_{sessionId}` | Day configs for a session | JSON array |
| `day_statuses_{sessionId}` | Day completion statuses | JSON array |

### Data Service Methods

**Category Management:**
```dart
saveCategories(String bookId, List<ReaderCategory> categories)
loadCategories(String bookId) → List<ReaderCategory>
```

**Reader Management:**
```dart
saveReaders(String bookId, List<Reader> readers)
loadReaders(String bookId) → List<Reader>
addReader(Reader reader)
deleteReader(String bookId, String readerId)
```

**Session Management:**
```dart
saveReadingSession(ReadingSession session)
getAllReadingSessions() → List<ReadingSession>
deleteReadingSession(String sessionId)
getActiveSession(String bookId) → ReadingSession?
setActiveSession(String bookId, String sessionId)
```

**Day Configuration:**
```dart
saveDayConfigurations(String bookId, List<DayConfiguration> configs)
loadDayConfigurations(String bookId, int totalDays) → List<DayConfiguration>
```

**Position Tracking:**
```dart
getCurrentLine(String bookId) → int
setCurrentLine(String bookId, int lineNumber)
getCurrentParagraph(String bookId) → int
setCurrentParagraph(String bookId, int paragraphNumber)
getCurrentDay(String bookId) → int
setCurrentDay(String bookId, int dayNumber)
```

**User Profile:**
```dart
saveUserProfile(UserProfile profile)
getCurrentUserProfile() → UserProfile?
clearUserProfile()
```

**Day Status:**
```dart
saveDayStatuses(String sessionId, List<DayStatus> statuses)
loadDayStatuses(String sessionId, int totalDays) → List<DayStatus>
```

### Data Serialization

All models implement:
- `toJson()`: Converts object to Map<String, dynamic>
- `fromJson(Map<String, dynamic>)`: Factory constructor for deserialization

**Example:**
```dart
// Saving
final reader = Reader(...);
final json = reader.toJson();
await prefs.setString(key, jsonEncode(json));

// Loading
final jsonString = prefs.getString(key);
final json = jsonDecode(jsonString);
final reader = Reader.fromJson(json);
```

### Data Isolation

- **Per-Book Storage**: Each book has independent data storage
- **Per-Session Storage**: Session-specific configurations are isolated
- **User Scope**: All data is tied to the current user profile

### Data Lifetime

- **Persistent**: Data survives app restarts
- **User-Scoped**: Cleared only on logout
- **Manual Deletion**: Users can delete sessions and readers
- **No Expiration**: No automatic data cleanup

---

## Key Features

### 1. Multi-Session Management

**Capability**: Multiple simultaneous reading sessions with independent configurations

**Use Case**: Run parallel sessions for different groups or time periods

**Implementation:**
- Each session has unique ID
- Session-specific categories and day configs
- Calendar view shows all sessions
- Color-coded for visual differentiation
- Status tracking (Active/Upcoming/Completed)

**Example Scenario:**
```
Session 1: "Bhagavatam Morning Group"
  - Dec 10-16, 2025
  - Category A: 120 lines
  - Color: Green

Session 2: "Bhagavatam Evening Group"
  - Dec 10-16, 2025
  - Category A: 80 lines
  - Color: Blue
```

### 2. Triple Progress Tracking

**Capability**: Track lines, paragraphs, and chapters independently

**Rationale**: Religious texts are structured in lines, logical paragraphs, and thematic chapters

**Implementation:**
- Each reader assigned line, paragraph, and chapter ranges
- Separate progress bars for each metric
- Day limits enforced for all three
- Independent counters maintained

**Visual:**
```
Reader Assignment:
Lines: 1-100 (100 total)
Paragraphs: 1-10 (10 total)
Chapters: 1-5 (5 total)

Day Progress:
Lines: ▓▓▓▓▓░░░░░ 500/1000 (50%)
Paragraphs: ▓▓▓▓▓░░░░░ 50/100 (50%)
Chapters: ▓▓▓░░░░░░░ 25/50 (50%)
```

### 3. Flexible Category System

**Capability**: Categorize readers by reading capacity

**Benefits:**
- Accommodates different reading speeds
- Fair distribution of workload
- Easy assignment process
- Visual identification

**Customization:**
- Default values provided
- Per-book customization
- Per-session customization
- Runtime modification

**Category Workflow:**
```
1. Configure default categories in Profile
2. Optionally customize during session creation
3. Select category when adding reader
4. App auto-calculates assignment
```

### 4. Day Limit Management

**Capability**: Set and enforce daily reading limits

**Purpose:**
- Prevent overloading any single day
- Ensure even distribution
- Maintain sustainable pace

**Features:**
- Per-day configuration (each day can differ)
- Dual limits (lines and paragraphs)
- Visual progress indicators
- Automatic overflow detection
- Prompt to advance to next day

**Limit Enforcement:**
```
if (totalLinesUsed > maxLines || totalParagraphsUsed > maxParagraphs) {
  showDialog("Day limit reached. Move to next day?");
}
```

### 5. Calendar Visualization

**Capability**: Visual representation of all sessions

**Features:**
- Month view with date navigation
- Color-coded session markers
- Multi-session support per date
- Tap to view session details
- Status badges

**Calendar Markers:**
- Single dot: One session on date
- Multiple dots: Multiple sessions (stacked colors)
- Dot color: Session's selected color

### 6. Reader Assignment Automation

**Capability**: Automatic calculation of reading ranges

**Process:**
1. User selects category
2. App fetches category limits
3. Calculates start/end positions
4. Checks day limits
5. Saves assignment
6. Updates counters

**Calculation:**
```dart
startLine = currentLine;
endLine = currentLine + category.lineCount - 1;
startParagraph = currentParagraph;
endParagraph = currentParagraph + category.paragraphCount - 1;
startChapter = currentChapter;
endChapter = currentChapter + category.chapterCount - 1;
currentLine = endLine + 1;
currentParagraph = endParagraph + 1;
currentChapter = endChapter + 1;
```

### 7. Reader Deletion with Recalculation

**Capability**: Remove readers and automatically adjust remaining assignments

**Complexity**: Maintains data integrity after deletion

**Algorithm:**
```
1. Find reader to delete at index i
2. Remove reader from list
3. For each reader after index i:
   a. Shift startLine/startParagraph to previous reader's end + 1
   b. Recalculate endLine/endParagraph based on category
4. Update currentLine/currentParagraph to last reader's end + 1
5. Update progress bars
6. Save updated reader list
```

**Example:**
```
Before deletion:
Reader 1: Lines 1-100
Reader 2: Lines 101-200  ← Delete this
Reader 3: Lines 201-250

After deletion:
Reader 1: Lines 1-100
Reader 3: Lines 101-150  ← Recalculated
```

### 8. Session Status Tracking

**Capability**: Automatic status determination based on dates

**Status Types:**
1. **Upcoming**: startDate > today
2. **Active**: startDate ≤ today ≤ endDate
3. **Completed**: endDate < today

**Visual Indicators:**
- Upcoming: Blue badge
- Active: Green badge
- Completed: Grey badge

**Use Cases:**
- Quick identification of current sessions
- Historical record keeping
- Planning future sessions

### 9. Auto-login

**Capability**: Persistent user session across app restarts

**Implementation:**
- Save user profile on first login
- Check for profile on app launch
- Auto-navigate if profile exists
- Skip login screen for returning users

**Flow:**
```
App Launch
    ↓
Check SharedPreferences
    ↓
Profile found? → Yes → BookSelectionScreen
              → No → LoginScreen
```

### 10. Day Completion Marking

**Capability**: Mark days as complete to prevent further assignments

**Purpose:**
- Lock completed days
- Prevent accidental modifications
- Track progress through session

**Features:**
- Confirmation dialog before marking
- Visual checkmark indicator
- Unmark option available
- Prevents new reader additions to done days

---

## Technical Implementation

### 1. State Management

**Approach**: StatefulWidget with local state

**Rationale:**
- Simple application structure
- Screen-level state independence
- No complex state sharing needs
- Built-in Flutter capability

**Pattern:**
```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  List<Reader> _readers = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final readers = await _dataService.loadReaders(bookId);
    setState(() {
      _readers = readers;
      _isLoading = false;
    });
  }
}
```

### 2. Navigation

**Approach**: Navigator 1.0 (push/pop)

**Routes:**
- `Navigator.push()`: Forward navigation
- `Navigator.pop()`: Back navigation
- `Navigator.pushReplacement()`: Replace current screen
- `Navigator.pushAndRemoveUntil()`: Clear stack and navigate

**Example:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SessionsScreen(userProfile: profile),
  ),
);
```

### 3. Asynchronous Operations

**Pattern**: async/await with Future

**Usage:**
- Data loading
- Data saving
- User confirmations
- Date picking

**Example:**
```dart
Future<void> _addReader() async {
  if (_nameController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter reader name')),
    );
    return;
  }
  
  final reader = Reader(...);
  await _dataService.addReader(reader);
  await _loadData();
}
```

### 4. Data Validation

**Levels:**
1. **UI Level**: Text field validation
2. **Business Logic**: Range checks
3. **Data Service**: Null checks

**Example:**
```dart
// UI validation
if (_nameController.text.trim().isEmpty) {
  showSnackBar('Please enter name');
  return;
}

// Business logic validation
if (_currentLine + category.lineCount > dayConfig.maxLines) {
  showDialog('Day limit exceeded');
  return;
}

// Data service validation
if (bookId == null || bookId.isEmpty) {
  return [];
}
```

### 5. Error Handling

**Approach**: Try-catch with user feedback

**Pattern:**
```dart
try {
  await _dataService.saveData(data);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Saved successfully')),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

### 6. UI Components

**Material Design 3:**
- AppBar: Screen titles and actions
- Card: Grouped content
- ListTile: List items
- TextField: User input
- ElevatedButton: Primary actions
- TextButton: Secondary actions
- SnackBar: Feedback messages
- AlertDialog: Confirmations
- CircularProgressIndicator: Loading states

**Custom Components:**
- Reader cards with delete functionality
- Category selection dropdowns
- Progress bars with dual metrics
- Calendar with session markers
- Expandable configuration sections

### 7. Date Handling

**Library**: intl package

**Formats:**
```dart
DateFormat('MMM dd, yyyy') // Dec 10, 2025
DateFormat('hh:mm a')      // 02:30 PM
```

**Calendar:**
- table_calendar widget
- Date selection
- Multi-date markers
- Custom builders

### 8. Color Management

**System:**
- Theme-based colors
- Custom color codes (hex strings)
- Category-specific colors
- Status-based colors

**Examples:**
```dart
// Theme colors
Theme.of(context).colorScheme.primary

// Session colors
ReadingSession.availableColors[0] // '#FF6B6B'

// Category colors
category.id == 'A' ? Colors.green : ...

// Status colors
session.isActive() ? Colors.green : ...
```

### 9. Input Formatting

**Text Input:**
- Number formatters for line/paragraph counts
- Text capitalization for names
- Email keyboard for email input

**Example:**
```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
  ],
)
```

### 10. Lifecycle Management

**Widget Lifecycle:**
```dart
initState()     // Load initial data
build()         // Render UI
dispose()       // Clean up controllers

// Controller disposal
@override
void dispose() {
  _nameController.dispose();
  _emailController.dispose();
  super.dispose();
}
```

**mounted check:**
```dart
if (!mounted) return;  // Prevent setState on unmounted widgets
```

---

## Screenshots and Visual References

### Available Images in Repository

The repository contains a background image that can be used for visual enhancement:

**Background Image:**
- Location: `web/bagawatham.jpg`
- Usage: Background for Bhagavatam book selection
- Display: Semi-transparent overlay (60% opacity)

### App Icons

Application icons are available for all platforms:
- **Android**: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- **iOS**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Web**: `web/icons/Icon-*.png`
- **macOS**: `macos/Runner/Assets.xcassets/AppIcon.appiconset/`

### UI Screenshots Guidance

To capture screenshots of the app in action:

**On Web (Chrome):**
```bash
flutter run -d chrome --web-browser-flag "--window-size=412,915"
```

**On Android:**
```bash
flutter run
```

**Key Screens to Screenshot:**
1. Login Screen - User authentication
2. Book Selection - Main hub with sessions/profile icons
3. Sessions Screen - Calendar view with colored dots
4. Create Session - Configuration form
5. Day Planning - Day list with status
6. Reader Assignment - Reader cards and progress bars
7. Profile Screen - Settings and configurations

### Visual Design Elements

**Color Scheme:**
- Primary: Deep Purple (from Material Design)
- Session Colors: 10 vibrant colors for differentiation
- Category Colors: Green (A), Blue (B), Orange (C), Red (D)
- Status Colors: Green (Active), Blue (Upcoming), Grey (Completed)

**Typography:**
- Headers: 24pt, Bold
- Body: 16pt, Regular
- Captions: 14pt, Regular
- Category Badges: 12pt, Bold

**Spacing:**
- Card padding: 16px
- Section spacing: 20px
- Item spacing: 12px
- Input field spacing: 8px

---

## Data Flow Diagrams

### Reader Assignment Flow
```
User Input (Name + Category)
        ↓
Validate Input (not empty)
        ↓
Fetch Category Configuration
        ↓
Calculate Assignment
  ├── startLine = currentLine
  ├── endLine = currentLine + category.lineCount - 1
  ├── startParagraph = currentParagraph
  └── endParagraph = currentParagraph + category.paragraphCount - 1
        ↓
Check Day Limits
  ├── totalLines ≤ maxLines?
  └── totalParagraphs ≤ maxParagraphs?
        ↓
    ┌───┴───┐
    │       │
   Yes     No
    │       │
    │       └→ Prompt to move to next day
    │                 ↓
    │            User confirms?
    │                 ↓
    │              Yes → Reset to next day
    │               No → Cancel
    ↓
Create Reader Object
        ↓
Save to DataService
        ↓
Update Current Position
  ├── currentLine = endLine + 1
  └── currentParagraph = endParagraph + 1
        ↓
Refresh UI
  ├── Add to reader list
  ├── Update progress bars
  └── Show success message
```

### Session Creation Flow
```
User Input
  ├── Session name
  ├── Book selection
  ├── Start/End dates
  └── Color selection
        ↓
Load Default Configurations
  ├── Day configurations for book
  └── Category settings for book
        ↓
User Reviews/Modifies
  ├── Day limits (lines & paragraphs)
  └── Category limits (lines & paragraphs)
        ↓
Validate All Fields
  ├── Name not empty?
  ├── Dates valid?
  └── All configs have positive values?
        ↓
Create Session Object
        ↓
Save to DataService
  ├── Session metadata
  ├── Session-specific day configs
  └── Session-specific categories
        ↓
Navigate Back to Sessions Screen
        ↓
Show Success Message
```

### Data Persistence Flow
```
Application Layer (Screens)
        ↓
    DataService
        ↓
  JSON Serialization
   (toJson/fromJson)
        ↓
  SharedPreferences
        ↓
   Device Storage
   (Key-Value Pairs)

Read Flow:
Device Storage → SharedPreferences → JSON String
     → jsonDecode → Map<String, dynamic>
     → Model.fromJson → Object
     → Application Layer

Write Flow:
Application Layer → Object
     → toJson → Map<String, dynamic>
     → jsonEncode → JSON String
     → SharedPreferences → Device Storage
```

---

## Future Enhancements

Based on the current code structure, potential enhancements include:

1. **Additional Books**: Activate Ramayanam and Sivapuranam
2. **Cloud Sync**: Backend integration for multi-device access
3. **Export/Import**: Data backup and restore functionality
4. **Analytics**: Reading statistics and reports
5. **Notifications**: Reminders for upcoming sessions
6. **Multi-language**: Support for regional languages
7. **Print Support**: Generate printed reading assignments
8. **Audio Integration**: Link to audio recordings of texts
9. **Search**: Find specific readers or sessions
10. **Themes**: Dark mode and custom themes

---

## Troubleshooting

### Common Issues

**1. Login Screen doesn't auto-login**
- Check if SharedPreferences has `user_profile` key
- Verify JSON deserialization is working
- Ensure network permissions (if backend added)

**2. Readers not showing in list**
- Verify `readers_{bookId}` key in SharedPreferences
- Check if day filtering is correct
- Ensure JSON serialization matches model

**3. Progress bars not updating**
- Recalculate totalLinesUsed and totalParagraphsUsed
- Verify setState() is called after changes
- Check day configuration is loaded

**4. Sessions not appearing on calendar**
- Verify date range calculation
- Check if session dates overlap with calendar view
- Ensure color code is valid hex string

**5. Category not showing correct values**
- Reload categories from SharedPreferences
- Check if book-specific categories exist
- Verify default categories are initialized

### Debug Strategies

1. **Print Statements**: Add debug prints to track data flow
2. **Breakpoints**: Use Flutter DevTools for debugging
3. **SharedPreferences Inspector**: Check stored data
4. **Widget Inspector**: Examine widget tree
5. **Network Tab**: Monitor async operations (if backend added)

---

## Conclusion

The Parayanam Reading Management App is a comprehensive solution for coordinating group reading sessions of religious texts. Its architecture emphasizes:

- **Simplicity**: Straightforward data models and flows
- **Flexibility**: Customizable configurations at multiple levels
- **Reliability**: Local data persistence without network dependency
- **Usability**: Intuitive UI with Material Design
- **Scalability**: Extensible to additional books and features

The app successfully addresses the complex requirements of managing multi-day reading sessions with varying reader capacities, triple progress tracking (lines, paragraphs, and chapters), and calendar-based visualization, all while maintaining data integrity and user-friendly operation.

---

*Documentation created for Parayanam Reading Management App v1.0.0*
*Last updated: December 2025*
