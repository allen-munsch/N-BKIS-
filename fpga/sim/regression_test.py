#!/usr/bin/env python3
import subprocess
import sys
import os
from datetime import datetime

def run_regression():
    tests = [
        "safety_monitor_tb",
        "sensor_hub_tb"
    ]
    
    results = {}
    failed_tests = []
    
    print(f"Starting regression test at {datetime.now()}")
    print("-" * 50)
    
    for test in tests:
        print(f"Running {test}...")
        cmd = f"vsim -c -do 'do run_sim.tcl; run_test {test}; exit'"
        
        try:
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            
            # Check for errors in simulation output
            if "Error:" in result.stdout or "Failed:" in result.stdout:
                results[test] = "FAILED"
                failed_tests.append(test)
            else:
                results[test] = "PASSED"
                
        except Exception as e:
            print(f"Error running {test}: {str(e)}")
            results[test] = "ERROR"
            failed_tests.append(test)
    
    # Generate report
    print("\nRegression Test Results:")
    print("-" * 50)
    for test, status in results.items():
        print(f"{test}: {status}")
    
    print(f"\nTotal Tests: {len(tests)}")
    print(f"Passed: {len(tests) - len(failed_tests)}")
    print(f"Failed: {len(failed_tests)}")
    
    if failed_tests:
        print("\nFailed Tests:")
        for test in failed_tests:
            print(f"- {test}")
        sys.exit(1)
    else:
        print("\nAll tests passed!")
        sys.exit(0)

if __name__ == "__main__":
    run_regression()