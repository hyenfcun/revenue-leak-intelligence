from pathlib import Path
import json

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[1]

INPUT_PATH = PROJECT_ROOT / "reports" / "data" / "category_leakage.json"
OUTPUT_PATH = PROJECT_ROOT / "reports" / "data" / "intervention_priority.csv"


def main() -> None:
    with INPUT_PATH.open() as f:
        raw = json.load(f)

    df = pd.DataFrame(raw["show"])

    median_leakage = df["direct_leak_amount"].median()
    median_leak_rate = df["revenue_leak_rate_pct"].median()

    df["potential_recovery_10pct"] = (
        df["direct_leak_amount"] * 0.10
    ).round(2)

    df["dominant_leak_type"] = df.apply(
        lambda row: (
            "Cancellation"
            if row["cancellation_leakage"] >= row["return_leakage"]
            else "Return"
        ),
        axis=1,
    )

    df["high_leakage"] = df["direct_leak_amount"] >= median_leakage
    df["high_leak_rate"] = (
        df["revenue_leak_rate_pct"] >= median_leak_rate
    )

    def classify_priority(row):
        if row["high_leakage"] and row["high_leak_rate"]:
            return "Tier 1 - Act Now"
        if row["high_leakage"]:
            return "Tier 2 - Scale Fix"
        if row["high_leak_rate"]:
            return "Tier 3 - Investigate"
        return "Tier 4 - Monitor"

    df["priority_tier"] = df.apply(classify_priority, axis=1)

    priority_order = {
        "Tier 1 - Act Now": 1,
        "Tier 2 - Scale Fix": 2,
        "Tier 3 - Investigate": 3,
        "Tier 4 - Monitor": 4,
    }

    df["priority_order"] = df["priority_tier"].map(priority_order)

    output_columns = [
        "product_category",
        "direct_leak_amount",
        "leak_share_pct",
        "revenue_leak_rate_pct",
        "cancellation_leakage",
        "return_leakage",
        "dominant_leak_type",
        "potential_recovery_10pct",
        "priority_tier",
    ]

    output = (
        df.sort_values(
            ["priority_order", "direct_leak_amount"],
            ascending=[True, False],
        )[output_columns]
        .reset_index(drop=True)
    )

    output.to_csv(OUTPUT_PATH, index=False)

    tier1 = output[
        output["priority_tier"] == "Tier 1 - Act Now"
    ]

    print("===== INTERVENTION PRIORITY MODEL =====")
    print(f"Categories evaluated: {len(output)}")
    print(f"Median category leakage: ${median_leakage:,.2f}")
    print(f"Median revenue leak rate: {median_leak_rate:.2f}%")
    print(f"Tier 1 categories: {len(tier1)}")
    print(
        "Tier 1 leakage opportunity: "
        f"${tier1['direct_leak_amount'].sum():,.2f}"
    )
    print(
        "Tier 1 potential recovery @10%: "
        f"${tier1['potential_recovery_10pct'].sum():,.2f}"
    )
    print(f"Output: {OUTPUT_PATH.relative_to(PROJECT_ROOT)}")
    print("STATUS: PASS")


if __name__ == "__main__":
    main()
