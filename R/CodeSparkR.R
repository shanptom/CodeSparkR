# CodeSparkR_openrouter.R

# Required libraries
library(httr)
library(jsonlite)
library(stringr)
library(magrittr)

# Null-coalescing operator
`%||%` <- function(a, b) if (is.null(a)) b else a

# Helper: string concatenation
`%+%` <- function(a, b) paste0(a, b)


#' Ask AI Model with Multiple Context Files
#'
#' Sends a prompt to a AI model using the OpenRouter API, with support for multiple context files and advanced options.
#'
#' @param prompt Character. The prompt or instruction for the model.
#' @param model Optional character. The model name (e.g., `"google/gemini-2.0-pro"`). Prompts interactively if NULL.
#' A complete list of available models can be found at: https://openrouter.ai/models
#' @param context_files Optional character vector. File paths to one or more context files.
#' @param save_to_file Logical. If TRUE, saves the output to a .Rmd file. Default is FALSE.
#' @param filename Optional character. Filename to save the output if `save_to_file = TRUE`.
#' @param format_output Logical. Whether to clean and print the response to console. Default is TRUE.
#' @param return_cleaned Logical. If TRUE, returns cleaned text. If FALSE, returns raw output. Default is TRUE.
#' @param custom_timeout Optional numeric. Timeout in seconds. Auto-computed if NULL.
#' @param open_file Logical. Whether to open the Rmd file after saving (interactive mode only). Default is FALSE.
#'
#' @return Invisibly returns the model response as a character string (cleaned or raw based on `return_cleaned`).
#' @export
#'
#' @examples
#' # Example using all options
#' \dontrun{
#' # Create dummy context files for the example
#' writeLines("This is the content of file1.", "file1.txt")
#' writeLines("This is the content of file2.", "file2.md")
#'
#' # Use ask_ai with all parameters
#' response <- ask_ai(
#'   prompt = "Summarize the content of the provided files.",
#'   model = "google/gemini-2.0-flash", # Replace with a valid model if needed
#'   context_files = c("file1.txt", "file2.md"),
#'   save_to_file = TRUE,
#'   filename = "summary_response.Rmd",
#'   format_output = TRUE,
#'   return_cleaned = TRUE,
#'   custom_timeout = 180,
#'   open_file = FALSE # Set to TRUE to open the file after saving
#' )
#'
#' # Print the cleaned response
#' print(response)
#'
#' # Clean up dummy files
#' unlink(c("file1.txt", "file2.md", "summary_response.Rmd"))
#' }
#'
ask_ai <- function(prompt,
                       model = NULL,
                       context_files = NULL,
                       save_to_file = FALSE,
                       filename = NULL,
                       format_output = TRUE,
                       return_cleaned = TRUE,
                       custom_timeout = NULL,
                       open_file = FALSE) {
  # Ask for model if not provided
  if (is.null(model)) {
    cat("Enter model (e.g. deepseek/deepseek-chat-v3-0324:free): ")
    model <- readline()
  }

  # Get API keys
  api_key <- Sys.getenv("OPENROUTER_API_KEY")
  if (api_key == "") {
    stop("Please set OPENROUTER_API_KEY via Sys.setenv() or .Renviron")
  }


  # Add context if applicable
  final_prompt <- prompt
  total_context_size <- 0
  context_parts <- c()

  if (!is.null(context_files)) {
    for (f in context_files) {
      if (file.exists(f)) {
        txt <- paste(readLines(f, warn = FALSE), collapse = "\n")
        ext <- tools::file_ext(f)
        type <- switch(tolower(ext),
                       "r" = "R", "py" = "Python", "sql" = "SQL", "csv" = "CSV",
                       "txt" = "Text", "md" = "Markdown", "json" = "JSON", "Unknown")
        chunk_start <- if (tolower(ext) == "r") "```{r}" else paste0("```", ext)
        context_parts <- c(context_parts, paste0(
          "File: ", basename(f), " (", type, ")\n",
          chunk_start, "\n", txt, "\n```\n"
        ))
        total_context_size <- total_context_size + nchar(txt)
      } else {
        warning("File not found: ", f)
      }
    }
  }

  if (length(context_parts) > 0) {
    final_prompt <- paste0(
      "Context: I'm providing ", length(context_parts), " file(s).\n\n",
      paste(context_parts, collapse = "\n"),
      "\nBased on this context, please help with the following:\n",
      prompt
    )
  }

  # Adaptive timeout
  total_size <- nchar(final_prompt)
  timeout_seconds <- if (!is.null(custom_timeout)) {
    custom_timeout
  } else if (total_size <= 10000) {
    120
  } else if (total_size <= 50000) {
    120 + ceiling((total_size - 10000) / 5000) * 15
  } else {
    min(240 + ceiling((total_size - 50000) / 25000) * 30, 900)
  }

  cat("📊 Content size:", format(total_size, big.mark = ","), "characters\n")
  cat("📁 Context size:", format(total_context_size, big.mark = ","), "characters\n")
  cat("🕒 Timeout set to:", timeout_seconds, "seconds\n")

  # Prepare message
  messages <- list(list(role = "user", content = final_prompt))

  # Prepare request
  url <- "https://openrouter.ai/api/v1/chat/completions"
  headers <- c(
    "Authorization" = paste("Bearer", api_key),
    "Content-Type" = "application/json",
    "HTTP-Referer" = "https://github.com/shanptom/chatR",
    "X-Title" = "CodeSparkR"
  )

  body <- list(
    model = model,
    messages = messages,
    max_tokens = 4096,
    temperature = 0.7
  )

  # POST request with retries
  res <- NULL
  max_retries <- 3
  for (i in 1:max_retries) {
    cat("🔄 Request attempt", i, "\n")
    res <- try(
      httr::POST(
        url,
        httr::add_headers(.headers = headers),
        body = jsonlite::toJSON(body, auto_unbox = TRUE),
        encode = "raw",
        httr::timeout(timeout_seconds + (i - 1) * 60)
      ),
      silent = TRUE
    )

    if (!inherits(res, "try-error") && httr::status_code(res) == 200) {
      break # Success, exit loop
    } else {
      if (i < max_retries) {
        cat("Attempt", i, "failed. Retrying in", i * 2, "seconds...\n")
        Sys.sleep(i * 2)
      } else {
        # Last attempt failed, handle error
        if (inherits(res, "try-error")) {
          stop("❌ API request failed after ", max_retries, " attempts: ", attr(res, "condition")$message)
        } else {
          stop("❌ API request failed after ", max_retries, " attempts with status code ", httr::status_code(res), ": ", httr::content(res, "text", encoding = "UTF-8"))
        }
      }
    }
  }

  # Parse response
  result <- httr::content(res, "parsed", encoding = "UTF-8")
  if (!"choices" %in% names(result) || length(result$choices) == 0 || is.null(result$choices[[1]]$message$content)) {
    stop("Unexpected or empty response format from API.")
  }
  raw_text <- result$choices[[1]]$message$content

  cleaned_text <- raw_text |>
    stringr::str_remove_all("^```[a-zA-Z]*\\s*|```$") |>
    stringr::str_replace_all("\\\\n", "\n") |>
    stringr::str_replace_all('\\"', '"') |>
    stringr::str_replace_all("\\\\t", "\t") |>
    stringr::str_replace_all("\n{3,}", "\n\n") |>
    stringr::str_replace_all("(?m)^```r(\\s*$)", "```{r}\\1") |>
    stringr::str_trim()

  if (format_output) {
    line <- paste(rep("=", 80), collapse = "")
    cat("\n", line, "\n🤖 AI RESPONSE\n", line, "\n\n", sep = "")
    cat(cleaned_text, "\n\n", line, "\n")
    cat("✅ Generated at:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")

    if (save_to_file) {
      if (is.null(filename)) {
        filename <- paste0("AI_Response_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".Rmd")
      }

      contains_codeblock <- grepl("```", cleaned_text, fixed = TRUE)

      response_chunk <- if (contains_codeblock) {
        paste0("## Response\n\n", cleaned_text)
      } else {
        is_r_code <- grepl(
          "function\\s*\\(|<-|\\bplot\\s*\\(|\\bggplot\\s*\\(|\\blm\\s*\\(|data\\.frame\\s*\\(|read\\.csv",
          cleaned_text
        )
        chunk_start <- if (is_r_code) "```{r}" else "```"
        chunk_end <- "```"

        paste0("## Response\n\n", chunk_start, "\n", cleaned_text, "\n", chunk_end)
      }

      md <- paste0(
        "---\n",
        "title: \"AI Response\"\n",
        "date: \"", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\"\n",
        "output: html_document\n",
        "---\n\n",
        "## Prompt\n\n", substr(prompt, 1, 300), ifelse(nchar(prompt) > 300, "...", ""), "\n\n",
        "## Context Files\n\n",
        if (length(context_files) > 0) paste("- ", basename(context_files), collapse = "\n") else "No context files provided", "\n\n",
        response_chunk
      )

      writeLines(md, filename)
      cat("💾 Saved to", filename, "\n")

      if (open_file && interactive()) {
        file.edit(filename)
      }
    }
  }

  if (return_cleaned) {
    invisible(cleaned_text)
  } else {
    invisible(raw_text)
  }
}
