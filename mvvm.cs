To convert this code into MVVM (Model-View-ViewModel) architecture in WPF, you'll need to refactor your code to separate:

Model – Represents your data and logic (e.g., test results, DLL paths).

View – Your existing XAML file (MainWindow.xaml) which will be mostly unchanged except for binding.

ViewModel – Handles logic and acts as the data context for the view.



---

✅ Steps to Convert to MVVM


---

1. Create a ViewModel Class

Create a new class called MainViewModel.cs.

using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Documents;
using System.Windows.Input;
using Microsoft.Win32;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using System.Windows.Media;

public class MainViewModel : INotifyPropertyChanged
{
    public event PropertyChangedEventHandler PropertyChanged;

    private string _dllPath;
    public string DllPath
    {
        get => _dllPath;
        set { _dllPath = value; OnPropertyChanged(); }
    }

    public ObservableCollection<string> TestLines { get; } = new();
    public ObservableCollection<Paragraph> SummaryLines { get; } = new();

    public ICommand BrowseDllCommand { get; }
    public ICommand RunTestsCommand { get; }

    public MainViewModel()
    {
        BrowseDllCommand = new RelayCommand(BrowseDll);
        RunTestsCommand = new RelayCommand(async () => await RunTestsAsync());
    }

    private void BrowseDll()
    {
        OpenFileDialog dlg = new()
        {
            Filter = "DLL Files (*.dll)|*.dll",
            Title = "Select Unit Test DLL"
        };
        if (dlg.ShowDialog() == true)
        {
            DllPath = dlg.FileName;
        }
    }

    private async Task RunTestsAsync()
    {
        if (string.IsNullOrWhiteSpace(DllPath) || !File.Exists(DllPath))
        {
            System.Windows.MessageBox.Show("Please select a valid test DLL first.");
            return;
        }

        string exePath = @"C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\Extensions\TestPlatform\vstest.console.exe";
        string arguments = $"\"{DllPath}\" --InIsolation";

        TestLines.Clear();
        SummaryLines.Clear();

        var psi = new ProcessStartInfo
        {
            FileName = exePath,
            Arguments = arguments,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true
        };

        var process = new Process { StartInfo = psi, EnableRaisingEvents = true };

        process.OutputDataReceived += (s, e) =>
        {
            if (!string.IsNullOrWhiteSpace(e.Data))
            {
                App.Current.Dispatcher.Invoke(() =>
                {
                    TestLines.Add(e.Data);
                });
            }
        };

        process.ErrorDataReceived += (s, e) =>
        {
            if (!string.IsNullOrWhiteSpace(e.Data))
            {
                App.Current.Dispatcher.Invoke(() =>
                {
                    TestLines.Add("[Error] " + e.Data);
                });
            }
        };

        try
        {
            process.Start();
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
            await process.WaitForExitAsync();
            ParseAndShowSummary(TestLines);
        }
        catch (Exception ex)
        {
            TestLines.Add("[Error] " + ex.Message);
        }
    }

    private void ParseAndShowSummary(ObservableCollection<string> lines)
    {
        foreach (var line in lines)
        {
            SolidColorBrush color = Brushes.Black;
            if (line.StartsWith("Passed", StringComparison.OrdinalIgnoreCase))
                color = Brushes.Green;
            else if (line.Contains("Failed", StringComparison.OrdinalIgnoreCase))
                color = Brushes.Red;
            else if (line.StartsWith("Total tests", StringComparison.OrdinalIgnoreCase))
                color = Brushes.CadetBlue;
            else if (line.Contains("Test Run Successful", StringComparison.OrdinalIgnoreCase))
                color = Brushes.Green;
            else if (line.Contains("Test Run Failed", StringComparison.OrdinalIgnoreCase))
                color = Brushes.Red;

            var p = new Paragraph(new Run(line) { Foreground = color });
            SummaryLines.Add(p);
        }
    }

    protected void OnPropertyChanged([CallerMemberName] string name = null)
        => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
}


---

2. Create a RelayCommand Class

For ICommand implementation.

public class RelayCommand : ICommand
{
    private readonly Action _execute;
    private readonly Func<bool> _canExecute;

    public RelayCommand(Action execute, Func<bool> canExecute = null)
    {
        _execute = execute;
        _canExecute = canExecute;
    }

    public bool CanExecute(object parameter) => _canExecute?.Invoke() ?? true;

    public void Execute(object parameter) => _execute();

    public event EventHandler CanExecuteChanged
    {
        add => CommandManager.RequerySuggested += value;
        remove => CommandManager.RequerySuggested -= value;
    }
}


---

3. Update Your View (XAML) to Use Data Binding

In MainWindow.xaml:

Add a DataContext in the code-behind or via XAML (recommended via code-behind).

Replace code-behind events with bindings.


<Window ...>
    <Window.DataContext>
        <local:MainViewModel/>
    </Window.DataContext>
    
    <Grid>
        <!-- Same layout -->
        <StackPanel Orientation="Horizontal">
            <Button Content="Browse DLL" Command="{Binding BrowseDllCommand}" Width="100"/>
            <TextBox Text="{Binding DllPath}" Width="600" IsReadOnly="True" Margin="10,0"/>
            <Button Content="Run Tests" Command="{Binding RunTestsCommand}" Width="100"/>
        </StackPanel>

        <TextBox Grid.Row="1" FontFamily="Consolas" FontSize="13"
                 Text="{Binding TestLines}" IsReadOnly="True"
                 TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"/>

        <RichTextBox Grid.Row="2" FontFamily="Consolas" FontSize="13"
                     IsReadOnly="True" VerticalScrollBarVisibility="Auto">
            <FlowDocument>
                <ItemsControl ItemsSource="{Binding SummaryLines}">
                    <ItemsControl.ItemsPanel>
                        <ItemsPanelTemplate>
                            <StackPanel/>
                        </ItemsPanelTemplate>
                    </ItemsControl.ItemsPanel>
                    <ItemsControl.ItemTemplate>
                        <DataTemplate>
                            <ContentPresenter Content="{Binding}"/>
                        </DataTemplate>
                    </ItemsControl.ItemTemplate>
                </ItemsControl>
            </FlowDocument>
        </RichTextBox>
    </Grid>
</Window>


---

4. Remove Logic from Code-Behind

Your MainWindow.xaml.cs should only initialize:

public partial class MainWindow : Window
{
    public MainWindow()
    {
        InitializeComponent();
        DataContext = new MainViewModel();
    }
}


---

✅ Benefits of This MVVM Refactor

Testability: Your logic is now in the ViewModel, making it unit-testable.

Maintainability: Clear separation of UI and logic.

Scalability: Easier to manage and extend as the application grows.




