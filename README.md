# README


## Recording Data

Save contract data in a single CSV file within the project directory.
The file “[my_records.csv](my_records.csv)” is included as an example:

``` r
source("invoice_functions.R")
read_csv("my_records.csv")
```

| date | action | course | group | contract | date_end |
|:---|:---|:---|:---|---:|:---|
| 2025-04-01 | mentored | Dogpaddling Foundations | Company 1 | 3640 | 2025-06-27 |
| 2025-04-02 | mentored | Advanced Sugargliding | Second Co. Ltd. | 2184 | 2025-05-16 |
| 2025-04-07 | missed | Dogpaddling Foundations | Company 1 | NA | NA |
| 2025-04-06 | covered | Expressive Bowling | Froggy Croakers | NA | NA |
| 2025-05-06 | covered | Expressive Bowling | Froggy Croakers | NA | NA |
| 2025-06-07 | missed | Dogpaddling Foundations | Company 1 | NA | NA |

Each contract, each missed day, and each covered day should be listed on
its own row. The `action` column should include a single word for each
row: “mentored” or “covered” or “missed”. Include the contract price and
`date_end` for mentoring. Do not include price or `date_end` for days
covered or missed. The `date` column refers to the **kick-off date**
when mentoring *or* to the date missed or covered.

## Adding details

Use `expand_invoices()` to aid with invoicing at the final Friday of
each period—either biweekly or monthly. In each contract, the final
`invoice_due` value is adjusted to accommodate rounding errors and
satisfy the contract price. `expand_invoices()` produces a data frame in
the following format:

``` r
read_csv("my_records.csv") |> 
  expand_invoices(period = "biweekly")
```

| date | action | course | group | contract | contract_end | invoice | invoices | invoice_due | week_start | week_end | period_start | period_end |
|:---|:---|:---|:---|---:|:---|:---|---:|---:|---:|---:|:---|:---|
| 2025-04-01 | mentored | Dogpaddling Foundations | Company 1 | 3640 | 2025-06-27 | 2025-04-18 | 6 | 606.67 | 0 | 2 | 2025-04-01 | 2025-04-18 |
| 2025-04-01 | mentored | Dogpaddling Foundations | Company 1 | 3640 | 2025-06-27 | 2025-05-02 | 6 | 606.67 | 3 | 4 | 2025-04-19 | 2025-05-02 |
| 2025-04-01 | mentored | Dogpaddling Foundations | Company 1 | 3640 | 2025-06-27 | 2025-05-16 | 6 | 606.67 | 5 | 6 | 2025-05-03 | 2025-05-16 |
| 2025-04-01 | mentored | Dogpaddling Foundations | Company 1 | 3640 | 2025-06-27 | 2025-05-30 | 6 | 606.67 | 7 | 8 | 2025-05-17 | 2025-05-30 |
| 2025-04-01 | mentored | Dogpaddling Foundations | Company 1 | 3640 | 2025-06-27 | 2025-06-13 | 6 | 606.67 | 9 | 10 | 2025-05-31 | 2025-06-13 |
| 2025-04-01 | mentored | Dogpaddling Foundations | Company 1 | 3640 | 2025-06-27 | 2025-06-27 | 6 | 606.65 | 11 | 12 | 2025-06-14 | 2025-06-27 |
| 2025-04-02 | mentored | Advanced Sugargliding | Second Co. Ltd. | 2184 | 2025-05-16 | 2025-04-18 | 3 | 728.00 | 0 | 2 | 2025-04-02 | 2025-04-18 |
| 2025-04-02 | mentored | Advanced Sugargliding | Second Co. Ltd. | 2184 | 2025-05-16 | 2025-05-02 | 3 | 728.00 | 3 | 4 | 2025-04-19 | 2025-05-02 |
| 2025-04-02 | mentored | Advanced Sugargliding | Second Co. Ltd. | 2184 | 2025-05-16 | 2025-05-16 | 3 | 728.00 | 5 | 6 | 2025-05-03 | 2025-05-16 |
| 2025-04-06 | covered | Expressive Bowling | Froggy Croakers | 133 | NA | 2025-04-18 | 1 | 133.00 | 0 | 0 | 2025-04-06 | 2025-04-06 |
| 2025-04-07 | missed | Dogpaddling Foundations | Company 1 | -122 | NA | 2025-04-18 | 1 | -122.00 | 0 | 0 | 2025-04-07 | 2025-04-07 |
| 2025-05-06 | covered | Expressive Bowling | Froggy Croakers | 133 | NA | 2025-05-16 | 1 | 133.00 | 0 | 0 | 2025-05-06 | 2025-05-06 |
| 2025-06-07 | missed | Dogpaddling Foundations | Company 1 | -122 | NA | 2025-06-13 | 1 | -122.00 | 0 | 0 | 2025-06-07 | 2025-06-07 |

