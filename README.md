# CodeQL SARIF Downloader

This tool helps you download and combine CodeQL SARIF reports from GitHub for a given repository, branch/PR, and commit. It is useful for extracting multi-language CodeQL scan results and producing a single SARIF file for further processing or integration.

## Prerequisites
- Python 3.7+
- A GitHub Personal Access Token (PAT) with the following scopes:
  - `repo` (for private repositories)
  - `security_events`

## Setup
1. **Generate a GitHub Personal Access Token (PAT):**
   - Go to [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
   - Click "Generate new token"
   - Select the following scopes:
     - `repo` (for private repos; not required for public repos)
     - `security_events`
   - Copy the generated token (you will use it in the next step)

2. **Edit `config.json`:**
   - Open `config.json` in this directory.
   - Replace the placeholder value with your PAT:
     ```json
     {
       "github_pat": "YOUR_GITHUB_PAT_HERE"
     }
     ```

3. **Install dependencies:**
   ```sh
   pip install -r requirements.txt
   ```

4. **Run the script:**
   ```sh
   python generate_sarif_from_github_codeql.py
   ```

## Usage
- Enter the repository in `owner/repo` format (e.g., `antonychiu2/codeql-mobb-fixer-integration`).
- The script will list all available CodeQL scan sets, grouped by branch/PR and commit.
- Each set shows the scan date, tool, and language category.
- Select the set number you want to download.
- The script will download all SARIF files for that set and combine them into a single SARIF file in the `sarif_downloads` directory.

## Example Demo

```
$ python generate_sarif_from_github_codeql.py
Enter the GitHub repository (owner/repo): antonychiu2/codeql-mobb-fixer-integration

Available scan sets:
1. ref: refs/heads/CodeQL | commit: 39bd235d5657c595f2e23a7c0356e81f5fa22c94 (3 runs)
    - Run 1: Date: 2025-06-20T09:50:07Z, Tool: CodeQL, Category: /language:java-kotlin
    - Run 2: Date: 2025-06-20T09:49:36Z, Tool: CodeQL, Category: /language:javascript-typescript
    - Run 3: Date: 2025-06-20T09:49:26Z, Tool: CodeQL, Category: /language:actions
...
Select a set to download SARIF from (number): 1

Downloading SARIF for set: ref: refs/heads/CodeQL | commit: 39bd235d5657c595f2e23a7c0356e81f5fa22c94
Downloaded SARIF to sarif_downloads/sarif_537505567.json
Downloaded SARIF to sarif_downloads/sarif_537504982.json
Downloaded SARIF to sarif_downloads/sarif_537504820.json
Combined SARIF written to sarif_downloads/codeql_sarif_antonychiu2_codeql-mobb-fixer-integration_refs_heads_CodeQL_20250620095007.json
```

## Output
- Individual SARIF files: `sarif_downloads/sarif_<analysis_id>.json`
- Combined SARIF file: `sarif_downloads/codeql_sarif_<owner_repo>_<ref>_<date>.json`

## Notes
- The combined SARIF file merges all `runs` from the selected set, matching the logic used in the GitHub Action workflow.
- The script only lists and downloads CodeQL analyses (not other tools).
- If you encounter errors, check your PAT permissions and repository visibility.


