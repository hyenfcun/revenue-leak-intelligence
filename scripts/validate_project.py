from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]

checks = []


def check(name, condition):
    status = "PASS" if condition else "ERROR"
    checks.append((status, name))
    print(f"[{status}] {name}")


print("\n===== FINAL PROJECT VALIDATION =====\n")

# Core project files
check("README exists", (ROOT / "README.md").exists())
check("dbt project exists", (ROOT / "revenue_leak" / "dbt_project.yml").exists())

# Documentation
check("Week 6 summary exists", (ROOT / "docs" / "week6_summary.md").exists())

# Executive report
check(
    "Executive report exists",
    (ROOT / "reports" / "revenue_leak_executive_report.pptx").exists(),
)

# Intervention model
priority_file = ROOT / "reports" / "data" / "intervention_priority.csv"
check("Intervention priority dataset exists", priority_file.exists())

if priority_file.exists():
    df = pd.read_csv(priority_file)

    required_cols = {
        "product_category",
        "direct_leak_amount",
        "revenue_leak_rate_pct",
        "priority_tier",
        "potential_recovery_10pct",
    }

    check("Intervention dataset is not empty", len(df) > 0)
    check(
        "Intervention dataset required columns",
        required_cols.issubset(df.columns),
    )

# Charts
check(
    "Intervention priority matrix exists",
    (ROOT / "reports" / "charts" / "intervention_priority_matrix.png").exists(),
)

check(
    "Recovery scenario chart exists",
    (ROOT / "reports" / "charts" / "intervention_recovery_scenarios.png").exists(),
)

check(
    "Monthly leakage chart exists",
    (ROOT / "reports" / "charts" / "monthly_leakage_trend.png").exists(),
)

check(
    "Category leakage chart exists",
    (ROOT / "reports" / "charts" / "top10_category_leakage.png").exists(),
)

# Final summary
passes = sum(status == "PASS" for status, _ in checks)
errors = sum(status == "ERROR" for status, _ in checks)

print("\n===== VALIDATION SUMMARY =====")
print(f"PASS={passes} ERROR={errors} TOTAL={len(checks)}")

if errors:
    raise SystemExit(1)

print("\nSTATUS: PASS")
