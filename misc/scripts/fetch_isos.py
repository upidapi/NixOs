"""
function downloadfile {
    # resolve url redirect to get a more specific link
    local url=$(curl -w "%{redirect_url}" -o /dev/null -s "$1")

    # curl said url and use the filename of it
    curl -jol "$url"
}

iso_names=(
    minimal
    gnome
    plasma6
)

for name in $iso_names; do
    echo "$name"
    downloadfile \
    "https://channels.nixos.org/nixos-24.11/latest-nixos-$1-x86_64-linux.iso"
done
"""

import requests
import time

def format_bytes(size):
    """
    Format bytes into human-readable units (KB, MB, GB, etc.).

    Args:
        size (int): The size in bytes.

    Returns:
        str: The formatted size with appropriate unit.
    """
    # Define size units
    power = 1024
    n = 0
    units = ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB']
    
    # Find the unit
    while size >= power and n < len(units) - 1:
        size /= power
        n += 1
    
    return f"{size:.2f} {units[n]}"


def download_file(url):
    local_filename = url.split("/")[-1]
    print(f"Downloading {local_filename}")
    s = time.time()

    # NOTE the stream=True parameter below
    with requests.get(url, stream=True, allow_redirects=True) as r:
        r.raise_for_status()

        total_size = int(r.headers.get("content-length", 0))
        local_filename = r.url.split("/")[-1]

        data_len = 0
        last_p = 0

        with open(local_filename, "wb") as f:
            for chunk in r.iter_content(chunk_size=8192):
                data_len += len(chunk)
                p = round(data_len / total_size * 100)
                if p != last_p:
                    print(f"{p}% done")
                    last_p = p

                # If you have chunk encoded response uncomment if
                # and set chunk_size parameter to None.
                # if chunk:
                f.write(chunk)

    print(f"finished {local_filename} in {time.time() - s:.3f} sec")
    return local_filename


def download_iso(version, name):
    download_file(
        "https://channels.nixos.org"
        f"/nixos-{version}/latest-nixos-{name}-x86_64-linux.iso"
    )


for name in ["minimal", "gnome", "plasma6"]:
    download_iso("24.11", name)
