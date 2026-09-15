---
name: foxybalance-cli
description: Use the FoxyBalance CLI (fb) to manage balances, transactions, bills, and transaction-bill matching. Use when the user wants to view balance summaries, list/create/update/delete transactions, manage recurring bills, or match transactions to bills.
---

# FoxyBalance CLI

The FoxyBalance CLI (`fb`) is a command-line interface for the FoxyBalance API. Assume the CLI is always in PATH and the user is already authenticated.

## Quick Reference

```
# View help
fb --help
fb <command> --help

# Balance
fb balance view [--json]
fb balance at-date --date yyyy-MM-dd [--include-pending] [--json]
fb balance before-transaction <id-or-link> [--use-clear-date] [--json]
fb balance after-transaction <id-or-link> [--use-clear-date] [--json]

# Transactions
fb transactions list [--page N] [--status pending|cleared|all] [--json]
fb transactions view <id-or-link> [--json]
fb transactions create --name "..." --amount "..." --date yyyy-MM-dd [--type debit|credit|check] [--check-number N] [--clear-date yyyy-MM-dd] [--json]
fb transactions update <id-or-link> [--name "..."] [--amount "..."] [--date yyyy-MM-dd] [--type debit|credit|check] [--check-number N] [--clear-date yyyy-MM-dd] [--json]
fb transactions delete <id-or-link> [--force/-f]
fb transactions import --file <path.csv> [--format capital-one] [--json]

# Bills
fb bills list [--active] [--json]
fb bills view <id-or-link> [--json]
fb bills create --name "..." --amount "..." --week-of-month N --day-of-week N [--json]
fb bills update <id-or-link> [--name "..."] [--amount "..."] [--week-of-month N] [--day-of-week N] [--json]
fb bills delete <id-or-link> [--force/-f]
fb bills toggle <id-or-link> [--json]

# Matching
fb match suggestions [--json]
fb match execute --transaction-id <tx-id-or-link> --bill-id <bill-id-or-link> [--json]

## Command Details

### HATEOAS Links

All API responses include HATEOAS (HAL+JSON) links. The CLI surfaces these in two ways:

1. **Human-readable output**: List views show a "Link" column with the self link href for each item. Detail views show a "Links:" section listing all available actions (rel, method, href).
2. **JSON output (`--json`)**: The full HAL resource is output, including `data` (the resource fields), `links` (a map of relation names to link objects with `href`, `method`, and `templated` fields), and `embedded` (if present). Collections output the full `HalCollection` structure with `items` (each a full HAL resource), `page`, `totalPages`, `totalCount`, and `links`.

Commands that accept `<id-or-link>` arguments can take either:
- A numeric ID (e.g., `12345`)
- A HATEOAS link href from a previous response (e.g., `/api/v1/transactions/12345`)

This enables chaining commands: list to get links, then pass the link to view/update/delete.

### Balance

**`fb balance view`** - View balance summary
- `--json`: Output as JSON (includes HATEOAS links)

**`fb balance at-date`** - View balance as of a specific date
- `--date yyyy-MM-dd` (required): Date to calculate balance as of (exclusive of that date)
- `--include-pending`: Include pending transactions (default: false)
- `--json`: Output as JSON (includes HATEOAS links)

**`fb balance before-transaction <id-or-link>`** - View balance before a specific transaction
- `<id-or-link>`: Transaction ID or HATEOAS link href (required)
- `--use-clear-date`: Use clear date instead of creation date (default: false)
- `--json`: Output as JSON (includes HATEOAS links)

**`fb balance after-transaction <id-or-link>`** - View balance after a specific transaction
- `<id-or-link>`: Transaction ID or HATEOAS link href (required)
- `--use-clear-date`: Use clear date instead of creation date (default: false)
- `--json`: Output as JSON (includes HATEOAS links)

### Transactions

**`fb transactions list`** - List transactions with pagination and filtering
- `--page N`: Page number (default: 1)
- `--status pending|cleared|all`: Filter by status (default: all)
- `--json`: Output as JSON (includes HATEOAS links)

Output includes a "Link" column showing the self link href for each transaction.

**`fb transactions view <id-or-link>`** - View a single transaction
- `<id-or-link>`: Transaction ID or HATEOAS link href (required)
- `--json`: Output as JSON (includes HATEOAS links)

**`fb transactions create`** - Create a new transaction
- `--name`: Transaction name/description (prompts if not provided)
- `--amount`: Transaction amount (e.g., "50.00") (prompts if not provided)
- `--date yyyy-MM-dd`: Transaction date (prompts if not provided)
- `--type debit|credit|check`: Transaction type (default: debit)
- `--check-number`: Check number (required if type is check)
- `--clear-date yyyy-MM-dd`: Clear date
- `--json`: Output as JSON (includes HATEOAS links)

**`fb transactions update <id-or-link>`** - Update an existing transaction
- `<id-or-link>`: Transaction ID or HATEOAS link href (required)
- `--name`: Transaction name
- `--amount`: Transaction amount
- `--date yyyy-MM-dd`: Transaction date
- `--type debit|credit|check`: Transaction type
- `--check-number`: Check number
- `--clear-date yyyy-MM-dd`: Clear date
- `--json`: Output as JSON (includes HATEOAS links)

**`fb transactions delete <id-or-link>`** - Delete a transaction
- `<id-or-link>`: Transaction ID or HATEOAS link href (required)
- `--force` / `-f`: Skip confirmation prompt

**`fb transactions import`** - Import transactions from a CSV file
- `--file <path.csv>`: Path to CSV file (required)
- `--format capital-one`: Import format (default: capital-one)
- `--json`: Output as JSON (includes HATEOAS links)

### Bills

**`fb bills list`** - List recurring bills
- `--active`: Show only active bills
- `--json`: Output as JSON (includes HATEOAS links)

Output includes a "Link" column showing the self link href for each bill.

**`fb bills view <id-or-link>`** - View a single recurring bill
- `<id-or-link>`: Bill ID or HATEOAS link href (required)
- `--json`: Output as JSON (includes HATEOAS links)

**`fb bills create`** - Create a new recurring bill
- `--name`: Bill name (prompts if not provided)
- `--amount`: Bill amount (e.g., "50.00") (prompts if not provided)
- `--week-of-month 1-4`: Week of month (prompts if not provided)
- `--day-of-week 0-6`: Day of week (0=Sunday through 6=Saturday) (prompts if not provided)
- `--json`: Output as JSON (includes HATEOAS links)

**`fb bills update <id-or-link>`** - Update an existing recurring bill
- `<id-or-link>`: Bill ID or HATEOAS link href (required)
- `--name`: Bill name
- `--amount`: Bill amount
- `--week-of-month 1-4`: Week of month
- `--day-of-week 0-6`: Day of week
- `--json`: Output as JSON (includes HATEOAS links)

**`fb bills delete <id-or-link>`** - Delete a recurring bill
- `<id-or-link>`: Bill ID or HATEOAS link href (required)
- `--force` / `-f`: Skip confirmation prompt

**`fb bills toggle <id-or-link>`** - Toggle a bill's active status
- `<id-or-link>`: Bill ID or HATEOAS link href (required)
- `--json`: Output as JSON (includes HATEOAS links)

### Matching

**`fb match suggestions`** - List transaction-bill match suggestions
- `--json`: Output as JSON (includes HATEOAS links)

Output includes a "Match Link" column showing the execute-match link href for each suggestion.

**`fb match execute`** - Match a transaction to a recurring bill
- `--transaction-id <tx-id-or-link>`: Transaction ID or HATEOAS link href (required, must resolve to positive ID)
- `--bill-id <bill-id-or-link>`: Bill ID or HATEOAS link href (required, must resolve to positive ID)
- `--json`: Output as JSON (includes HATEOAS links)

## Usage Patterns

### View current balance
```bash
fb balance view
```

### View balance as of a specific date
```bash
fb balance at-date --date 2025-01-01
```

### View balance as of date including pending transactions
```bash
fb balance at-date --date 2025-01-01 --include-pending
```

### View balance before transaction #1234 was created
```bash
fb balance before-transaction 1234
```

### View balance before transaction #1234 was cleared
```bash
fb balance before-transaction 1234 --use-clear-date
```

### View balance after transaction using HATEOAS link
```bash
fb balance after-transaction /api/v1/transactions/1234
```

### List all transactions
```bash
fb transactions list
```

### List pending transactions on page 2
```bash
fb transactions list --status pending --page 2
```

### View a specific transaction
```bash
fb transactions view 12345
```

### Create a new transaction
```bash
fb transactions create --name "Groceries" --amount "125.50" --date 2026-09-05 --type debit
```

### Update a transaction
```bash
fb transactions update 12345 --name "Grocery Store" --amount "127.50"
```

### Delete a transaction (with confirmation)
```bash
fb transactions delete 12345
```

### Delete a transaction (skip confirmation)
```bash
fb transactions delete 12345 --force
```

### Import transactions from CSV
```bash
fb transactions import --file /path/to/transactions.csv --format capital-one
```

### List all recurring bills
```bash
fb bills list
```

### List only active bills
```bash
fb bills list --active
```

### View a specific bill
```bash
fb bills view 42
```

### Create a new recurring bill
```bash
fb bills create --name "Rent" --amount "1500.00" --week-of-month 1 --day-of-week 0
```

### Update a bill
```bash
fb bills update 42 --name "Monthly Rent" --amount "1600.00"
```

### Toggle bill active status
```bash
fb bills toggle 42
```

### Delete a bill
```bash
fb bills delete 42 --force
```

### Get match suggestions
```bash
fb match suggestions
```

### Execute a match
```bash
fb match execute --transaction-id 12345 --bill-id 42
```

### View a transaction using a HATEOAS link
```bash
# First, list transactions to get links
fb transactions list
# Then view using the link from the "Link" column
fb transactions view /api/v1/transactions/12345
```

### Update a transaction using a HATEOAS link
```bash
fb transactions update /api/v1/transactions/12345 --name "Updated Name"
```

### Delete a transaction using a HATEOAS link
```bash
fb transactions delete /api/v1/transactions/12345 --force
```

### Toggle a bill using a HATEOAS link
```bash
fb bills toggle /api/v1/bills/42
```

### Execute a match using HATEOAS links
```bash
# Links from match suggestions output can be passed directly
fb match execute --transaction-id /api/v1/transactions/12345 --bill-id /api/v1/bills/42
```

### Get JSON output with HATEOAS links
```bash
fb transactions list --json
fb balance view --json
```

## Notes

- The CLI uses `fb` as the command alias
- All commands assume the user is already authenticated
- JSON output is available via `--json` flag and includes full HATEOAS links (HAL+JSON format with `data`, `links`, and `embedded` fields)
- Human-readable output includes HATEOAS links: list views show a "Link" column, detail views show a "Links:" section
- Commands accepting `<id-or-link>` arguments accept both numeric IDs and HATEOAS link hrefs from API responses
- `--transaction-id` and `--bill-id` on `match execute` accept both numeric IDs and HATEOAS link hrefs (IDs are extracted from link hrefs automatically)
- Confirmation prompts are used for destructive operations unless `--force` is specified
- Date format is `yyyy-MM-dd`
- Day of week: 0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday
- Week of month: 1-4
- Transaction types: debit, credit, check