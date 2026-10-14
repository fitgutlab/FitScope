# FitScope - NIRS mitochondrial oxidative capacity pipeline
#
# A thin Shiny front end over the three validated Rscripts in the repo root's
# cleaning_STEP/, analysis_STEP/, plotting_STEP/ (clean_nirs.R, analyse_nirs.R,
# plot_nirs.R). This app does not reimplement any pipeline logic - it copies
# the unmodified scripts into a working project folder, shells out to Rscript
# for each step, and displays the CSVs/PNGs the scripts already produce. See
# ../CLAUDE.md for the method and the guardrails a "converged fit" still has
# to pass.

suppressMessages({
  library(shiny)
  library(bslib)
  library(DT)
})

# shiny::runApp() sets the working directory to this file's folder for the
# duration of the app, so relative paths below are reliable.
source("R/pipeline_runner.R")

PIPELINE_ROOT   <- normalizePath("..", mustWork = TRUE)
DEFAULT_PROJECT <- normalizePath(file.path("..", "workspace"), mustWork = FALSE)

fmt_num <- function(x, digits = 3) ifelse(is.na(x), "NA", formatC(x, digits = digits, format = "f"))

# Palette pulled from app/www/fitscope-logo-dark.png (k-means over the PNG's
# pixels): the dark-navy background, the coral recovery-curve dots, and the
# muted blue-gray subtitle/baseline. `danger` is kept apart from `primary` -
# both are reds, and a bad-fit flag must not read as "on brand".
fit_ui <- list(
  primary   = "#ED5F4F",
  secondary = "#44607A",
  accent    = "#E3A54C",
  ink       = "#0F2230",
  muted     = "#5B6B78",
  surface   = "#FFFFFF",
  canvas    = "#F7F5F1",
  border    = "#E2E1DC",
  danger    = "#B3261E"
)

