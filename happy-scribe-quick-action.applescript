on run {input, parameters}
    try
        -- Check if we received a file
        if input is {} then
            display dialog "No file selected." buttons {"OK"} default button "OK" with icon stop
            return input
        end if
        
        set theFile to item 1 of input
        
        -- Check if the file is an MP3
        set filePath to POSIX path of theFile
        set fileExtension to do shell script "echo " & quoted form of filePath & " | awk -F. '{print tolower($NF)}'"
        
        if fileExtension is not "mp3" then
            display dialog "Selected file is not an MP3. Please select an MP3 file." buttons {"OK"} default button "OK" with icon stop
            return input
        end if
        
        -- Get file name for the transcription
        set fileName to do shell script "basename " & quoted form of filePath
        
        -- URL encode the filename for the API request (handle spaces and special characters)
        set encodedFileName to do shell script "echo " & quoted form of fileName & " | sed 's/ /%20/g'"
        
        -- Get API key from Keychain or ask user
        try
            set apiKey to do shell script "security find-generic-password -s 'HappyScribeAPI' -w"
        on error
            set apiKeyDialog to display dialog "Please enter your Happy Scribe API key:" default answer "" buttons {"Cancel", "OK"} default button "OK" with title "Happy Scribe API"
            if button returned of apiKeyDialog is "Cancel" then return input
            set apiKey to text returned of apiKeyDialog
            
            -- Save API key to Keychain for future use
            do shell script "security add-generic-password -a ${USER} -s 'HappyScribeAPI' -w " & quoted form of apiKey
        end try
        
        -- Organization ID for Happy Scribe
        set organizationId to "8761770"
        
        -- Show a single confirmation dialog
        display dialog "Send \"" & fileName & "\" to Happy Scribe for transcription?" buttons {"Cancel", "Send"} default button "Send" with title "Happy Scribe Transcription"
        
        -- Create a progress script that will run in background
        set progressScript to "
        tell application \"System Events\"
            repeat
                try
                    do shell script \"test -f /tmp/happyscribe_progress\"
                    delay 0.5
                on error
                    exit repeat
                end try
            end repeat
        end tell"
        
        -- Start the background progress script
        do shell script "echo " & quoted form of progressScript & " | osascript &"
        
        -- Create the progress flag file
        do shell script "touch /tmp/happyscribe_progress"
        
        -- Show initial progress dialog that will auto-dismiss
        try
            display dialog "⏳ Preparing upload to Happy Scribe..." buttons {} giving up after 2 with title "Happy Scribe Transcription" with icon note
        end try
        
        -- STEP 1: Get a signed URL for file upload
        set getUrlCmd to "curl -s -X GET 'https://www.happyscribe.com/api/v1/uploads/new?filename=" & encodedFileName & "' -H 'Authorization: Bearer " & apiKey & "'"
        
        try
            set signedUrlResponse to do shell script getUrlCmd
            
            -- Check for error response
            if signedUrlResponse contains "\"error\":" then
                do shell script "rm -f /tmp/happyscribe_progress"
                display dialog "Error getting signed URL from Happy Scribe. Please try again." buttons {"OK"} default button "OK" with icon stop
                return input
            end if
        on error urlErr
            do shell script "rm -f /tmp/happyscribe_progress"
            display dialog "Network error connecting to Happy Scribe. Please check your internet connection and try again." buttons {"OK"} default button "OK" with icon stop
            return input
        end try
        
        -- Extract the signed URL using simple text parsing
        if signedUrlResponse contains "\"signedUrl\":" then
            -- Find the position of the signedUrl field
            set urlStartPos to offset of "\"signedUrl\":\"" in signedUrlResponse
            
            -- Get text after the field name
            set urlStartPos to urlStartPos + 13 -- Length of "signedUrl":"
            set remainingText to text urlStartPos thru -1 of signedUrlResponse
            
            -- Find the closing quote
            set urlEndPos to offset of "\"" in remainingText
            
            -- Extract the URL
            set signedUrl to text 1 thru (urlEndPos - 1) of remainingText
        else
            do shell script "rm -f /tmp/happyscribe_progress"
            display dialog "Unable to get upload URL from Happy Scribe. Please try again." buttons {"OK"} default button "OK" with icon stop
            return input
        end if
        
        -- Show upload progress
        try
            display dialog "📤 Uploading file to Happy Scribe..." buttons {} giving up after 2 with title "Happy Scribe Transcription" with icon note
        end try
        
        -- STEP 2: Upload the file to the signed URL
        set uploadCmd to "curl -s -X PUT -T " & quoted form of filePath & " " & quoted form of signedUrl
        
        try
            do shell script uploadCmd
        on error uploadErr
            do shell script "rm -f /tmp/happyscribe_progress"
            display dialog "Error uploading file to Happy Scribe. Please try again." buttons {"OK"} default button "OK" with icon stop
            return input
        end try
        
        -- Show transcription creation progress
        try
            display dialog "🎤 Creating transcription..." buttons {} giving up after 2 with title "Happy Scribe Transcription" with icon note
        end try
        
        -- STEP 3: Create a transcription using the file URL
        -- Create a temporary JSON file to avoid escaping issues
        set tmpJsonFile to do shell script "mktemp /tmp/happyscribe_XXXXXX.json"
        set jsonContent to "{\"transcription\": {\"name\": \"" & fileName & "\", \"language\": \"en\", \"tmp_url\": \"" & signedUrl & "\", \"is_subtitle\": false, \"organization_id\": \"" & organizationId & "\"}}"
        
        do shell script "echo " & quoted form of jsonContent & " > " & quoted form of tmpJsonFile
        
        -- Create the transcription using the JSON file
        set createCmd to "curl -s -X POST 'https://www.happyscribe.com/api/v1/transcriptions' -H 'Authorization: Bearer " & apiKey & "' -H 'Content-Type: application/json' -d @" & quoted form of tmpJsonFile
        
        try
            set apiResponse to do shell script createCmd
            
            -- Clean up temp file and progress flag
            do shell script "rm -f " & quoted form of tmpJsonFile
            do shell script "rm -f /tmp/happyscribe_progress"
            
            -- Check for error response
            if apiResponse contains "\"error\":" then
                display dialog "Happy Scribe returned an error. Please check your account and try again." buttons {"OK"} default button "OK" with icon stop
                return input
            end if
            
            -- Extract the transcription ID using simple text parsing
            if apiResponse contains "\"id\":" then
                -- Find the position of the id field
                set idStartPos to offset of "\"id\":\"" in apiResponse
                
                -- Get text after the field name
                set idStartPos to idStartPos + 6 -- Length of "id":"
                set remainingText to text idStartPos thru -1 of apiResponse
                
                -- Find the closing quote
                set idEndPos to offset of "\"" in remainingText
                
                -- Extract the ID
                set transcriptionId to text 1 thru (idEndPos - 1) of remainingText
                
                -- Success notification
                display notification "Transcription started successfully! ID: " & transcriptionId with title "Happy Scribe Transcription"
                
                -- Final success dialog with option to open
                display dialog "✅ File successfully sent to Happy Scribe for transcription!" & return & return & "Transcription ID: " & transcriptionId buttons {"Done", "Open in Browser"} default button "Open in Browser" with title "Happy Scribe Transcription"
                
                if button returned of result is "Open in Browser" then
                    open location "https://www.happyscribe.com/transcriptions/" & transcriptionId
                end if
            else
                display dialog "Transcription may have been created, but couldn't get the ID. Check your Happy Scribe dashboard." buttons {"OK"} default button "OK" with icon caution
                return input
            end if
            
        on error apiErr
            -- Clean up temp file and progress flag even if there's an error
            do shell script "rm -f " & quoted form of tmpJsonFile
            do shell script "rm -f /tmp/happyscribe_progress"
            
            display dialog "Error creating transcription. Please try again." buttons {"OK"} default button "OK" with icon stop
            return input
        end try
        
        return input
    on error errMsg
        -- Clean up progress flag if there's an unexpected error
        do shell script "rm -f /tmp/happyscribe_progress"
        display dialog "An unexpected error occurred. Please try again." buttons {"OK"} default button "OK" with icon stop
        return input
    end try
end run
