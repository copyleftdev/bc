# BC (Branch Cleaner)

A blazingly fast Git branch cleanup utility that supports parallel processing.

## Features

- Parallel branch deletion using GNU parallel when available
- Automatic fallback to sequential processing
- Interactive branch selection with age info
- Bulk cleanup with pattern matching
- Remote branch cleanup support
- Stale branch detection

## Installation

1. Clone the repository:
```bash
git clone https://github.com/copyleftdev/bc.git
```

2. Make the script executable:
```bash
chmod +x bc
```

3. Optional: Add to your path
```bash
ln -s $(pwd)/bc ~/.local/bin/bc
```

## Usage

### Purge Branches by Pattern

Delete all merged branches matching a pattern:
```bash
bc purge "feat|fix"

# Include remote branches
bc purge "feat|fix" true
```

### Find Old Branches

List branches not updated in X days:
```bash
bc old 30

# With pattern matching
bc old 30 "feat|fix"
```

### Interactive Mode

Select branches to delete from a menu:
```bash
bc pick
```

## Performance

When GNU parallel is available, bc will:
- Use 50% of available CPU cores
- Process branch deletions in parallel
- Automatically handle both local and remote operations

## Dependencies

- Git
- Bash
- GNU parallel (optional, for parallel processing)


## Author

copyleftdev

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-feature`)
3. Commit your changes (`git commit -am 'Add feature'`)
4. Push to the branch (`git push origin my-feature`)
5. Create a Pull Request
