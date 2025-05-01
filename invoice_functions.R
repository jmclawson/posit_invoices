library(tidyverse)
library(gt)

expand_invoice <- function(df, missed_price = -122, covered_price = 133) {
  if ("invoice" %in% colnames(df)) {
    message("`df` already has an 'invoice_num' column")
    return(invisible(df))
  }
  
  df |> 
    filter(action == "mentored") |> 
    group_by(date, course, group) |> 
    mutate(invoice_num = list(1:invoices)) |> 
    unnest_longer(invoice_num) |> 
    mutate(
      date_end = as_date(date) + dweeks(invoice_num*2) + (6 - wday(as_date(date))),
      kickoff = date,
      date = case_when(
        invoice_num != 1 ~ lag(date_end) + ddays(1),
        .default = date)) |> 
    ungroup() |> 
    list(filter(df, action != "mentored")) |> 
    list_rbind() |> 
    mutate(
      price = case_when(
        action == "missed" ~ missed_price,
        action == "covered" ~ covered_price,
        .default = round(contract / invoices, 2))) |> 
    # correct rounding in final invoice
    mutate(
      .by = c(kickoff, course, group),
      price = case_when(
        date == max(date) & sum(price) > contract ~ price - (sum(price) - contract),
        .default = price)) |> 
    arrange(date) |> 
    select(-kickoff)
}

print_dates <- function(x, y){
  case_when(
    x == y ~ as_date(x) |> format("%b %e"),
    format(as_date(x), "%b") == format(as_date(y), "%b") ~ 
      paste0(as_date(x) |> format("%b %e"), 
             "--",
             as_date(y) |> format("%e")),
    .default = 
      paste0(as_date(x) |> format("%b %e"), 
             "--", 
             as_date(y) |> format("%b %e"))) |> 
    str_squish()
}

set_place <- function(df, invoice_dates = as_date(params$date_range), alt_date = Sys.Date()) {
  if (any(is.na(invoice_dates))) {
    invoice_dates <- df |> 
      filter(as_date(alt_date) %within% interval(date, date_end)) |> 
      {\(x) c(min(x$date), max(x$date_end))}()
  }
  the_df <- df |> 
    filter(as_date(date) >= as_date(invoice_dates[1]),
           if_else(
             !is.na(date_end), 
             as_date(date_end) <= as_date(invoice_dates[2]), 
             as_date(date) <= as_date(invoice_dates[2]))
    ) |> 
    mutate(
      incl_dates = case_when(
        !is.na(date_end) ~ print_dates(date, date_end),
        TRUE ~ as_date(date) |> 
          format("%b %e") |> 
          str_squish()),
      action = action,
      description = paste0(
        action, " *", course, "* with **", group, "**"),
      amount = 1)
  
  the_df |> 
    select(date, date_end, incl_dates, description, contract, invoices, price, amount)
}

set_table <- function(data, alt_date = params$inv_date %||% Sys.Date()) {
  data |> 
    set_place(alt_date = alt_date) |> 
    mutate(
      .by = c(description, contract, price, invoices),
      collapse_dates = case_when(
        !is.na(lag(date_end)) & all(date == (lag(date_end) + ddays(1))) ~ TRUE,
        is.na(lag(date_end)) & date == (lead(date_end) + ddays(1)) ~ TRUE,
        .default = FALSE)
    ) |> 
    rowwise() |> 
    mutate(
      included_dates = list(
        seq(from = date, 
            to = if_else(is.na(date_end), date, date_end), 
            by = "1 day"))) |> 
    ungroup() |> 
    mutate(
      .by = c(description, contract, price, invoices),
      included_dates = list(as_date(unique(unlist(included_dates)))),
      date = if_else(is.na(date_end), date, min(date)),
      date_end = if_else(is.na(date_end), date, max(date_end))) |> 
    rowwise() |> 
    mutate(
      collapse_it = length(setdiff(unlist(included_dates), seq(date, date_end, "1 day")))  == 0) |> 
    ungroup() |> 
    summarize(
      .by = c(description, contract, price, invoices),
      amount = sum(amount),
      date = min(date),
      date_end = if_else(is.na(date_end), date, max(date_end)),
      incl_dates = case_when(
        collapse_it ~ print_dates(min(date), max(date_end)),
        .default = str_flatten_comma(incl_dates))) |> 
    distinct() |> 
    mutate(
      due = price * amount,
      amount = case_when(
        !is.na(invoices) ~ amount/invoices,
        .default = amount),
      price = case_when(
        !is.na(contract) ~ contract,
        .default = price)) |> 
    select(-contract, -invoices) |>
    select(description, price, incl_dates, amount, due) |> 
    gt(rowname_col = "description") |>
    tab_style(
      style = cell_text(v_align = "top"),
      locations = cells_body()) |>
    tab_style(
      style = cell_borders(
        sides = c("top", "bottom"),
        color = "white",
        weight = px(0),
        style = "solid"),
      locations = cells_body()) |>
    tab_style(
      style = cell_borders(
        sides = c("top", "bottom"),
        color = "white",
        weight = px(0),
        style = "solid"),
      locations = cells_stub()) |>
    fmt_markdown(columns = c("incl_dates", "description")) |>
    cols_label(
      incl_dates = "DATES",
      price = "PRICE",
      amount = "AMT",
      due = "DUE",
    ) |>
    fmt_fraction(columns = "amount") |> #, layout = "diagonal") |> 
    fmt_currency(
      columns = c(price), 
      accounting = FALSE,
      use_subunits = FALSE) |> 
    fmt_currency(
      columns = c(due), 
      accounting = TRUE) |> 
    fmt_missing(missing_text = " ") |> 
    grand_summary_rows(
      columns = due,
      fns = list(TOTAL ~ sum(.)),
      fmt = ~ fmt_currency(.),
      missing_text = " ") |>
    tab_options(
      stub.border.width = 0) |>
    opt_table_font(
      font = "Georgia",
      size = 14) |> 
    cols_align("center", "amount") |> 
    tab_style(
      style = list(
        cell_text(align = "right")
      ),
      locations = cells_stub_grand_summary()) |> 
    opt_row_striping() |>
    tab_options(row.striping.include_stub = TRUE)
}

render_invoice <- function(csv, from = NA, to = NA, invoice_date = Sys.Date(), pdf = NULL) {
  quarto::quarto_render(
    input = "hybrid_invoice.qmd",
    output_file = pdf %||% paste0("invoice_", invoice_date, ".pdf"),
    execute_params = list(
      inv_date = invoice_date,
      date_range = c(from, to),
      file = csv),
    metadata = list(date = invoice_date),
    quarto_args = c("--metadata", paste0("date=", invoice_date)))
}

####### Usage ######
## 1. Invoice for the period including today:
# render_invoice("my_records.csv")

## 2. Invoice for the period including a specific invoice date:
# render_invoice("my_records.csv", invoice_date = "2025-05-02")

## 3. Invoice for work from an explicit date range:
# render_invoice("my_records.csv", from = "2025-04-01", to = "2025-04-18", pdf = "invoice_example3.pdf")

## 4. Invoice for work from an explicit date range with an explicit invoice date
# render_invoice("my_records.csv", from = "2025-04-01", to = "2025-04-18", invoice_date = "2025-04-18")
