using System.Management.Automation;
using System.Management.Automation.Subsystem;
using System.Management.Automation.Subsystem.Prediction;

namespace PoshCode.Snippets
{
    /// <summary>
    /// Register the predictor on module loading and unregister it on module un-loading.
    /// </summary>
    public class Init : IModuleAssemblyInitializer, IModuleAssemblyCleanup
    {
        /// <summary>
        /// Gets called when assembly is loaded.
        /// </summary>
        public void OnImport()
        {
            SubsystemManager.RegisterSubsystem(SubsystemKind.CommandPredictor, Predictor.Instance);
        }

        /// <summary>
        /// Gets called when the binary module is unloaded.
        /// </summary>
        public void OnRemove(PSModuleInfo psModuleInfo)
        {
            SubsystemManager.UnregisterSubsystem<ICommandPredictor>(Predictor.Identifier);
        }
    }
}