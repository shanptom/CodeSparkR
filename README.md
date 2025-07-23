
# CodeSparkR

**Supercharge your R workflow with AI-powered coding assistance.**

Access large language models (including premium ones) directly from your R console and get instant, executable code. No more copy-pasting or context switching—just pure productivity.

-  **400+ LLMs** – Including paid models, all accessible from R
-  **Ready-to-run code chunks** – Responses come as `.Rmd` files you can execute immediately  
-  **Smart context handling** – Attach files directly, no more massive copy-paste sessions
-  **RStudio integration** – Save and open AI responses as `.Rmd` files seamlessly
-  **Streamlined workflow** – From prompt to production code in seconds

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
then in R:

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

####  Option 1 (Recommended): Add to `.Renviron`

1. Open (or create)  `.Renviron` in your R home or project directory.

2. Add this line (replace *"your_key"* with your actual key):

   ```
   OPENROUTER_API_KEY="your_key"
   ```

3. Save and restart your R session for the change to take effect.

   >  You can run `usethis::edit_r_environ()` to open `.Renviron` in RStudio.



####  Option 2: Set Temporarily with `Sys.setenv()`

   1. Run the following (replace *"your_key"* with your actual key):
      
      ```
        Sys.setenv(OPENROUTER_API_KEY = "your_key")
      ```

      > This works only for the current session and is not persistent.


Once the key is set, you can use `ask_ai()`.


## 💳 Accessing Paid Models (BYOK)

By default, your OpenRouter API key gives access to **free-tier models**.

To use **paid models** like Claude, Gemini, GPT, or others, follow these steps:

1. Visit the official website of the model you want to use (e.g., Anthropic, Google, OpenAI).
2. Sign in and generate an API key from your account on that platform.
3. Go to [OpenRouter Integrations](https://openrouter.ai/settings/integrations).
4. Paste the API key you obtained into the appropriate provider field (e.g., OpenAI, Google, etc.).

Once set, OpenRouter will automatically use your provider-specific keys when calling those models.

---

## 🔹 View Available Models

The `getModel_list()` function retrieves the full list of available large language models (LLMs) from the OpenRouter. By default, it lists all models, but users can provide a search string (e.g., "free", "claude", "gpt") to filter and display only those that match the query. This is particularly useful for identifying free-to-use models, which can be selected by calling `getModel_list("free")`. Users can then browse the results and manually choose a specific model ID to use in the model argument of `ask_ai()`. Note that while the function may return multiple matches, only one model ID should be used at a time when querying the API. This utility helps streamline model selection and ensures compatibility with OpenRouter's evolving model catalog.

```r

# List all models
getModel_list()

# List only free-to-use models
free_models <- getModel_list("free")

# Use a selected model with ask_ai()
ask_ai(
  prompt = "Summarize the concept of phylogenetic diversity",
  model = free_models[1]
)

```

## 🚀 Function: `ask_ai(prompt, model, context_files, ...)`

Send a prompt to a supported OpenRouter model with advanced options.

**Arguments:**

* `prompt`: A character string with your question or instruction.
* `model`: Optional character. The model name (e.g., `"google/gemini-2.5-pro"`). If `NULL`, the function will prompt interactively for the model name. 
* `context_files`: Optional character vector. File paths to one or more context files.
* `save_to_file`: Logical. If `TRUE`, saves the output to an `.Rmd` file. Default is `FALSE`.
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

**Example:**

```r
ask_ai(
  prompt = "Summarize the key differences between these two R scripts.",
  model = "google/gemini-2.0-pro",
  context_files = c("script1.R", "script2.R")
)
```

### `ask_ai2(prompt, model, context_files, ..., use_context = TRUE, system_prompt = NULL, role = "user")`

Sends a prompt to an AI model using the OpenRouter API with persistent conversation memory. This function maintains chat history across calls and supports the same features as `ask_ai()`.

**Key Difference from `ask_ai()`:** `ask_ai2()` maintains a persistent chat history and allows for setting a background context, enabling multi-turn conversations and more nuanced interactions with the AI model.

**Arguments:**

* `prompt`: Character. The prompt or instruction for the model.
* `model`: Optional character. The model name (e.g., `"google/gemini-2.5-pro"`). Prompts interactively if `NULL`.
* `context_files`: Optional character vector. File paths to one or more context files.
* `save_to_file`: Logical. If `TRUE`, saves the output to a .Rmd file. Default is `FALSE`.
* `filename`: Optional character. Filename to save the output if `save_to_file = TRUE`.
* `format_output`: Logical. Whether to clean and print the response to console. Default is `TRUE`.
* `return_cleaned`: Logical. If `TRUE`, returns cleaned text. If `FALSE`, returns raw output. Default is `TRUE`.
* `custom_timeout`: Optional numeric. Timeout in seconds. Auto-computed if `NULL`.
* `open_file`: Logical. Whether to open the Rmd file after saving (interactive mode only). Default is `FALSE`.
* `use_context`: Logical. Whether to include persistent context set via `set_context()`. Default is `TRUE`.
* `system_prompt`: Optional character. System prompt to prepend to the conversation.
* `role`: Character. Role for the current message ("user", "assistant", "system"). Default is "user".

**Example:**

```r
# Start a conversation
ask_ai2(prompt = "Hello, what is the capital of France?", model = "google/gemini-2.0-flash")


# Continue the conversation, model remembers previous turns
ask_ai2(prompt = "And what is the main river flowing through it?", model = "google/gemini-2.0-flash")


# Clear chat history
clear_chat()
```

### `set_context(content, id = "codespark_context", metadata = list())`

Sets a persistent background context for the current R session. This context will be included in all subsequent `ask_ai2()` calls where `use_context` is `TRUE`.

**Arguments:**

* `content`: Character. The text content to set as the background context.
* `id`: Optional character. A unique identifier for the context. Default is `"codespark_context"`.
* `metadata`: Optional list. Additional metadata associated with the context.

**Example:**

```r
set_context("The user is a data scientist working with R and Python.")
response <- ask_ai2(prompt = "Suggest a good library for data visualization.", model = "google/gemini-2.0-flash")
print(response)
```

### `clear_context()`

Clears the currently set persistent background context.

**Example:**

```r
clear_context()
```

### `show_context()`

Shows the currently set persistent background context.

**Returns:** A list containing the context details (id, type, content, metadata) or `NULL` if no context is set.

**Example:**

```r
show_context()
```

### `clear_chat()`

Clears the running chat history for `ask_ai2()`.

**Example:**

```r
clear_chat()
```

### `show_chat()`

Shows the current chat history for `ask_ai2()`.

**Returns:** A list of messages representing the conversation history.

**Example:**

```r
show_chat()
```


## 🧩 Dependencies

This package uses:

* `httr`
* `jsonlite`
* `stringr`
* `tools`
