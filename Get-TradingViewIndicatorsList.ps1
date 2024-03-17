<#
.Synopsis
   Get TradingView.com indicators list
.DESCRIPTION
   Get most use TradingView.com indicators list, over 10000
.EXAMPLE
   Get-TradingViewIndicatorsList | Export-Csv -Path MostUseTradingViewIndicatorsList.csv -NoTypeInformation -Encoding utf8    
#>
function Get-TradingViewIndicatorsList
{
    [CmdletBinding()]
    $allLeters = 'a'..'z'
    $indicatorsList = @()

    foreach ($letter in $allLeters) {
        $tradingViewIndicatorsUrl = "https://www.tradingview.com/pubscripts-suggest-json/?search=$letter"
        $indicatorsList += Invoke-RestMethod -Uri $tradingViewIndicatorsUrl
    }

    # get all indicators with agreeCount > 10000, display only scriptName, agreeCount, and author
    $indicatorsList.results | Where-Object { $_.agreeCount -gt 10000} | 
        Select-Object -Property scriptName, agreeCount, @{Name='author'; Expression={$_.author.username}} -Unique | 
        Sort-Object -Property agreeCount -Descending
}