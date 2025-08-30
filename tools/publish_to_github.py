#!/usr/bin/env python3
import json
import os
import subprocess
import sys
import urllib.request
import urllib.error

GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
GITHUB_USER = os.getenv("GITHUB_USER", "yurkoivan")
REPO_NAME = os.getenv("REPO_NAME", "Jellyfin.Plugin.ThePornDB")
TAG = os.getenv("TAG", "v1.6.0.0")
ZIP_PATH = "Jellyfin.Plugin.ThePornDB/bin/Release/Jellyfin.Plugin.ThePornDB.zip"

if not GITHUB_TOKEN:
    print("ERROR: GITHUB_TOKEN not set", file=sys.stderr)
    sys.exit(1)

def gh_api(method, url, data=None, headers=None):
    hdrs = {
        "Authorization": f"Bearer {GITHUB_TOKEN}",
        "Accept": "application/vnd.github+json",
        "User-Agent": "CodexCLI/1.0",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    if headers:
        hdrs.update(headers)
    body = None
    if data is not None:
        body = json.dumps(data).encode("utf-8")
        hdrs.setdefault("Content-Type", "application/json")
    req = urllib.request.Request(url, data=body, headers=hdrs, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            return resp.getcode(), resp.read()
    except urllib.error.HTTPError as e:
        return e.code, e.read()

def repo_exists():
    code, _ = gh_api("GET", f"https://api.github.com/repos/{GITHUB_USER}/{REPO_NAME}")
    return code == 200

def ensure_repo():
    if repo_exists():
        return
    print(f"Creating repo {REPO_NAME} under {GITHUB_USER}...")
    code, body = gh_api("POST", "https://api.github.com/user/repos", {
        "name": REPO_NAME,
        "private": False,
        "description": "Jellyfin 10.10 compatible ThePornDB plugin",
    })
    if code not in (200, 201):
        print(f"ERROR creating repo: {code} {body}")
        sys.exit(1)

def run(cmd):
    subprocess.run(cmd, check=True)

def git_push():
    run(["git", "init", "-q"]) 
    run(["git", "config", "user.name", "Codex CLI"]) 
    run(["git", "config", "user.email", "codex@example.com"]) 
    run(["git", "add", "."]) 
    try:
        run(["git", "commit", "-q", "-m", "feat: Jellyfin 10.10 compatibility (v1.6.0.0)"])
    except subprocess.CalledProcessError:
        pass
    run(["git", "branch", "-M", "main"]) 
    # Use token in remote URL for non-interactive push
    remote = f"https://{GITHUB_USER}:{GITHUB_TOKEN}@github.com/{GITHUB_USER}/{REPO_NAME}.git"
    # Reset remote if exists
    subprocess.run(["git", "remote", "remove", "origin"], check=False)
    run(["git", "remote", "add", "origin", remote])
    run(["git", "push", "-q", "-u", "origin", "main"]) 
    # Tag and push tag
    subprocess.run(["git", "tag", "-a", TAG, "-m", f"Release {TAG}"], check=False)
    subprocess.run(["git", "push", "-q", "origin", TAG], check=False)

def create_release():
    code, body = gh_api("POST", f"https://api.github.com/repos/{GITHUB_USER}/{REPO_NAME}/releases", {
        "tag_name": TAG,
        "name": TAG,
        "prerelease": False,
        "draft": False,
    })
    if code not in (200, 201):
        # If already exists, get it
        code, body = gh_api("GET", f"https://api.github.com/repos/{GITHUB_USER}/{REPO_NAME}/releases/tags/{TAG}")
        if code != 200:
            print(f"ERROR creating or fetching release: {code} {body}")
            sys.exit(1)
    data = json.loads(body.decode("utf-8"))
    upload_url = data["upload_url"].split("{")[0]
    return upload_url

def upload_asset(upload_url):
    if not os.path.exists(ZIP_PATH):
        print(f"ERROR: asset not found: {ZIP_PATH}")
        sys.exit(1)
    with open(ZIP_PATH, "rb") as f:
        bin_data = f.read()
    url = f"{upload_url}?name={os.path.basename(ZIP_PATH)}"
    code, _ = gh_api("POST", url, data=None, headers={
        "Content-Type": "application/zip",
        "Content-Length": str(len(bin_data)),
    })
    # If GitHub rejects JSON-less upload, fallback to raw urlopen
    req = urllib.request.Request(url, data=bin_data, headers={
        "Authorization": f"Bearer {GITHUB_TOKEN}",
        "Accept": "application/vnd.github+json",
        "Content-Type": "application/zip",
        "User-Agent": "CodexCLI/1.0",
        "X-GitHub-Api-Version": "2022-11-28",
    }, method="POST")
    try:
        with urllib.request.urlopen(req) as resp:
            if resp.getcode() not in (200, 201):
                print(f"ERROR uploading asset: {resp.getcode()}")
                sys.exit(1)
    except urllib.error.HTTPError as e:
        if e.code == 422:
            # asset likely exists, ignore
            pass
        else:
            print(f"ERROR uploading asset: {e.code} {e.read()}")
            sys.exit(1)

def main():
    ensure_repo()
    git_push()
    upload_url = create_release()
    upload_asset(upload_url)
    print(f"Done. Repo: https://github.com/{GITHUB_USER}/{REPO_NAME}")
    print(f"Release: https://github.com/{GITHUB_USER}/{REPO_NAME}/releases/tag/{TAG}")

if __name__ == "__main__":
    main()
