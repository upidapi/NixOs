#!/usr/bin/env python3
import argparse
import contextlib
import io
import os
import sys
import zipfile
from urllib.parse import urlparse, urljoin
import requests

DEFAULT_BACKEND = "wastebin"  # looks much better
DEFAULT_URL = {
    "wastebin": "https://paste.upidapi.dev",
    "pastebin": "https://p2.upidapi.dev",
}


@contextlib.contextmanager
def get_data_stream(file_path, file_name, is_dir, service_type):
    """
    Context manager that yields the data in the optimal format for the target service.
    Streams are yielded for pastebin (to avoid RAM usage), while bytes are yielded for wastebin.
    """
    if is_dir:
        print(
            f"Creating zip archive of {os.path.abspath(file_path)} ...", file=sys.stderr
        )
        zip_buffer = io.BytesIO()
        with zipfile.ZipFile(zip_buffer, "w", zipfile.ZIP_DEFLATED) as zipf:
            for root, _, files in os.walk(file_path):
                for f in files:
                    abs_p = os.path.join(root, f)
                    rel_p = os.path.relpath(abs_p, file_path).replace(os.sep, "/")
                    zipf.write(abs_p, rel_p)
        zip_buffer.seek(0)
        if service_type == "pastebin":
            yield zip_buffer, f"{file_name}.zip"
        else:
            # Yield raw bytes so .decode() doesn't fail on a BytesIO object
            yield zip_buffer.getvalue(), f"{file_name}.zip"
    elif file_path:
        # File on disk
        if service_type == "pastebin":
            with open(file_path, "rb") as f:
                yield f, file_name
        else:
            with open(file_path, "rb") as f:
                yield f.read(), file_name
    else:
        # Piped standard input (stdin)
        if service_type == "pastebin":
            yield sys.stdin.buffer, file_name
        else:
            yield sys.stdin.buffer.read(), file_name


def pastebin_upload(url, data, file_name, args):
    """Handler for traditional transfer.sh-style pastebins."""
    headers = {"User-Agent": "curl/8.4.0"}
    if args.once:
        headers["Max-Downloads"] = "1"
    if not args.never:
        headers["Max-Days"] = str(args.expire.strip()[:-1])
    if args.password:
        headers["X-Encrypt-Password"] = args.password

    upload_url = f"{url.rstrip('/')}/{file_name or 'paste'}"

    if args.verbose:
        print(f"Request Endpoint: {upload_url}", file=sys.stderr)

    response = requests.put(upload_url, data=data, headers=headers)

    if args.verbose:
        print("--- Response Headers ---", file=sys.stderr)
        for k, v in response.headers.items():
            print(f"{k}: {v}", file=sys.stderr)
        print("--- Response Body ---", file=sys.stderr)
        print(response.text, file=sys.stderr)

    response.raise_for_status()

    resp_text = response.text.strip()
    final_url = resp_text.splitlines()[-1] if resp_text else ""
    del_url = response.headers.get("x-url-delete")

    get_cmd = None
    if args.password and final_url:
        get_cmd = f'curl -H "X-Decrypt-Password: {args.password}" {final_url}'

    # could return the /get/ url, but seams unnecessary since 
    # it just reads the curl header
    return final_url, "", del_url, get_cmd


def wastebin_upload(url, data, file_name, args):
    """Handler for matze/wastebin service using standard HTML Form format."""
    text_content = data.decode("utf-8", errors="replace")
    _, ext = os.path.splitext(file_name)
    ext = ext.lstrip(".") if ext else None

    # Mimic standard HTML browser form fields exactly
    # We include 'password' here to ensure it is always sent, even when empty.
    payload = {
        "text": text_content,
        "title": file_name if file_name else "",
        "password": args.password if args.password else "",
    }
    if ext:
        payload["extension"] = ext
    if args.once:
        payload["burn-after-reading"] = "on"
    if not args.never:
        payload["expires"] = str(
            int(args.expire[:-1])
            * {
                "s": 1,
                "m": 60,
                "h": 60 * 60,
                "d": 60 * 60 * 24,
                "w": 60 * 60 * 24 * 7,
                "M": 60 * 60 * 24 * 30,
                "y": 60 * 60 * 24 * 365,
            }[args.expire[-1:]]
        )

    # Safely build the POST endpoint URL (the form action is '/new')
    # Ensuring base_url has a trailing slash preserves potential subpaths (e.g., /wastebin/)
    base_url = url if url.endswith("/") else f"{url}/"
    post_url = urljoin(base_url, "new")

    # Parse origin and referer to mimic a browser submission
    parsed_url = urlparse(url)
    origin = f"{parsed_url.scheme}://{parsed_url.netloc}"
    referer = base_url

    headers = {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:151.0) Gecko/20100101 Firefox/151.0",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.9",
        "Referer": referer,
        "Origin": origin,
        "Connection": "keep-alive",
    }

    if args.verbose:
        print(f"Request Endpoint: {post_url}", file=sys.stderr)

    # Use a session to track cookies cleanly
    session = requests.Session()

    # We set allow_redirects=False to catch the 303 See Other redirect immediately.
    # This prevents the client from fetching the page (which would instantly burn a "burn-after-reading" paste).
    response = session.post(
        post_url, data=payload, headers=headers, allow_redirects=False
    )

    if args.verbose:
        print("--- Response Headers ---", file=sys.stderr)
        for k, v in response.headers.items():
            print(f"{k}: {v}", file=sys.stderr)
        print("--- Response Body ---", file=sys.stderr)
        print(response.text[:500], file=sys.stderr)

    # Standard form submission in wastebin redirects using HTTP 303
    if response.status_code in (301, 302, 303, 307, 308):
        location = response.headers.get("Location")
        if not location:
            raise requests.exceptions.RequestException(
                "Redirect response was missing 'Location' header."
            )
        final_url = urljoin(post_url, location)
    else:
        # Fallback if no redirect occurs
        response.raise_for_status()
        final_url = response.url

    # Extract paste ID cleanly from the path, preserving subpaths
    paste_id = final_url.rstrip("/").split("/")[-1]

    # Strip any extension (like .py or .rs) from the ID for delete and raw operations
    paste_id_without_ext, _ = os.path.splitext(paste_id)

    # Construct the delete URL and raw URL using the stripped ID
    delete_url = urljoin(base_url, paste_id_without_ext)
    raw_url = urljoin(base_url, f"raw/{paste_id_without_ext}")

    # Extract the 'uid' cookie set during redirect so the user can delete the paste later
    uid_cookie = response.cookies.get("uid") or session.cookies.get("uid")
    del_url = (delete_url, uid_cookie) if uid_cookie else None

    get_cmd = None
    if args.password:
        get_cmd = f'curl -H "wastebin-password: {args.password}" {raw_url}'

    # return final_url, del_url, get_cmd
    return raw_url, final_url, del_url, get_cmd


