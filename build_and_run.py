import subprocess
import sys
import os

def build_xv6_riscv(path):
    print("Building xv6-riscv...")
    result = subprocess.run(["make", "clean"], cwd=path)
    if result.returncode != 0:
        print("make clean failed")
        sys.exit(1)
    result = subprocess.run(["make"], cwd=path)
    if result.returncode != 0:
        print("make failed")
        sys.exit(1)
    print("Build complete.")

def run_xv6_riscv(path):
    print("Running xv6-riscv in QEMU...")
    result = subprocess.run(["make", "qemu"], cwd=path)
    if result.returncode != 0:
        print("make qemu failed")
        sys.exit(1)

def main():
    xv6_path = os.path.abspath(os.path.dirname(__file__))
    build_xv6_riscv(xv6_path)
    run_xv6_riscv(xv6_path)

if __name__ == "__main__":
    main()