ui <- bslib::page_navbar(
  title = tags$div(
    class = "fs-brand",
    tags$img(src = "fitscope-logo-dark.png", class = "fs-brand-logo",
             alt = "FitScope - NIRS muscle oxidative capacity")
  ),
  window_title = "FitScope - NIRS oxidative capacity",
  id = "tabs",
  fillable = FALSE,
  theme = bslib::bs_theme(
    version = 5,
    base_font    = bslib::font_google("Inter", local = FALSE),
    heading_font = bslib::font_google("Inter", local = FALSE),
    code_font    = bslib::font_google("JetBrains Mono", local = FALSE),
    primary   = fit_ui$primary,
    secondary = fit_ui$secondary,
    success   = "#1B6B3A",
    info      = fit_ui$secondary,
    warning   = fit_ui$accent,
    danger    = fit_ui$danger,
    bg        = fit_ui$canvas,
    fg        = fit_ui$ink,
    "border-radius"     = "0.6rem",
    "card-border-color" = fit_ui$border,
    "navbar-bg"         = fit_ui$ink
  ),

  header = tags$head(tags$style(HTML(sprintf("
    :root {
      --fs-primary:%s; --fs-secondary:%s; --fs-accent:%s;
      --fs-ink:%s; --fs-muted:%s; --fs-surface:%s;
      --fs-canvas:%s; --fs-border:%s; --fs-danger:%s;
    }
    body { background:var(--fs-canvas); }

    .fs-brand { display:flex; align-items:center; }
    .fs-brand-logo { height:70px; max-width:100%%; display:block; }

    .navbar { box-shadow:0 1px 0 rgba(0,0,0,.06); padding-top:1rem; padding-bottom:1rem; }
    .navbar .container-fluid { position:relative; }
    .navbar-brand { padding-top:0; padding-bottom:0; }
    /* Centered independent of the brand's width, rather than just left-aligned
       in whatever space is left after it. */
    .navbar-collapse {
      position:absolute; left:50%%; top:50%%; transform:translate(-50%%, -50%%);
    }
    .navbar .nav-link { font-size:1.1rem; font-weight:500; padding:.85rem 1.5rem; }

    /* Cards separate by surface contrast and a soft two-layer shadow rather
       than a hard border: a tight contact shadow plus a wide ambient one. */
    .card {
      border:none; border-radius:8px; background:var(--fs-surface);
      box-shadow:0 3.2px 7.2px 0 rgba(0,0,0,.132), 0 .6px 1.8px 0 rgba(0,0,0,.108);
      margin-bottom:1.25rem;
    }
    .card-body { padding:1.5rem; }
    .card-header {
      background:var(--fs-surface); border-bottom:1px solid var(--fs-border);
      border-radius:8px 8px 0 0;
      font-weight:500; font-size:1.05rem; color:var(--fs-ink);
      padding:1rem 1.5rem;
    }

    .fs-section-title { font-size:.72rem; font-weight:700; letter-spacing:.09em;
      text-transform:uppercase; color:var(--fs-muted); margin:.9rem 0 .5rem; }
    .fs-section-title:first-child { margin-top:.15rem; }

    .fs-hint { font-size:.75rem; color:var(--fs-muted); margin:-.35rem 0 .8rem; }

    .info-box {
      background:#FBEEEC; border:1px solid #F3D7D2; border-left:3px solid var(--fs-primary);
      border-radius:.45rem; padding:.6rem .7rem; margin-bottom:.85rem;
      font-size:.79rem; line-height:1.45; color:#41525C;
    }

    /* One control height and one radius throughout, so a dense sidebar still
       reads as a single system. */
    .form-label, label { font-size:.875rem; font-weight:500; color:var(--fs-ink); margin-bottom:.35rem; }
    .form-control, .form-select {
      font-size:.875rem; min-height:40px; border-radius:4px; border:1px solid #d2d0ce;
    }
    .form-control:focus, .form-select:focus {
      border-color:var(--fs-primary); box-shadow:0 0 0 .18rem rgba(237,95,79,.16);
    }
    .btn {
      font-size:.875rem; font-weight:500; border-radius:4px;
      min-height:40px; padding:8px 16px;
      transition:box-shadow 200ms cubic-bezier(.4,1,.75,.9), background-color 150ms ease;
    }
    .sidebar .form-group, .sidebar .shiny-input-container { margin-bottom:1rem; }

    .flag-bad  { color: var(--fs-danger); font-weight:600; }
    .flag-ok   { color: #1b6b3a; font-weight:600; }
    .flag-warn { color: #a15c00; font-weight:500; }

    pre.console { background:var(--fs-ink); color:#d1d5db; padding:12px; border-radius:6px;
                  max-height:420px; overflow-y:auto; white-space:pre-wrap; font-size:12px; }
    .console-warning { color:#fca5a5; }
    .console-note    { color:#fcd34d; }

    .fs-stat-row { display:flex; flex-wrap:wrap; gap:.75rem; margin-bottom:1.25rem; }
    .fs-stat {
      flex:1 1 150px; background:var(--fs-surface); border:1px solid var(--fs-border);
      border-radius:.55rem; padding:.7rem .85rem;
      box-shadow:0 3.2px 7.2px 0 rgba(0,0,0,.08);
    }
    .fs-stat-label { font-size:.68rem; text-transform:uppercase; letter-spacing:.07em;
      color:var(--fs-muted); font-weight:650; }
    .fs-stat-value { font-size:1.45rem; font-weight:680; color:var(--fs-ink); line-height:1.15; }
    .fs-stat-note  { font-size:.72rem; color:var(--fs-muted); }

    /* FitGut Lab badge, pinned top-right independent of the centered tabs -
       kept as a circle (its native shape) rather than cropped to a strip,
       diameter matched to the FitScope logo's height on the left. */
    .fs-partner-logo {
      position:absolute; right:1.5rem; top:50%%; transform:translateY(-50%%);
      height:70px; width:70px; border-radius:50%%; object-fit:cover;
    }
  ",
  fit_ui$primary, fit_ui$secondary, fit_ui$accent, fit_ui$ink,
  fit_ui$muted, fit_ui$surface, fit_ui$canvas, fit_ui$border, fit_ui$danger))),
    tags$script(HTML("
      document.addEventListener('DOMContentLoaded', function() {
        var bar = document.querySelector('.navbar .container-fluid');
        if (!bar || document.querySelector('.fs-partner-logo')) return;
        var img = document.createElement('img');
        img.src = 'fitgut-logo.png';
        img.alt = 'FitGut Lab';
        img.className = 'fs-partner-logo';
        bar.appendChild(img);
      });
    "))
  ),

  sidebar = bslib::sidebar(
    width = 320, title = "Pipeline",

    div(class = "fs-section-title", "Project"),
    textInput("project_dir", "Project directory", value = DEFAULT_PROJECT),
    actionButton("prep_project", "Prepare project folder", icon = icon("folder-plus"),
                 class = "w-100"),
    div(class = "fs-hint",
        "Copies clean_nirs.R / analyse_nirs.R / plot_nirs.R into this ",
        "folder's cleaning_STEP/analysis_STEP/plotting_STEP if not already there. ",
        "Never overwrites a script you've edited."),

    div(class = "fs-section-title", "Raw data"),
    uiOutput("upload_ui"),
    uiOutput("raw_file_picker"),

    div(class = "fs-section-title", "Run"),
    actionButton("run_clean",   "1. Clean",   icon = icon("broom"),      width = "100%"),
    div(class = "mt-2"),
    actionButton("run_analyse", "2. Analyse", icon = icon("chart-line"), width = "100%"),
    div(class = "mt-2"),
    actionButton("run_plot",    "3. Plot",    icon = icon("image"),      width = "100%"),
    div(class = "mt-2"),
    actionButton("run_all", "Run all 3 steps", icon = icon("play"), width = "100%",
                 class = "btn-primary"),

    div(class = "fs-section-title", "View existing subject"),
    uiOutput("subject_picker"),

    div(class = "fs-section-title", "R package check"),
    tableOutput("pkg_check")
  ),

  bslib::nav_panel(
    "Console", icon = icon("terminal"),
    bslib::card(bslib::card_header("Pipeline console"), htmlOutput("console"))
  ),

  bslib::nav_panel(
    "QC report", icon = icon("clipboard-check"),
    bslib::card(bslib::card_header("Per-probe QC"), DTOutput("qc_table"))
  ),

  bslib::nav_panel(
    "Recovery fit (Tc)", icon = icon("chart-line"),
    uiOutput("tc_stats"),
    bslib::card(bslib::card_header("Plausibility"), uiOutput("plausibility")),
    bslib::card(bslib::card_header("Fit table"), DTOutput("fit_table")),
    bslib::card(bslib::card_header("Figure 6 — mV̇O2 recovery fit"), uiOutput("fig6_img"))
  ),

  bslib::nav_panel(
    "Signal figures (1–5)", icon = icon("images"),
    uiOutput("figs_gallery")
  ),

  bslib::nav_panel(
    "Output files", icon = icon("folder-open"),
    bslib::card(
      bslib::card_header("Output files"),
      div(class = "d-flex gap-2 mb-3",
          downloadButton("download_selected_file", "Download selected",
                         class = "btn-outline-secondary"),
          downloadButton("download_all_zip", "Download all (.zip)",
                         class = "btn-primary")),
      div(class = "fs-hint",
          "Click a row to select it, then \"Download selected\" - or grab every ",
          "output for this subject at once as a .zip."),
      DTOutput("files_table")
    )
  )
)

server <- function(input, output, session) {

  state <- reactiveValues(log = "", subject_id = NULL, last_step = NULL, upload_reset = 0)

  append_log <- function(header, res) {
    lines <- res$output
    isolate({
      state$log <- paste0(state$log, "\n\n### ", header, " ###\n", lines)
    })
  }

  current_project <- reactive(input$project_dir)

  observeEvent(input$prep_project, {
    dir.create(current_project(), recursive = TRUE, showWarnings = FALSE)
    copied <- ensure_project(current_project(), PIPELINE_ROOT)
    msg <- if (length(copied)) paste("Copied:", paste(copied, collapse = ", "))
           else "Project already has all three step scripts - nothing copied."
    state$log <- paste0(state$log, "\n\n### Prepare project ###\n", msg)
    showNotification(msg, type = "message")
  })

  output$raw_file_picker <- renderUI({
    input$prep_project; input$upload  # re-list after either
    files <- tryCatch(list_raw_files(current_project()), error = function(e) character(0))
    selectInput("raw_file", "Raw .xlsx in project root", choices = files)
  })

  # The fileInput lives behind a uiOutput so it can be redrawn from scratch
  # after each upload - the only way to clear Shiny's "file chosen" display,
  # since fileInput has no server-side reset of its own.
  output$upload_ui <- renderUI({
    state$upload_reset
    fileInput("upload", "Upload a raw Oxysoft .xlsx export", accept = ".xlsx")
  })

  observeEvent(input$upload, {
    req(input$upload)
    dir.create(current_project(), recursive = TRUE, showWarnings = FALSE)
    dest <- file.path(current_project(), input$upload$name)
    file.copy(input$upload$datapath, dest, overwrite = TRUE)
    showNotification(paste("Uploaded", input$upload$name, "into project root."), type = "message")
    state$upload_reset <- state$upload_reset + 1
  })

  subject_from_raw <- reactive({
    req(input$raw_file)
    tools::file_path_sans_ext(input$raw_file)
  })

  output$subject_picker <- renderUI({
    input$run_clean; input$run_all
    subs <- tryCatch(list_cleaned_subjects(current_project()), error = function(e) character(0))
    selectInput("view_subject", "Cleaned subjects", choices = subs)
  })

  observeEvent(input$view_subject, {
    req(input$view_subject)
    state$subject_id <- input$view_subject
  })

  output$pkg_check <- renderTable({
    check_r_packages()
  }, striped = TRUE, spacing = "xs")

  do_clean <- function() {
    req(input$raw_file)
    res <- run_step("clean", input$raw_file, current_project())
    append_log("Clean", res)
    state$subject_id <- subject_from_raw()
    res
  }
  do_analyse <- function() {
    req(state$subject_id)
    res <- run_step("analyse", state$subject_id, current_project())
    append_log("Analyse", res)
    res
  }
  do_plot <- function() {
    req(state$subject_id)
    res <- run_step("plot", state$subject_id, current_project())
    append_log("Plot", res)
    res
  }

  observeEvent(input$run_clean,   { withProgress(message = "Cleaning...",   do_clean())   })
  observeEvent(input$run_analyse, { withProgress(message = "Analysing...",  do_analyse()) })
  observeEvent(input$run_plot,    { withProgress(message = "Plotting...",   do_plot())    })
  observeEvent(input$run_all, {
    withProgress(message = "Running full pipeline...", value = 0, {
      incProgress(0.05, detail = "clean")
      c1 <- do_clean()
      incProgress(0.4, detail = "analyse")
      if (isTRUE(c1$ok)) do_analyse()
      incProgress(0.4, detail = "plot")
      if (!is.null(state$subject_id)) do_plot()
      incProgress(0.15)
    })
  })

  output$console <- renderUI({
    lines <- strsplit(state$log, "\n")[[1]]
    spans <- lapply(lines, function(l) {
      cls <- if (grepl("^\\[WARNING\\]", l)) "console-warning"
             else if (grepl("^\\[NOTE\\]", l)) "console-note"
             else ""
      tags$span(class = cls, paste0(l, "\n"))
    })
    tags$pre(class = "console", spans)
  })

  fit_data <- reactive({
    req(state$subject_id)
    read_recovery_fit(current_project(), state$subject_id)
  })

  qc_data <- reactive({
    req(state$subject_id)
    read_qc_report(current_project(), state$subject_id)
  })

  primary_fit_row <- reactive({
    d <- fit_data()
    req(d)
    d[d$signal == "HHb" & d$correction == "corrected", ]
  })

  output$qc_table <- renderDT({
    req(qc_data())
    datatable(qc_data(), options = list(pageLength = 10, dom = "t"))
  })

  output$fit_table <- renderDT({
    req(fit_data())
    d <- fit_data()
    num_cols <- c("Rest", "Delta", "End", "Tc", "k", "r_squared", "resting_mVO2", "beta")
    d[num_cols] <- lapply(d[num_cols], round, 4)
    datatable(d, options = list(pageLength = 10, dom = "t"))
  })

  output$tc_stats <- renderUI({
    primary <- primary_fit_row()
    req(nrow(primary) == 1)
    flags <- plausibility_flags(primary)
    bad  <- any(grepl("negative|below 0.8|implausibly|outside the typical", flags))
    warn <- any(grepl("Tc = NA", flags))
    tc_cls <- if (bad) "flag-bad" else if (warn) "flag-warn" else "flag-ok"

    stat <- function(label, value, note = NULL, cls = NULL) {
      div(class = "fs-stat",
          div(class = "fs-stat-label", label),
          div(class = paste(c("fs-stat-value", cls), collapse = " "), value),
          if (!is.null(note)) div(class = "fs-stat-note", note))
    }
    div(
      class = "fs-stat-row",
      stat("Tc", if (is.na(primary$Tc)) "NA" else paste0(fmt_num(primary$Tc, 1), " s"),
           "time constant (HHb, corrected)", tc_cls),
      stat("k = 1/Tc", if (is.na(primary$k)) "NA" else fmt_num(primary$k, 4), "per second"),
      stat("R²", fmt_num(primary$r_squared, 3), "fit quality"),
      stat("Converged", if (isTRUE(primary$converged)) "Yes" else "No")
    )
  })

  output$plausibility <- renderUI({
    req(fit_data())
    primary <- primary_fit_row()
    flags <- plausibility_flags(primary)
    tags$ul(lapply(flags, function(f) {
      cls <- if (grepl("negative|below 0.8|implausibly|outside the typical", f)) "flag-bad"
             else if (grepl("Tc = NA", f)) "flag-warn"
             else "flag-ok"
      tags$li(class = cls, f)
    }))
  })

  output$fig6_img <- renderUI({
    req(state$subject_id)
    f <- file.path(current_project(), "analysis_STEP",
                    paste0(state$subject_id, "_fig6_mvo2_recovery_fit.png"))
    if (!file.exists(f)) return(div(class = "info-box", "Not generated yet - run Analyse."))
    tags$img(src = base64_img(f), style = "max-width:100%;")
  })

  output$figs_gallery <- renderUI({
    req(state$subject_id)
    names <- c("fig1_protocol_overview", "fig2_recovery_series", "fig3_cuff_magnification",
               "fig4_resting_occlusion", "fig5_probe_comparison")
    cards <- lapply(names, function(n) {
      f <- file.path(current_project(), "plotting_STEP", paste0(state$subject_id, "_", n, ".png"))
      if (!file.exists(f)) return(NULL)
      title <- tools::toTitleCase(gsub("_", " ", sub("^fig[0-9]+_", "", n)))
      bslib::card(bslib::card_header(title), tags$img(src = base64_img(f), style = "max-width:100%;"))
    })
    cards <- Filter(Negate(is.null), cards)
    if (!length(cards)) return(div(class = "info-box", "Not generated yet - run Plot."))
    do.call(bslib::layout_column_wrap, c(list(width = "400px"), cards))
  })

  # Full paths behind the Output files tab - shared by the table and both
  # downloadHandlers so "row 3 in the table" and "row 3 in this vector" never
  # drift apart.
  output_files <- reactive({
    req(state$subject_id)
    dirs <- file.path(current_project(), c("cleaning_STEP", "analysis_STEP", "plotting_STEP"))
    files <- unlist(lapply(dirs, function(d) {
      if (!dir.exists(d)) return(character(0))
      f <- list.files(d, pattern = state$subject_id, full.names = TRUE)
      f[grepl(paste0("^", state$subject_id), basename(f))]
    }))
    files
  })

  output$files_table <- renderDT({
    files <- output_files()
    if (!length(files)) return(datatable(data.frame(file = character(0))))
    info <- file.info(files)
    datatable(data.frame(file = sub(paste0(current_project(), "/"), "", files),
                          bytes = info$size, modified = format(info$mtime)),
              selection = "single",
              options = list(pageLength = 15, dom = "t"))
  })

  output$download_selected_file <- downloadHandler(
    filename = function() {
      sel <- input$files_table_rows_selected
      req(sel)
      basename(output_files()[sel])
    },
    content = function(file) {
      sel <- input$files_table_rows_selected
      req(sel)
      file.copy(output_files()[sel], file, overwrite = TRUE)
    }
  )

  output$download_all_zip <- downloadHandler(
    filename = function() paste0(state$subject_id, "_outputs.zip"),
    content = function(file) {
      files <- output_files()
      req(length(files) > 0)
      # Stage under <step>/<filename> so the zip mirrors the project layout
      # instead of embedding this machine's absolute temp-dir path.
      stage <- file.path(tempdir(), paste0("fitscope_zip_", as.integer(Sys.time())))
      dir.create(stage)
      on.exit(unlink(stage, recursive = TRUE), add = TRUE)
      step_dir <- basename(dirname(files))
      for (i in seq_along(files)) {
        dst_dir <- file.path(stage, step_dir[i])
        dir.create(dst_dir, showWarnings = FALSE)
        file.copy(files[i], file.path(dst_dir, basename(files[i])))
      }
      old_wd <- setwd(stage)
      on.exit(setwd(old_wd), add = TRUE)
      # zip::zipr's default "cherry-pick" mode flattens individual file paths
      # to the archive root - pass the step directories themselves so it
      # recurses and keeps the cleaning_STEP/analysis_STEP/plotting_STEP layout.
      zip::zipr(zipfile = file, files = list.dirs(".", recursive = FALSE))
    }
  )

  base64_img <- function(path) {
    ext <- tools::file_ext(path)
    raw <- readBin(path, "raw", file.info(path)$size)
    paste0("data:image/", ext, ";base64,", base64enc::base64encode(raw))
  }
}

shinyApp(ui, server)
