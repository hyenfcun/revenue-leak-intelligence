# Revenue Leak Taxonomy

## Objective

Define how this project classifies measurable revenue loss versus revenue-at-risk.

Core principle:

> Direct revenue leakage and revenue-at-risk are not the same thing.

Only measurable financial losses are included in the core direct leakage metric. Operational and customer behavior signals are analyzed separately to avoid overstating lost revenue.

---

## Data Grain

Primary analytical grain:

**1 row = 1 order item**

Source model:

`int_order_items_enriched`

---

## 1. Cancellation Leakage

Revenue associated with cancelled order items.

### Business Rationale

Cancelled items represent demand that existed but did not convert into realized revenue.

### Formula

```text
cancelled_revenue =
CASE
    WHEN item_status = 'Cancelled'
    THEN sale_price
    ELSE 0
END
```

### Classification

**Direct Leakage**

### Validation Note

The source schema does not contain a `cancelled_at` timestamp.

Cancellation is therefore identified using the canonical field:

```text
item_status = 'Cancelled'
```

The current dataset contains:

```text
27,034 Cancelled order items
```

---

## 2. Return Leakage

Revenue associated with returned order items.

### Business Rationale

Returns reverse previously realized sales and may also create additional fulfillment, processing, and inventory costs.

### Formula

```text
returned_revenue =
CASE
    WHEN item_status = 'Returned'
    THEN sale_price
    ELSE 0
END
```

### Classification

**Direct Leakage**

### Validation Note

Return status is fully consistent with lifecycle timestamps.

The current dataset contains:

```text
18,145 Returned order items
18,145 / 18,145 have returned_at IS NOT NULL
```

Therefore:

```text
item_status = 'Returned'
```

is used as the canonical return rule.

`returned_at` is retained for lifecycle validation rather than used as a second classification rule.

### Important Assumption

The initial model measures returned sales value.

Additional return-processing costs are excluded unless reliable cost data exists.

---

## 3. Margin Leakage

Financial loss generated when product cost exceeds selling price.

### Base Metrics

```text
gross_margin = sale_price - product_cost
```

```text
gross_margin_pct =
gross_margin / sale_price
```

### Negative Margin Flag

```text
is_negative_margin =
gross_margin < 0
```

### Leakage Formula

```text
margin_leakage =
CASE
    WHEN gross_margin < 0
    THEN ABS(gross_margin)
    ELSE 0
END
```

### Classification

**Direct Leakage**

### Important Assumption

WK3 initially counts only negative-margin losses.

Low-but-positive margins are treated as profitability risk rather than automatically classified as financial leakage.

---

## 4. Fulfillment Risk

Operational signals indicating elevated revenue risk.

Potential indicators include:

- long order-to-ship duration
- long ship-to-delivery duration
- abnormal lifecycle timestamps
- incomplete fulfillment lifecycle
- operational delay before cancellation or return

### Example Metrics

```text
fulfillment_days
shipping_days
```

### Classification

**Revenue-at-Risk**

### Important Rule

Fulfillment-risk revenue is not included in direct leakage unless a measurable financial loss can be demonstrated.

---

## 5. Customer Leakage Risk

Customer behavior suggesting future revenue loss or declining customer value.

Potential indicators include:

- high return rate
- high cancellation rate
- declining purchase frequency
- long periods without repeat purchase
- previously valuable customers becoming inactive

### Classification

**Revenue-at-Risk**

### Important Rule

Estimated future customer value loss is kept separate from realized direct leakage.

---

# Core Revenue Metrics

## Gross Revenue

```text
gross_revenue = sale_price
```

## Gross Margin

```text
gross_margin = sale_price - product_cost
```

## Component Leakage Metrics

```text
cancelled_revenue
returned_revenue
margin_leakage
```

## Revenue Leak Rate

```text
revenue_leak_rate =
direct_leak_amount / gross_revenue
```

---

# Double-Counting Policy

A single order item may exhibit more than one leakage signal.

For example:

- an item may be returned
- and also have negative margin

Therefore:

- leakage components are tracked separately
- overlap must be measured explicitly
- component values must not be blindly summed
- a reconciled leakage metric will be created in the mart layer

This prevents the project from overstating total financial leakage.

---

# Canonical Status Values

Validated values in the current staging dataset:

```text
Shipped
Complete
Processing
Cancelled
Returned
```

Validated order-item count:

```text
180,858 total order items
```

Status counts observed during WK3 validation:

```text
Shipped       54,774
Complete      44,760
Processing    36,145
Cancelled     27,034
Returned      18,145
```

---

# Analytical Dimensions

Revenue leakage will later be analyzed across:

- product
- category
- brand
- customer
- distribution center
- traffic source
- order month
- lifecycle status

These dimensions will support root-cause and Pareto analysis.

---

# WK3 Modeling Principle

The analytical architecture separates:

```text
Realized Financial Loss
        vs
Operational Risk
        vs
Customer Revenue Risk
```

This distinction prevents inflated leakage estimates and creates a defensible business metric layer.

