# Happy Scribe Quick Action

A macOS Quick Action workflow that allows you to easily send MP3 files to Happy Scribe for transcription directly from Finder with just a right-click.

## Features

- Sends MP3 files to Happy Scribe for transcription with a single click
- Securely stores your API key in macOS Keychain
- Shows progress at each step of the process
- Offers to open the transcription in your browser when complete
- Works directly from Finder as a Quick Action

## Requirements

- macOS (tested on macOS Monterey and later)
- A Happy Scribe account with API access
- Your Happy Scribe API key and organization ID

## Installation

1. Download the workflow file or clone this repository
2. If you downloaded the .workflow file:
   - Double-click the file to install it
   - Click "Install" when prompted

3. If you cloned the repository:
   - Open Automator
   - Create a new "Quick Action" workflow
   - Set it to receive "audio files" in "Finder"
   - Add the "Run AppleScript" action
   - Copy and paste the script from `happy-scribe-quick-action.applescript`
   - Save it as "Send to Happy Scribe"

## Configuration

Before using the workflow, you need to:

1. Get your Happy Scribe API key from your account settings
2. Know your Happy Scribe organization ID
3. Update the `organizationId` variable in the script if it's different from the default

The default organization ID in the script is set to "8761770". If your organization ID is different, you'll need to modify line 35 in the script:

```applescript
-- Organization ID for Happy Scribe
set organizationId to "YOUR_ORGANIZATION_ID"
```

## Usage

1. Right-click on any MP3 file in Finder
2. Go to "Quick Actions" in the context menu
3. Select "Send to Happy Scribe"
4. The first time you use it, you'll be prompted to enter your API key
5. Confirm the transcription request
6. A processing dialog will appear while the file is uploaded and transcription is created
7. When complete, you'll see the transcription ID and option to open it in your browser

## User Experience

The workflow is designed to be minimal and unobtrusive:

- **Single confirmation**: "Send [filename] to Happy Scribe?"
- **Processing indicator**: Shows progress without multiple interruptions
- **Success notification**: Displays transcription ID with browser option
- **Maximum 2 dialog interactions** for the complete workflow

## Troubleshooting

- **API Key Issues**: If you need to reset your API key, delete it from Keychain Access by searching for "HappyScribeAPI"
- **File Upload Errors**: Make sure your file is accessible and not locked
- **Permission Issues**: Ensure Automator has the necessary permissions in System Preferences > Security & Privacy > Privacy > Automation

## How It Works

The workflow follows these steps:

1. Gets a signed URL from Happy Scribe's API
2. Uploads the MP3 file to the provided URL
3. Creates a transcription request with the required parameters
4. Extracts the transcription ID from the response
5. Offers to open the transcription in your browser

## Contributing

Contributions are welcome! Feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Happy Scribe](https://www.happyscribe.com/) for providing the transcription API
- [Automator](https://support.apple.com/guide/automator/) for making macOS workflow automation accessible
