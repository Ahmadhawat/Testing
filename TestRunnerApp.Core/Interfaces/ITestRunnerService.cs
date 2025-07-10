namespace TestRunnerApp.Core.Interfaces;

public interface ITestRunnerService
{
    Task RunTestsAsync(string testFilePath, Action<string> onOutput, Action<string> onError);
}
