import json
import requests
import sys
import os

CONFIG_FILE = 'config.json'
SARIF_DIR = 'sarif_downloads'

# Load config
def load_config():
    with open(CONFIG_FILE, 'r') as f:
        return json.load(f)

def get_github_headers(token):
    return {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/vnd.github+json'
    }

def get_repo_info():
    repo = input('Enter the GitHub repository (owner/repo): ').strip()
    return repo

def list_codeql_analyses(repo, headers):
    url = f'https://api.github.com/repos/{repo}/code-scanning/analyses?per_page=100'
    resp = requests.get(url, headers=headers)
    if resp.status_code != 200:
        print(f'Error fetching analyses: {resp.status_code} {resp.text}')
        sys.exit(1)
    return resp.json()

def group_analyses(analyses):
    sets = {}
    seen = set()
    for a in analyses:
        ref = a.get('ref', 'unknown')
        tool = a.get('tool', {}).get('name', 'unknown')
        created_at = a.get('created_at', 'unknown')
        commit_sha = a.get('commit_sha', 'unknown')
        category = a.get('category', 'unknown')
        # Only consider unique (ref, commit_sha, category)
        unique_key = (ref, commit_sha, category)
        if unique_key in seen:
            continue
        seen.add(unique_key)
        set_key = f'ref: {ref} | commit: {commit_sha}'
        sets.setdefault(set_key, []).append({
            'tool': tool,
            'created_at': created_at,
            'ref': ref,
            'commit_sha': commit_sha,
            'category': category,
            'analysis': a
        })
    return sets

def choose_set(sets):
    print('\nAvailable scan sets:')
    for i, (set_key, items) in enumerate(sets.items()):
        print(f'{i+1}. {set_key} ({len(items)} runs)')
        for j, item in enumerate(items):
            print(f'    - Run {j+1}: Date: {item["created_at"]}, Tool: {item["tool"]}, Category: {item["category"]}')
    idx = int(input('Select a set to download SARIF from (number): ')) - 1
    set_key = list(sets.keys())[idx]
    return set_key, sets[set_key]

def download_sarif(repo, analyses, headers):
    import re
    os.makedirs(SARIF_DIR, exist_ok=True)
    sarif_runs = []
    owner_repo = repo.replace('/', '_')
    if not analyses:
        print('No analyses to download.')
        return
    # Use ref and date from the first run
    ref = analyses[0]['ref']
    date = analyses[0]['created_at'].replace(':', '').replace('-', '').replace('T', '').replace('Z', '')
    # Clean ref for filename
    ref_clean = re.sub(r'[^a-zA-Z0-9_\-]', '_', ref)
    combined_sarif_path = os.path.join(SARIF_DIR, f'codeql_sarif_{owner_repo}_{ref_clean}_{date}.json')
    for item in analyses:
        a = item['analysis']
        analysis_id = a['id']
        url = f'https://api.github.com/repos/{repo}/code-scanning/analyses/{analysis_id}'
        sarif_headers = headers.copy()
        sarif_headers['Accept'] = 'application/sarif+json'
        resp = requests.get(url, headers=sarif_headers)
        if resp.status_code != 200:
            print(f'Error downloading SARIF for analysis {analysis_id}: {resp.status_code}')
            print(f'Response: {resp.text}')
            continue
        sarif_json = resp.json()
        if 'runs' in sarif_json:
            sarif_runs.extend(sarif_json['runs'])
        # Save each SARIF individually as before
        out_file = os.path.join(SARIF_DIR, f'sarif_{analysis_id}.json')
        with open(out_file, 'w', encoding='utf-8') as f:
            json.dump(sarif_json, f, indent=2)
        print(f'Downloaded SARIF to {out_file}')
    # Combine all runs into one SARIF file
    combined_sarif = {
        'version': '2.1.0',
        'runs': sarif_runs
    }
    with open(combined_sarif_path, 'w', encoding='utf-8') as f:
        json.dump(combined_sarif, f, indent=2)
    print(f'Combined SARIF written to {combined_sarif_path}')

def main():
    config = load_config()
    token = config['github_pat']
    headers = get_github_headers(token)
    repo = get_repo_info()
    analyses = list_codeql_analyses(repo, headers)
    sets = group_analyses(analyses)
    origin, chosen_analyses = choose_set(sets)
    print(f'\nDownloading SARIF for set: {origin}')
    download_sarif(repo, chosen_analyses, headers)

if __name__ == '__main__':
    main()
