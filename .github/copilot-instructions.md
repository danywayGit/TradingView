# TradingView Indicators Development Guide

## Repository Philosophy
**Keep it minimal** - Avoid heavy documentation, inline comments, or separate doc files. Code should be self-explanatory with clear variable names and structure.

## Project Overview

This repository contains TradingView technical analysis tools:
- **PineScript indicator** (`dca_spot_strategy_indicator.pinescript`): Dollar-Cost Averaging (DCA) trading signal generator using scoring system
- **PowerShell tooling** (`Get-TradingViewIndicatorsList.ps1`): Web scraping utility to fetch popular indicators from TradingView.com

### Indicator Purpose
Designed for **volatile crypto markets** (BTC, ETH, BNB, TRX):
- **Primary use**: Find low entry points during big dips below 200 EMA
- **Exit strategy**: Sell partially on significant upward moves
- **Timeframes**: Optimized for 12h/1d, but should work on 1h/4h
- **Parameters**: Must remain adjustable for different coin behaviors

## PineScript Indicator Architecture

### Core Signal System
The DCA indicator generates BUY/SELL signals using a **weighted scoring system** (1-9 points) based on:

1. **Distance from 200 EMA** (3 pts max): Measures price deviation as percentage
   - Buy: Negative distance (price below EMA200) = `-8%` to `-18%+`
   - Sell: Positive distance (price above EMA200) = `+8%` to `+18%+`
   
2. **RSI Levels** (2 pts max): Momentum confirmation via 14-period RSI
   - Buy: RSI `35-45` (1pt), RSI `<35` (2pts)
   - Sell: RSI `55-65` (1pt), RSI `>65` (2pts)

3. **V-shape/^-shape Pattern** (2 pts): Detects price reversals using 20-bar lookback
   - Buy: Recovery from lowest quartile of distance range
   - Sell: Decline from highest quartile

4. **Price Acceleration** (1 pt): 2-bar distance change `>=3%`

5. **Volume Spike** (1 pt): Volume exceeds 1.5x of 20-bar SMA

### Signal Thresholds
- Configurable via inputs: `scoreThresholdBuy` (default 4) and `scoreThresholdSell` (default 5)
- Signals suppressed for 5 bars after triggering to prevent spam
- Additional filters: Pivot detection with configurable thresholds (`pivothighfiler`/`pivotlowfiler`)

### Webhook Integration
Alert messages follow pattern: `DCA_BUY|BTC|{close}|{emaDistance}|{score}|{myrsi}`
- Designed for automated trading system integration (external bot/service)

## Development Patterns

### PineScript Conventions
- Use `@version=6` (current standard)
- Group related inputs with `group` parameter
- Store state variables with `var` keyword for bar-to-bar persistence
- Calculate `emaDistance` as percentage: `(close - ema200) / ema200 * 100`
- Always validate signal conditions before label/plotshape rendering

### Code Organization Pattern
```pine
// === Section Name ===
// Comments explain "why" not "what"
variable = calculation
```

### PowerSh**primary pairs**: BTC/USD, ETH/USD, BNB/USD, TRX/USD
3. Verify across timeframes: **1h, 4h, 12h, 1d** (optimized for 12h/1d)
4. Check score calculations in labels match conditions
5. Validate signal spacing (min 5 bars apart)
6. Test parameter adjustments for each coin's volatility profile
7. Verify threshold: `agreeCount > 10000` (high-quality indicators only)
- Export format: CSV with `scriptName`, `agreeCount`, `author`, `type`

## Testing & Validation

### PineScript Testing
1. Load indicator in TradingView chart editor
2. Test on BTC/USD or ETH/USD with 1H/4H timeframe
3. Verify score calculations in labels match conditions
4. Validate signal spacing (min 5 bars apart)
5. Check webhook message format in alert creation dialog

### PowerShell Script
```powershell
# Source the script first
. .\Get-TradingViewIndicatorsList.ps1

# Run and export
Get-TradingViewIndicatorsList | Export-Csv -Path MostUseTradingViewIndicatorsList.csv -NoTypeInformation -Encoding utf8
```

## Key Files Reference

- **[dca_spot_strategy_indicator.pinescript](dca_spot_strategy_indicator.pinescript)**: Main DCA indicator with scoring logic
- **[Get-TradingViewIndicatorsList.ps1](Get-TradingViewIndicatorsList.ps1)**: Indicator discovery tool
- **[MostUseTradingViewIndicatorsList.csv](MostUseTradingViewIndicatorsList.csv)**: Generated dataset (98+ indicators with 10k+ followers)

## Modification Guidelines

When updating the indicator:
- **Scoring changes**: Adjust point allocations in `// === Scoring System ===` section
- **New conditions**: Add to appropriate scoring category (1-5) and update max points in comments
- **Multi-coin support**: Test parameter changes across BTC, ETH, BNB, TRX to ensure signals work for different volatility profiles

Always maintain:
- Score threshold configurability via inputs
- Separate buy/sell score calculations
- Bar suppression logic to prevent signal spam
- Flexibility for 1h-1d timeframes

**Documentation rules**: No README updates, no inline comment bloat, no separate docs - keep repo lightweight
- Separate buy/sell score calculations
- Bar suppression logic to prevent signal spam
