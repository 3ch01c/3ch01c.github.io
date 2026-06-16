#!/usr/bin/env python3
# =============================================================================
# trivy.py
#
# Generate an HTML executive summary report from a Trivy container image scan.
#
# Usage:
#   ./trivy.py -i <image> [-o <output-dir>] [--insecure] [--archive]
#              [--source <remote|docker|podman|containerd>]
#
# Options:
#   -i, --image          Container image to scan (required)
#   -o, --output-dir     Directory for output files (default: ./trivy-report)
#   --insecure           Skip TLS verification when pulling images
#   --archive            Save a compressed tarball of the scanned image
#   --source             Image source: remote, docker, podman, or containerd
#                        (default: remote)
#
# Requirements:
#   * trivy              The Trivy security scanner
#                        (https://github.com/aquasecurity/trivy)
#   * Python 3.7+        Standard library only
#   * docker or podman   Optional, required only if using --archive
#
# Output:
#   * <image>.trivy.json              Raw Trivy scan results (JSON)
#   * <image>.executive-summary.html  Human-readable vulnerability report
#   * <image>.tar.gz                  Compressed image archive (if --archive)
#
# The HTML report includes:
#   - Vulnerability counts by severity (Critical, High, Medium, Low)
#   - Number of affected packages and available fixes
#   - Complete list of all affected packages with finding counts
#   - Detailed vulnerability table with CVE links, versions, and locations
# =============================================================================

import argparse
import json
import subprocess
import sys
import html
import shutil
import gzip
from pathlib import Path
from datetime import datetime
from collections import Counter, defaultdict
from typing import List, Dict, Any

# ---------------------------------------------------------------------------
# Helper utilities
# ---------------------------------------------------------------------------

def run_trivy(args: List[str]) -> None:
    """Execute Trivy with the supplied argument list."""
    print("Running Trivy scan...")
    print(" ".join(["trivy"] + args))

    trivy_exe = shutil.which("trivy")
    if trivy_exe is None:
        sys.stderr.write(
            "\nERROR: The `trivy` executable was not found on your PATH.\n"
            "       • Install Trivy (https://github.com/aquasecurity/trivy)\n"
        )
        sys.exit(1)

    result = subprocess.run([trivy_exe] + args, capture_output=True, text=True)

    if result.returncode != 0:
        sys.stderr.write("\nTrivy failed (exit code {}):\n".format(result.returncode))
        sys.stderr.write(result.stderr)
        sys.exit(result.returncode)


def save_image_as_tarball(image: str, dest_dir: Path, source: str) -> Path:
    """
    Pull the image (if needed) and save it as a compressed tarball.

    Parameters
    ----------
    image : str
        The image reference (e.g. ``registry.example.com/repo:tag``).
    dest_dir : pathlib.Path
        Directory where the ``.tar.gz`` file will be written.
    source : str
        The container‑runtime that should be used to pull/save the image.
        For ``remote``, will try Docker first, then Podman.

    Returns
    -------
    pathlib.Path | None
        Full path to the created tarball, or None if no runtime available.
    """
    # --------------------------------------------------------------------
    # 1️⃣  Choose the runtime binary
    # --------------------------------------------------------------------
    runtime = None
    if source == "docker":
        runtime = shutil.which("docker")
    elif source == "podman":
        runtime = shutil.which("podman")
    elif source == "remote":
        # Try Docker first, then Podman
        runtime = shutil.which("docker") or shutil.which("podman")
    else:
        # containerd or unknown - skip
        print(f"[INFO] Image source '{source}' not supported for archiving. Skipping.")
        return None

    if runtime is None:
        print(f"[WARN] No container runtime (docker/podman) found – skipping archive.")
        return None

    # --------------------------------------------------------------------
    # 2️⃣  Pull the image (idempotent – Docker/Podman will skip if already present)
    # --------------------------------------------------------------------
    print(f"[INFO] Pulling image '{image}' using {runtime} …")
    pull_cmd = [runtime, "pull", image]
    pull_res = subprocess.run(pull_cmd, capture_output=True, text=True)
    if pull_res.returncode != 0:
        print(f"[WARN] Unable to pull image:")
        print(pull_res.stderr.strip())
        # Continue anyway – the save step will fail and we'll report it.
    
    # --------------------------------------------------------------------
    # 3️⃣  Save the image to an uncompressed tarball
    # --------------------------------------------------------------------
    safe = safe_name(image)
    uncompressed = dest_dir / f"{safe}.tar"
    save_cmd = [runtime, "save", "-o", str(uncompressed), image]
    print(f"[INFO] Saving image to {uncompressed} …")
    save_res = subprocess.run(save_cmd, capture_output=True, text=True)
    if save_res.returncode != 0:
        print("[WARN] Image save failed:")
        print(save_res.stderr.strip())
        return None

    # --------------------------------------------------------------------
    # 4️⃣  Compress the tarball (gzip) and delete the raw .tar
    # --------------------------------------------------------------------
    compressed = uncompressed.with_suffix(".tar.gz")
    with open(uncompressed, "rb") as f_in:
        with gzip.open(compressed, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)

    uncompressed.unlink()   # remove the intermediate .tar
    print(f"[INFO] Archive created: {compressed}")
    return compressed


