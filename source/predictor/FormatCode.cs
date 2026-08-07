using System.Management.Automation;
using System.Management.Automation.Language;
using System.Text;

namespace PoshCode.Snippets;

[Cmdlet(VerbsCommon.Format, "Code")]
[OutputType(typeof(string))]
public sealed class FormatCodeCommand : PSCmdlet
{
    [Parameter(Mandatory = true, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true, Position = 0)]
    [AllowEmptyString]
    [Alias("CommandLine", "Command")]
    public string Code { get; set; } = string.Empty;

    private PSObject? theme;

    protected override void BeginProcessing()
    {
        theme = InvokeCommand
            .InvokeScript("Get-PSReadLineOption | Select-Object *Color")
            .FirstOrDefault();
    }

    protected override void ProcessRecord()
    {
        var source = Code ?? string.Empty;
        if (source.Length == 0)
        {
            WriteObject(string.Empty);
            return;
        }

        System.Management.Automation.Language.Token[] tokens;
        ParseError[] errors;
        Parser.ParseInput(source, out tokens, out errors);

        var str = new StringBuilder(source.Length + (tokens.Length * 4));
        var index = 0;

        foreach (var token in tokens)
        {
            str.Append(' ', token.Extent.StartOffset - index);

            str.WriteToken(token, theme);
            index = token.Extent.EndOffset;
        }

        str.Append("\u001b[0m\u001b[24m\u001b[27m");

        WriteObject(str.ToString());
    }


}

internal static class StringBuilderExtensions
{
    public static void WriteToken(this StringBuilder stringBuilder, System.Management.Automation.Language.Token token, PSObject? theme)
    {
        ArgumentNullException.ThrowIfNull(stringBuilder);
        ArgumentNullException.ThrowIfNull(token);

        switch (token)
        {
            case StringExpandableToken expandableToken:
                {
                    var startingOffset = expandableToken.Extent.StartOffset;
                    var lastEndOffset = startingOffset;

                    if (expandableToken.NestedTokens != null && expandableToken.NestedTokens.Count > 0)
                    {
                        foreach (var nestedToken in expandableToken.NestedTokens)
                        {
                            AppendThemeColor(stringBuilder, theme, "StringColor");
                            stringBuilder.Append(
                                expandableToken.Text,
                                lastEndOffset - startingOffset,
                                nestedToken.Extent.StartOffset - lastEndOffset);

                            stringBuilder.WriteToken(nestedToken, theme);
                            lastEndOffset = nestedToken.Extent.EndOffset;
                        }
                    }

                    AppendThemeColor(stringBuilder, theme, "StringColor");
                    stringBuilder.Append(
                        expandableToken.Text,
                        lastEndOffset - startingOffset,
                        expandableToken.Extent.EndOffset - lastEndOffset);
                    return;
                }
            case StringToken stringToken when stringToken.TokenFlags.HasFlag(TokenFlags.CommandName):
                AppendThemeColor(stringBuilder, theme, "CommandColor");
                break;
            case StringToken:
                AppendThemeColor(stringBuilder, theme, "StringColor");
                break;
            case NumberToken:
                AppendThemeColor(stringBuilder, theme, "NumberColor");
                break;
            case ParameterToken:
                AppendThemeColor(stringBuilder, theme, "ParameterColor");
                break;
            case VariableToken:
                AppendThemeColor(stringBuilder, theme, "VariableColor");
                break;
            case var _ when token.TokenFlags.HasFlag(TokenFlags.BinaryOperator):
                AppendThemeColor(stringBuilder, theme, "OperatorColor");
                break;
            case var _ when token.TokenFlags.HasFlag(TokenFlags.UnaryOperator):
                AppendThemeColor(stringBuilder, theme, "OperatorColor");
                break;
            case var _ when token.TokenFlags.HasFlag(TokenFlags.CommandName):
                AppendThemeColor(stringBuilder, theme, "CommandColor");
                break;
            case var _ when token.TokenFlags.HasFlag(TokenFlags.MemberName):
                AppendThemeColor(stringBuilder, theme, "MemberColor");
                break;
            case var _ when token.TokenFlags.HasFlag(TokenFlags.TypeName):
                AppendThemeColor(stringBuilder, theme, "TypeColor");
                break;
            case var _ when token.TokenFlags.HasFlag(TokenFlags.Keyword):
                AppendThemeColor(stringBuilder, theme, "KeywordColor");
                break;
            default:
                AppendThemeColor(stringBuilder, theme, "DefaultTokenColor");
                break;
        }

        stringBuilder.Append(token.Text);
        stringBuilder.Append("\u001b[0m");
    }

    private static void AppendThemeColor(StringBuilder stringBuilder, PSObject? theme, string colorProperty)
    {
        if (theme?.Properties[colorProperty]?.Value is string value)
        {
            stringBuilder.Append(value);
        }
    }
}
