#!/usr/bin/env python3
"""
Test script for document conversion API on kkomjang.synology.me:4000
Tests all sample files (HWP, HWPX, DOC, DOCX, XLS, XLSX, PPT, PPTX)
"""

import os
import sys
import time
import requests
from pathlib import Path
from typing import Dict, List, Tuple

# ANSI color codes
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'

# API configuration
HWP_URL = "https://kkomjang.synology.me:4000/convert"  # Flask endpoint for HWP (binary format)
HWPX_URL = "https://kkomjang.synology.me:4000/convert_hwpx"  # Flask endpoint for HWPX (XML format)
OFFICE_URL = "https://kkomjang.synology.me:4000/forms/libreoffice/convert"  # Gotenberg endpoint for Office docs
AUTH = ("kkomi", "kkomi")
TIMEOUT = 30

# File type routing
HWP_EXTENSIONS = {'.hwp'}
HWPX_EXTENSIONS = {'.hwpx'}
OFFICE_EXTENSIONS = {'.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx'}

def format_size(bytes_size: int) -> str:
    """Format bytes to human-readable size"""
    for unit in ['B', 'KB', 'MB']:
        if bytes_size < 1024.0:
            return f"{bytes_size:.2f} {unit}"
        bytes_size /= 1024.0
    return f"{bytes_size:.2f} GB"

def test_conversion(file_path: Path) -> Tuple[bool, Dict]:
    """
    Test document conversion for a single file

    Returns:
        (success: bool, result: dict with status, time, size, error)
    """
    result = {
        'file': file_path.name,
        'extension': file_path.suffix.upper()[1:],
        'input_size': format_size(file_path.stat().st_size),
        'status_code': None,
        'time': None,
        'output_size': None,
        'error': None
    }

    try:
        # Determine endpoint and field name based on file type
        file_ext = file_path.suffix.lower()
        if file_ext in HWP_EXTENSIONS:
            url = HWP_URL
            field_name = 'file'  # Flask uses singular 'file'
        elif file_ext in HWPX_EXTENSIONS:
            url = HWPX_URL
            field_name = 'file'  # Flask uses singular 'file'
        elif file_ext in OFFICE_EXTENSIONS:
            url = OFFICE_URL
            field_name = 'files'  # Gotenberg uses plural 'files'
        else:
            result['error'] = f"Unsupported extension: {file_ext}"
            return False, result

        # Open file
        with open(file_path, 'rb') as f:
            files = {field_name: (file_path.name, f, 'application/octet-stream')}

            # Send request with timing
            start_time = time.time()
            response = requests.post(
                url,
                files=files,
                auth=AUTH,
                timeout=TIMEOUT,
                verify=False  # Skip SSL verification for self-signed cert
            )
            elapsed_time = time.time() - start_time

            result['status_code'] = response.status_code
            result['time'] = f"{elapsed_time:.2f}s"

            # Check response
            if response.status_code == 200:
                result['output_size'] = format_size(len(response.content))
                return True, result
            else:
                result['error'] = f"HTTP {response.status_code}"
                return False, result

    except requests.Timeout:
        result['error'] = f"Timeout (>{TIMEOUT}s)"
        return False, result
    except Exception as e:
        result['error'] = str(e)
        return False, result

def print_header():
    """Print test header"""
    print(f"\n{BLUE}{'='*80}{RESET}")
    print(f"{BLUE}Document Conversion Test Suite{RESET}")
    print(f"{BLUE}HWP:       {HWP_URL}{RESET}")
    print(f"{BLUE}HWPX:      {HWPX_URL}{RESET}")
    print(f"{BLUE}Office:    {OFFICE_URL}{RESET}")
    print(f"{BLUE}{'='*80}{RESET}\n")

def print_result(success: bool, result: Dict):
    """Print test result for a single file"""
    status_icon = f"{GREEN}✓{RESET}" if success else f"{RED}✗{RESET}"
    status_text = f"{GREEN}PASS{RESET}" if success else f"{RED}FAIL{RESET}"

    print(f"{status_icon} [{result['extension']:5s}] {result['file']:30s} ", end="")
    print(f"({result['input_size']:>10s}) → ", end="")

    if success:
        print(f"{result['output_size']:>10s} in {result['time']:>7s} {status_text}")
    else:
        print(f"{RED}{result['error']:>30s}{RESET} {status_text}")

def print_summary(results: List[Tuple[bool, Dict]]):
    """Print test summary"""
    total = len(results)
    passed = sum(1 for success, _ in results if success)
    failed = total - passed

    print(f"\n{BLUE}{'='*80}{RESET}")
    print(f"{BLUE}Test Summary{RESET}")
    print(f"{BLUE}{'='*80}{RESET}")
    print(f"Total:  {total} tests")
    print(f"{GREEN}Passed: {passed} tests{RESET}")
    if failed > 0:
        print(f"{RED}Failed: {failed} tests{RESET}")
    else:
        print(f"Failed: {failed} tests")

    # Calculate total time
    total_time = sum(
        float(result['time'].rstrip('s'))
        for success, result in results
        if result['time']
    )
    print(f"\nTotal execution time: {total_time:.2f}s")
    print(f"{BLUE}{'='*80}{RESET}\n")

def main():
    """Main test function"""
    # Disable SSL warnings
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    # Find all sample files
    current_dir = Path.cwd()
    extensions = ['.hwp', '.hwpx', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx']

    sample_files = []
    for ext in extensions:
        sample_files.extend(current_dir.glob(f'*{ext}'))
        sample_files.extend(current_dir.glob(f'sample{ext}'))
        sample_files.extend(current_dir.glob(f'real{ext}'))
        sample_files.extend(current_dir.glob(f'real_sample{ext}'))

    # Remove duplicates and sort
    sample_files = sorted(set(sample_files), key=lambda p: (p.suffix, p.name))

    if not sample_files:
        print(f"{RED}No sample files found!{RESET}")
        print(f"Looking for: {', '.join(extensions)}")
        sys.exit(1)

    print_header()
    print(f"Found {len(sample_files)} sample files\n")

    # Run tests
    results = []
    for file_path in sample_files:
        success, result = test_conversion(file_path)
        print_result(success, result)
        results.append((success, result))

    # Print summary
    print_summary(results)

    # Exit code based on results
    sys.exit(0 if all(success for success, _ in results) else 1)

if __name__ == '__main__':
    main()
