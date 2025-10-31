# Reading Management App

A Flutter application for managing reading assignments for religious texts like Bhagavatam, Sivapuranam, and Ramayanam with session-based configuration and calendar visualization.

## Features

### 1. Login Screen
- User authentication with name and email
- Profile information is saved and persists across sessions
- Auto-login for returning users

### 2. Book Selection Screen
- Currently showing: **Bhagavatam** (active)
- Coming soon: Sivapuranam (11 days), Ramayanam (9 days)
- **Sessions icon** for managing reading sessions
- **Profile icon** at top right for quick access to settings
- Easily extensible to add more books

### 3. Sessions Management Screen ⭐ NEW
- **Calendar View** with color-coded sessions
- View all reading sessions across time
- Sessions displayed by:
  - **Active**: Currently ongoing sessions (green)
  - **Upcoming**: Future sessions (blue)
  - **Completed**: Past sessions (grey)
- Click any day to see sessions on that date
- Color-coded dots on calendar for quick identification
- Create new sessions with custom configurations
- View session details with reader count and dates
- Delete sessions when needed

### 4. Create Session Screen ⭐ NEW
- **Session Name**: Give each reading period a unique name (e.g., "Bhagavatam December 2025")
- **Book Selection**: Choose which book for this session
- **Date Range**: Set start and end dates for the reading period
- **Color Selection**: Choose from 10 colors for calendar visualization
- **Day Configuration**: Customize max lines for each day of this session
- **Reader Categories**: Set specific line counts for categories A, B, C, D
- All configurations saved separately per session
- Each session maintains its own:
  - Day limits (7 days for Bhagavatam)
  - Category settings
  - Reader assignments

### 5. Profile & Settings Screen
- User profile information display
- **Default Day Configuration** for each book:
  - Bhagavatam: 7 days
  - Set default maximum **lines and paragraphs** per day
  - Default: 1000 lines and 100 paragraphs per day (both configurable)
- **Default Reader Categories** per book:
  - **Category A**: Readers who read more than 100 lines (default: 100 lines, 10 paragraphs)
  - **Category B**: Readers who read 60-80 lines (default: 70 lines, 7 paragraphs)
  - **Category C**: Readers who read 40-60 lines (default: 50 lines, 5 paragraphs)
  - **Category D**: Readers who read less than 40 lines (default: 30 lines, 3 paragraphs)
- Expandable sections for each book
- Settings used as defaults for new sessions
- Logout option

### 6. Reader Assignment Screen
- **Day tracking**: Shows current day (e.g., "Day 1 of 7")
- **Day limit monitoring**: 
  - Displays maximum **lines and paragraphs** allowed for current day
  - **Dual progress bars** showing usage for both lines and paragraphs
  - Auto-prompt to move to next day when either limit is reached
- Add readers with name and category selection
- Quick access to category settings via settings icon
- **Dual assignment system**:
  - **Line assignment**: Current line number (continues from last reader)
  - **Paragraph assignment**: Current paragraph number (continues from last reader)
  - Both tracked separately and assigned based on selected category
  - Punch-in time (automatically recorded)
  - Day limits for both lines and paragraphs (warns when approaching either limit)
- View all assigned readers with:
  - Name and category
  - Assigned **line range** (start to end) with total lines
  - Assigned **paragraph range** (start to end) with total paragraphs
  - Punch-in time and date
- **Delete individual readers**: 
  - Click the delete icon on any reader card
  - Confirmation dialog before deletion
  - Automatically recalculates positions for remaining readers
  - Updates current line and paragraph counters
- Clear all readers option (resets to Day 1, Line 1, Paragraph 1)

## How to Use

### Getting Started

1. **Launch the app** - You'll see the Login screen
   - Enter your name and email
   - Click "Sign In"
   - Your profile is saved for future sessions

2. **Select a book** - Choose Bhagavatam

### Managing Sessions

3. **Create a Reading Session**
   - Click the **Sessions icon** (calendar with notes) in the top bar
   - Click **"New Session"** button
   - Fill in session details:
     - **Name**: e.g., "Bhagavatam December 2025"
     - **Book**: Bhagavatam
     - **Start Date**: When reading begins
     - **End Date**: When reading ends (typically 7 days later for Bhagavatam)
     - **Color**: Choose a color for calendar visualization
   - Configure **Day Settings**:
     - Set maximum **lines and paragraphs** for each of the 7 days
     - Each day can have different limits for both metrics
   - Configure **Category Settings**:
     - Set **lines and paragraphs** for categories A, B, C, D
     - Both values customizable per category
   - Click **"Create Session"**

