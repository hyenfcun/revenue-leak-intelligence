from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.ticker import FuncFormatter


PROJECT_ROOT = Path(__file__).resolve().parents[1]

SCENARIO_PATH = (
    PROJECT_ROOT / "reports" / "data" / "intervention_scenarios.csv"
)
PRIORITY_PATH = (
    PROJECT_ROOT / "reports" / "data" / "intervention_priority.csv"
)
OUTPUT_DIR = PROJECT_ROOT / "reports" / "charts"


def currency_k(x, _):
    return f"${x / 1000:,.0f}K"


def create_recovery_chart():
    df = pd.read_csv(SCENARIO_PATH)

    pivot = df.pivot(
        index="reduction_rate_pct",
        columns="primary_leak_type",
        values="estimated_recoverable_revenue",
    )

    ax = pivot.plot(
        kind="bar",
        figsize=(10, 6),
    )

    ax.set_title("Potential Revenue Recovery by Intervention Scenario")
    ax.set_xlabel("Simulated Leakage Reduction")
    ax.set_ylabel("Estimated Recoverable Revenue")
    ax.yaxis.set_major_formatter(FuncFormatter(currency_k))

    ax.set_xticklabels(
        [f"{int(x)}%" for x in pivot.index],
        rotation=0,
    )

    ax.legend(title="Leak Type")

    plt.tight_layout()

    output = OUTPUT_DIR / "intervention_recovery_scenarios.png"
    plt.savefig(output, dpi=180, bbox_inches="tight")
    plt.close()

    return output


def create_priority_matrix():
    df = pd.read_csv(PRIORITY_PATH)

    median_leakage = df["direct_leak_amount"].median()
    median_rate = df["revenue_leak_rate_pct"].median()

    fig, ax = plt.subplots(figsize=(11, 7))

    ax.scatter(
        df["direct_leak_amount"],
        df["revenue_leak_rate_pct"],
        s=70,
        alpha=0.75,
    )

    ax.axvline(
        median_leakage,
        linestyle="--",
        linewidth=1,
    )

    ax.axhline(
        median_rate,
        linestyle="--",
        linewidth=1,
    )

    tier1 = df[df["priority_tier"] == "Tier 1 - Act Now"]

    for _, row in tier1.iterrows():
        ax.annotate(
            row["product_category"],
            (
                row["direct_leak_amount"],
                row["revenue_leak_rate_pct"],
            ),
            xytext=(5, 5),
            textcoords="offset points",
            fontsize=8,
        )

    ax.set_title("Category Intervention Priority Matrix")
    ax.set_xlabel("Direct Revenue Leakage")
    ax.set_ylabel("Revenue Leak Rate (%)")
    ax.xaxis.set_major_formatter(FuncFormatter(currency_k))

    plt.tight_layout()

    output = OUTPUT_DIR / "intervention_priority_matrix.png"
    plt.savefig(output, dpi=180, bbox_inches="tight")
    plt.close()

    return output


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    recovery_chart = create_recovery_chart()
    priority_chart = create_priority_matrix()

    print("===== INTERVENTION CHARTS =====")
    print(
        f"Recovery chart: "
        f"{recovery_chart.relative_to(PROJECT_ROOT)}"
    )
    print(
        f"Priority matrix: "
        f"{priority_chart.relative_to(PROJECT_ROOT)}"
    )
    print("Charts generated: 2")
    print("STATUS: PASS")


if __name__ == "__main__":
    main()
