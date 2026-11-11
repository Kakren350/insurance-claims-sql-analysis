# Insurance Claims Analysis in SQL

**MySQL portfolio project | Actuarial & Insurance Analytics**

I first analysed this simulated insurance portfolio in Excel (see my [Excel dashboard project](https://github.com/Kakren350/Insurance-Claims-excel-dashboard)). Here I rebuilt the same analysis in MySQL to see whether SQL gives me the same answers, and to practise cleaning messy data.

## The data

- 500 policies and 250 claims (all simulated)
- Four policy types: Motor, Life, Health and Property, with 125 policies each
- Two tables, `policies` and `claims`, linked by `Policy_ID`

## Cleaning the data

The CSV files needed work before I could analyse them:

- The first column in both tables had a hidden character stuck to its name, so I renamed it.
- Premiums and claim amounts were stored as text like "KES 12,000". I removed the "KES" and commas and converted them to numbers.
- 83 claims had a dash in `Recognised_Incurred`. All of them were Rejected claims, so I treated the dash as zero. This is an assumption on my part.
- Every claim matched a policy, so there were no orphan Policy IDs.

## What I found

**Claims frequency:** about 0.5 for every policy type, which is roughly one claim for every two policies. Exactly 250 different policies made a claim, so no policy claimed twice.

**Claim severity:** the average incurred claim is about KES 22,400 for Life and Health, and KES 22,262 for Motor and Property. Rejected claims are spread evenly (about 21 per type), so they don't favour any one type.

**Loss ratio** (recognised claims divided by annual premium):

| Policy type | Premium (KES) | Recognised claims (KES) | Loss ratio |
|---|---|---|---|
| Motor | 2,107,000 | 923,496 | 43.8% |
| Life | 2,483,375 | 940,758 | 37.9% |
| Health | 2,854,125 | 940,758 | 33.0% |
| Property | 3,726,250 | 918,496 | 24.6% |

These match my Excel results (Motor 44%, Property 25%) after rounding.

**Paid vs outstanding:** of KES 3,723,508 in recognised claims, KES 1,875,762 has been paid. That leaves KES 1,847,746 outstanding, about half. Health has the most outstanding (KES 476,133) and Property the least (KES 445,240).

## What this tells me

Frequency and severity are almost the same across all four types, so the gap in loss ratios doesn't come from the claims. It comes from premiums. Motor has the lowest average premium (about KES 16,856 per policy) and Property the highest (about KES 29,810), so similar claims cost produce a much higher loss ratio for Motor.

## What I learned

- A green tick in Workbench doesn't mean the data changed. I now check with a `SELECT` after every `UPDATE`.
- Documenting assumptions, like treating dashes as zero, matters as much as the queries.
- Checking my SQL results against my Excel results showed me the cleaning had worked.

## Files

- `claims_analysis.sql`: all my queries, in order, with comments
- `policies.csv` and `claims.csv`: the raw data
- `screenshots/`: query results

## Tools

MySQL, MySQL Workbench

*All data is simulated for educational and portfolio purposes.*
