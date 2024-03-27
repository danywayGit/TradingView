<#
.Synopsis
   Get TradingView.com indicators list
.DESCRIPTION
   Get most use TradingView.com indicators list, over 10000
.EXAMPLE
   Get-TradingViewIndicatorsList | Export-Csv -Path MostUseTradingViewIndicatorsList.csv -NoTypeInformation -Encoding utf8    
#>
function Get-TradingViewIndicatorsList {
    [CmdletBinding()]
    $allLeters = 'a'..'z'
    $indicatorsList = New-Object System.Collections.ArrayList

    foreach ($letter in $allLeters) {
        $tradingViewIndicatorsUrl = "https://www.tradingview.com/pubscripts-suggest-json/?search=$letter"
        $result = Invoke-RestMethod -Uri $tradingViewIndicatorsUrl
        $null = $indicatorsList.add($result.results)
    }

    # get all indicators with agreeCount > 10000, display only scriptName, agreeCount, and author
    $indicatorsList | ForEach-Object { $_ } |
      Where-Object { $_.agreeCount -gt 10000} |
      Select-Object -Property scriptName, agreeCount, @{Name='author'; Expression={$_.author.username}}, @{Name='type'; Expression={$_.extra.kind}} -Unique | 
      Sort-Object -Property agreeCount -Descending
}