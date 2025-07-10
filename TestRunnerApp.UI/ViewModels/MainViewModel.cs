using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
using TestRunnerApp.Core.Interfaces;

namespace TestRunnerApp.UI.ViewModels;

public partial class MainViewModel : ObservableObject
{
    private readonly ITestRunnerService _testRunner;
    private readonly ILogService _logger;

    [ObservableProperty]
    private string testFilePath = "YourTestAssembly.dll";

    public ObservableCollection<string> LogLines { get; } = new();

    public MainViewModel(ITestRunnerService testRunner, ILogService logger)
    {
        _testRunner = testRunner;
        _logger = logger;
    }

    [RelayCommand]
    private async Task RunTestsAsync()
    {
        LogLines.Clear();
        await _testRunner.RunTestsAsync(TestFilePath,
            output => App.Current.Dispatcher.Invoke(() =>
            {
                LogLines.Add(output);
                _logger.Log(output);
            }),
            error => App.Current.Dispatcher.Invoke(() =>
            {
                LogLines.Add($"ERROR: {error}");
                _logger.Log($"ERROR: {error}");
            }));
    }
}
