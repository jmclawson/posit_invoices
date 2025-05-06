# README


## Recording Data

Save contract data in a single CSV file within the project directory.
The file “[my_records.csv](my_records.csv)” is included as an example:

``` r
readr::read_csv("my_records.csv")
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

The `expand_invoices()` function adjusts a simple CSV file to aid with
invoicing at the final Friday of each period—either biweekly or monthly.
It produces a data frame in the following format:

``` r
source("invoice_functions.R")
readr::read_csv("my_records.csv") |> 
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
| 2025-04-06 | covered | Expressive Bowling | Froggy Croakers | 133 | NA | 2025-04-11 | 1 | 133.00 | 0 | 0 | 2025-04-06 | 2025-04-06 |
| 2025-04-07 | missed | Dogpaddling Foundations | Company 1 | -122 | NA | 2025-04-18 | 1 | -122.00 | 0 | 0 | 2025-04-07 | 2025-04-07 |
| 2025-05-06 | covered | Expressive Bowling | Froggy Croakers | 133 | NA | 2025-05-16 | 1 | 133.00 | 0 | 0 | 2025-05-06 | 2025-05-06 |
| 2025-06-07 | missed | Dogpaddling Foundations | Company 1 | -122 | NA | 2025-06-13 | 1 | -122.00 | 0 | 0 | 2025-06-07 | 2025-06-07 |

A data frame in this format can then be passed along to `set_table()`
for formatting with gt.

## Formatting the table

The `set_table()` function prepares a formatted table for invoicing a
given period of work.

``` r
readr::read_csv("my_records.csv") |> 
  expand_invoices(period = "biweekly") |> 
  set_table(invoice_period = "2025-05-02")
```

<div id="beuraxqzyr" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#beuraxqzyr table {
  font-family: Georgia, system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#beuraxqzyr thead, #beuraxqzyr tbody, #beuraxqzyr tfoot, #beuraxqzyr tr, #beuraxqzyr td, #beuraxqzyr th {
  border-style: none;
}
&#10;#beuraxqzyr p {
  margin: 0;
  padding: 0;
}
&#10;#beuraxqzyr .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 14px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#beuraxqzyr .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#beuraxqzyr .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#beuraxqzyr .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#beuraxqzyr .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#beuraxqzyr .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#beuraxqzyr .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#beuraxqzyr .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#beuraxqzyr .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#beuraxqzyr .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#beuraxqzyr .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#beuraxqzyr .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#beuraxqzyr .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#beuraxqzyr .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#beuraxqzyr .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#beuraxqzyr .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#beuraxqzyr .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#beuraxqzyr .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#beuraxqzyr .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 0px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#beuraxqzyr .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#beuraxqzyr .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#beuraxqzyr .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#beuraxqzyr .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#beuraxqzyr .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#beuraxqzyr .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#beuraxqzyr .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#beuraxqzyr .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#beuraxqzyr .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#beuraxqzyr .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#beuraxqzyr .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#beuraxqzyr .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#beuraxqzyr .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#beuraxqzyr .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#beuraxqzyr .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#beuraxqzyr .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#beuraxqzyr .gt_left {
  text-align: left;
}
&#10;#beuraxqzyr .gt_center {
  text-align: center;
}
&#10;#beuraxqzyr .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#beuraxqzyr .gt_font_normal {
  font-weight: normal;
}
&#10;#beuraxqzyr .gt_font_bold {
  font-weight: bold;
}
&#10;#beuraxqzyr .gt_font_italic {
  font-style: italic;
}
&#10;#beuraxqzyr .gt_super {
  font-size: 65%;
}
&#10;#beuraxqzyr .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#beuraxqzyr .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#beuraxqzyr .gt_indent_1 {
  text-indent: 5px;
}
&#10;#beuraxqzyr .gt_indent_2 {
  text-indent: 10px;
}
&#10;#beuraxqzyr .gt_indent_3 {
  text-indent: 15px;
}
&#10;#beuraxqzyr .gt_indent_4 {
  text-indent: 20px;
}
&#10;#beuraxqzyr .gt_indent_5 {
  text-indent: 25px;
}
&#10;#beuraxqzyr .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#beuraxqzyr div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>

