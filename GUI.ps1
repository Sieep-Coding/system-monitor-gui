Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to get CPU usage
function Get-CPUUsage {
    try {
        $cpuCounter = Get-WmiObject Win32_PerfFormattedData_PerfOS_Processor | Where-Object { $_.Name -eq "_Total" }
        return [Math]::Round($cpuCounter.PercentProcessorTime, 2)
    } catch {
        return "N/A"
    }
}

# Function to get Memory usage
function Get-MemoryUsage {
    try {
        $memoryCounter = Get-WmiObject Win32_OperatingSystem
        return [Math]::Round(($memoryCounter.TotalVisibleMemorySize - $memoryCounter.FreePhysicalMemory) / $memoryCounter.TotalVisibleMemorySize * 100, 2)
    } catch {
        return "N/A"
    }
}

# Function to get Disk usage
function Get-DiskUsage {
    try {
        $diskCounter = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
        return [Math]::Round(($diskCounter.Size - $diskCounter.FreeSpace) / $diskCounter.Size * 100, 2)
    } catch {
        return "N/A"
    }
}

# Function to get Network activity
function Get-NetworkActivity {
    try {
        $networkCounter = Get-Counter '\Network Interface(*)\Bytes Total/sec' -ErrorAction SilentlyContinue
        if ($networkCounter) {
            $networkCounter = $networkCounter.CounterSamples | Where-Object { $_.InstanceName -ne "_Total" } | Measure-Object -Property CookedValue -Sum
            return [Math]::Round($networkCounter.Sum / 1MB, 2) # Convert to MB
        } else {
            return "N/A"
        }
    } catch {
        return "N/A"
    }
}

# Create Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "System Dashboard"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# CPU Label
$cpuLabel = New-Object System.Windows.Forms.Label
$cpuLabel.Text = "CPU Usage:"
$cpuLabel.AutoSize = $true
$cpuLabel.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($cpuLabel)

# CPU Value Label
$cpuValueLabel = New-Object System.Windows.Forms.Label
$cpuValueLabel.AutoSize = $true
$cpuValueLabel.Location = New-Object System.Drawing.Point(120, 20)
$form.Controls.Add($cpuValueLabel)

# Memory Label
$memoryLabel = New-Object System.Windows.Forms.Label
$memoryLabel.Text = "Memory Usage:"
$memoryLabel.AutoSize = $true
$memoryLabel.Location = New-Object System.Drawing.Point(20, 60)
$form.Controls.Add($memoryLabel)

# Memory Value Label
$memoryValueLabel = New-Object System.Windows.Forms.Label
$memoryValueLabel.AutoSize = $true
$memoryValueLabel.Location = New-Object System.Drawing.Point(120, 60)
$form.Controls.Add($memoryValueLabel)

# Disk Label
$diskLabel = New-Object System.Windows.Forms.Label
$diskLabel.Text = "Disk Usage:"
$diskLabel.AutoSize = $true
$diskLabel.Location = New-Object System.Drawing.Point(20, 100)
$form.Controls.Add($diskLabel)

# Disk Value Label
$diskValueLabel = New-Object System.Windows.Forms.Label
$diskValueLabel.AutoSize = $true
$diskValueLabel.Location = New-Object System.Drawing.Point(120, 100)
$form.Controls.Add($diskValueLabel)

# Network Label
$networkLabel = New-Object System.Windows.Forms.Label
$networkLabel.Text = "Network Activity:"
$networkLabel.AutoSize = $true
$networkLabel.Location = New-Object System.Drawing.Point(20, 140)
$form.Controls.Add($networkLabel)

# Network Value Label
$networkValueLabel = New-Object System.Windows.Forms.Label
$networkValueLabel.AutoSize = $true
$networkValueLabel.Location = New-Object System.Drawing.Point(120, 140)
$form.Controls.Add($networkValueLabel)

# Timer to update values every 1 second
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({
    try {
        $cpuUsage = Get-CPUUsage
        $memoryUsage = Get-MemoryUsage
        $diskUsage = Get-DiskUsage
        $networkActivity = Get-NetworkActivity

        $cpuValueLabel.Text = "$cpuUsage %"
        $memoryValueLabel.Text = "$memoryUsage %"
        $diskValueLabel.Text = "$diskUsage %"
        $networkValueLabel.Text = "$networkActivity MB/s"
    } catch {
        # Handle exceptions gracefully
        $cpuValueLabel.Text = "N/A"
        $memoryValueLabel.Text = "N/A"
        $diskValueLabel.Text = "N/A"
        $networkValueLabel.Text = "N/A"
    }
})
$timer.Start()

# Display Form
$form.ShowDialog() | Out-Null