def safe_name(image: str) -> str:
    """Create a filesystem‑safe name from an image reference."""
    # Replace anything not alphanumeric, dot, underscore or hyphen with an underscore.
    return "".join(c if c.isalnum() or c in "._-" else "_" for c in image)


def severity_rank(sev: str) -> int:
    """Numeric order used for sorting (lower = more severe)."""
    order = {
        "CRITICAL": 1,
        "HIGH": 2,
        "MEDIUM": 3,
        "LOW": 4,
        "UNKNOWN": 5,
    }
    return order.get(sev.upper(), 5)


def html_escape(text: Any) -> str:
    """HTML‑escape a value (None → empty string)."""
    return html.escape("" if text is None else str(text))


def cve_link(vuln: Dict[str, Any]) -> str:
    """Return an HTML fragment for the CVE column."""
    cve = vuln.get("VulnerabilityID", "")
    url = vuln.get("PrimaryURL", "")
    if url:
        return f'<a href="{html_escape(url)}" target="_blank">{html_escape(cve)}</a>'
    elif cve.startswith("CVE-"):
        return f'<a href="https://nvd.nist.gov/vuln/detail/{html_escape(cve)}" target="_blank">{html_escape(cve)}</a>'
    else:
        return html_escape(cve)


def location_for(vuln: Dict[str, Any]) -> str:
    """Resolve the location string for a vulnerability."""
    return (
        vuln.get("PkgPath")
        or vuln.get("FilePath")
        or vuln.get("Target")
        or "Unknown"
    )


