using System.Diagnostics;
using TestRunnerApp.Core.Interfaces;

namespace TestRunnerApp.Infrastructure.Services;

public class VSTestRunnerService : ITestRunnerService
{
    public async Task RunTestsAsync(string testFilePath, Action<string> onOutput, Action<string> onError)
    {
        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = "vstest.console.exe",
                Arguments = $"\"{testFilePath}\"",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            }
        };

        process.OutputDataReceived += (s, e) => { if (e.Data != null) onOutput(e.Data); };
        process.ErrorDataReceived += (s, e) => { if (e.Data != null) onError(e.Data); };

        process.Start();
        process.BeginOutputReadLine();
        process.BeginErrorReadLine();
        await process.WaitForExitAsync();
    }
}
