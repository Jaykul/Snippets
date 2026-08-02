BeforeAll {
    if (-not (Get-Module -Name Snippets)) {
        $modulePath = Join-Path $PSScriptRoot '..' 'output' 'Snippets' 'Snippets.psd1'
        Import-Module $modulePath
    }
}

Describe 'Add-Snippet' {
    BeforeEach {
        $script:AppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)
        $script:snippetRoot = Join-Path $script:AppData 'PoshCode' 'Snippets'
        $script:uniqueId = [guid]::NewGuid().ToString('N')

        [PoshCode.SnippetPredictor]::Instance.Snippets.Clear()
        [PoshCode.SnippetPredictor]::Instance.LoadSnippets()
    }

    AfterEach {
        Remove-Item -Path (Join-Path $script:snippetRoot "*-$script:uniqueId") -Recurse -Force -ErrorAction SilentlyContinue
    }

    It 'writes a YAML file and registers the snippet when a command line is supplied' {
        $folderName = "Tests-$script:uniqueId"
        $folderPath = Join-Path $script:snippetRoot $folderName
        New-Item -ItemType Directory -Path $folderPath -Force | Out-Null

        Add-Snippet -Name $uniqueId -CommandLine 'Write-Host "hello"' -Description 'A test snippet' -Tags @('test', 'demo') -Folder $folderName

        $filePath = Join-Path $folderPath "$uniqueId.yaml"
        $filePath | Should -Exist
        (Get-Content -Path $filePath -Raw) | Should -Match 'name:'
        (Get-Content -Path $filePath -Raw) | Should -Match 'command: Write-Host "hello"'
        ([PoshCode.SnippetPredictor]::Instance.Snippets | Where-Object Name -EQ $uniqueId).Count | Should -Be 1
    }

    It 'creates the folder when -Force is specified' {
        $folderName = "Forced-$script:uniqueId"
        Add-Snippet -Name 'ForceSnippet' -CommandLine 'Get-ChildItem' -Description 'Force create folder' -Tags @('force') -Folder $folderName -Force

        $folderPath = Join-Path $script:snippetRoot $folderName
        $folderPath | Should -Exist
    }

    It 'fails when the target folder does not exist and -Force is not specified' {
        $folderName = "Missing-$script:uniqueId"
        $expectedFile = Join-Path $script:snippetRoot $folderName 'MissingFolderSnippet.yaml'

        { Add-Snippet -Name 'MissingFolderSnippet' -CommandLine 'Write-Output hi' -Description 'Missing folder' -Tags @('missing') -Folder $folderName -ErrorAction Stop } | Should -Throw -ErrorId 'FolderNotFound*'

        $expectedFile | Should -Not -Exist
    }
}
