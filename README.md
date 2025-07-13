
# CodeSparkR

**Supercharge your R workflow with AI-powered coding assistance.**

Access 400+ large language models (including premium ones) directly from your R console and get instant, executable code. No more copy-pasting or context switching—just pure productivity.

✨ **What makes CodeSparkR special:**
- 🤖 **400+ LLMs at your fingertips** – Including paid models, all accessible from R
- 📝 **Ready-to-run code chunks** – Responses come as `.Rmd` files you can execute immediately  
- 🔗 **Smart context handling** – Attach files directly, no more massive copy-paste sessions
- 🎯 **RStudio integration** – Save and open AI responses as `.Rmd` files seamlessly
- ⚡ **Streamlined workflow** – From prompt to production code in seconds

Perfect for data scientists, analysts, and R developers who want to leverage AI without breaking their flow.

---


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

## 🔐 API Key Setup

To use CodeSparkR, you’ll need an **OpenRouter API key**.

### Step 1: Get Your OpenRouter API Key

1. Go to [https://openrouter.ai/account](https://openrouter.ai/account)
2. Sign in or create an account.
3. Create and copy your API key from the **Settings > API Keys** section.



### Step 2: Set the API Key in Your R Environment

You have two ways to store the key securely:

#### ✅ Option 1 (Recommended): Add to `.Renviron`

1. Open (or create) a file named `.Renviron` in your R home or project directory.

2. Add this line (replace with your actual key):

   ```
   OPENROUTER_API_KEY="your_key"
   ```

3. Save and restart your R session for the change to take effect.

💡 Tip: You can run `usethis::edit_r_environ()` to open `.Renviron` in RStudio.



#### ⚠️ Option 2: Set Temporarily with `Sys.setenv()`

```r
Sys.setenv(OPENROUTER_API_KEY = "your_actual_key_here")
```

Note: This works only for the current session and is not persistent.


Once the key is set, you can use `ask_ai()`.

### 💳 Accessing Paid Models (BYOK)

By default, your OpenRouter API key gives access to **free-tier models**.

To use **paid models** like Claude, Gemini, GPT or others, follow these steps:

1. Visit the official website of the model you want to use (e.g., Anthropic, Google, OpenAI).
2. Sign in and generate an API key from your account on that platform.
3. Go to [OpenRouter Integrations](https://openrouter.ai/settings/integrations).
4. Paste the API key you obtained into the appropriate provider field (e.g., OpenAI, Google, etc.).

Once set, OpenRouter will automatically use your provider-specific keys when calling those models.


### 🔹 View Available Models

To view the full list of supported models (over 400+ from 60+ providers), visit:
[https://openrouter.ai/models](https://openrouter.ai/models)

You can also:

* Use the search bar to filter models by name, provider, or feature.
* Type `free` into the search box to quickly list **free models**.



## 🚀 Functions

### `ask_ai(prompt, model, context_files, ...)`

Send a prompt to a supported OpenRouter model with advanced options.

**Arguments:**

* `prompt`: A character string with your question or instruction.
* `model`: Optional character. The model name (e.g., `"google/gemini-2.5-pro"`). If `NULL`, the function will prompt interactively for the model name. A complete list of available models can be found at: https://openrouter.ai/models
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
ask_ai(
  prompt = "Summarize the key differences between these two R scripts.",
  model = "google/gemini-2.0-pro",
  context_files = c("script1.R", "script2.R")
)
```
For more examples, visit code [Wiki Page](https://github.com/shanptom/CodeSparkR/wiki).

## 🧩 Dependencies

This package uses:

* `httr`
* `jsonlite`
* `stringr`
* `magrittr`
* `tools`

