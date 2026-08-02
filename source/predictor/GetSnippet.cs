using System.Management.Automation;

namespace PoshCode
{
    [Cmdlet(VerbsCommon.Get, "Snippet")]
    public partial class GetSnippet : PSCmdlet
    {
        override protected void ProcessRecord()
        {
            var predictor = SnippetPredictor.Instance;
            if (predictor == null)
            {
                WriteError(new ErrorRecord(
                    new InvalidOperationException("Snippet predictor is not initialized."),
                    "SnippetPredictorNotInitialized",
                    ErrorCategory.InvalidOperation,
                    null));
                return;
            }

            var snippets = predictor.Snippets;
            foreach (var snippet in snippets)
            {
                WriteObject(snippet);
            }
        }
    }
}