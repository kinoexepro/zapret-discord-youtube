# Neon Zapret GUI 2026 — by neonchik
# Modern Windows 11 launcher for zapret-discord-youtube

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Xaml

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-ElevatedBat {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { throw "Файл не найден: $Path" }
    Start-Process -FilePath 'cmd.exe' -ArgumentList @('/c', '"' + $Path + '"') -WorkingDirectory $Root -Verb RunAs
}

function Invoke-ElevatedServiceMenu {
    $service = Join-Path $Root 'service.bat'
    Invoke-ElevatedBat -Path $service
}

function Stop-Zapret {
    Start-Process -FilePath 'cmd.exe' -ArgumentList @('/c', 'taskkill /IM winws.exe /F & net stop zapret & sc stop WinDivert') -Verb RunAs -WindowStyle Hidden
}

function Get-ZapretStatus {
    $running = Get-Process -Name 'winws' -ErrorAction SilentlyContinue
    if ($running) { return 'Активен: winws.exe запущен' }
    $service = Get-Service -Name 'zapret' -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq 'Running') { return 'Активен: служба zapret запущена' }
    return 'Остановлен: выберите стратегию для запуска'
}

[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Neon Zapret 2026" Height="720" Width="1100" MinHeight="650" MinWidth="980"
        WindowStartupLocation="CenterScreen" Background="Transparent" AllowsTransparency="True" WindowStyle="None">
  <Window.Resources>
    <Style x:Key="NeonButton" TargetType="Button">
      <Setter Property="Foreground" Value="#FFF7F2FF"/>
      <Setter Property="FontSize" Value="15"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Margin" Value="0,0,0,12"/>
      <Setter Property="Padding" Value="18,13"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="Bd" CornerRadius="18" Background="{TemplateBinding Background}" BorderBrush="#55C084FC" BorderThickness="1">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="Bd" Property="Effect">
                  <Setter.Value><DropShadowEffect Color="#BB7C3AED" BlurRadius="26" ShadowDepth="0" Opacity="0.85"/></Setter.Value>
                </Setter>
                <Setter Property="RenderTransform"><Setter.Value><ScaleTransform ScaleX="1.015" ScaleY="1.015"/></Setter.Value></Setter>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
  </Window.Resources>
  <Border CornerRadius="30" BorderBrush="#663B0764" BorderThickness="1.5">
    <Border.Background>
      <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
        <GradientStop Color="#FF040006" Offset="0"/>
        <GradientStop Color="#FF12001F" Offset="0.45"/>
        <GradientStop Color="#FF2E1065" Offset="1"/>
      </LinearGradientBrush>
    </Border.Background>
    <Grid Margin="28">
      <Grid.RowDefinitions><RowDefinition Height="86"/><RowDefinition Height="*"/><RowDefinition Height="44"/></Grid.RowDefinitions>
      <Grid.ColumnDefinitions><ColumnDefinition Width="345"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>

      <StackPanel Grid.ColumnSpan="2" Orientation="Horizontal" VerticalAlignment="Center">
        <Border Width="58" Height="58" CornerRadius="20" Background="#802E1065" BorderBrush="#FFA855F7" BorderThickness="1">
          <TextBlock Text="⚡" FontSize="31" HorizontalAlignment="Center" VerticalAlignment="Center"/>
        </Border>
        <StackPanel Margin="16,0,0,0">
          <TextBlock Text="Neon Zapret 2026" Foreground="White" FontSize="32" FontWeight="Black"/>
          <TextBlock Text="black × purple gradient GUI • made by neonchik" Foreground="#FFC4B5FD" FontSize="14"/>
        </StackPanel>
      </StackPanel>
      <StackPanel Grid.ColumnSpan="2" HorizontalAlignment="Right" Orientation="Horizontal" VerticalAlignment="Top">
        <Button x:Name="MinBtn" Content="—" Width="42" Height="34" Style="{StaticResource NeonButton}" Background="#22111127" Margin="0,0,8,0"/>
        <Button x:Name="CloseBtn" Content="✕" Width="42" Height="34" Style="{StaticResource NeonButton}" Background="#44EF4444" Margin="0"/>
      </StackPanel>

      <Border Grid.Row="1" Grid.Column="0" CornerRadius="26" Background="#55100B1F" BorderBrush="#33DDD6FE" BorderThickness="1" Padding="22">
        <StackPanel>
          <TextBlock Text="Стратегии запуска" Foreground="White" FontSize="22" FontWeight="Bold" Margin="0,0,0,12"/>
          <TextBlock Text="Выберите .bat стратегию. Запуск происходит с правами администратора." TextWrapping="Wrap" Foreground="#FFD8B4FE" Margin="0,0,0,18"/>
          <ListBox x:Name="StrategyList" Height="400" Background="#33000000" Foreground="White" BorderThickness="0" FontSize="14"/>
          <Button x:Name="RunBtn" Content="▶ Запустить выбранную" Style="{StaticResource NeonButton}" Background="#FF7C3AED"/>
          <Button x:Name="StopBtn" Content="■ Остановить zapret" Style="{StaticResource NeonButton}" Background="#FFBE185D"/>
        </StackPanel>
      </Border>

      <Border Grid.Row="1" Grid.Column="1" CornerRadius="28" Margin="24,0,0,0" Background="#44160B2D" BorderBrush="#44A855F7" BorderThickness="1" Padding="28">
        <StackPanel>
          <TextBlock Text="Панель управления" Foreground="White" FontSize="26" FontWeight="Black"/>
          <TextBlock x:Name="StatusText" Text="Загрузка статуса..." Foreground="#FF86EFAC" FontSize="16" Margin="0,10,0,24"/>
          <UniformGrid Columns="2" Rows="3">
            <Button x:Name="ServiceBtn" Content="⚙ Service Manager" Style="{StaticResource NeonButton}" Background="#FF4C1D95" Margin="0,0,12,12"/>
            <Button x:Name="StatusBtn" Content="↻ Обновить статус" Style="{StaticResource NeonButton}" Background="#FF6D28D9" Margin="0,0,0,12"/>
            <Button x:Name="FolderBtn" Content="📁 Открыть папку" Style="{StaticResource NeonButton}" Background="#FF581C87" Margin="0,0,12,12"/>
            <Button x:Name="DnsBtn" Content="🌐 Secure DNS help" Style="{StaticResource NeonButton}" Background="#FF312E81" Margin="0,0,0,12"/>
            <Button x:Name="ReadmeBtn" Content="📘 README" Style="{StaticResource NeonButton}" Background="#FF1E1B4B" Margin="0,0,12,12"/>
            <Button x:Name="AboutBtn" Content="💜 by neonchik" Style="{StaticResource NeonButton}" Background="#FF701A75" Margin="0,0,0,12"/>
          </UniformGrid>
          <Border CornerRadius="24" Background="#33000000" BorderBrush="#337C3AED" BorderThickness="1" Padding="20" Margin="0,14,0,0">
            <TextBlock Foreground="#FFE9D5FF" FontSize="15" TextWrapping="Wrap" LineHeight="24"
              Text="Современный лаунчер не меняет параметры zapret: он аккуратно запускает существующие проверенные .bat стратегии, открывает Service Manager для установки автозапуска, обновлений, диагностики и переключателей Game/IPSet."/>
          </Border>
        </StackPanel>
      </Border>
      <TextBlock Grid.Row="2" Grid.ColumnSpan="2" Text="© 2026 • made by neonchik • Windows 11 neon edition" Foreground="#FF9CA3AF" HorizontalAlignment="Center" VerticalAlignment="Bottom"/>
    </Grid>
  </Border>
</Window>
'@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)
$window.Opacity = 0
$window.Add_Loaded({
    $anim = New-Object Windows.Media.Animation.DoubleAnimation(0, 1, [TimeSpan]::FromMilliseconds(420))
    $window.BeginAnimation([Windows.Window]::OpacityProperty, $anim)
})
$window.Add_MouseLeftButtonDown({ if ($_.ButtonState -eq 'Pressed') { $window.DragMove() } })

$StrategyList = $window.FindName('StrategyList')
$StatusText = $window.FindName('StatusText')
Get-ChildItem -LiteralPath $Root -Filter '*.bat' |
    Where-Object { $_.Name -notlike 'service*' -and $_.Name -notlike 'build*' -and $_.Name -notlike 'start*' } |
    Sort-Object Name | ForEach-Object { [void]$StrategyList.Items.Add($_.Name) }
if ($StrategyList.Items.Count -gt 0) { $StrategyList.SelectedIndex = 0 }
$StatusText.Text = Get-ZapretStatus

$window.FindName('RunBtn').Add_Click({
    if ($StrategyList.SelectedItem) { Invoke-ElevatedBat -Path (Join-Path $Root ([string]$StrategyList.SelectedItem)); $StatusText.Text = 'Запуск: ' + $StrategyList.SelectedItem }
})
$window.FindName('StopBtn').Add_Click({ Stop-Zapret; $StatusText.Text = 'Команда остановки отправлена' })
$window.FindName('ServiceBtn').Add_Click({ Invoke-ElevatedServiceMenu })
$window.FindName('StatusBtn').Add_Click({ $StatusText.Text = Get-ZapretStatus })
$window.FindName('FolderBtn').Add_Click({ Start-Process explorer.exe $Root })
$window.FindName('DnsBtn').Add_Click({ Start-Process 'ms-settings:network-advancedsettings' })
$window.FindName('ReadmeBtn').Add_Click({ Start-Process (Join-Path $Root 'README.md') })
$window.FindName('AboutBtn').Add_Click({ [System.Windows.MessageBox]::Show('Neon Zapret 2026`nСделал by neonchik`nЧерно‑фиолетовый Windows 11 GUI.', 'by neonchik', 'OK', 'Information') | Out-Null })
$window.FindName('MinBtn').Add_Click({ $window.WindowState = 'Minimized' })
$window.FindName('CloseBtn').Add_Click({ $window.Close() })

[void]$window.ShowDialog()
