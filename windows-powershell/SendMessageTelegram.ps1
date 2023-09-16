<#
Usage:

Just edit the line below with your own chatID and bot token:
Send-TelegramMessage -chatID 'place your chatid here' -botToken '12345678:ABCDEFGHIJKLMNOG' -textToSend ([String](checkSQLServices))


#>
function checkSQLServices {

    try {
    
            # Initialize an empty hashtable
            $serviceStatusHashTable = @{}
            
            # This can be changed to query the service you would like to check, I changed from SQL to Windows because not everyone has SQL Installed
            Get-Service | Select-Object -Property Status,DisplayName | Where-Object {$_.DisplayName -like "Windows*"} | 
            ForEach-Object {
                $escapedName = Escape-PSSpecialCharacters -inputstring $_.DisplayName
                $escapedStatus = Escape-PSSpecialCharacters -inputstring $_.Status.ToString()
                $serviceStatusHashTable[$escapedName] = $escapedStatus
            }
            
            # Display the formatted output
            Write-Output "Name : Status `n"
            $serviceStatusHashTable.GetEnumerator() | ForEach-Object {
                Write-Output "$($_.Key) : $($_.Value) `n"
            }

        }

        catch {

            Write-Warning -Message 'An error was encountered in checking for SQL Services:'
            Write-Error $_ 
            exit

        }

    }

function Escape-PSSpecialCharacters {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$inputString
    )

    # List of characters that have special meaning in PowerShell and can cause script issues if not escaped.
    $restrictedChars = '#&(){}[];@'',.|+*?:<>=!$%^-`"'

    foreach ($char in $restrictedChars.ToCharArray()) {
        # Using regex to escape each character in the input string.
        $inputString = $inputString -replace [regex]::Escape("$char"), ("\" + $char)
    }

    return $inputString
}


function Send-TelegramMessage {
[CmdletBinding()]
    param (
        [string]$chatID, [string]$botToken, [string]$textToSend
       
    )

    $payload = @{
        chat_id                  = "$chatID"
        text                     = $textToSend
        parse_mode               = 'Markdownv2'
    }

    $parameters = @{
        Uri         = 'https://api.telegram.org/bot{0}/sendMessage' -f $botToken
        Body        = ([System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -Compress -InputObject $payload -Depth 50)))
        ErrorAction = 'Stop'
        ContentType = 'application/json'
        Method      = 'Post'
    }

    try {

        Invoke-RestMethod @parameters

    }

    catch {
        
        Write-Output 'Error Encountered'
        Write-Error $_

    }

}

# Edit your chatID & botToken Here 
Send-TelegramMessage -chatID 'place your chatid here' -botToken '12345678:ABCDEFGHIJKLMNOG' -textToSend ([String](checkSQLServices))
