using namespace System.Collections.Generic
$script:SelectorOption = [PowerShellRun.SelectorOption]@{
    Theme = [PowerShellRun.Theme]@{
        PreviewSizePercentage = 5
        CanvasTopMargin       = 0
        PromptSymbol          = ''
    }
}

# TODO: These hotkeys should be user-configurable...
Set-PSReadLineKeyHandler -Key 'Ctrl+k' -ScriptBlock {
    $tokens = $null
    $parseError = $null
    $ast = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseError, [ref]$cursor)
    if ($ast.Extent.EndOffset -eq 0) {
        [List[PowerShellRun.SelectorEntry]]$Snippets = @(
            [PoshCode.Snippets.Predictor]::Instance.Snippets.GetEnumerator().ForEach{
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
        # TODO: There's a bug, it's only selecting every other time
        # In our snippets, we insist on using ${variables} for the tokens that should be replaced, so we can find them easy:
        $VariableTokens = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.VariableExpressionAst] -and $args[0].Extent.Text.StartsWith('${') }, $true)
        $NextToken = $VariableTokens.Where({ $_.Extent.StartOffset -gt $cursor }, "First")
        $extent = $NextToken.Extent ?? $VariableTokens[0].Extent

        # An insert ensures the completion list is up
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("")
        # Highlighting the suggestion makes the tooltip visible
        # And breaks any selection ...
        [Microsoft.PowerShell.PSConsoleReadLine]::PreviousSuggestion()

        # This triplet moves the cursor AND makes sure there's no selection
        # [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor)
        # [Microsoft.PowerShell.PSConsoleReadLine]::ExchangePointAndMark()
        # [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor)

        # But really the reason you used this key is to select the next token:
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($extent.StartOffset)
        [Microsoft.PowerShell.PSConsoleReadLine]::SelectForwardChar($null, ($extent.EndOffset - $extent.StartOffset))
    }
}

Set-PSReadLineKeyHandler -Key 'Alt+LeftArrow' -ScriptBlock {
    $tokens = $null
    $parseError = $null
    $ast = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseError, [ref]$cursor)

    # In our snippets, we insist on using ${variables} for the tokens that should be replaced, so we can find them easy:
    $VariableTokens = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.VariableExpressionAst] -and $args[0].Extent.Text.StartsWith('${') }, $true)
    $NextToken = $VariableTokens.Where({ $_.Extent.EndOffset -lt $cursor }, "Last")

    $extent = $NextToken.Extent ?? $VariableTokens[-1].Extent
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($extent.StartOffset)
    [Microsoft.PowerShell.PSConsoleReadLine]::ExchangePointAndMark()
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($extent.StartOffset)
    [Microsoft.PowerShell.PSConsoleReadLine]::SelectForwardChar($null, ($extent.EndOffset - $extent.StartOffset))
}

Set-PSReadLineKeyHandler -Key 'Alt+RightArrow' -ScriptBlock {
    $tokens = $null
    $parseError = $null
    $ast = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseError, [ref]$cursor)

    # In our snippets, we insist on using ${variables} for the tokens that should be replaced, so we can find them easy:
    $VariableTokens = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.VariableExpressionAst] -and $args[0].Extent.Text.StartsWith('${') }, $true)
    $NextToken = $VariableTokens.Where({ $_.Extent.StartOffset -gt $cursor }, "First")

    $extent = $NextToken.Extent ?? $VariableTokens[0].Extent
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($extent.StartOffset)
    [Microsoft.PowerShell.PSConsoleReadLine]::ExchangePointAndMark()
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($extent.StartOffset)
    [Microsoft.PowerShell.PSConsoleReadLine]::SelectForwardChar($null, ($extent.EndOffset - $extent.StartOffset))
}
