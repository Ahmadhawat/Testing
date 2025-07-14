<Window x:Class="UnitTestRunner.Views.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:viewmodels="clr-namespace:UnitTestRunner.ViewModels"
        xmlns:converters="clr-namespace:VSTestRunnerMVVM.Converters"
        Title="Unit Test Runner" Height="450" Width="880">

    <!-- Application-level Resources -->
    <Window.Resources>
        <converters:StatusToBrushConverter x:Key="StatusToBrushConverter" />
    </Window.Resources>

    <!-- ViewModel as DataContext -->
    <Window.DataContext>
        <viewmodels:MainViewModel />
    </Window.DataContext>

    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/> <!-- Controls -->
            <RowDefinition Height="2*"/>  <!-- Raw Output -->
            <RowDefinition Height="3*"/>  <!-- Summary -->
        </Grid.RowDefinitions>

        <!-- File Controls -->
        <StackPanel Orientation="Horizontal" Margin="0,0,0,10">
            <Button Content="Browse DLL" Width="100" Command="{Binding BrowseDllCommand}" />
            <TextBox Text="{Binding DllPath}" Width="600" Margin="10,0" IsReadOnly="True" />
            <Button Content="Run Tests" Width="100" Command="{Binding RunTestsCommand}" Margin="10,0,0,0" />
        </StackPanel>

        <!-- Raw Output List -->
        <ListBox Grid.Row="1"
                 ItemsSource="{Binding TestResults}"
                 FontFamily="Consolas"
                 FontSize="13"
                 Background="#111"
                 Foreground="#ddd">
            <ListBox.ItemTemplate>
                <DataTemplate>
                    <TextBlock Text="{Binding Message}"
                               Foreground="{Binding Status, Converter={StaticResource StatusToBrushConverter}}" />
                </DataTemplate>
            </ListBox.ItemTemplate>
        </ListBox>

        <!-- Test Summary RichTextBox (optional, separate summary) -->
        <RichTextBox Grid.Row="2"
                     Name="SummaryBox"
                     Margin="0,10,0,0"
                     FontFamily="Consolas"
                     FontSize="13"
                     IsReadOnly="True"
                     VerticalScrollBarVisibility="Auto"/>
    </Grid>
</Window>