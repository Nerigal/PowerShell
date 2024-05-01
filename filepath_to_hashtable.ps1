# Define the root directory
$root_directory = 'test/subscription/resource/virtualmachine'

# Get all files and directories recursively
$items = Get-ChildItem -Path $root_directory -Recurse

# Initialize an empty hash table
$hash_table = @{}

# Function to recursively build hash table
function Add-ItemToHashTable($path, $value) {
    $pathParts = $path -split '\\|/'
    $currentHash = $hash_table
    for ($i = 0; $i -lt $pathParts.Count; $i++) {
        $part = $pathParts[$i]
        if ($i -eq $pathParts.Count - 1) {
            $currentHash[$part] = $value
        }
        else {
            if (-not $currentHash.ContainsKey($part)) {
                $currentHash[$part] = @{}
            }
            $currentHash = $currentHash[$part]
        }
    }
}

# Iterate through each item (file or directory)
foreach ($item in $items) {
    # If it's a directory, add it to the hash table
    if ($item.PSIsContainer) {
        Add-ItemToHashTable -path $item.FullName -value @{}
    } else {
        # If it's a file, add it to the hash table
        $parentPath = Split-Path $item.FullName -Parent
        $parent = $hash_table
        while ($parentPath -ne $root_directory -and $parentPath -ne '') {
            $pathParts = $parentPath -split '\\|/'
            $currentHash = $hash_table
            for ($i = 0; $i -lt $pathParts.Count; $i++) {
                $part = $pathParts[$i]
                $currentHash = $currentHash[$part]
            }
            $parent = $currentHash
            $parentPath = Split-Path $parentPath -Parent
        }
        Add-ItemToHashTable -path $item.FullName -value $item.Name
    }
}

# Display the multidimensional hash table
$hash_table
