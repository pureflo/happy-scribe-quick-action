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
        
        -- Show confirmation before sending
        display dialog "Ready to send " & fileName & " to Happy Scribe with:" & return & return & "Organization ID: " & organizationId buttons {"Cancel", "Send"} default button "Send"
        
        -- STEP 1: Get a signed URL for file upload
        set getUrlCmd to "curl -s -X GET 'https://www.happyscribe.com/api/v1/uploads/new?filename=" & fileName & "' -H 'Authorization: Bearer " & apiKey & "'"
        set signedUrlResponse to do shell script getUrlCmd
        
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
            
            display dialog "Got signed URL successfully!" buttons {"Continue"} default button "Continue"
        else
            display dialog "Could not find signed URL in response: " & signedUrlResponse buttons {"OK"} default button "OK"
            return input
        end if
        
        -- STEP 2: Upload the file to the signed URL
        set uploadCmd to "curl -s -X PUT -T " & quoted form of filePath & " " & quoted form of signedUrl
        
        try
            do shell script uploadCmd
            display dialog "File uploaded successfully!" buttons {"Continue"} default button "Continue"
        on error uploadErr
            display dialog "Error uploading file: " & uploadErr buttons {"OK"} default button "OK"
            return input
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
            
            -- Clean up temp file
            do shell script "rm -f " & quoted form of tmpJsonFile
            
            -- Check for error response
            if apiResponse contains "error" then
                display dialog "API Error: " & apiResponse buttons {"OK"} default button "OK"
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
                
                -- Success! Show the transcription ID and offer to open it
                display dialog "File successfully sent to Happy Scribe! Transcription ID: " & transcriptionId buttons {"Done", "Open in Browser"} default button "Open in Browser"
                
                if button returned of result is "Open in Browser" then
                    open location "https://www.happyscribe.com/transcriptions/" & transcriptionId
                end if
            else
                display dialog "Couldn't extract transcription ID. Response: " & apiResponse buttons {"OK"} default button "OK"
                return input
            end if
            
        on error apiErr
            -- Clean up temp file even if there's an error
            do shell script "rm -f " & quoted form of tmpJsonFile
            
            display dialog "API Error: " & apiErr buttons {"OK"} default button "OK"
            return input
        end try
        
        return input
    on error errMsg
        display dialog "Error: " & errMsg buttons {"OK"} default button "OK"
        return input
    end try
end run
