namespace TestRunnerApp.Core.Models;

public class TestResult
{
    public string TestName { get; set; }
    public bool Passed { get; set; }
    public string Output { get; set; }
}
