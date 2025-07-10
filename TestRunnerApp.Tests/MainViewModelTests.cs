using Moq;
using TestRunnerApp.Core.Interfaces;
using TestRunnerApp.UI.ViewModels;
using Xunit;

public class MainViewModelTests
{
    [Fact]
    public async Task RunTestsCommand_AddsLogLines()
    {
        var mockRunner = new Mock<ITestRunnerService>();
        var logger = new Mock<ILogService>();

        mockRunner.Setup(r => r.RunTestsAsync(It.IsAny<string>(), It.IsAny<Action<string>>(), It.IsAny<Action<string>>()))
            .Returns<string, Action<string>, Action<string>>((path, onOut, onErr) =>
            {
                onOut("Test passed");
                return Task.CompletedTask;
            });

        var vm = new MainViewModel(mockRunner.Object, logger.Object);
        await vm.RunTestsAsyncCommand.ExecuteAsync(null);

        Assert.Contains("Test passed", vm.LogLines);
    }
}
