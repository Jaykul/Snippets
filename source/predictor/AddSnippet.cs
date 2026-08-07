using System.Management.Automation;
using Microsoft.PowerShell.Commands;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;

namespace PoshCode.Snippets;

[Cmdlet(VerbsCommon.Add, "Snippet")]
public partial class AddSnippet : PSCmdlet
{
    [Parameter(Mandatory = true, Position = 0)]
    public string Name { get; set; } = string.Empty;

    [Parameter(Mandatory = true, Position = 1, ParameterSetName = "History", ValueFromPipelineByPropertyName = true)]
    public string CommandLine { get; set; } = string.Empty;

    [Parameter(Mandatory = false, Position = 1, ParameterSetName = "Id")]
    public long Id { get; set; } = -1;

    [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true)]
    public string Description { get; set; } = string.Empty;

    [Parameter(Mandatory = true, ValueFromPipelineByPropertyName = true)]
    public string[] Tags { get; set; } = Array.Empty<string>();

    [Parameter(Mandatory = false, ValueFromPipelineByPropertyName = true)]
    public string Folder { get; set; } = "_";

    [Parameter(Mandatory = false)]
    public SwitchParameter Force { get; set; }

    override protected void ProcessRecord()
    {
        if (ParameterSetName == "Id")
        {
            if (Id < 0)
            {
                Id = MyInvocation.HistoryId + Id;
                if (Id < 0)
                {
                    WriteError(new ErrorRecord(
                        new ArgumentOutOfRangeException(nameof(Id), "Id must be within the history range."),
                        "InvalidId",
                        ErrorCategory.InvalidArgument,
                        null));
                    return;
                }
            }
            HistoryInfo? historyItem = InvokeCommand.InvokeScript($"Get-History -Id {Id}").FirstOrDefault()?.BaseObject as HistoryInfo;
            CommandLine = historyItem?.CommandLine ?? string.Empty;
        }

        if (string.IsNullOrWhiteSpace(CommandLine))
        {
            WriteError(new ErrorRecord(
                new ArgumentException("CommandLine cannot be empty.", nameof(CommandLine)),
                "EmptyCommandLine",
                ErrorCategory.InvalidArgument,
                null));
            return;
        }

        var snippet = new Snippet
        {
            Name = Name,
            Description = Description,
            Command = CommandLine,
            Tags = Tags,
            Tokens = Array.Empty<Token>()
        };
        var _serializer = new SerializerBuilder()
            .WithNamingConvention(LowerCaseNamingConvention.Instance)
            .Build();

        var container = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "PoshCode", "Snippets", Folder);
        var filePath = Path.Combine(container, $"{Name}.yaml");
        if (!Directory.Exists(container))
        {
            if (!Force.IsPresent)
            {
                WriteError(new ErrorRecord(
                    new DirectoryNotFoundException($"The snippet folder '{container}' does not exist. Use -Force to create it."),
                    "FolderNotFound",
                    ErrorCategory.ObjectNotFound,
                    null));
                return;
            }
            Directory.CreateDirectory(container);
        }

        using var writer = File.CreateText(filePath);
        _serializer.Serialize(writer, snippet);

        Predictor.Instance.Snippets.Add(snippet);
    }
}
