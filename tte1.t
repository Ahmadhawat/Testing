Absolutely — here is your final setup, combining everything:

✅ ViewModel (with separate ConsoleOutput and SummaryLines)

✅ XAML (MainWindow.xaml) with proper bindings

✅ Includes colored summary using RichTextBox

✅ Live terminal-like output using ListBox



---

📄 MainViewModel.cs

using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using Microsoft.Win32;
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
        public ObservableCollection<Paragraph> SummaryLines { get; } = new();

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
                SummaryLines.Clear();

                foreach (var result in results)
                {
                    ConsoleOutput.Add(result.Message);

                    if (result.Status != TestResultStatus.Info)
                    {
                        var paragraph = new Paragraph(new Run(result.Message)
                        {
                            Foreground = GetBrush(result.Status)
                        });
                        SummaryLines.Add(paragraph);
                    }
                }

                OnPropertyChanged(nameof(ConsoleOutput));
                OnPropertyChanged(nameof(SummaryLines));
            }
            catch (Exception ex)
            {
                ConsoleOutput.Add("[Error] " + ex.Message);
                SummaryLines.Add(new Paragraph(new Run("[Error] " + ex.Message)
                {
                    Foreground = Brushes.Red
                }));

                OnPropertyChanged(nameof(ConsoleOutput));
                OnPropertyChanged(nameof(SummaryLines));
            }
        }

        private Brush GetBrush(TestResultStatus status)
        {
            return status switch
            {
                TestResultStatus.Passed => Brushes.Green,
                TestResultStatus.Failed => Brushes.Red,
                TestResultStatus.Summary => Brushes.CadetBlue,
                _ => Brushes.LightGray
            };
        }

        protected void OnPropertyChanged([CallerMemberName] string name = null)
            => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
    }
}


---

📄 MainWindow.xaml

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
            <RowDefinition Height="3*"/>
        </Grid.RowDefinitions>

        <!-- Toolbar -->
        <StackPanel Orientation="Horizontal" Margin="0,0,0,10">
            <Button Content="Browse DLL" Width="100" Command="{Binding BrowseDllCommand}" />
            <TextBox Text="{Binding DllPath}" Width="600" Margin="10,0" IsReadOnly="True"/>
            <Button Content="Run Tests" Width="100" Command="{Binding RunTestsCommand}" Margin="10,0,0,0"/>
        </StackPanel>

        <!-- Console Output -->
        <ListBox Grid.Row="1"
                 ItemsSource="{Binding ConsoleOutput}"
                 FontFamily="Consolas"
                 FontSize="13"
                 Background="Black"
                 Foreground="LightGray"
                 BorderBrush="Gray"
                 BorderThickness="1" />

        <!-- Summary -->
        <RichTextBox Grid.Row="2"
                     FontFamily="Consolas"
                     FontSize="13"
                     IsReadOnly="True"
                     VerticalScrollBarVisibility="Auto">
            <FlowDocument>
                <ItemsControl ItemsSource="{Binding SummaryLines}">
                    <ItemsControl.ItemsPanel>
                        <ItemsPanelTemplate>
                            <StackPanel />
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

✅ With this setup:

UI Part	Binds to	Purpose

ListBox	ConsoleOutput	Raw terminal-style output
RichTextBox	SummaryLines	Colored test results
Run Button	Enabled only with DLL	Uses CanExecute logic


Let me know if you want:

MainWindow.xaml.cs

Auto-scroll to bottom

Export-to-file option for logs


You're now running a real MVVM test harness UI — excellent work!

