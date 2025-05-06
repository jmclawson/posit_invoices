library(tidyverse)
library(gt)

invoice_biweekly <- function(df, cluster_iso = TRUE) {
  df |> 
    rowwise() |> 
    mutate(
      date = as_date(date),
      isoweek = ifelse(
        is.na(date_end),
        list(isoweek(date)),
        list(isoweek(date):isoweek(date_end)))) |>
    ungroup() |> 
    unnest_longer(isoweek) |> 
    mutate(
      .by = c(date, action, course, group, contract, date_end),
      week = 0:(n() - 1),
      friday = date + 6 - wday(date) + 7 * week) |> 
    rowwise() |> 
    mutate(
      invoice = case_when(
        all(
          cluster_iso,
          week > 1,
          isoweek %% 2 == 0) ~ friday,
        all(
          !cluster_iso,
          week != 0,
          week %% 2 == 0) ~ friday
      )
    ) |> 
    ungroup() |> 
    group_by(date, action, course, group, contract, date_end) |> 
    mutate(
      invoice = case_when(
        cluster_iso & is.na(date_end) & isoweek %% 2 == 0 ~ friday,
        cluster_iso & is.na(date_end) & isoweek %% 2 == 1 ~ friday + 7,
        !cluster_iso & is.na(date_end) ~ friday,
        friday == last(friday) & is.na(invoice) ~ friday + 7,
        .default = invoice)) |> 
    ungroup() |> 
    fill(invoice, .direction = "up")
}

invoice_monthly <- function(df) {
  df |> 
    rowwise() |> 
    mutate(
      date = as_date(date),
      isoweek = ifelse(
        is.na(date_end),
        list(isoweek(date)),
        list(isoweek(date):isoweek(date_end)))) |>
    ungroup() |> 
    unnest_longer(isoweek) |> 
    mutate(
      .by = c(date, action, course, group, contract, date_end),
      week = 0:(n() - 1),
      friday = date + 6 - wday(date) + 7 * week,
      month = month(friday)) |> 
    group_by(month) |> 
    mutate(
      invoice = case_when(
        friday == max(friday) ~ friday)) |> 
    ungroup() |> 
    arrange(friday) |> 
    fill(invoice, .direction = "up")
}

expand_invoices <- function(df, period = c("biweekly", "monthly"), missed_price = -122, covered_price = 133) {
  period <- match.arg(period)
  switch(
    period,
    biweekly = invoice_biweekly(df),
    monthly = invoice_monthly(df)) |> 
    group_by(date, action, course, group, contract, date_end, invoice) |> 
    summarize(
      week_start = min(week),
      week_end = max(week)) |> 
    mutate(
      invoices = n(),
      contract = case_when(
        action == "missed" ~ missed_price,
        action == "covered" ~ covered_price,
        .default = contract),
      invoice_due = round(contract / invoices, 2),
      period_start = if_else(
        is.na(lag(invoice)),
        date, 
        lag(invoice) + 1),
      period_end = if_else(
        is.na(date_end),
        date,
        invoice)) |>
    ungroup() |> 
    rename(contract_end = date_end) |> 
    relocate(
      week_start, week_end,
      .before = period_start) |> 
    mutate(
      .by = c(date, action, course, group, contract, contract_end),
      invoice_due = case_when(
        invoice == max(invoice) ~ invoice_due + contract - sum(invoice_due),
        .default = invoice_due))
}

print_range <- function(x, y){
  if (is.numeric(x) & is.numeric(y)) {
    case_when(
      x == y ~ as.character(x),
      .default = paste0(x,"--",y)
    )
  } else if (is.Date(x)) {
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
  } else {
    stop(paste("Range confusion with", x, "and", y))
  }
}

set_table <- function(df, invoice_period = params$period_date %||% Sys.Date()) {
  if (length(invoice_period) == 1) {
    df <- df |> 
      filter(invoice <= invoice_period) |> 
      filter(invoice == max(invoice))
  } else if (length(invoice_period) == 2) {
    df <- df |> 
      filter(invoice %within% interval( as_date(invoice_period[1]), as_date(invoice_period[2])))
  } else if (length(invoice_period) > 2) {
    df <- df |> 
      filter(invoice %in% invoice_period)
  }
  df |> 
    mutate(amount = 1/invoices) |> 
    group_by(action, course, group, contract, contract_end) |> 
    arrange(period_start) |> 
    mutate(
      noncontiguous = any(period_start != (lag(period_end) + 1), na.rm = TRUE)) |>
    ungroup() |> 
    group_by(action, course, group, contract, contract_end) |> 
    summarize(
      date = list(date),
      noncontiguous = all(noncontiguous),
      week_start = min(week_start),
      week_end = max(week_end),
      period_start = min(period_start),
      period_end = max(period_end),
      amount = sum(amount),
      invoice_due = sum(invoice_due)) |> 
    ungroup() |> 
    rowwise() |> 
    mutate(
      week_range = print_range(week_start, week_end),
      week_range = case_when(
        str_detect(week_range, "--") ~ paste("weeks", week_range), 
        is.na(contract_end) ~ "",
        .default = paste("week", week_range)),
      period_range = if_else(
        noncontiguous,
        date |> 
          unlist() |> 
          as_date() |> 
          format("%b %e") |> 
          str_flatten_comma(),
        print_range(
          x = period_start,
          y = period_end)),
      description = paste0(action, " *", course, "* with **", group, "** ", week_range) |> str_squish()) |> 
    select(description, period_range, contract, 
           amount, invoice_due) |>
    arrange(desc(contract)) |> 
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
    fmt_markdown(columns = c("period_range", "description")) |>
    cols_label(
      period_range = "DATES",
      contract = "PRICE",
      amount = "AMT",
      invoice_due = "DUE",
    ) |>
    fmt_fraction(columns = "amount") |> 
    fmt_currency(
      columns = c(contract), 
      accounting = FALSE,
      use_subunits = FALSE) |> 
    fmt_currency(
      columns = c(invoice_due), 
      accounting = TRUE) |> 
    fmt_missing(missing_text = " ") |> 
    grand_summary_rows(
      columns = invoice_due,
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

render_invoice <- function(csv, periods = c("biweekly", "monthly"), period_date = NULL, invoice_date = Sys.Date(), pdf = NULL) {
  quarto::quarto_render(
    input = "hybrid_invoice.qmd",
    output_file = pdf %||% paste0("invoice_", invoice_date, ".pdf"),
    execute_params = list(
      periods = match.arg(periods),
      period_date = period_date %||% invoice_date,
      file = csv),
    metadata = list(date = invoice_date),
    quarto_args = c("--metadata", paste0("date=", invoice_date)))
}

####### Usage ######
## 1. Invoice for the period ending today (or before today):
# render_invoice("my_records.csv")

## 2. Invoice for a specific invoice date:
# render_invoice("my_records.csv", invoice_date = "2025-05-02")
