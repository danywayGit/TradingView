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
- Configurable via inputs: `scoreThresholdBuy` (default 5) and `scoreThresholdSell` (default 5)
- Signals suppressed for 5 bars after triggering to prevent spam (arbitrary value - adjust if signals too sparse/frequent)
- Additional filters: Pivot detection with configurable thresholds (`pivothighfilter`/`pivotlowfilter`)
- **Coin-specific tuning**: Each crypto has different volatility - no automated coin detection yet, requires manual parameter adjustment

### Webhook Integration
Alert messages use **JSON structure** for trading bot integration:
```json
{
  "key": "YOUR_SECRET_KEY_HERE",
  "type": "trading_bot",
  "msg": "Username: ALL,\\nExchange: Binance,\\nSymbol: {{ticker}},\\nSide: BUY,\\nEntry: {{close}},\\nScore: X,\\nStrategy: DCA_Spot,\\nAction: OpenLong"
}
```
- Two alert types: `alertcondition(buySignal)` and `alertcondition(sellSignal)`
- Uses TradingView placeholders: `{{ticker}}`, `{{close}}`
- Designed for external bot/service integration via webhook URLs

## Development Patterns

### PineScript Conventions
- Use `@version=6` (current standard)
- Keep `shorttitle` at **10 characters maximum**
- Group related inputs with `group` parameter
- Store state variables with `var` keyword for bar-to-bar persistence
- Calculate `emaDistance` as percentage: `(close - ema200) / ema200 * 100`
- Always validate signal conditions before label/plotshape rendering
- **Multi-line formatting**: No trailing spaces on first line; continuation lines start with 2 spaces

### Code Organization Pattern
```pine
// === Section Name ===
// Comments explain "why" not "what"
variable = calculation
```

### Critical Architecture: Temporal Scoring Windows
Points 3-5 (V-shape, acceleration, volume) use **conditional scoring based on temporal proximity**:
- Base conditions (points 1+2) must be met first
- V-shape: Awarded if base AND V-shape both occurred within **10 bars** of each other
- Acceleration/Volume: Awarded if base AND condition occurred within **5 bars**
- Uses `ta.barssince()` to track timing between conditions
- This prevents awarding points for unrelated market events

### PowerShell Script Implementation
- **Alphabet iteration**: Queries TradingView API with search params `a-z` to discover all indicators
- **Filter threshold**: `agreeCount > 10000` (high-quality indicators only)
- **Export format**: CSV with `scriptName`, `agreeCount`, `author`, `type`
- Run: `. .\Get-TradingViewIndicatorsList.ps1` then call function

## Testing & Validation

### PineScript Testing
1. Load indicator in TradingView chart editor
2. Test on **primary pairs**: BTC/USD, ETH/USD, BNB/USD, TRX/USD
3. Verify across timeframes: **1h, 4h, 12h, 1d** (optimized for 12h/1d)
4. Verify score calculations in labels match conditions
5. Validate signal spacing (min 5 bars apart)
6. Test parameter adjustments for each coin's volatility profile
7. Check webhook JSON format in alert creation dialog

### Backtesting Workflow
1. Use **Bar Replay** (TradingView) to simulate real-time signal generation on historical data
2. Verify signals appear at actual market bottoms (buy) and tops (sell) relative to 200 EMA
3. Check for **false positives**: Signals that don't lead to meaningful reversals
4. Adjust parameters if needed:
   - Increase `scoreThreshold` if too many signals
   - Widen `pivotlowfilter`/`pivothighfilter` for more selective entries
   - Increase suppression window (5 bars) in code if consecutive signals too close
5. **Paper trade** with alert webhooks before live deployment to validate bot integration

### Debugging Workflow
Enable debug plots at end of [dca_spot_strategy_indicator.pinescript](dca_spot_strategy_indicator.pinescript) by uncommenting:
- `barsSinceVShapeBuy/Sell`: Track V-shape pattern timing
- `barsSinceAccelerationBuy/Sell`: Track acceleration timing
- `barsSinceVolume`: Track volume spike timing  
- `score/sellScore`: View calculated scores in realtime

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
- **Future work**: Implement coin-specific parameter presets (currently requires manual tuning per asset)

Always maintain:
- Score threshold configurability via inputs
- Separate buy/sell score calculations
- Bar suppression logic to prevent signal spam
- Flexibility for 1h-1d timeframes

**Documentation rules**: No README updates, no inline comment bloat, no separate docs - keep repo lightweight
