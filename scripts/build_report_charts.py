import json
from pathlib import Path

import pandas as pd
import matplotlib.pyplot as plt


PROJECT_ROOT = Path(__file__).resolve().parents[1]

INPUT_FILE = PROJECT_ROOT / "reports" / "data" / "category_leakage.json"
OUTPUT_FILE = PROJECT_ROOT / "reports" / "charts" / "top10_category_leakage.png"


with open(INPUT_FILE, "r") as f:
    raw = json.load(f)

df = pd.DataFrame(raw["show"])

top10 = (
    df[["product_category", "direct_leak_amount"]]
    .sort_values("direct_leak_amount", ascending=False)
    .head(10)
    .sort_values("direct_leak_amount")
)

fig, ax = plt.subplots(figsize=(10, 6))

ax.barh(
    top10["product_category"],
    top10["direct_leak_amount"] / 1000,
)

ax.set_title(
    "Top 10 Product Categories by Direct Revenue Leakage",
    fontsize=15,
    fontweight="bold",
)

ax.set_xlabel("Direct Revenue Leakage ($K)")
ax.set_ylabel("")

for i, value in enumerate(top10["direct_leak_amount"] / 1000):
    ax.text(
        value + 3,
        i,
        f"${value:.0f}K",
        va="center",
        fontsize=9,
    )

ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)

plt.tight_layout()

OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)

plt.savefig(
    OUTPUT_FILE,
    dpi=200,
    bbox_inches="tight",
)

plt.close()

print(f"Saved chart: {OUTPUT_FILE}")




# ============================================================
# Chart 2: Cancellation vs Return Leakage
# ============================================================

top10_causes = (
    df[
        [
            "product_category",
            "cancellation_leakage",
            "return_leakage",
        ]
    ]
    .assign(
        total=lambda x: x["cancellation_leakage"] + x["return_leakage"]
    )
    .sort_values("total", ascending=False)
    .head(10)
    .sort_values("total")
)

fig, ax = plt.subplots(figsize=(10, 6))

cancel_values = top10_causes["cancellation_leakage"] / 1000
return_values = top10_causes["return_leakage"] / 1000

ax.barh(
    top10_causes["product_category"],
    cancel_values,
    label="Cancellation",
)

ax.barh(
    top10_causes["product_category"],
    return_values,
    left=cancel_values,
    label="Return",
)

ax.set_title(
    "Cancellation Drives Most Leakage Across Top Categories",
    fontsize=15,
    fontweight="bold",
)

ax.set_xlabel("Direct Revenue Leakage ($K)")
ax.set_ylabel("")

ax.legend(frameon=False)

ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)

plt.tight_layout()

CAUSE_OUTPUT_FILE = (
    PROJECT_ROOT
    / "reports"
    / "charts"
    / "top10_leakage_causes.png"
)

plt.savefig(
    CAUSE_OUTPUT_FILE,
    dpi=200,
    bbox_inches="tight",
)

plt.close()

print(f"Saved chart: {CAUSE_OUTPUT_FILE}")







# ============================================================
# Chart 3: Distribution Center Leakage
# ============================================================

DC_INPUT_FILE = (
    PROJECT_ROOT
    / "reports"
    / "data"
    / "distribution_center_leakage.json"
)

with open(DC_INPUT_FILE, "r") as f:
    dc_raw = json.load(f)

dc_df = pd.DataFrame(dc_raw["show"])

top10_dc = (
    dc_df[
        [
            "distribution_center_name",
            "direct_leak_amount",
            "total_leak_share_pct",
        ]
    ]
    .sort_values("direct_leak_amount", ascending=False)
    .head(10)
    .sort_values("direct_leak_amount")
)

top5_share = (
    dc_df
    .sort_values("direct_leak_amount", ascending=False)
    .head(5)["total_leak_share_pct"]
    .sum()
)

fig, ax = plt.subplots(figsize=(10, 6))

values = top10_dc["direct_leak_amount"] / 1000

ax.barh(
    top10_dc["distribution_center_name"],
    values,
)

ax.set_title(
    f"Top 5 Distribution Centers Account for {top5_share:.1f}% of Leakage",
    fontsize=15,
    fontweight="bold",
)

ax.set_xlabel("Direct Revenue Leakage ($K)")
ax.set_ylabel("")

for i, value in enumerate(values):
    ax.text(
        value + 4,
        i,
        f"${value:.0f}K",
        va="center",
        fontsize=9,
    )

ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)

plt.tight_layout()

DC_OUTPUT_FILE = (
    PROJECT_ROOT
    / "reports"
    / "charts"
    / "distribution_center_leakage.png"
)

plt.savefig(
    DC_OUTPUT_FILE,
    dpi=200,
    bbox_inches="tight",
)

plt.close()

print(f"Saved chart: {DC_OUTPUT_FILE}")
print(f"Top 5 DC leakage share: {top5_share:.2f}%")






# ============================================================
# Chart 4: Monthly Leakage Trend
# ============================================================

MONTHLY_INPUT_FILE = (
    PROJECT_ROOT
    / "reports"
    / "data"
    / "monthly_leak_trend.json"
)

with open(MONTHLY_INPUT_FILE, "r") as f:
    monthly_raw = json.load(f)

monthly_df = pd.DataFrame(monthly_raw["show"])

monthly_df["order_month"] = pd.to_datetime(monthly_df["order_month"])

# Focus on recent period for executive readability
recent = monthly_df[
    monthly_df["order_month"] >= "2024-01-01"
].copy()

recent["direct_leak_k"] = recent["direct_leak_amount"] / 1000

fig, ax = plt.subplots(figsize=(11, 6))

ax.plot(
    recent["order_month"],
    recent["direct_leak_k"],
    linewidth=2,
)

ax.set_title(
    "Revenue Leakage Rises as Business Volume Scales",
    fontsize=15,
    fontweight="bold",
)

ax.set_xlabel("")
ax.set_ylabel("Direct Revenue Leakage ($K)")

ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)

plt.tight_layout()

MONTHLY_OUTPUT_FILE = (
    PROJECT_ROOT
    / "reports"
    / "charts"
    / "monthly_leakage_trend.png"
)

plt.savefig(
    MONTHLY_OUTPUT_FILE,
    dpi=200,
    bbox_inches="tight",
)

plt.close()

print(f"Saved chart: {MONTHLY_OUTPUT_FILE}")


