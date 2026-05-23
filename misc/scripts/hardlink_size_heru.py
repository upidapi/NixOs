import os
from collections import defaultdict
import json

def find_duplicates_across_dirs_by_size(dir1, dir2):
    """
    Finds files in dir1 that have the exact same size as files in dir2.
    """
    # Dictionaries to group files by their size (size_in_bytes -> [list of file paths])
    size_map1 = defaultdict(list)
    size_map2 = defaultdict(list)

    def populate_size_map(directory, size_map):
        """Walks through a directory and groups files by their size."""
        for root, _, files in os.walk(directory):
            for filename in files:
                filepath = os.path.join(root, filename)
                try:
                    # Skip symlinks to avoid circular loops or misreporting sizes
                    if not os.path.islink(filepath):
                        size = os.path.getsize(filepath)
                        size_map[size].append(filepath)
                except OSError:
                    # Handle cases where file might be inaccessible
                    pass

    print(f"Scanning '{dir1}' to get file sizes...")
    populate_size_map(dir1, size_map1)

    print(f"Scanning '{dir2}' to get file sizes...")
    populate_size_map(dir2, size_map2)

    # Heuristic step: Only look at file sizes that exist in BOTH directories
    common_sizes = set(size_map1.keys()).intersection(set(size_map2.keys()))

    print(f"\nComparing files based on {len(common_sizes)} common file sizes...\n")

    size_based_matches = []
    
    with open("s1.json", "w") as f:
        f.write(json.dumps(size_map1, indent=2))
    with open("s2.json", "w") as f:
        f.write(json.dumps(size_map1, indent=2))
    
    # exit(1)
    # Iterate through common sizes and record all file pairs
    for size in sorted(list(common_sizes)):
        files_in_dir1 = size_map1[size]
        files_in_dir2 = size_map2[size]

        # If there are files of this size in both directories,
        # we consider them "size-based duplicates".
        # We'll pair every file from dir1 with every file from dir2 that has this size.
        # This might result in many pairs if there are multiple files of the same size
        # in each directory.
        
        print(files_in_dir1, files_in_dir2)
        assert len(files_in_dir1 + files_in_dir2) == 2
        assert len(files_in_dir1) == 1
        assert len(files_in_dir2) == 1

        for file1_path in files_in_dir1:
            for file2_path in files_in_dir2:
                size_based_matches.append((file1_path, file2_path, size))
                break

    return size_based_matches

def apply_hardlinks(matches, dry_run=True):
    """Replaces the second file in each match with a hardlink to the first."""
    if dry_run:
        print("--- DRY RUN MODE: No changes will be made ---")

    count = 0
    for src, dst, size in matches:
        # 1. Check if they are already the same file (same inode)
        try:
            if os.path.samefile(src, dst):
                continue 
        except OSError: continue

        print(f"Linking: {dst} -> {src} ({size} bytes)")
        
        if not dry_run:
            try:
                # To create a hard link, the destination path must not exist.
                # We remove the duplicate in Dir 2 and link it to the file in Dir 1.
                os.remove(dst)
                os.link(src, dst)
                count += 1
            except OSError as e:
                print(e)
                # if e.errno == errn
                #     print(f"  [Error] Cannot hardlink across different partitions/drives.")
                # else:
                #     print(f"  [Error] {e.strerror}")

if __name__ == "__main__":
    # d1 = "/raid/media/torrents/movies"
    # d2 = "/raid/media/movies"
    d1 = "/raid/media/torrents/tv"
    d2 = "/raid/media/tv"

    # Ensure directories exist before running
    if not os.path.isdir(d1) or not os.path.isdir(d2):
        print("Error: One or both of the provided directories do not exist.")
    else:
        matches = find_duplicates_across_dirs_by_size(d1, d2)

        if matches:
            # print(f"Found {len(matches)} potential duplicate(s) based on file size:")
            # print("-" * 50)
            # for file1, file2, size in matches:
            #     print(
            #         f"Match (Size: {size} bytes):\n  [Dir 1] {file1}\n  [Dir 2] {file2}\n"
            #     )
            # exit(1)
            apply_hardlinks(matches, dry_run=False)
        else:
            print("No size-based matches found between the two directories.")
