import sys

def parse_version(version):
    """Parse a version string into a tuple of integers."""
    try:
        return tuple(map(int, version.split(".")))
    except ValueError:
        raise ValueError(f"Invalid version format: {version}")

def compare_versions(local, remote):
    """Compare local and remote version tuples."""
    if local < remote:
        return "lower"
    elif local == remote:
        return "equal"
    else:
        return "higher"

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: compare_versions.py <local_version> <remote_version>")
        sys.exit(1)

    local_version = sys.argv[1]
    remote_version = sys.argv[2]

    try:
        local = parse_version(local_version)
        remote = parse_version(remote_version)
    except ValueError as e:
        print(f"Error: {e}")
        sys.exit(1)

    result = compare_versions(local, remote)
    if result == "higher":
        print(f"Error: Local version ({local_version}) is higher than remote version ({remote_version})")
        sys.exit(1)
    elif result == "lower":
        print(f"Local version ({local_version}) is lower than remote version ({remote_version})")
    else:
        print(f"Local version ({local_version}) is equal to remote version ({remote_version})")
