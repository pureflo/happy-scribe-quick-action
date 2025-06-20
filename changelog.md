# Changelog

All notable changes to this project will be documented in this file.

## [2.1.0] - 2025-06-20

### Added
- Visual progress indicators with emoji icons during upload process
- Auto-dismissing progress dialogs (⏳ Preparing, 📤 Uploading, 🎤 Creating transcription)
- Better visual feedback without user interaction required
- Improved success message with checkmark emoji (✅)

### Changed
- Progress dialogs now auto-dismiss after 2 seconds
- Enhanced user experience with clear visual stages
- More professional and polished interface

### Fixed
- Improved cleanup of temporary progress files

## [2.0.0] - 2025-06-20

### Added
- Streamlined user interface with minimal interruptions
- System notifications for non-critical progress updates
- User-friendly error messages instead of technical details

### Changed
- **BREAKING**: Reduced dialog interactions from 6-8 to 2-3 maximum
- Replaced debugging dialogs with unobtrusive notifications
- Improved error handling with cleaner, more helpful messages
- Enhanced overall user experience flow

### Removed
- All debugging and technical progress dialogs
- Step-by-step confirmation prompts
- Raw API response displays
- Command display dialogs

## [1.2.0] - 2025-05-14

### Added
- Support for filenames with spaces and special characters
- URL encoding for proper filename handling
- Comprehensive error handling for each API step
- Detailed debugging information for troubleshooting

### Fixed
- Shell command escaping issues with complex filenames
- Quote handling in curl commands
- JSON parsing reliability improvements

### Changed
- Improved temp file handling for JSON requests
- Better error messages with command details for debugging

## [1.1.0] - 2025-05-14

### Added
- Two-step file upload process (get signed URL, then upload)
- Proper JSON request formatting for Happy Scribe API
- Organization ID parameter support
- Temporary file creation for avoiding shell escaping issues

### Fixed
- API parameter format (organization_id now properly included in JSON body)
- Shell command syntax errors
- JSON structure compliance with Happy Scribe API requirements

### Changed
- Complete API workflow restructure to match Happy Scribe documentation
- Improved error detection and handling

## [1.0.0] - 2025-05-13

### Added
- Initial release of Happy Scribe Quick Action
- Right-click context menu integration for MP3 files
- Secure API key storage in macOS Keychain
- Basic file validation (MP3 format checking)
- Transcription creation with Happy Scribe API
- Browser integration to open completed transcriptions
- MIT License for open source distribution

### Features
- macOS Automator Quick Action workflow
- One-click MP3 to transcription submission
- Automatic API key management
- Organization ID configuration
- Error handling and user feedback
- Integration with Happy Scribe web interface

## [Unreleased]

### Planned
- Support for additional audio formats (WAV, M4A, etc.)
- Batch processing for multiple files
- Language selection options
- Subtitle/caption mode toggle
- Transcription status checking
- Custom organization ID configuration dialog
