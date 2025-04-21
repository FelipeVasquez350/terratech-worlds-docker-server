import os
import re
import sys
from datetime import datetime
import requests
from steam.webapi import WebAPI

STEAM_API_KEY = os.getenv("STEAM_API_KEY")
DOCKER_HUB_API_URL = "https://hub.docker.com/v2"
GAME_APP_ID = 2313330


api = WebAPI(key=STEAM_API_KEY)

def get_all_news(app_id, count=100, maxlength=300):
  try:
    response = api.call(
      'ISteamNews.GetNewsForApp',
      appid=app_id,
      count=count,
      maxlength=maxlength,
      format='json'
    )
    return response.get('appnews', {}).get('newsitems', [])
  except Exception as e:
    print(f"Error fetching news: {e}", file=sys.stderr)
    sys.exit(1)


def parse_patch_notes(news_items):
  latest = {'stable': None, 'beta': None}
  # Updated pattern: requires hyphen immediately after digits for beta versions
  version_pattern = re.compile(r'(\d+\.\d+\.\d+)(-[\w.-]+)?', re.IGNORECASE)

  for item in news_items:
    title = item.get('title', '').strip()
    date_unix = item.get('date', 0)

    # Search for the version pattern anywhere in the title
    match = version_pattern.search(title)
    if match:
      base_version = match.group(1) # e.g., "0.6.2"
      beta_suffix = match.group(2) # e.g., "-unstable" or None

      if beta_suffix:
        # It's a beta version
        branch = 'beta'
        # Combine base version and suffix for the full version string
        full_version = base_version + beta_suffix
      else:
        # It's a stable version
        branch = 'stable'
        full_version = base_version

      # Update the latest version for the detected branch if this one is newer
      if (
        latest[branch] is None or
        date_unix > latest[branch]['date_unix']
      ):
        latest[branch] = {
          'version': full_version,
          'date_unix': date_unix
        }

  return latest

def set_output(name, value):
  with open(os.environ['GITHUB_OUTPUT'], 'a') as fh:
    print(f'{name}={value}', file=fh)

def main():
  news_items = get_all_news(app_id=GAME_APP_ID)
  patch_notes = parse_patch_notes(news_items)

  stable_version = patch_notes['stable']['version'] if patch_notes['stable'] else ""
  beta_version = patch_notes['beta']['version'] if patch_notes['beta'] else ""

  if stable_version:
    print(f"stable_version={stable_version}")
    set_output("stable_version",stable_version)
  else:
    print("stable_version NOT FOUND")
  if beta_version:
    print(f"beta_version={beta_version}")
    set_output("beta_version",beta_version)
  else:
    print("beta_version NOT FOUND")

if __name__ == "__main__":
  main()
