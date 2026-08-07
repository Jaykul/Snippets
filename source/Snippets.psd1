@{
    # Version number of this module.
    ModuleVersion = '1.0.0'
    PrivateData      = @{
        PSData = @{
            # The prerelease portion of a semantic version. Blank for releases
            Prerelease   = ''
            ReleaseNotes = ''

            Tags         = @('Code', 'Snippets')

            # LicenseUri = ''
            # ProjectUri = ''
            # IconUri = ''

            # Modules that aren't in the same PowerShellGallery
            # ExternalModuleDependencies = @()
        } # End of PSData hashtable
    } # End of PrivateData hashtable

    Description          = 'PowerShell Code Snippets UX!'
    ScriptsToProcess     = @()
    FunctionsToExport    = @()
    CmdletsToExport      = @('Get-Snippet', 'Add-Snippet', 'Format-Code')
    VariablesToExport    = @()
    AliasesToExport      = @()
    NestedModules        = @()
    RequiredModules      = @(
        @{ ModuleName = "Theme.PSReadLine"; ModuleVersion = "0.3.0" }
        @{ ModuleName = "Yayaml";           ModuleVersion = "0.5.0" }
        @{ ModuleName = "PowerShellRun";    ModuleVersion = "0.12.0" }
    )
    TypesToProcess       = @('Snippets.types.ps1xml')
    FormatsToProcess     = @('Snippets.format.ps1xml')

    # Script module or binary module file associated with this manifest.
    RootModule           = 'Snippets.psm1'
    GUID                 = '29f0e09b-9e18-4ca2-bfb0-1acd72aac728'
    Author               = "Joel 'Jaykul' Bennett"
    CompanyName          = 'PoshCode.org'
    Copyright            = '(c) Joel Bennett 2025. All rights reserved.'
    CompatiblePSEditions = @('Desktop', 'Core')

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion    = '7.4'
}

