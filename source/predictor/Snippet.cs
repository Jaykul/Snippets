using System.Collections.ObjectModel;
using System.Management.Automation;
using System.Management.Automation.Subsystem.Prediction;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;
namespace PoshCode
{
    public class Snippet
    {
        public required string Name { get; set; }
        public required string Description { get; set; }
        public required string Command { get; set; }

        public required string[] Tags { get; set; }

        public Token[] Tokens { get; set; } = Array.Empty<Token>();

        public Collection<PSObject> Invoke(EngineIntrinsics executionContext)
        {
            var command = Command;
            if (Tokens != null)
            {
                foreach (var token in Tokens)
                {
                    var value = token.Value ?? "";
                    command = command.Replace($"${{{token.Name}}}", value);
                }
            }
            return executionContext.InvokeCommand.InvokeScript(command);
        }

        public ScriptBlock ToScriptBlock()
        {
            return ScriptBlock.Create(Command);
        }

        public static Snippet FromYaml(string yaml)
        {
            var deserializer = new DeserializerBuilder()
                .IgnoreUnmatchedProperties()
                .WithNamingConvention(LowerCaseNamingConvention.Instance)
                .Build();
            return deserializer.Deserialize<Snippet>(yaml);
        }

        internal PredictiveSuggestion ToSuggestion() => new PredictiveSuggestion("<# " + Name + " #> " + Command.Trim(), Description + "Tags: [@" + string.Join(", @", Tags) + "]");
    }

    public class Token
    {
        public required string Name { get; set; }
        public required string Description { get; set; }
        public string? Value { get; set; }
    }
}