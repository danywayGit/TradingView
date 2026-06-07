# TradingView Indicators List

---

## Pine Script Syntax Rules

### Multi-line expression continuation — 2-space indent

When a Pine Script expression spans multiple lines, every continuation line must be indented by **exactly 2 spaces**. Using 4 spaces, tabs, or aligning under the opening parenthesis causes a syntax error.

**Correct:**
```pine
allow_day = (dayofweek == dayofweek.monday and trade_mon) or
  (dayofweek == dayofweek.tuesday and trade_tue) or
  (dayofweek == dayofweek.wednesday and trade_wed)
```

**Wrong — 4-space indent (syntax error):**
```pine
allow_day = (dayofweek == dayofweek.monday and trade_mon) or
    (dayofweek == dayofweek.tuesday and trade_tue) or
    (dayofweek == dayofweek.wednesday and trade_wed)
```

**Wrong — aligned under paren (syntax error):**
```pine
allow_day = (dayofweek == dayofweek.monday and trade_mon) or
            (dayofweek == dayofweek.tuesday and trade_tue)
```

This applies to any multi-line boolean, arithmetic expression, function call, or assignment.

---

This PowerShell script retrieves the most used TradingView.com indicators list (that have over 10000 follower/linker).

## Usage

1. Clone this repository.
2. Open PowerShell.
3. . Source this file
4. Run the `Get-TradingViewIndicatorsList` function to get the filtered list of indicators.
5. Export the results to a CSV file using the following command:

```powershell
Get-TradingViewIndicatorsList | Export-Csv -Path MostUseTradingViewIndicatorsList.csv -NoTypeInformation -Encoding utf8