#!/usr/bin/env python3
import os
import re
import sys

# Default directory to scan
TV_DIR = "/raid/media/tv"
if len(sys.argv) > 1:
    TV_DIR = sys.argv[1]

# File extension filter
VALID_EXTENSIONS = {".mpg", ".avi", ".mp4", ".mkv"}

# Regex patterns to extract standard TV episode identifiers
EP_PATTERNS = [
    re.compile(r'[sS](\d+)\s*[eE](\d+)'),  # Matches S01E01, s01e01, S01 e01, etc.
    re.compile(r'(\d+)x(\d+)'),             # Matches 1x01, 01x01, etc.
]

def get_episode_code(filename):
    """
    Extracts and normalizes the episode code (e.g., 's01e01') from a filename.
    Returns None if no pattern is found.
    """
    for pattern in EP_PATTERNS:
        match = pattern.search(filename)
        if match:
            season = int(match.group(1))
            episode = int(match.group(2))
            return f"s{season:02d}e{episode:02d}"
    return None

def main():
    if not os.path.exists(TV_DIR):
        print(f"Error: Directory '{TV_DIR}' does not exist.", file=sys.stderr)
        sys.exit(1)

    # Groups files by (directory, episode_code) -> list of (filepath, nlink)
    groups = {}  
    # List for files where no standard episode pattern was detected
    ungrouped = []  

    for root, _, files in os.walk(TV_DIR):
        for file in files:
            # Exclude files containing "sample" (case-insensitive)
            if "sample" in file.lower():
                continue

            # Check file extension (case-insensitive)
            ext = os.path.splitext(file)[1].lower()
            if ext not in VALID_EXTENSIONS:
                continue

            full_path = os.path.join(root, file)

            try:
                stat_info = os.stat(full_path)
                nlink = stat_info.st_nlink
            except OSError:
                # Skip files that cannot be accessed
                continue

            ep_code = get_episode_code(file)
            if ep_code:
                key = (root, ep_code)
                if key not in groups:
                    groups[key] = []
                groups[key].append((full_path, nlink))
            else:
                ungrouped.append((full_path, nlink))

    final_files = []
    extra_files = []

    # Process grouped episodes
    for (root_dir, ep_code), file_list in groups.items():
        # Check if any duplicate of this episode has a hardlink (links > 1)
        has_hardlink = any(nlink > 1 for _, nlink in file_list)
        
        # If no file in this episode group is a hardlink, keep the ones with link == 1
        if not has_hardlink:
            for path, nlink in file_list:
                if nlink == 1:
                    final_files.append(path)

        if has_hardlink:
            for path, nlink in file_list:
                if nlink == 1:
                    extra_files.append(path)

    # Process ungrouped files (no episode code found)
    for path, nlink in ungrouped:
        if nlink == 1:
            final_files.append(path)

    # Sort alphabetically
    final_files.sort()

    # Output the paths
    # for i, path in enumerate(final_files):
    #     print(i, path)

    for i, path in enumerate(extra_files):
        os.remove(path)
        # print(i, path)

if __name__ == "__main__":
    main()