A data frame in this format can then be passed along to `set_table()`
for formatting with gt.

## Formatting the table

Use `set_table()` to prepare a formatted table for invoicing a given
period of work.

``` r
read_csv("my_records.csv") |> 
  expand_invoices(period = "biweekly") |> 
  set_table(invoice_period = "2025-04-18")
```

<div id="xllcneoyay" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
  &#10;  

|  | DATES | PRICE | QTY | DUE |
|:---|:---|---:|:--:|---:|
| mentored *Dogpaddling Foundations* with **Company 1** weeks 0–2 | Apr 1–18 | \$3,640 | 1/6 | \$606.67 |
| mentored *Advanced Sugargliding* with **Second Co. Ltd.** weeks 0–2 | Apr 2–18 | \$2,184 | 1/3 | \$728.00 |
| covered *Expressive Bowling* with **Froggy Croakers** | Apr 6 | \$133 | 1 | \$133.00 |
| missed *Dogpaddling Foundations* with **Company 1** | Apr 7 | −\$122 | 1 | (\$122.00) |
| TOTAL |   |   |   | \$1,345.67 |

</div>

## Rendering Invoices as PDF

Invoices can be created either by modifying the Quarto file directly or
by using a dedicated function.

### Render the Quarto file in the IDE

Use [`hybrid_invoice.qmd`](hybrid_invoice.qmd) as a template. After
setting the document’s `date` in the metadata and `periods`,
`period_date`, and `file` parameters in the YAML, use the “Render”
button in RStudio or Positron to create a PDF:

- [📄 hybrid_invoice.pdf](hybrid_invoice.pdf)

### Render using a function

The `render_invoice()` function can be used to set details for an
invoice and create a PDF without needing to touch a file.

#### For the most recent period

By default, an invoice will be prepared for the period ending on or
before today, with the date marking the filename.

``` r
render_invoice("my_records.csv")
```

- [📄 hybrid_invoice_2025-05-06.pdf](hybrid_invoice_2025-05-06.pdf)

#### Set a file name

Setting the `pdf` argument overrides filename defaults.

``` r
render_invoice(
  csv = "my_records.csv", 
  pdf = "sherman_invoice2.pdf")
```

- [📄 sherman_invoice2.pdf](sherman_invoice2.pdf)

#### Choose an invoice date

The `invoice_date` argument prepares an invoice for some other date.

``` r
render_invoice(
  csv = "my_records.csv", 
  invoice_date = "2025-06-18")
```

- [📄 hybrid_invoice_2025-06-18.pdf](hybrid_invoice_2025-06-18.pdf)

#### Choose an invoice period

Manually select an invoice period with `period_date`.

``` r
render_invoice(
  csv = "my_records.csv", 
  period_date = "2025-04-18", 
  pdf = "sherman_invoice3.pdf")
```

- [📄 sherman_invoice3.pdf](sherman_invoice3.pdf)

This method can also be used to set a broader range than might usually
be chosen. Two values will construct a range and prepare an invoice for
all periods ending within the range; more than two values will match
invoice dates on each value. Columns update to reflect the weeks, dates,
quantity, and amount due.

``` r
render_invoice(
  csv = "my_records.csv", 
  period_date = c("2025-03-01", "2025-06-18"), 
  invoice_date = "2025-06-18")
```

- [📄 hybrid_invoice_2025-06-18.pdf](hybrid_invoice_2025-06-18.pdf)

## Credit

Typst invoice template adapted from Eric Scott’s design. Quarto
extension adapted from [Jonathan Pedroza’s
code](https://github.com/jpedroza1228/quarto_extensions/tree/main/invoice).
