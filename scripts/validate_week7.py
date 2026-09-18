from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[1]

SCENARIO_PATH = PROJECT_ROOT / "reports" / "data" / "intervention_scenarios.csv"
PRIORITY_PATH = PROJECT_ROOT / "reports" / "data" / "intervention_priority.csv"

REQUIRED_FILES = [
    SCENARIO_PATH,
    PRIORITY_PATH,
    PROJECT_ROOT / "reports" / "data" / "intervention_scenarios.json",
    PROJECT_ROOT / "reports" / "charts" / "intervention_recovery_scenarios.png",
    PROJECT_ROOT / "reports" / "charts" / "intervention_priority_matrix.png",
    PROJECT_ROOT / "docs" / "week7_intervention_strategy.md",
]

PASS = 0
ERROR = 0


def check(condition, message):
    global PASS, ERROR

    if condition:
        print(f"[PASS] {message}")
        PASS += 1
    else:
        print(f"[ERROR] {message}")
        ERROR += 1


def main():
    print("===== WEEK 7 VALIDATION =====")

    for path in REQUIRED_FILES:
        check(
            path.exists(),
            f"File exists — {path.relative_to(PROJECT_ROOT)}",
        )

    scenarios = pd.read_csv(SCENARIO_PATH)
    priority = pd.read_csv(PRIORITY_PATH)

    check(
        len(scenarios) == 6,
        "Expected 6 intervention scenarios",
    )

    check(
        set(scenarios["primary_leak_type"]) == {"Cancellation", "Return"},
        "Expected leakage types present",
    )

    check(
        set(scenarios["reduction_rate_pct"]) == {5.0, 10.0, 20.0},
        "Expected reduction rates present",
    )

    check(
        (scenarios["estimated_recoverable_revenue"] >= 0).all(),
        "Recoverable revenue is non-negative",
    )

    check(
        (
            scenarios["estimated_recoverable_revenue"]
            <= scenarios["baseline_leakage"]
        ).all(),
        "Recoverable revenue does not exceed baseline leakage",
    )

    reconciliation = (
        scenarios["baseline_leakage"]
        - scenarios["estimated_recoverable_revenue"]
        - scenarios["remaining_leakage"]
    ).abs()

    check(
        (reconciliation <= 0.02).all(),
        "Baseline = recovery + remaining leakage",
    )

    expected_recovery = (
        scenarios["baseline_leakage"]
        * scenarios["reduction_rate_pct"]
        / 100
    )

    check(
        (
            expected_recovery
            - scenarios["estimated_recoverable_revenue"]
        ).abs().max()
        <= 0.02,
        "Recovery calculations match scenario rates",
    )

    ten_pct = scenarios[
        scenarios["reduction_rate_pct"] == 10
    ]["estimated_recoverable_revenue"].sum()

    check(
        abs(ten_pct - 264728.21) <= 0.02,
        "10% combined recovery reconciles to $264,728.21",
    )

    check(
        len(priority) == 26,
        "Expected 26 product categories",
    )

    tier1 = priority[
        priority["priority_tier"] == "Tier 1 - Act Now"
    ]

    check(
        len(tier1) == 6,
        "Expected 6 Tier 1 categories",
    )

    check(
        set(tier1["dominant_leak_type"]) == {"Cancellation"},
        "All Tier 1 categories are cancellation-dominant",
    )

    tier1_recovery = tier1["potential_recovery_10pct"].sum()

    check(
        abs(tier1_recovery - 103429.04) <= 0.02,
        "Tier 1 recovery reconciles to $103,429.04",
    )

    print()
    print(
        f"Done. PASS={PASS} ERROR={ERROR} TOTAL={PASS + ERROR}"
    )

    if ERROR > 0:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
