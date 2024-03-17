# TradingView Indicators List

This PowerShell script retrieves the most used TradingView.com indicators list (that have over 10000 follower/linker).

## Usage

1. Clone this repository.
2. Open PowerShell.
3. . Source this file
4. Run the `Get-TradingViewIndicatorsList` function to get the filtered list of indicators.
5. Export the results to a CSV file using the following command:

```powershell
Get-TradingViewIndicatorsList | Export-Csv -Path MostUseTradingViewIndicatorsList.csv -NoTypeInformation -Encoding utf8