# ---------------------------------------------------------------------------
# Main logic
# ---------------------------------------------------------------------------


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Run Trivy on an image and generate an HTML executive summary."
    )
    parser.add_argument("-i", "--image", required=True, help="Container image to scan")
    parser.add_argument(
        "-o",
        "--output-dir",
        default="./trivy-report",
        help="Directory where JSON and HTML files will be written (default: ./trivy-report)",
    )
    parser.add_argument(
        "--insecure",
        action="store_true",
        help="Pass --insecure to Trivy (skip TLS verification)",
    )
    parser.add_argument(
        "--source",
        default="remote",
        choices=["remote", "docker", "podman", "containerd"],
        help="Image source for Trivy (default: remote)",
    )
    parser.add_argument(
        "--archive",
        action="store_true",
        help="Save a local tarball of the scanned image (default: do not save)",
    )
    args = parser.parse_args()

    # -----------------------------------------------------------------------
    # Prepare paths
    # -----------------------------------------------------------------------
    output_dir = Path(args.output_dir).expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    safe = safe_name(args.image)
    json_path = output_dir / f"{safe}.trivy.json"
    html_path = output_dir / f"{safe}.executive-summary.html"

    # -----------------------------------------------------------------------
    # Run Trivy
    # -----------------------------------------------------------------------
    trivy_args = [
        "image",
        "--image-src",
        args.source,
        "--scanners",
        "vuln",
        "--format",
        "json",
        "-o",
        str(json_path),
    ]
    if args.insecure:
        trivy_args.append("--insecure")
    trivy_args.append(args.image)

    run_trivy(trivy_args)
    # -----------------------------------------------------------------------
    # OPTIONAL: Save the image locally as a compressed tarball
    # -----------------------------------------------------------------------
    archive_path = None
    if args.archive:
        archive_path = save_image_as_tarball(args.image, output_dir, args.source)
    archive_note = f"<br><strong>Archive:</strong> {html_escape(str(archive_path))}" if archive_path else ""

    # -----------------------------------------------------------------------
    # Load JSON report
    # -----------------------------------------------------------------------
    with json_path.open("r", encoding="utf-8") as f:
        report = json.load(f)

    # Flatten all vulnerability objects across all results
    vulns: List[Dict[str, Any]] = []
    for result in report.get("Results", []):
        if not result.get("Vulnerabilities"):
            continue
        for v in result["Vulnerabilities"]:
            # Enrich each vulnerability with the surrounding result fields
            enriched = dict(v)  # shallow copy
            enriched["Target"] = result.get("Target", "")
            enriched["Class"] = result.get("Class", "")
            enriched["Type"] = result.get("Type", "")
            vulns.append(enriched)

    # -----------------------------------------------------------------------
    # Compute aggregates
    # -----------------------------------------------------------------------
    # Severity counters
    severity_counts = Counter(v.get("Severity", "UNKNOWN").upper() for v in vulns)

    # Fix‑available count
    fix_available = sum(1 for v in vulns if v.get("FixedVersion"))

    # Affected packages (unique names)
    affected_packages = len(
        {
            v.get("PkgName")
            for v in vulns
            if v.get("PkgName")
        }
    )

    # Packages sorted by finding count (descending)
    pkg_counter = Counter(v.get("PkgName", "UNKNOWN") for v in vulns)
    package_rows = [
        f"<tr><td>{html_escape(pkg)}</td><td>{count}</td></tr>"
        for pkg, count in pkg_counter.most_common()
    ]

    # All findings sorted by severity → CVE ID
    vulns_sorted = sorted(
        vulns,
        key=lambda v: (severity_rank(v.get("Severity", "UNKNOWN")), v.get("VulnerabilityID", "")),
    )

    finding_rows = []
    for v in vulns_sorted:
        severity = v.get("Severity", "UNKNOWN")
        cve_html = cve_link(v)
        pkg = v.get("PkgName", "")
        installed = v.get("InstalledVersion", "")
        fixed = v.get("FixedVersion", "None listed")
        loc = location_for(v)
        class_ = v.get("Class", "")
        type_ = v.get("Type", "")
        title = v.get("Title") or v.get("VulnerabilityID", "")

        row = f"""
        <tr>
            <td class='sev {html_escape(severity)}'>{html_escape(severity)}</td>
            <td>{cve_html}</td>
            <td>{html_escape(pkg)}</td>
            <td>{html_escape(installed)}</td>
            <td>{html_escape(fixed)}</td>
            <td>{html_escape(loc)}<br><small>Class: {html_escape(class_)}, Type: {html_escape(type_)}</small></td>
            <td>{html_escape(title)}</td>
        </tr>"""
        finding_rows.append(row)

    # -----------------------------------------------------------------------
    # Build HTML
    # -----------------------------------------------------------------------
    generated = datetime.now().strftime("%Y-%m-%d %H:%M:%S %z")
    html_content = f"""<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Trivy Executive Summary - {html_escape(args.image)}</title>
<style>
body {{font-family: Segoe UI, Arial, sans-serif; margin:32px; color:#222;}}
h1, h2 {{margin-bottom:0.3em;}}
.meta {{color:#555; margin-bottom:24px;}}
.cards {{display:flex; gap:12px; flex-wrap:wrap; margin:20px 0;}}
.card {{border:1px solid #ddd; border-radius:8px; padding:16px; min-width:130px; background:#fafafa;}}
.card .label {{font-size:13px; color:#555;}}
.card .value {{font-size:30px; font-weight:700;}}
.CRITICAL {{color:#7a0019; font-weight:700;}}
.HIGH {{color:#b00020; font-weight:700;}}
.MEDIUM {{color:#b36b00; font-weight:700;}}
.LOW {{color:#666; font-weight:700;}}
.UNKNOWN {{color:#555; font-weight:700;}}
table {{border-collapse:collapse; width:100%; margin-top:12px;}}
th, td {{border:1px solid #ddd; padding:8px; vertical-align:top;}}
th {{background:#f0f0f0; text-align:left;}}
.summary {{border-left:4px solid #666; padding:12px 16px; background:#f8f8f8; margin:20px 0;}}
.footer {{margin-top:32px; font-size:12px; color:#666;}}
</style>
</head>
<body>

<h1>Container Vulnerability Executive Summary</h1>
<div class="meta">
    <strong>Image:</strong> {html_escape(args.image)}<br>
    <strong>Generated:</strong> {generated}<br>
    <strong>Scanner:</strong> Trivy<br>
    <strong>Source:</strong> {html_escape(args.source)}{archive_note}
</div>

<div class="cards">
    <div class="card"><div class="label">Critical</div><div class="value CRITICAL">{severity_counts.get('CRITICAL',0)}</div></div>
    <div class="card"><div class="label">High</div><div class="value HIGH">{severity_counts.get('HIGH',0)}</div></div>
    <div class="card"><div class="label">Medium</div><div class="value MEDIUM">{severity_counts.get('MEDIUM',0)}</div></div>
    <div class="card"><div class="label">Low</div><div class="value LOW">{severity_counts.get('LOW',0)}</div></div>
    <div class="card"><div class="label">Affected Packages</div><div class="value">{affected_packages}</div></div>
    <div class="card"><div class="label">Fixes Available</div><div class="value">{fix_available}</div></div>
</div>

<div class="summary">
    <strong>Executive assessment:</strong>
    This image contains {severity_counts.get('CRITICAL',0)} critical, {severity_counts.get('HIGH',0)} high, and {severity_counts.get('MEDIUM',0)} medium vulnerabilities.
    {fix_available} findings have a fixed version listed by Trivy.
</div>

<h2>All Affected Packages</h2>
<table>
<thead><tr><th>Package</th><th>Finding Count</th></tr></thead>
<tbody>
{''.join(package_rows)}
</tbody>
</table>

<h2>All Findings</h2>
<table>
<thead>
<tr>
    <th>Severity</th>
    <th>CVE</th>
    <!--<th>Details</th>-->
    <th>Package</th>
    <th>Installed Version</th>
    <th>Fixed Version</th>
    <th>Location</th>
    <th>Title</th>
</tr>
</thead>
<tbody>
{''.join(finding_rows)}
</tbody>
</table>

<div class="footer">
    Full machine‑readable results saved to: {html_escape(str(json_path))}
</div>

</body>
</html>
"""

    # Write HTML file
    html_path.write_text(html_content, encoding="utf-8")
    print("\nDone.")
    print(f"JSON report: {json_path}")
    print(f"HTML summary: {html_path}")
    if archive_path:
        print(f"Image archive: {archive_path}")


if __name__ == "__main__":
    main()