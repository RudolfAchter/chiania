

#mongodb+srv://rudi:<password>@chia-stuff.g7ivxgh.mongodb.net/?retryWrites=true&w=majority

$connectionString="mongodb+srv://rudi:Windach2014@chia-stuff.g7ivxgh.mongodb.net/chia-stuff?retryWrites=true&w=majority"

# Connect the new collection test.test
Connect-Mdbc -ConnectionString $connectionString -DatabaseName "chia-stuff" -CollectionName "test"

# Add some test data
@{_id=1; value=42}, @{_id=2; value=3.14} | Add-MdbcData

# Get all data as custom objects and show them in a table
Get-MdbcData -As PS | Format-Table -AutoSize | Out-String