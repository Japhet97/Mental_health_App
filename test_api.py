#!/usr/bin/env python3
"""
Quick API Test Script
Run this to verify the backend API is working correctly
"""

import requests
import json

API_BASE = "http://localhost:8001"

def test_health():
    """Test health endpoint"""
    try:
        response = requests.get(f"{API_BASE}/health", timeout=5)
        if response.status_code == 200:
            print("✅ Health check: PASSED")
            return True
        else:
            print(f"❌ Health check: FAILED (Status: {response.status_code})")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Health check: FAILED (Connection refused - server not running)")
        return False
    except Exception as e:
        print(f"❌ Health check: FAILED ({str(e)})")
        return False

def test_issues_endpoint():
    """Test issues endpoint"""
    try:
        response = requests.get(f"{API_BASE}/admin/issues", timeout=5)
        if response.status_code == 200:
            print("✅ Issues endpoint: PASSED")
            issues = response.json()
            print(f"   Found {len(issues)} issues")
            return True
        else:
            print(f"❌ Issues endpoint: FAILED (Status: {response.status_code})")
            return False
    except Exception as e:
        print(f"❌ Issues endpoint: FAILED ({str(e)})")
        return False

def main():
    print("🧪 Testing YONECO API...")
    print("=" * 40)
    
    # Test health
    health_ok = test_health()
    
    if health_ok:
        # Test issues endpoint
        test_issues_endpoint()
        print("\n✅ API is working! You can now use the Vue admin dashboard.")
    else:
        print("\n❌ API is not running. Please start it with:")
        print("   cd python_api")
        print("   python -m uvicorn main:app --reload --host 0.0.0.0 --port 8001")

if __name__ == "__main__":
    main()