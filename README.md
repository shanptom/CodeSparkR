# CodeSparkR

A lightweight R interface to query AI models via the [OpenRouter](https://openrouter.ai) API. This package allows you to send prompts to AI models and receive responses, with options for context files, and markdown output.

## 📦 Installation

Install the development version directly from GitHub:

```r
# install.packages("devtools")
devtools::install_github("shanptom/codesparkr")
```

Or, clone the repo and install locally:

```bash
git clone https://github.com/shanptom/CodeSparkR.git
cd CodeSparkR
```

```r
devtools::install()
```

## 🚀 Functions

### `ask_aiPro(prompt, model, context_files, ...)`

Send a prompt to a supported OpenRouter model with advanced options.

**Arguments:**

* `prompt`: A character string with your question or instruction.
* `model`: Optional character. The model name (e.g., `"google/gemini-2.0-pro"`). If `NULL`, the function will prompt interactively for the model name. A complete list of available models can be found at: https://openrouter.ai/models
* `context_files`: Optional character vector. File paths to one or more context files.
* `save_to_file`: Logical. If `TRUE`, saves the output to a .Rmd file. Default is `FALSE`.
* `filename`: Optional character. Filename to save the output if `save_to_file = TRUE`.
* `format_output`: Logical. Whether to clean and print the response to console. Default is `TRUE`.
* `return_cleaned`: Logical. If `TRUE`, returns cleaned text. If `FALSE`, returns raw output. Default is `TRUE`.
* `custom_timeout`: Optional numeric. Timeout in seconds. Auto-computed if `NULL`.
* `open_file`: Logical. Whether to open the Rmd file after saving (interactive mode only). Default is `FALSE`.

This function supports:

* Multiple context files
* Smart timeout scaling
* Optional raw or cleaned response return
* Interactive file opening (RStudio)

**Arguments:**

* `prompt`: Main prompt to the model.
* `model`: Model name.
* `context_files`: A character vector of file paths.
* `save_to_file`: Save response to `.Rmd` file.
* `filename`: Custom filename (optional).
* `format_output`: Pretty-print the response in console.
* `return_cleaned`: If `TRUE`, returns a cleaned string.
* `custom_timeout`: Override default timeout logic.
* `open_file`: Open file after saving (interactive mode only).

**Example:**

```r
ask_aiPro(
  prompt = "Summarize the key differences between these two R scripts.",
  model = "google/gemini-2.0-pro",
  context_files = c("script1.R", "script2.R")
)
```

## 🔐 API Key Setup

To use the `ask_aiPro` function (and other functions in this package that interact with OpenRouter), you only need to set your **OpenRouter API Key**.

If you have added API keys for specific models (like Google's Gemini, Anthropic's Claude, etc.) on the OpenRouter website, OpenRouter will automatically use those keys when you select the corresponding model. You **do not** need to set separate environment variables for each model provider in your R environment.

You can set your `OPENROUTER_API_KEY` using one of the following methods:

1.  **Using `.Renviron` file (Recommended):**
    *   Create a file named `.Renviron` in the root directory of your R project (`d:/CodeSparkR`).
    *   Add the following line to the file, replacing `"YOUR_OPENROUTER_API_KEY"` with your actual key:
        ```
        OPENROUTER_API_KEY="YOUR_OPENROUTER_API_KEY"
        ```
    *   Save the file and restart your R session for the changes to take effect.

2.  **Using `Sys.setenv()`:**
    *   You can set the environment variable directly in your R script or console using:
        ```r
        Sys.setenv(OPENROUTER_API_KEY = "YOUR_OPENROUTER_API_KEY")
        ```
    *   Note that this setting is only temporary and will be lost when your R session ends. Using `.Renviron` is generally preferred for persistent settings.

**How to get your OpenRouter API Key:**

You can get your OpenRouter API key on your [OpenRouter Account Page](https://openrouter.ai/account).

## 📄 Output

If `save_to_file = TRUE`, the response will be saved as an R Markdown (`.Rmd`) file with embedded prompt and response.

## 🧩 Dependencies

This package uses:

* `httr`
* `jsonlite`
* `stringr`
* `magrittr`
* `tools`

Make sure these are installed before using.
