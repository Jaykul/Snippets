using System.Collections.Generic;
using System.IO;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;

namespace PoshCode
{
    public class SnippetLoader
    {
        private readonly IDeserializer _deserializer;

        public SnippetLoader()
        {
            _deserializer = new DeserializerBuilder()
                .IgnoreUnmatchedProperties()
                .WithNamingConvention(LowerCaseNamingConvention.Instance)
                .Build();
        }

        public IEnumerable<Snippet> LoadSnippets(string folderPath)
        {
            if (!Directory.Exists(folderPath))
            {
                yield break;
            }

            foreach (var file in Directory.EnumerateFiles(folderPath, "*.yaml", SearchOption.AllDirectories))
            {
                var yamlContent = File.ReadAllText(file);
                var snippet = _deserializer.Deserialize<Snippet>(yamlContent);
                yield return snippet;
            }
        }
    }
}