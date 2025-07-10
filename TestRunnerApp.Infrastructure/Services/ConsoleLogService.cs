using TestRunnerApp.Core.Interfaces;

namespace TestRunnerApp.Infrastructure.Services;

public class ConsoleLogService : ILogService
{
    public void Log(string message)
    {
        Console.WriteLine(message);
    }
}
