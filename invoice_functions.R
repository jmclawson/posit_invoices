library(tidyverse)
library(gt)

handle_exceptions <- function(df, exceptions) {
  if ("start_week" %in% names(exceptions)) {
    df <- df |> 
      add_startwk(exceptions$start_week)
  } else {
    df <- df |> 
      add_startwk(NULL)
  }
  
  if ("skip_invoices" %in% names(exceptions)) {
    df <- df |> 
      add_skip_invoices(exceptions$skip_invoices)
  } else {
    df <- df |> add_skip_invoices(NULL)
  }
  df
}

add_skip_invoices <- function(df, skip_invoices){
  if (!is.null(skip_invoices)) {
    skipped_invoices_exceptions <- tibble(
      rule = names(unlist(skip_invoices)),
      skip_invoice_wk = unname(unlist(skip_invoices)) |> 
        as.integer()) |> 
      mutate(group = str_subset(df$group, rule)) |> 
      select(group, skip_invoice_wk)
    
    df <- df |> 
      left_join(skipped_invoices_exceptions) |> 
      replace_na(list(skip_invoice_wk = 0))
  } else {
    df <- df |> 
      mutate(skip_invoice_wk = 0)
  }
  df
}

add_startwk <- function(df, start_week) {
  if (!is.null(start_week)) {
    starting_exceptions <- tibble(
      rule = names(unlist(start_week)),
      startwk = unname(unlist(start_week))) |> 
      mutate(group = str_subset(df$group, rule)) |> 
      select(group, startwk)
    
    df <- df |> 
      left_join(starting_exceptions) |> 
      replace_na(list(startwk = 0))
  } else {
    df <- df |> 
      mutate(startwk = 0)
  }
  df
}

invoice_biweekly <- function(df, cluster_iso = TRUE, exceptions = NULL) {
  df |> 
    handle_exceptions(exceptions) |> 
    rowwise() |> 
    mutate(
      date = as_date(date),
      isoweek = ifelse(
        is.na(date_end),
        list(isoweek(date)),
        list(isoweek(date):isoweek(date_end)))) |>
    ungroup() |> 
    unnest_longer(isoweek) |> 
    group_by(date, action, course, 
             group, contract, date_end) |> 
    mutate(
      week = startwk:(n() - 1 + startwk),
      friday = date + 6 - wday(date) + 7 * (week - startwk)) |> 
    arrange(friday) |> 
    ungroup() |> 
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
        week == 0 ~ as.Date(NA),
        cluster_iso & is.na(date_end) & isoweek %% 2 == 0 ~ friday,
        cluster_iso & is.na(date_end) & isoweek %% 2 == 1 ~ friday + 7,
        !cluster_iso & is.na(date_end) ~ friday,
        friday == last(friday) & is.na(invoice) ~ friday + 7,
        (week - startwk) <= skip_invoice_wk ~ as.Date(NA),
        .default = invoice)) |> 
    fill(invoice, .direction = "up") |> 
    ungroup() |> 
    fill(invoice, .direction = "up")
}

invoice_monthly <- function(df, exceptions) {
  df |> 
    handle_exceptions(exceptions) |> 
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
      week = startwk:(n() - 1 + startwk),
      friday = date + 6 - wday(date) + 7 * (week - startwk),
      month = month(friday)) |> 
    group_by(month) |> 
    mutate(
      invoice = case_when(
        friday == max(friday) ~ friday)) |> 
    ungroup() |> 
    arrange(friday) |> 
    fill(invoice, .direction = "up")
}

#' Convert per-contract data frame into per-invoice
#'
#' @param df Data frame containing columns for `date`, `action`, `course`, `group`, `contract`, and `date_end`
#' @param period Either "biweekly" or "monthly"
#' @param cluster_iso By default, biweekly invoicing will follow the calendar year. Set `cluster_iso` to FALSE to instead invoice biweekly from the starting date.
#' @param missed_price Amount to deduct for missing a class.
#' @param covered_price Amount to add for covering someone else's class.
#' @param exceptions A named list of exceptions. 
#'   - Set `start_week` for values other than 0 for rare circumstances in which a class is picked up from another after the kickoff week.
#'   - Set `skip_invoices` to modify the default invoicing schedule. This might make sense, for example, if a 6-week course is picked up in week 4, leading to a strange scenario of half of the contract being invoiced in week 1. In this scenario, set `skip_invoices` to `1` for that group to skip the first invoice date.
#'
#' @returns A data frame with one row per invoice item
#' @export
#'
#' @examples
#' params$file |> 
#'   read_csv() |> 
#'   expand_invoices(
#'     params$periods, 
#'     cluster_iso = FALSE,
#'     exceptions = list(
#'       start_week = list(
#'         # Name partial matches a group
#'         "Condo-B" = 4
#'       ),
#'       skip_invoices = list(
#'         "Condo-B" = 1
#'       )
#'     )
#'   ) |>
#'   set_table()
expand_invoices <- function(df, period = c("biweekly", "monthly"), cluster_iso = TRUE, missed_price = -122, covered_price = 133, exceptions = NULL) {
  period <- match.arg(period)
  switch(
    period,
    biweekly = invoice_biweekly(df, cluster_iso, exceptions),
    monthly = invoice_monthly(df, exceptions)) |> 
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

set_table <- function(df, invoice_period = params$period_date %||% Sys.Date(), contract_cents = NULL) {
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
  if (is.null(contract_cents)) {
    contract_cents <- ifelse(any(df$contract %% 1 != 0), TRUE, FALSE)
  }
  df |> 
    mutate(quantity = 1/invoices) |> 
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
      quantity = sum(quantity),
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
      description = paste0(action, " *", course, "* with **", group, "** ", week_range, if_else(!is.na(contract_end) & (period_end >= contract_end), " —*contract complete*", "")) |> str_squish()) |> 
    select(description, period_range, contract, 
           quantity, invoice_due) |>
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
      quantity = "QTY",
      invoice_due = "DUE",
    ) |>
    fmt_fraction(columns = "quantity") |> 
    fmt_currency(
      columns = c(contract), 
      accounting = FALSE,
      use_subunits = contract_cents) |> 
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
    cols_align("center", "quantity") |> 
    tab_style(
      style = list(
        cell_text(align = "right")
      ),
      locations = cells_stub_grand_summary()) |> 
    # tab_style(
    #   style = list(
    #     cell_text(weight = "bold"),
    #     "font-variant: small-caps;"), 
    #   locations = cells_column_labels(columns = everything())) |> 
    opt_row_striping() |>
    tab_options(row.striping.include_stub = TRUE)
}

render_invoice <- function(csv, qmd = "hybrid_invoice.qmd", periods = c("biweekly", "monthly"), period_date = NULL, invoice_date = Sys.Date(), pdf = NULL) {
  qmd_filename <- tools::file_path_sans_ext(basename(qmd))
  pdf_filename <- pdf %||% paste0(qmd_filename, "_", invoice_date) |> 
    {\(x) if_else(str_detect(x, "[.]pdf$"), x, paste0(x, ".pdf"))}()
  
  quarto::quarto_render(
    input = qmd,
    output_file = pdf_filename,
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
