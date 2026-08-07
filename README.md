# Snippets in PowerShell

I'm just playing with some ideas for how to do snippets in PowerShell. This is a work in progress.

## A Snippet Predictor

My first idea was to [write a predictor](https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/create-cmdline-predictor) that would suggest snippets based on what you type.

This is implemented in the `PoshCode.Snippets.Predictor` class.

With the module loaded, you _search_ for snippets by starting to type the _name_ as a comment, or by typing a `@tag` to filter:

`#convert @ssl`

`@ssl self-signed`

It searches based on matching _words_, without regard to order, so if you have a bunch of snippets with names like "Convert CRT to DER", "Convert CRT to PFX", "Convert PFX to CRT", "Convert DER to CRT", and so on, you can type `#convert` and it show all four, but add more, like `#convert der` and it will filter to only those two ("Convert CRT to DER" and "Convert DER to CRT").

## Using PowerShellRun to pick snippets

Another idea I had was to use [PowerShellRun](https://github.com/mrdgrs/PowerShellRun) to create a picker for snippets. This is implemented in [source/private/PowerShellRun.ps1](source/private/PowerShellRun.ps1) as a Ctrl+K binding hotkey for PSReadLine.

I haven't gotten the UX the way I want it for this.

## Other ideas

I'm just pushing this to share the idea for now, because I'm still playing around with snippets ideas:

- I'm trying to fix up hotkeys to navigate between the tokens in the snippet so you can easily update the
- I've added a couple of basic cmdlets for enumerating and adding snippets (e.g. calling `Add-Snippet New-Foo` will prompt you for a description and tags, and then add the last command as a new snippet).
