import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

DATA_DIR = Path(".")
tickers = ["GLD", "GOOG", "QQQ", "VOO"]  # explicit = no accidental extra csvs

for t in ["GLD","GOOG","QQQ","VOO"]:
    df = pd.read_csv(f"{t}.csv")
    print(t, df["Open"].head(3).tolist())


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
axes = axes.flatten()

for ax, ticker in zip(axes, tickers):
    csv_path = DATA_DIR / f"{ticker}.csv"
    df = pd.read_csv(csv_path)

    # parse & sort by date properly
    df["Date"] = pd.to_datetime(df["Date"])
    df = df.sort_values("Date").reset_index(drop=True)

    # returns: (p_t / p_{t-1}) - 1
    prices = pd.to_numeric(df["Open"], errors="coerce")
    returns = prices.pct_change()

    # x-axis as 0..n-1
    x = range(len(returns))

    ax.plot(x, returns)                 # <-- IMPORTANT: ax.plot, not plt.plot
    ax.axhline(0, linestyle="--", linewidth=0.8)
    ax.set_title(f"{ticker} Returns")
    ax.set_xlabel("Time index")
    ax.set_ylabel("Return")

plt.tight_layout()
plt.show()
