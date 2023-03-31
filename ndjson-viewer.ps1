#Version 1.0

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

$openFileBtn = New-Object System.Windows.Forms.Button
$propertiesSearchDropDown = New-Object System.Windows.Forms.ComboBox
$searchOperator = New-Object System.Windows.Forms.TextBox
$searchTextBox = New-Object System.Windows.Forms.TextBox
$searchBtn = New-Object System.Windows.Forms.Button
$resetSearchBtn = New-Object System.Windows.Forms.Button
$gridView = New-Object System.Windows.Forms.DataGridView

$openFileBtn.Location = New-Object System.Drawing.Point(12, 11)
$openFileBtn.Name = "openFileBtn"
$openFileBtn.Size = New-Object System.Drawing.Size(120, 23)
$openFileBtn.TabIndex = 0
$openFileBtn.Text = "Open ndjson file"
$openFileBtn.UseVisualStyleBackColor = $true

$propertiesSearchDropDown.FormattingEnabled = $true
$propertiesSearchDropDown.Location = New-Object System.Drawing.Point(12, 41)
$propertiesSearchDropDown.Name = "propertiesSearchDropDown"
$propertiesSearchDropDown.Size = New-Object System.Drawing.Size(121, 23)
$propertiesSearchDropDown.TabIndex = 0

$searchOperator.Enabled = $false
$searchOperator.Location = New-Object System.Drawing.Point(139, 41)
$searchOperator.Name = "searchOperator"
$searchOperator.Size = New-Object System.Drawing.Size(60, 23)
$searchOperator.TabIndex = 1
$searchOperator.Text = "Contains"
$searchOperator.TextAlign = 'center'

$searchTextBox.Location = New-Object System.Drawing.Point(205, 41)
$searchTextBox.Name = "searchTextBox"
$searchTextBox.Size = New-Object System.Drawing.Size(459, 23)
$searchTextBox.TabIndex = 2
$searchTextBox.Anchor = 'top,right,left'

$searchBtn.Location = New-Object System.Drawing.Point(670, 40)
$searchBtn.Name = "searchBtn"
$searchBtn.Size = New-Object System.Drawing.Size(57, 23)
$searchBtn.TabIndex = 3
$searchBtn.Text = "Filter"
$searchBtn.UseVisualStyleBackColor = $true
$searchBtn.Anchor = 'top,right'

$resetSearchBtn.Location = New-Object System.Drawing.Point(733, 40)
$resetSearchBtn.Name = "resetSearchBtn"
$resetSearchBtn.Size = New-Object System.Drawing.Size(55, 23)
$resetSearchBtn.TabIndex = 4
$resetSearchBtn.Text = "Reset"
$resetSearchBtn.UseVisualStyleBackColor = $true
$resetSearchBtn.Anchor = 'top,right'

$gridView.AutoSizeColumnsMode = 'Fill'
$gridView.ColumnHeadersHeightSizeMode = 'AutoSize'
$gridView.Location = New-Object System.Drawing.Point(12, 74)
$gridView.Name = "gridView"
$gridView.ReadOnly = $true
$gridView.RowTemplate.Height = 25
$gridView.Size = New-Object System.Drawing.Size(776, 510)
$gridView.TabIndex = 2
$gridView.Anchor = 'top,bottom,right,left'

$mainForm = New-Object system.Windows.Forms.Form
$mainForm.ClientSize = '800,600'
$mainForm.MinimumSize = '800,600'
$mainForm.text = "ndjson Viewer"
$mainForm.TopMost = $false
$mainForm.ShowIcon = $false

$mainForm.Controls.Add($openFileBtn)
$mainForm.Controls.Add($propertiesSearchDropDown)
$mainForm.Controls.Add($searchOperator)
$mainForm.Controls.Add($searchTextBox)
$mainForm.Controls.Add($searchBtn)
$mainForm.Controls.Add($resetSearchBtn)
$mainForm.Controls.Add($gridView)

$dtLogs = New-Object System.Data.DataTable("logs")

function OpenLogFileAndFillDataTable() {
   
   $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
   $openFileDialog.InitialDirectory = [Environment]::GetFolderPath('Desktop') 
   $openFileDialog.Title = 'Please Select a ndjson File'
   $openFileDialog.filter = 'ndjson  (*.ndjson)| *.ndjson'
   
   if ($openFileDialog.ShowDialog() -eq 1) { 
      
      $fileContent = Get-Content $openFileDialog.FileName
      
      #Each json line can have different properties and we need to show all available columns.
      foreach ($line in $fileContent) {
         $jsonLogLine = $line | ConvertFrom-Json
         $jsonLogLine.psobject.properties | ForEach-Object {
            if ($dtLogs.Columns.Contains($_.Name) -eq $false) {
               $dtLogs.Columns.Add($_.Name)
            }
         }
      }
      
      foreach ($line in $fileContent) {
         $jsonLogLine = $line | ConvertFrom-Json
         $row = $dtLogs.NewRow()
         $jsonLogLine.psobject.properties | ForEach-Object {
            $row[$_.Name] = $_.Value
         }
         $dtLogs.Rows.Add($row)
         $gridView.DataSource = $dtLogs
      }
   }
}












$openFileBtn.Add_Click( { OpenLogFileAndFillDataTable })
$mainForm.ShowDialog()

<#

filter dt:
$result = $dtPeople.Select("log.level = info")
#>