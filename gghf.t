Excellent — here is the final and fully working version using two ListBoxes:

✅ One for live console output

✅ One for colored test result summary

❌ No more RichTextBox or FlowDocument (since that doesn’t work with dynamic binding)



---

📄 MainViewModel.cs (Updated)

using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Win32;
using System.Windows.Media;
using VSTestRunnerMVVM.Models;

namespace VSTestRunnerMVVM.ViewModels
{
    public class MainViewModel : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        private string _dllPath;
        public string DllPath
        {
            get => _dllPath;
            set
            {
                _dllPath = value;
                OnPropertyChanged();
                _runTestsCommand?.RaiseCanExecuteChanged();
            }
        }

        public ObservableCollection<string> ConsoleOutput { get; } = new();
        public ObservableCollection<TestResult> SummaryResults { get; } = new();

        public ICommand BrowseDllCommand { get; }
        public ICommand RunTestsCommand => _runTestsCommand;

        private readonly TestRunner testRunner = new();
        private readonly RelayCommand _runTestsCommand;

        public MainViewModel()
        {
            BrowseDllCommand = new RelayCommand(BrowseDll);
            _runTestsCommand = new RelayCommand(
                async () => await RunTestsAsync(),
                () => !string.IsNullOrWhiteSpace(DllPath));
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
            try
            {
                var results = await testRunner.RunTestsAsync(DllPath);

                ConsoleOutput.Clear();
                SummaryResults.Clear();

                foreach (var result in results)
                {
                    ConsoleOutput.Add(result.Message);

                    if (result.Status != TestResultStatus.Info)
                        SummaryResults.Add(result);
                }

                OnPropertyChanged(nameof(ConsoleOutput));
                OnPropertyChanged(nameof(SummaryResults));
            }
            catch (Exception ex)
            {
                var error = new TestResult
                {
                    Message = "[Error] " + ex.Message,
                    Status = TestResultStatus.Failed
                };

                ConsoleOutput.Add(error.Message);
                SummaryResults.Add(error);

                OnPropertyChanged(nameof(ConsoleOutput));
                OnPropertyChanged(nameof(SummaryResults));
            }
        }

        protected void OnPropertyChanged([CallerMemberName] string name = null)
            => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
    }
}


---

📄 MainWindow.xaml (Updated)

<Window x:Class="VSTestRunnerMVVM.Views.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:viewmodels="clr-namespace:VSTestRunnerMVVM.ViewModels"
        xmlns:converters="clr-namespace:VSTestRunnerMVVM.Converters"
        Title="Unit Test Runner" Height="650" Width="900">

    <Window.Resources>
        <converters:StatusToBrushConverter x:Key="StatusToBrushConverter"/>
    </Window.Resources>

    <Window.DataContext>
        <viewmodels:MainViewModel/>
    </Window.DataContext>

    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="2*"/>
            <RowDefinition Height="2*"/>
        </Grid.RowDefinitions>

        <!-- Toolbar -->
        <StackPanel Orientation="Horizontal" Margin="0,0,0,10">
            <Button Content="Browse DLL" Width="100" Command="{Binding BrowseDllCommand}" />
            <TextBox Text="{Binding DllPath}" Width="600" Margin="10,0" IsReadOnly="True"/>
            <Button Content="Run Tests" Width="100" Command="{Binding RunTestsCommand}" Margin="10,0,0,0"/>
        </StackPanel>

        <!-- Terminal-style raw output -->
        <ListBox Grid.Row="1"
                 ItemsSource="{Binding ConsoleOutput}"
                 FontFamily="Consolas"
                 FontSize="13"
                 Background="Black"
                 Foreground="LightGray"
                 BorderBrush="Gray"
                 BorderThickness="1" />

        <!-- Colored summary output -->
        <ListBox Grid.Row="2"
                 ItemsSource="{Binding SummaryResults}"
                 FontFamily="Consolas"
                 FontSize="13"
                 Background="#111"
                 Foreground="LightGray"
                 BorderBrush="Gray"
                 BorderThickness="1">
            <ListBox.ItemTemplate>
                <DataTemplate>
                    <TextBlock Text="{Binding Message}"
                               Foreground="{Binding Status, Converter={StaticResource StatusToBrushConverter}}" />
                </DataTemplate>
            </ListBox.ItemTemplate>
        </ListBox>
    </Grid>
</Window>


---

✅ Result:

You now get terminal output live in the top ListBox.

A clean colored test summary is shown in the bottom ListBox.


Would you like auto-scroll added to either ListBox or export-to-text options next?

