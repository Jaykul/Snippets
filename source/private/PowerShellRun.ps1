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
    [ReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseError, [ref]$cursor)
    if ($ast.Extent.EndOffset -eq 0) {
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
        # In our snippets, we insist on using ${variables} for the tokens that should be replaced, so we can find them easy:
        $VariableTokens = $Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.VariableExpressionAst] -and $args[0].Extent.Text.StartsWith('${') }, $true)
        $NextToken = $VariableTokens.Where({ $_.Extent.StartOffset -gt $cursor }, "First")

        $extent = $NextToken.Extent ?? $VariableTokens[0].Extent
        [ReadLine]::SetCursorPosition($extent.StartOffset)
        [ReadLine]::ExchangePointAndMark()
        [ReadLine]::SetCursorPosition($extent.StartOffset)
        [ReadLine]::SelectForwardChar($null, ($extent.EndOffset - $extent.StartOffset))
    }
}

<#
Set-PSReadLineKeyHandler -Key 'Ctrl+k' -ScriptBlock {
    $global:tokens = $null
    $global:parseError = $null
    $global:ast = $null
    $global:cursor = $null
    [ReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseError, [ref]$cursor)
}
#>

Set-PSReadLineKeyHandler -Key 'Alt+LeftArrow' -ScriptBlock {
    $tokens = $null
    $parseError = $null
    $ast = $null
    $cursor = $null
    [ReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseError, [ref]$cursor)

    # In our snippets, we insist on using ${variables} for the tokens that should be replaced, so we can find them easy:
    $VariableTokens = $Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.VariableExpressionAst] -and $args[0].Extent.Text.StartsWith('${') }, $true)
    $NextToken = $VariableTokens.Where({ $_.Extent.EndOffset -lt $cursor }, "Last")

    $extent = $NextToken.Extent ?? $VariableTokens[-1].Extent
    [ReadLine]::SetCursorPosition($extent.StartOffset)
    [ReadLine]::ExchangePointAndMark()
    [ReadLine]::SetCursorPosition($extent.StartOffset)
    [ReadLine]::SelectForwardChar($null, ($extent.EndOffset - $extent.StartOffset))
}

Set-PSReadLineKeyHandler -Key 'Alt+RightArrow' -ScriptBlock {
    $tokens = $null
    $parseError = $null
    $ast = $null
    $cursor = $null
    [ReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseError, [ref]$cursor)

    # In our snippets, we insist on using ${variables} for the tokens that should be replaced, so we can find them easy:
    $VariableTokens = $Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.VariableExpressionAst] -and $args[0].Extent.Text.StartsWith('${') }, $true)
    $NextToken = $VariableTokens.Where({ $_.Extent.StartOffset -gt $cursor }, "First")

    $extent = $NextToken.Extent ?? $VariableTokens[0].Extent
    [ReadLine]::SetCursorPosition($extent.StartOffset)
    [ReadLine]::ExchangePointAndMark()
    [ReadLine]::SetCursorPosition($extent.StartOffset)
    [ReadLine]::SelectForwardChar($null, ($extent.EndOffset - $extent.StartOffset))
}
