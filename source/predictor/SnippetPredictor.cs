using System;
using System.Collections.Generic;
using System.Threading;
using System.Management.Automation.Subsystem.Prediction;
using System.Text.RegularExpressions;

namespace PoshCode
{
    public partial class SnippetPredictor : ICommandPredictor
    {
        private readonly Guid _guid;

        public List<Snippet> Snippets { get; } = new List<Snippet>();

        [GeneratedRegex(@"@(?<tag>\w+)")]
        private static partial Regex TagPattern();

        [GeneratedRegex(@"[#\s](?<name>\w+)")]
        private static partial Regex NamePattern();


        internal SnippetPredictor(string guid)
        {
            _guid = new Guid(guid);
            LoadSnippets();
        }

        public void LoadSnippets()
        {
            // We load snippets from two locations:
            // The "snippets" directory shipped with the module
            // A "snippets" directory in AppData\PoshCode\Snippets
            var snippetLoader = new SnippetLoader();
            Snippets.Clear();
            Snippets.AddRange(
                snippetLoader.LoadSnippets(
                    Path.Combine(Path.GetDirectoryName(Path.GetDirectoryName(typeof(SnippetPredictor).Assembly.Location))!, "snippets")));
            Snippets.AddRange(
                snippetLoader.LoadSnippets(
                    Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "PoshCode", "Snippets")));
        }

        /// <summary>
        /// Gets the unique identifier for a subsystem implementation.
        /// </summary>
        public Guid Id => _guid;

        /// <summary>
        /// Gets the name of a subsystem implementation.
        /// </summary>
        public string Name => "Snippets";

        /// <summary>
        /// Gets the description of a subsystem implementation.
        /// </summary>
        public string Description => "A Snippet Predictor";

        /// <summary>
        /// Get the predictive suggestions. It indicates the start of a suggestion rendering session.
        /// </summary>
        /// <param name="client">Represents the client that initiates the call.</param>
        /// <param name="context">The <see cref="PredictionContext"/> object to be used for prediction.</param>
        /// <param name="cancellationToken">The cancellation token to cancel the prediction.</param>
        /// <returns>An instance of <see cref="SuggestionPackage"/>.</returns>
        public SuggestionPackage GetSuggestion(PredictionClient client, PredictionContext context, CancellationToken cancellationToken)
        {
            string input = context.InputAst.Extent.Text;
            if (string.IsNullOrEmpty(input))
            {
                return default;
            }
            // We only trigger if you start with a @tag or a #name (or a <# name #> I guess)
            if (!input.StartsWith('#') && !input.StartsWith("<#") && !input.StartsWith("@"))
            {
                return default;
            }

            return new SuggestionPackage(Filter(input).Select(s => s.ToSuggestion()).ToList());
        }

        public IEnumerable<Snippet> Filter(string input)
        {
            var filtered = Snippets.AsEnumerable();
            var searchTags = TagPattern().Matches(input).ToList().ConvertAll(m => m.Groups["tag"].Value);
            var searchName = NamePattern().Matches(input).ToList().ConvertAll(m => m.Groups["name"].Value);

            if (searchTags.Count > 0)
            {
                filtered = from s in filtered
                           where s.Tags.Any(tag => searchTags.Any(st => tag.StartsWith(st, StringComparison.OrdinalIgnoreCase)))
                           select s;
            }
            if (searchName.Count > 0)
            {
                filtered = from s in filtered
                           where searchName.All(word => (s.Name + " " + s.Description + " " + s.Command).Split(' ').Any(n => n.StartsWith(word, StringComparison.OrdinalIgnoreCase)))
                           select s;
            }
            return filtered;
        }

        #region "interface methods for processing feedback"

        /// <summary>
        /// Gets a value indicating whether the predictor accepts a specific kind of feedback.
        /// </summary>
        /// <param name="client">Represents the client that initiates the call.</param>
        /// <param name="feedback">A specific type of feedback.</param>
        /// <returns>True or false, to indicate whether the specific feedback is accepted.</returns>
        public bool CanAcceptFeedback(PredictionClient client, PredictorFeedbackKind feedback) => false;


        /// <summary>
        /// One or more suggestions provided by the predictor were displayed to the user.
        /// </summary>
        /// <param name="client">Represents the client that initiates the call.</param>
        /// <param name="session">The mini-session where the displayed suggestions came from.</param>
        /// <param name="countOrIndex">
        /// When the value is greater than 0, it's the number of displayed suggestions from the list
        /// returned in <paramref name="session"/>, starting from the index 0. When the value is
        /// less than or equal to 0, it means a single suggestion from the list got displayed, and
        /// the index is the absolute value.
        /// </param>
        public void OnSuggestionDisplayed(PredictionClient client, uint session, int countOrIndex) { }

        /// <summary>
        /// The suggestion provided by the predictor was accepted.
        /// </summary>
        /// <param name="client">Represents the client that initiates the call.</param>
        /// <param name="session">Represents the mini-session where the accepted suggestion came from.</param>
        /// <param name="acceptedSuggestion">The accepted suggestion text.</param>
        public void OnSuggestionAccepted(PredictionClient client, uint session, string acceptedSuggestion) { }

        /// <summary>
        /// A command line was accepted to execute.
        /// The predictor can start processing early as needed with the latest history.
        /// </summary>
        /// <param name="client">Represents the client that initiates the call.</param>
        /// <param name="history">History command lines provided as references for prediction.</param>
        public void OnCommandLineAccepted(PredictionClient client, IReadOnlyList<string> history) { }

        /// <summary>
        /// A command line was done execution.
        /// </summary>
        /// <param name="client">Represents the client that initiates the call.</param>
        /// <param name="commandLine">The last accepted command line.</param>
        /// <param name="success">Shows whether the execution was successful.</param>
        public void OnCommandLineExecuted(PredictionClient client, string commandLine, bool success) { }

        #endregion;

        public static SnippetPredictor Instance { get; internal set; } = new SnippetPredictor(Init.Identifier);
    }
}