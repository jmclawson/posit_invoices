# README


## Recording Data

Save contract data in a single CSV file within the project directory.
The file “[my_records.csv](my_records.csv)” is included as an example:

``` r
readr::read_csv("my_records.csv")
```

| date       | action   | course                  | group           | contract | invoices |
|:-----------|:---------|:------------------------|:----------------|---------:|---------:|
| 2025-04-01 | mentored | Dogpaddling Foundations | Company 1       |     3640 |        6 |
| 2025-04-02 | mentored | Advanced Sugargliding   | Comp 2          |     2184 |        3 |
| 2025-04-07 | missed   | Dogpaddling Foundations | Company 1       |       NA |       NA |
| 2025-04-06 | covered  | Expressive Bowling      | Froggy Croakers |       NA |       NA |
| 2025-05-06 | covered  | Expressive Bowling      | Froggy Croakers |       NA |       NA |
| 2025-06-07 | missed   | Dogpaddling Foundations | Company 1       |       NA |       NA |

Each contract, each missed day, and each covered day should be listed on
its own row. The `action` column should include a single word for each
row: “mentored” or “covered” or “missed”. Include the contract price and
number of invoices where applicable. Do not include price or number of
invoices for days covered or missed. The `date` column refers to the
**kick-off date** for a particular group *or* to the date missed or
covered.

## Rendering Invoices

Invoices can be created either by modifying the Quarto file directly or
by using a dedicated function.

### Render the Quarto file in the IDE

Use `hybrid_invoice.qmd` as a template. After setting the document’s
`date` in the metadata and `date_range` in the parameters in the YAML,
use the “Render” button in RStudio or Positron the file to create a PDF.

When rendering the “[hybrid_invoice.qmd](hybrid_invoice.qmd)” file as
included, the resulting file is
“[hybrid_invoice.pdf](hybrid_invoice.pdf).”

### Render using `render_invoice()`

`render_invoice()` can be used to set details for an invoice and create
a PDF without needing to adjust a file.

#### Invoice for the period including today:

``` r
render_invoice("my_records.csv")
```

The above code, rendered on May 1, produces
“[invoice_2025-05-01.pdf](invoice_2025-05-01.pdf).”

#### Invoice for the period including a specific invoice date:

``` r
render_invoice("my_records.csv", invoice_date = "2025-05-02")
```

The above code produces
“[invoice_2025-05-02.pdf](invoice_2025-05-02.pdf).”

#### Invoice for work from an explicit date range:

``` r
render_invoice("my_records.csv", from = "2025-04-01", to = "2025-04-18", pdf = "invoice_example3.pdf")
```

The above code produces “[invoice_example3.pdf](invoice_example3.pdf).”

#### Invoice for work from an explicit date range with an explicit invoice date

``` r
render_invoice("my_records.csv", from = "2025-04-01", to = "2025-04-18", invoice_date = "2025-04-18")
```

This code produces “[invoice_2025-04-18.pdf](invoice_2025-04-18.pdf).”

This method can also be used to set a broader range than might usually
be chosen, which will adjust the “amount” column:

``` r
render_invoice(
  "my_records.csv", 
  from = "2025-04-01", 
  to = "2025-06-18", 
  invoice_date = "2025-06-18")
```

This code produces “[invoice_2025-06-18.pdf](invoice_2025-06-18.pdf).”

## Custom use

The `expand_invoice()` function makes many assumptions about beginning
with a simple CSV file and invoicing every two weeks. It produces a data
frame in the following format:

``` r
source("invoice_functions.R")
readr::read_csv("my_records.csv") |> 
  expand_invoice()
```

| date | action | course | group | contract | invoices | invoice_num | date_end | price |
|:---|:---|:---|:---|---:|---:|---:|:---|---:|
| 2025-04-01 | mentored | Dogpaddling Foundations | Company 1 | 3640 | 6 | 1 | 2025-04-18 | 606.67 |
| 2025-04-02 | mentored | Advanced Sugargliding | Comp 2 | 2184 | 3 | 1 | 2025-04-18 | 728.00 |
| 2025-04-06 | covered | Expressive Bowling | Froggy Croakers | NA | NA | NA | NA | 133.00 |
| 2025-04-07 | missed | Dogpaddling Foundations | Company 1 | NA | NA | NA | NA | -122.00 |
| 2025-04-19 | mentored | Dogpaddling Foundations | Company 1 | 3640 | 6 | 2 | 2025-05-02 | 606.67 |
| 2025-04-19 | mentored | Advanced Sugargliding | Comp 2 | 2184 | 3 | 2 | 2025-05-02 | 728.00 |
| 2025-05-03 | mentored | Dogpaddling Foundations | Company 1 | 3640 | 6 | 3 | 2025-05-16 | 606.67 |
| 2025-05-03 | mentored | Advanced Sugargliding | Comp 2 | 2184 | 3 | 3 | 2025-05-16 | 728.00 |
| 2025-05-06 | covered | Expressive Bowling | Froggy Croakers | NA | NA | NA | NA | 133.00 |
| 2025-05-17 | mentored | Dogpaddling Foundations | Company 1 | 3640 | 6 | 4 | 2025-05-30 | 606.67 |
| 2025-05-31 | mentored | Dogpaddling Foundations | Company 1 | 3640 | 6 | 5 | 2025-06-13 | 606.67 |
| 2025-06-07 | missed | Dogpaddling Foundations | Company 1 | NA | NA | NA | NA | -122.00 |
| 2025-06-14 | mentored | Dogpaddling Foundations | Company 1 | 3640 | 6 | 6 | 2025-06-27 | 606.65 |

If these assumptions don’t apply, adjust the Quarto template
accordingly, making sure to prepare a data frame with the appropriate
parameters before using `set_table()` for rendering.

## Credit

Typst invoice template adapted from Eric Scott’s design. Quarto
extension adapted from [Jonathan Pedroza’s
code](https://github.com/jpedroza1228/quarto_extensions/tree/main/invoice).
