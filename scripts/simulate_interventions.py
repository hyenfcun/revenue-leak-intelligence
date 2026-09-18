from pathlib import Path
import json
import subprocess

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SQL_PATH = (
    PROJECT_ROOT
    / "revenue_leak"
    / "target"
    / "compiled"
    / "revenue_leak"
    / "analyses"
    / "08_intervention_scenarios.sql"
)
OUTPUT_DIR = PROJECT_ROOT / "reports" / "data"

CSV_OUTPUT = OUTPUT_DIR / "intervention_scenarios.csv"
JSON_OUTPUT = OUTPUT_DIR / "intervention_scenarios.json"


def run_bigquery(sql: str) -> list[dict]:
    command = [
        "bq",
        "query",
        "--use_legacy_sql=false",
        "--format=json",
        sql,
    ]

    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
        check=True,
    )

    return json.loads(result.stdout)


def main() -> None:
    if not SQL_PATH.exists():
        raise FileNotFoundError(
            f"Compiled SQL not found: {SQL_PATH}\n"
            "Run: cd revenue_leak && "
            "dbt compile --select 08_intervention_scenarios"
        )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    sql = SQL_PATH.read_text()
    rows = run_bigquery(sql)

    df = pd.DataFrame(rows)

    numeric_columns = [
        "baseline_leakage",
        "reduction_rate_pct",
        "estimated_recoverable_revenue",
        "remaining_leakage",
    ]

    for column in numeric_columns:
        df[column] = pd.to_numeric(df[column])

    df = df.sort_values(
        ["primary_leak_type", "reduction_rate_pct"]
    ).reset_index(drop=True)

    df.to_csv(CSV_OUTPUT, index=False)

    JSON_OUTPUT.write_text(
        json.dumps(
            df.to_dict(orient="records"),
            indent=2,
        )
    )

    print("===== INTERVENTION SIMULATOR =====")
    print(f"Scenarios generated: {len(df)}")
    print(
        "Baseline leakage: "
        f"${df.groupby('primary_leak_type')['baseline_leakage'].first().sum():,.2f}"
    )

    ten_pct = df[df["reduction_rate_pct"] == 10]

    print(
        "10% combined potential recovery: "
        f"${ten_pct['estimated_recoverable_revenue'].sum():,.2f}"
    )

    print(f"CSV:  {CSV_OUTPUT.relative_to(PROJECT_ROOT)}")
    print(f"JSON: {JSON_OUTPUT.relative_to(PROJECT_ROOT)}")
    print("STATUS: PASS")


if __name__ == "__main__":
    main()
