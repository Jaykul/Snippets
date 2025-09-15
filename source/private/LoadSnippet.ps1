
using namespace System.Collections.Generic
$script:SnippetSchema = New-YamlSchema -ParseMap {
    param ($Map, $Schema)

    # The top level snippet has a command on it
    if ($Map.Values["command"]) {
        $Map.Values["command"] = [scriptblock]::Create($Map.Values["command"].Trim())
        # And probably tokens and tags
        if ($Map.Values["tokens"]) {
            $Map.Values["tokens"] = $Map.Values["tokens"]
        }
        if ($Map.Values["tags"]) {
            $Map.Values["tags"] = [string[]]$Map.Values["tags"]
        }
        $Map.Values["PSTypeName"] = 'PoshCode.Snippet'
        [PSCustomObject]$Map.Values
    } else {
        # The only Map is the tokens which require a name and description
        if (!$Map.Values.Contains("name") -or !$Map.Values.Contains("description")) {
            throw "Snippet token missing required 'name' or 'description' property"
        }
        $Map.Values["PSTypeName"] = 'PoshCode.Token'
        [PSCustomObject]$Map.Values
    }
}

filter ImportSnippet {
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)]
        [string]$Path
    )

    try {
        Get-Content -Path $Path -Raw
        | ConvertFrom-Yaml -Schema $script:SnippetSchema
    } catch {
        throw ([Exception]::new("Failed to import snippet from '$Path'", $_.Exception))
    }
}

function LoadSnippet {
    [List[PowerShellRun.SelectorEntry]]$script:Snippets = Get-ChildItem $PSScriptRoot -Recurse -Filter *.yaml
    | ImportSnippet
    | ForEach-Object {
        [PowerShellRun.SelectorEntry]@{
            UserData                       = $_
            Name                           = $_.name
            Description                    = $_.description
            PreviewAsyncScript             = {
                param($command)
                Show-Code "$Command"
            }
            PreviewAsyncScriptArgumentList = $_.Command
        }
    }
}