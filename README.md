# Snippets in PowerShell

I'm just playing with some ideas for how to do snippets in PowerShell. This is a work in progress.


## A Snippet Predictor

My first idea was to write a Predictor that would suggest snippets based on what you type.
This is implemented in the `SnippetPredictor` class.

With the module loaded, you _search_ for snippets by starting typing the name as a comment, or by typing a `@tag` to filter:

`# convert @ssl`
`@ssl self-signed`

## Using PowerShellRun to pick snippets

Another idea I had was to use [PowerShellRun](https://github.com/mrdgrs/PowerShellRun) to create a picker for snippets. This is implemented in [source/private/PowerShellRun.ps1](source/private/PowerShellRun.ps1) as a Ctrl+K binding hotkey for PSReadLine.

I'm still playing around with the idea and definitely will make it possible to load just one of those and customize the hotkey, but I'm just pushing this to share the idea for now.
