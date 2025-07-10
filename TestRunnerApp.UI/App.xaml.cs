using Microsoft.Extensions.DependencyInjection;
using System.Windows;
using TestRunnerApp.Core.Interfaces;
using TestRunnerApp.Infrastructure.Services;
using TestRunnerApp.UI.ViewModels;

namespace TestRunnerApp.UI;

public partial class App : Application
{
    public static new App Current => (App)Application.Current;

    public IServiceProvider Services { get; private set; }

    protected override void OnStartup(StartupEventArgs e)
    {
        var services = new ServiceCollection();

        services.AddSingleton<ITestRunnerService, VSTestRunnerService>();
        services.AddSingleton<ILogService, ConsoleLogService>();
        services.AddSingleton<MainViewModel>();

        Services = services.BuildServiceProvider();

        var mainWindow = new Views.MainWindow
        {
            DataContext = Services.GetRequiredService<MainViewModel>()
        };

        mainWindow.Show();

        base.OnStartup(e);
    }
}
