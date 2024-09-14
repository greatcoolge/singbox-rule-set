import requests
import datetime
import os

# GitHub API token and repository details
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
REPO_OWNER = 'greatcoolge'
REPO_NAME = 'singbox-rule-set'
WORKFLOW_RUNS_API_URL = f'https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/actions/runs'

# Define the age threshold (e.g., 30 days)
THRESHOLD_DAYS = 1
THRESHOLD_DATE = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(days=THRESHOLD_DAYS)

headers = {
    'Authorization': f'token {GITHUB_TOKEN}',
    'Accept': 'application/vnd.github.v3+json'
}

def delete_old_workflow_runs():
    response = requests.get(WORKFLOW_RUNS_API_URL, headers=headers)
    response.raise_for_status()
    runs = response.json().get('workflow_runs', [])

    for run in runs:
        run_date = datetime.datetime.strptime(run['created_at'], '%Y-%m-%dT%H:%M:%SZ')
        run_date = run_date.replace(tzinfo=datetime.timezone.utc)  # 将 run_date 转换为时区感知的时间
        if run_date < THRESHOLD_DATE:
            run_id = run['id']
            delete_url = f'{WORKFLOW_RUNS_API_URL}/{run_id}'
            delete_response = requests.delete(delete_url, headers=headers)
            if delete_response.status_code == 204:
                print(f'Deleted workflow run {run_id}')
            else:
                print(f'Failed to delete workflow run {run_id}: {delete_response.content}')

if __name__ == '__main__':
    delete_old_workflow_runs()