|  | DATES | PRICE | AMT | DUE |
|----|----|----|----|----|
| mentored *Dogpaddling Foundations* with **Company 1** weeks 3–4 | Apr 19–May 2 | \$3,640 | 1/6 | \$606.67 |
| mentored *Advanced Sugargliding* with **Second Co. Ltd.** weeks 3–4 | Apr 19–May 2 | \$2,184 | 1/3 | \$728.00 |
| TOTAL |   |   |   | \$1,334.67 |

</div>

## Rendering Invoices as PDF

Invoices can be created either by modifying the Quarto file directly or
by using a dedicated function.

### Render the Quarto file in the IDE

Use [`hybrid_invoice.qmd`](hybrid_invoice.qmd) as a template. After
setting the document’s `date` in the metadata and `periods`,
`period_date`, and `file` parameters in the YAML, use the “Render”
button in RStudio or Positron to create [a PDF](hybrid_invoice.pdf).

### Render using `render_invoice()`

`render_invoice()` can be used to set details for an invoice and create
a PDF without needing to touch a file.

#### For the most recent period

By default, an invoice will be prepared for the period ending on or
before today, with the date marking the filename.

<div class="columns" style="display: flex; align-items: center;">

<div class="column" width="50%">

``` r
render_invoice("my_records.csv")
```

</div>

<div class="column" width="50%">

[📄 invoice_2025-05-06.pdf](invoice_2025-05-06.pdf)

</div>

</div>

#### Set a file name

Setting the `pdf` argument overrides filename defaults.

<div class="columns" style="display: flex; align-items: center;">

<div class="column" width="50%">

``` r
render_invoice(
  csv = "my_records.csv", 
  pdf = "sherman_invoice2.pdf")
```

</div>

<div class="column" width="50%">

[📄 sherman_invoice2.pdf](sherman_invoice2.pdf)

</div>

</div>

#### Choose an invoice date

The `invoice_date` argument prepares an invoice for some other date.

<div class="columns" style="display: flex; align-items: center;">

<div class="column" width="50%">

``` r
render_invoice(
  csv = "my_records.csv", 
  invoice_date = "2025-06-18")
```

</div>

<div class="column" width="50%">

[📄 invoice_2025-06-18.pdf](invoice_2025-06-18.pdf)

</div>

</div>

#### Choose an invoice period

Manually select an invoice period with `period_date`.

<div class="columns" style="display: flex; align-items: center;">

<div class="column" width="50%">

``` r
render_invoice(
  csv = "my_records.csv", 
  period_date = "2025-04-18", 
  pdf = "sherman_invoice3.pdf")
```

</div>

<div class="column" width="50%">

[📄 sherman_invoice3.pdf](sherman_invoice3.pdf)

</div>

</div>

This method can also be used to set a broader range than might usually
be chosen. Two values will construct a range and prepare an invoice for
all periods ending within the range; more than two values will match
invoice dates on each value. Columns update to reflect the weeks, dates,
number of units, and amount due.

<div class="columns" style="display: flex; align-items: center;">

<div class="column" width="50%">

``` r
render_invoice(
  csv = "my_records.csv", 
  period_date = c("2025-03-01", "2025-06-18"), 
  invoice_date = "2025-06-18")
```

</div>

<div class="column" width="50%">

[📄 invoice_2025-06-18.pdf](invoice_2025-06-18.pdf)

</div>

</div>

## Credit

Typst invoice template adapted from Eric Scott’s design. Quarto
extension adapted from [Jonathan Pedroza’s
code](https://github.com/jpedroza1228/quarto_extensions/tree/main/invoice).
