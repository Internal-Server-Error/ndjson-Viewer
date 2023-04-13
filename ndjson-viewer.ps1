#Version 2.0

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
$filterOperator = New-Object System.Windows.Forms.TextBox
$searchTextBox = New-Object System.Windows.Forms.TextBox
$filterBtn = New-Object System.Windows.Forms.Button
$resetFilterBtn = New-Object System.Windows.Forms.Button
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

$filterOperator.Enabled = $false
$filterOperator.Location = New-Object System.Drawing.Point(139, 41)
$filterOperator.Name = "filterOperator"
$filterOperator.Size = New-Object System.Drawing.Size(60, 23)
$filterOperator.TabIndex = 1
$filterOperator.Text = "Contains"
$filterOperator.TextAlign = 'center'

$searchTextBox.Location = New-Object System.Drawing.Point(205, 41)
$searchTextBox.Name = "searchTextBox"
$searchTextBox.Size = New-Object System.Drawing.Size(459, 23)
$searchTextBox.TabIndex = 2
$searchTextBox.Anchor = 'top,right,left'

$filterBtn.Location = New-Object System.Drawing.Point(670, 40)
$filterBtn.Name = "filterBtn"
$filterBtn.Size = New-Object System.Drawing.Size(57, 23)
$filterBtn.TabIndex = 3
$filterBtn.Text = "Filter"
$filterBtn.UseVisualStyleBackColor = $true
$filterBtn.Anchor = 'top,right'

$resetFilterBtn.Location = New-Object System.Drawing.Point(733, 40)
$resetFilterBtn.Name = "resetFilterBtn"
$resetFilterBtn.Size = New-Object System.Drawing.Size(55, 23)
$resetFilterBtn.TabIndex = 4
$resetFilterBtn.Text = "Reset"
$resetFilterBtn.UseVisualStyleBackColor = $true
$resetFilterBtn.Anchor = 'top,right'

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
$mainForm.Controls.Add($filterOperator)
$mainForm.Controls.Add($searchTextBox)
$mainForm.Controls.Add($filterBtn)
$mainForm.Controls.Add($resetFilterBtn)
$mainForm.Controls.Add($gridView)

$dtLogs = New-Object System.Data.DataTable("logs")

function OpenLogFileAndFillDataTable() {
   
   $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
   $openFileDialog.InitialDirectory = [Environment]::GetFolderPath('Desktop') 
   $openFileDialog.Title = 'Please Select a ndjson File'
   $openFileDialog.filter = 'ndjson  (*.ndjson)| *.ndjson|all  (*.*)| *.*'
   
   if ($openFileDialog.ShowDialog() -eq 1) { 
      
      $fileContent = Get-Content $openFileDialog.FileName
      
      #Each json line can have different properties and we need to show all available columns.
      foreach ($line in $fileContent) {
         $jsonLogLine = $line | ConvertFrom-Json
         $jsonLogLine.psobject.properties | ForEach-Object {
            if ($dtLogs.Columns.Contains($_.Name) -eq $false) {
               $dtLogs.Columns.Add($_.Name)
               $propertiesSearchDropDown.Items.Add($_.Name)
            }
         }
      }

      $propertiesSearchDropDown.SelectedIndex = 0
      
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

function ResetDataTable() {
   if ($dtLogs.Columns.Count -le 0) {
      return
   }
   $columnName = $propertiesSearchDropDown.SelectedItem
   $dtLogs.DefaultView.RowFilter = "$columnName LIKE '%'"
   $searchTextBox.Text = ''
}

function FilterDataTableByPropertyAndSearchText() {
   if ($dtLogs.Columns.Count -le 0) {
      return
   }
   $columnName = $propertiesSearchDropDown.SelectedItem
   $searchText = $searchTextBox.Text
   $dtLogs.DefaultView.RowFilter = "$columnName LIKE '%$searchText%'"
}


$searchTextBox.Add_KeyDown({
      if ($_.KeyCode -eq "Enter") {
         FilterDataTableByPropertyAndSearchText
      }
   })
$filterBtn.Add_Click( { FilterDataTableByPropertyAndSearchText })
$resetFilterBtn.Add_Click( { ResetDataTable })
$openFileBtn.Add_Click( { OpenLogFileAndFillDataTable })
$mainForm.ShowDialog()