4. **View Sessions in Calendar**
   - Calendar shows all sessions with colored dots
   - Click any date to see sessions on that day
   - Sessions show status badges (Active/Upcoming/Completed)
   - View session details by clicking on any session
   - Delete old sessions if needed

### Daily Reading Management

5. **Assign readers** - During active session:
   - From book selection, tap on Bhagavatam
   - See current day indicator (Day X of 7)
   - Check **dual progress bars** for lines and paragraphs
   - Enter the reader's name
   - Select their category (A, B, C, or D) - shows lines and paragraphs (e.g., "100 lines, 10 ¶")
   - Click "Add Reader"
   - App automatically:
     - Assigns **line numbers** (e.g., Lines 1-100)
     - Assigns **paragraph numbers** (e.g., Paragraphs 1-10)
     - Records punch-in time
     - Checks **both** day limits (lines and paragraphs)
     - Prompts to move to next day if either limit is reached
   - Success message shows both assignments (e.g., "Lines 1-100, Paragraphs 1-10")

6. **Manage Reader Assignments**:
   - View all readers in reverse chronological order (newest first)
   - Each reader card shows:
     - Name and category badge
     - Line range with total count
     - Paragraph range with total count (marked with ¶ symbol)
     - Punch-in timestamp
   - **Delete individual readers**:
     - Click the red delete icon on any reader card
     - Confirmation dialog shows what will be removed
     - Line and paragraph positions automatically recalculate
     - Next assignment continues from last reader
   - **Clear all readers**:
     - Click trash icon in app bar
     - Resets to Day 1, Line 1, Paragraph 1

7. **Day Management**:
   - App tracks which day you're on (1-7 for Bhagavatam)
   - Monitors **both lines and paragraphs** usage
   - When approaching either limit, corresponding progress bar turns orange
   - When **either** limit is reached, app asks to move to next day
   - All reader assignments are preserved across days

### Settings Management

8. **Default Settings** (Profile Screen)
   - Access via profile icon
   - Set default configurations for new sessions
   - Configure **lines and paragraphs** for both day limits and categories
   - These become templates for session creation

9. **Session-Specific Settings**
   - Each session has its own configuration
   - Modify during session creation
   - Settings remain with that session

## Book Configuration

### Currently Active:
- **Bhagavatam**: 7 days reading cycle

### Coming Soon:
- **Ramayanam**: 9 days reading cycle
- **Sivapuranam**: 11 days reading cycle

## Technical Details

- Built with Flutter
- Uses SharedPreferences for local data persistence
- User profiles with saved login state
- Day configuration system:
  - Configurable number of days per book
  - Maximum lines per day limit
  - Automatic day progression
- Category settings stored per book
- Supports multiple books with separate configurations
- Automatic line tracking across reader assignments and days
- Color-coded categories for easy identification:
  - Category A: Green
  - Category B: Blue
  - Category C: Orange
  - Category D: Red

## Running the App

### On Web (Chrome)
```bash
# Get dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run with mobile dimensions
flutter run -d chrome --web-browser-flag "--window-size=412,915"
```

### On Android
```bash
# Setup Android Studio first (see below)

# Run on connected device or emulator
flutter run
```

### Setting Up Android Development

1. **Install Android Studio** from https://developer.android.com/studio
2. **During installation**, ensure you select:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device (AVD)
3. **After installation**:
   ```bash
   flutter doctor --android-licenses
   ```
   Accept all licenses
4. **Create an emulator** in Android Studio:
   - Tools → Device Manager → Create Device
   - Choose Pixel 6 (phone) or Pixel Tablet (tablet)
   - Select system image (Android 13+)
5. **Run the app**:
   ```bash
   flutter run
   ```

## Data Persistence

All data is stored locally on the device:
- User profile and login state
- Category configurations per book
- Reader assignments per book
- Current line number per book

Data persists across app restarts until explicitly cleared or logged out.