def main():
    parser = argparse.ArgumentParser(
        description="Uploads a file or directory to a server.", add_help=False
    )
    parser.add_argument(
        "-1", dest="once", action="store_true", help="Limit the download count to 1."
    )
    parser.add_argument("-n", "--never", action="store_true", help="Disable expiry")
    parser.add_argument("-u", "--url", help="override URL to connect to.")
    parser.add_argument(
        "-e",
        "--expire",
        type=str,
        default="30d",
        help="Time until expiry (default: 30d).",
    )
    parser.add_argument(
        "-p", "--pass", dest="password", help="Encrypt using a password."
    )

    parser.add_argument(
        "-P", "--pastebin", action="store_true", help="Use pastebin backend"
    )
    parser.add_argument(
        "-w", "--wastebin", action="store_true", help="Use pastebin backend"
    )
    parser.add_argument(
        "-t",
        "--type",
        choices=["p", "pastebin", "w", "wastebin"],
        help="Set backend",
    )

    parser.add_argument(
        "-v", "--verbose", action="store_true", help="Enable verbose mode."
    )
    parser.add_argument("file", nargs="?", help="File or directory to upload.")
    parser.add_argument(
        "--help", action="help", help="Display this help message and exit."
    )

    args = parser.parse_args()

    if not args.file and sys.stdin.isatty():
        print("Error: No filename specified.", file=sys.stderr)
        parser.print_help(sys.stderr)
        sys.exit(1)

    service_type = DEFAULT_BACKEND

    if args.type is not None:
        service_type = {
            "p": "pastebin",
            "pastebin": "pastebin",
            "w": "watebin",
            "wastebin": "wastebin",
        }[args.type]
    elif args.pastebin:
        service_type = "pastebin"
    elif args.wastebin:
        service_type = "wastebin"

        
    url = args.url or DEFAULT_URL[service_type]

    if args.expire is not None:
        if args.expire[-1:] not in "smhdwMy":
            print("time increment must be in smhdMy")
        if service_type == "pastebin" and not args.expire.endswith("d"):
            print("Pastebin only supports expiry times in days")
            exit(1)

    if sys.stdin.isatty():
        file_path = args.file
        if not os.path.exists(file_path):
            print(f"Error: {file_path}: No such file or directory", file=sys.stderr)
            sys.exit(1)
        file_name = os.path.basename(os.path.normpath(file_path))
        is_dir = os.path.isdir(file_path)
    else:
        file_path = None
        file_name = os.path.basename(args.file) if args.file else "" 
        is_dir = False

    handlers = {"pastebin": pastebin_upload, "wastebin": wastebin_upload}

    print("Uploading file...", file=sys.stderr)

    try:
        with get_data_stream(file_path, file_name, is_dir, service_type) as (
            data,
            target_name,
        ):
            raw_url, final_url, del_url, get_cmd = handlers[service_type](
                url, data, target_name, args
            )

        if args.once:
            print("\nWarning: paste will self destruct after reading", file=sys.stderr)

        if get_cmd:
            print(f"\nTo retrieve and decrypt use:\n{get_cmd}", file=sys.stderr)

        if del_url:
            print("\nTo delete use:", file=sys.stderr)
            if isinstance(del_url, tuple):
                url_to_del, cookie = del_url
                print(
                    f'curl -X DELETE --cookie "uid={cookie}" {url_to_del}',
                    file=sys.stderr,
                )
            else:
                print(f"curl -X DELETE {del_url}", file=sys.stderr)
    
        if final_url:
            print(f"\n{final_url}", file=sys.stderr)

        if get_cmd or del_url or args.once or final_url:
            print(file=sys.stderr)
        
        print(raw_url)

    except requests.exceptions.RequestException as e:
        print(f"Error connecting to server: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
