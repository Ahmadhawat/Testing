Certainly! Here’s a concise C# MVVM example based on Josh Smith’s 2009 MSDN Magazine article *“WPF Apps With the Model‑View‑ViewModel Design Pattern”*  .


---

🔍 Scenario

Josh Smith’s sample application demonstrates:

A separation between Model, ViewModel, and View.

Use of INotifyPropertyChanged in ViewModels.

Commands via a RelayCommand implementing ICommand.

Data binding between View (XAML) and ViewModel.



---

1. Model

A simple model class representing domain data (e.g., a customer).

public class Customer
{
    public string FirstName { get; set; }
    public string LastName { get; set; }
}


---

2. ViewModel

Implements INotifyPropertyChanged, holds the model, exposes properties and commands:

public class CustomerViewModel : INotifyPropertyChanged
{
    private Customer _model;
    public CustomerViewModel(Customer model) => _model = model;

    public string FirstName
    {
        get => _model.FirstName;
        set
        {
            if (_model.FirstName != value)
            {
                _model.FirstName = value;
                OnPropertyChanged(nameof(FirstName));
            }
        }
    }
    // same for LastName ...

    public ICommand SaveCommand { get; }

    public CustomerViewModel()
    {
        SaveCommand = new RelayCommand(
            () => Save(),
            () => CanSave()
        );
    }

    private void Save() { /* perform saving */ }

    private bool CanSave()
        => !string.IsNullOrEmpty(FirstName) && !string.IsNullOrEmpty(LastName);

    public event PropertyChangedEventHandler PropertyChanged;
    protected void OnPropertyChanged(string propName)
        => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propName));
}

Smith’s article introduces a lightweight RelayCommand class, widely used in MVVM  .


---

3. View (XAML)

Data‑binding to ViewModel properties and commands:

<Window x:Class="SampleApp.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:local="clr-namespace:SampleApp"
        Title="Customer Editor" Height="200" Width="400">
  <Window.DataContext>
    <local:CustomerViewModel/>
  </Window.DataContext>
  <Grid Margin="10">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>
    <TextBox Grid.Row="0" Text="{Binding FirstName, UpdateSourceTrigger=PropertyChanged}" 
             Margin="0,0,0,5" PlaceholderText="First Name"/>
    <TextBox Grid.Row="1" Text="{Binding LastName, UpdateSourceTrigger=PropertyChanged}" 
             Margin="0,0,0,5" PlaceholderText="Last Name"/>
    <Button Grid.Row="2" Content="Save" Command="{Binding SaveCommand}" 
            Margin="0,10,0,0" HorizontalAlignment="Left"/>
  </Grid>
</Window>

This view binds text fields to ViewModel properties and the Save button to the SaveCommand.


---

🛠 Additional Insights

Commands & RelayCommand
Smith’s version of RelayCommand decouples UI actions from logic and encapsulates Execute and CanExecute via delegates  .

Testability
Since ViewModels contain all logic and no UI code, they can be unit-tested independently of WPF, a major pattern benefit.

Templates & Data Binding
The full sample also demonstrates using ViewModel collections with data templates and WPF data binding to present lists of items in the View  .



---

✅ Summary

Model: simple POCO classes.

ViewModel: wraps the model, implements INotifyPropertyChanged, exposes properties and commands.

View (XAML): binds UI controls to ViewModel properties and ICommand properties.

RelayCommand: a reusable helper class for MVVM.


If you'd like the full sample code (including collection ViewModels, templates or unit tests), many community repositories mirror Josh Smith’s MVVM demo (e.g. on GitHub)  .

Would you like to see that example extended—e.g. with a list of customers, deletion/edit dialog, or state‑based command enabling as in Smith’s full demo?

