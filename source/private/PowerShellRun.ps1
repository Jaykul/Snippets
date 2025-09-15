using namespace System.Collections.Generic
$script:SelectorOption = [PowerShellRun.SelectorOption]@{
    Theme = [PowerShellRun.Theme]@{
        PreviewSizePercentage = 5
        CanvasTopMargin       = 0
        PromptSymbol          = ''
    }
}

Set-PSReadLineKeyHandler -Key 'Ctrl+k' -ScriptBlock {
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if (!$line) {
        [List[PowerShellRun.SelectorEntry]]$Snippets = @(
            [PoshCode.SnippetPredictor]::Instance.Snippets.GetEnumerator().ForEach{
                [PowerShellRun.SelectorEntry]@{
                    UserData                       = $_
                    Name                           = $_.Name
                    Description                    = $_.Description
                    PreviewAsyncScript             = {
                        param($command)
                        Show-Code "$Command"
                    }
                    PreviewAsyncScriptArgumentList = $_.Command
                }
            }
        )

        $result = [PowerShellRun.Selector]::Open($Snippets, "SingleSelection", $SelectorOption, $null).FocusedEntry.UserData
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($result.Command)
    } else {

        [PoshCode.SnippetPredictor]::Instance.Snippets.GetEnumerator().Where{ $_.Command -eq $line }
    }
}
