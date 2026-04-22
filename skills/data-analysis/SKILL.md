---
name: data-analysis
description: Data analysis patterns for CSV, JSON, pandas, and reporting
---

# Data Analysis Patterns

## CSV Parsing (Python — pandas)

```python
import pandas as pd

# Read CSV
df = pd.read_csv("data.csv")

# Quick overview
print(df.shape)          # (rows, columns)
print(df.dtypes)         # Column types
print(df.describe())     # Statistics summary
print(df.head(10))       # First 10 rows
print(df.isnull().sum()) # Missing values per column

# Filter
active = df[df["status"] == "active"]
recent = df[df["date"] >= "2024-01-01"]

# Group and aggregate
summary = df.groupby("category").agg(
    count=("id", "count"),
    total=("amount", "sum"),
    avg=("amount", "mean"),
).reset_index()

# Sort
top_10 = df.nlargest(10, "revenue")
```

## CSV Parsing (Node.js)

```javascript
import { createReadStream } from 'fs';
import { parse } from 'csv-parse';

async function parseCSV(filepath) {
  const records = [];
  const parser = createReadStream(filepath).pipe(
    parse({ columns: true, skip_empty_lines: true })
  );
  for await (const record of parser) {
    records.push(record);
  }
  return records;
}
```

## JSON Data Manipulation

```python
import json

# Read JSON
with open("data.json") as f:
    data = json.load(f)

# Flatten nested JSON to tabular
df = pd.json_normalize(data, record_path="items", meta=["order_id", "date"])

# Write cleaned data
with open("output.json", "w") as f:
    json.dump(data, f, indent=2, default=str)
```

```javascript
// Node.js — JSON transformation
const data = JSON.parse(await fs.readFile('data.json', 'utf-8'));

// Group by key
const grouped = data.reduce((acc, item) => {
  (acc[item.category] ??= []).push(item);
  return acc;
}, {});

// Aggregate
const summary = Object.entries(grouped).map(([key, items]) => ({
  category: key,
  count: items.length,
  total: items.reduce((sum, i) => sum + i.amount, 0),
}));
```

## Data Validation

```python
# Quick checks before analysis
def validate_dataframe(df: pd.DataFrame, required_cols: list[str]) -> list[str]:
    issues = []

    # Check required columns exist
    missing = set(required_cols) - set(df.columns)
    if missing:
        issues.append(f"Missing columns: {missing}")

    # Check for empty dataframe
    if df.empty:
        issues.append("DataFrame is empty")

    # Check for duplicates
    dupes = df.duplicated().sum()
    if dupes > 0:
        issues.append(f"Found {dupes} duplicate rows")

    # Check for nulls in critical columns
    for col in required_cols:
        if col in df.columns:
            nulls = df[col].isnull().sum()
            if nulls > 0:
                issues.append(f"Column '{col}' has {nulls} null values")

    return issues
```

## Data Cleaning Patterns

```python
# Remove duplicates
df = df.drop_duplicates(subset=["email"], keep="last")

# Fill missing values
df["category"] = df["category"].fillna("Unknown")
df["amount"] = df["amount"].fillna(0)

# Type conversion
df["date"] = pd.to_datetime(df["date"], errors="coerce")
df["amount"] = pd.to_numeric(df["amount"], errors="coerce")

# Strip whitespace from string columns
str_cols = df.select_dtypes(include="object").columns
df[str_cols] = df[str_cols].apply(lambda x: x.str.strip())

# Rename columns (clean names)
df.columns = df.columns.str.lower().str.replace(" ", "_").str.replace("-", "_")
```

## Reporting Templates

### Summary Report (Markdown output)

```python
def generate_summary(df: pd.DataFrame, title: str) -> str:
    report = f"# {title}\n\n"
    report += f"**Total Records:** {len(df):,}\n"
    report += f"**Date Range:** {df['date'].min()} to {df['date'].max()}\n\n"

    report += "## By Category\n\n"
    report += "| Category | Count | Total | Average |\n"
    report += "|----------|-------|-------|---------|\n"

    summary = df.groupby("category").agg(
        count=("id", "count"),
        total=("amount", "sum"),
        avg=("amount", "mean"),
    )
    for cat, row in summary.iterrows():
        report += f"| {cat} | {row['count']:,} | ${row['total']:,.2f} | ${row['avg']:,.2f} |\n"

    return report
```

## Export Patterns

```python
# To CSV
df.to_csv("output.csv", index=False)

# To JSON
df.to_json("output.json", orient="records", indent=2)

# To Excel
df.to_excel("output.xlsx", index=False, sheet_name="Data")

# To Markdown table
print(df.to_markdown(index=False))

# To clipboard (for pasting)
df.to_clipboard(index=False)
```

## Quick Analysis Checklist

When asked to analyze data:
1. **Load** — Read the file, check shape and dtypes
2. **Inspect** — head(), describe(), isnull().sum()
3. **Clean** — Handle nulls, dupes, type conversion
4. **Validate** — Check required columns and data quality
5. **Analyze** — Group, aggregate, filter as needed
6. **Report** — Generate summary with key findings
7. **Export** — Save results in requested format
