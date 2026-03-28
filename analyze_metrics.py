#!/usr/bin/env python3

"""
Metrics Analysis and CSV Export Tool for xv6-riscv

Usage:
    python3 analyze_metrics.py --input <logfile> --output <csvfile>
    python3 analyze_metrics.py --baseline  # Generate baseline CSV
"""

import csv
import json
import sys
import argparse
from datetime import datetime
from pathlib import Path

class MetricsAnalyzer:
    """Analyze xv6 metrics and export to CSV"""
    
    def __init__(self):
        self.metrics = {}
        self.processes = []
        self.system_metrics = {}
        
    def parse_kernel_output(self, log_content):
        """Parse kernel metrics output"""
        lines = log_content.strip().split('\n')
        
        current_section = None
        for line in lines:
            line = line.strip()
            if not line:
                continue
                
            if 'Extended Process Scheduling Metrics' in line:
                current_section = 'process'
            elif 'System-Wide Metrics' in line:
                current_section = 'system'
            elif line.startswith('PID'):
                # Skip header lines
                continue
            elif line.startswith('---'):
                # Skip separator lines
                continue
            elif current_section == 'process' and line[0].isdigit():
                # Parse process line
                parts = line.split('\t')
                if len(parts) >= 5:
                    try:
                        proc = {
                            'pid': int(parts[0]),
                            'name': parts[1].strip(),
                            'turnaround': int(parts[2]) if parts[2] else 0,
                            'avg_wait': int(parts[3]) if parts[3] else 0,
                            'response': int(parts[4]) if parts[4] else 0,
                            'context_switches': int(parts[5]) if len(parts) > 5 and parts[5] else 0
                        }
                        self.processes.append(proc)
                    except (ValueError, IndexError):
                        pass
            elif current_section == 'system':
                # Parse system metric line
                if ': ' in line:
                    key, value = line.split(': ', 1)
                    try:
                        # Try to convert to number
                        if value.endswith('%'):
                            self.system_metrics[key] = float(value.rstrip('%'))
                        else:
                            self.system_metrics[key] = int(value)
                    except ValueError:
                        self.system_metrics[key] = value
    
    def export_process_csv(self, output_file):
        """Export process metrics to CSV"""
        if not self.processes:
            print("No process metrics to export")
            return
        
        fieldnames = [
            'timestamp',
            'pid',
            'name',
            'turnaround_time_ticks',
            'avg_wait_ticks',
            'response_time_ticks',
            'context_switches'
        ]
        
        timestamp = datetime.now().isoformat()
        
        with open(output_file, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            
            for proc in self.processes:
                writer.writerow({
                    'timestamp': timestamp,
                    'pid': proc['pid'],
                    'name': proc['name'],
                    'turnaround_time_ticks': proc['turnaround'],
                    'avg_wait_ticks': proc['avg_wait'],
                    'response_time_ticks': proc['response'],
                    'context_switches': proc['context_switches']
                })
        
        print(f"✓ Process metrics exported to: {output_file}")
    
    def export_system_csv(self, output_file):
        """Export system metrics to CSV"""
        if not self.system_metrics:
            print("No system metrics to export")
            return
        
        fieldnames = ['timestamp', 'metric', 'value', 'unit']
        
        timestamp = datetime.now().isoformat()
        
        with open(output_file, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            
            metric_units = {
                'Elapsed Time (ticks)': 'ticks',
                'Total Processes Created': 'count',
                'Total Processes Completed': 'count',
                'Total Context Switches': 'count',
                'Total CPU Time (ticks)': 'ticks',
                'CPU Utilization': 'percent',
                'Throughput': 'count',
            }
            
            for metric, value in self.system_metrics.items():
                unit = metric_units.get(metric, 'unknown')
                writer.writerow({
                    'timestamp': timestamp,
                    'metric': metric,
                    'value': value,
                    'unit': unit
                })
        
        print(f"✓ System metrics exported to: {output_file}")
    
    def export_combined_csv(self, output_file):
        """Export all metrics to a single combined CSV"""
        fieldnames = [
            'timestamp',
            'category',
            'metric',
            'pid',
            'value',
            'unit'
        ]
        
        timestamp = datetime.now().isoformat()
        rows = []
        
        # Add system metrics
        for metric, value in self.system_metrics.items():
            unit = 'ticks' if 'ticks' in metric else ('percent' if '%' in metric else 'count')
            rows.append({
                'timestamp': timestamp,
                'category': 'system',
                'metric': metric,
                'pid': '',
                'value': value,
                'unit': unit
            })
        
        # Add process metrics
        for proc in self.processes:
            for metric_key, metric_name, unit in [
                ('turnaround', 'Turnaround Time', 'ticks'),
                ('avg_wait', 'Average Wait Time', 'ticks'),
                ('response', 'Response Time', 'ticks'),
                ('context_switches', 'Context Switches', 'count')
            ]:
                rows.append({
                    'timestamp': timestamp,
                    'category': 'process',
                    'metric': metric_name,
                    'pid': proc['pid'],
                    'value': proc[metric_key],
                    'unit': unit
                })
        
        with open(output_file, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(rows)
        
        print(f"✓ Combined metrics exported to: {output_file}")

def generate_baseline_csv(output_dir):
    """Generate baseline metrics CSV for reference"""
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    baseline_file = Path(output_dir) / 'baseline_metrics.csv'
    
    # Define baseline values
    baselines = [
        {
            'metric': 'Boot Time',
            'expected_value': 1000,
            'min_value': 500,
            'max_value': 1500,
            'unit': 'ticks',
            'description': 'Time from start to first process ready'
        },
        {
            'metric': 'Simple Echo Duration',
            'expected_value': 100,
            'min_value': 50,
            'max_value': 150,
            'unit': 'ticks',
            'description': 'Execution time of echo command'
        },
        {
            'metric': 'Process Creation Time',
            'expected_value': 60,
            'min_value': 20,
            'max_value': 100,
            'unit': 'ticks',
            'description': 'Time for fork() syscall'
        },
        {
            'metric': 'Response Time (Single Process)',
            'expected_value': 15,
            'min_value': 5,
            'max_value': 30,
            'unit': 'ticks',
            'description': 'Time from creation to first run'
        },
        {
            'metric': 'Context Switches Per Second',
            'expected_value': 200,
            'min_value': 50,
            'max_value': 500,
            'unit': 'count/sec',
            'description': 'Typical system context switches'
        },
        {
            'metric': 'CPU Utilization (Idle)',
            'expected_value': 0,
            'min_value': 0,
            'max_value': 10,
            'unit': 'percent',
            'description': 'CPU usage when no user processes'
        },
        {
            'metric': 'CPU Utilization (Loaded)',
            'expected_value': 95,
            'min_value': 80,
            'max_value': 100,
            'unit': 'percent',
            'description': 'CPU usage with user processes'
        }
    ]
    
    with open(baseline_file, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'metric',
            'expected_value',
            'min_value',
            'max_value',
            'unit',
            'description'
        ])
        writer.writeheader()
        writer.writerows(baselines)
    
    print(f"✓ Baseline metrics generated: {baseline_file}")
    return baseline_file

def main():
    parser = argparse.ArgumentParser(
        description='Analyze xv6-riscv metrics and export to CSV'
    )
    parser.add_argument(
        '--input', '-i',
        help='Input log file containing metrics output'
    )
    parser.add_argument(
        '--output', '-o',
        help='Output CSV file'
    )
    parser.add_argument(
        '--combined', '-c',
        action='store_true',
        help='Export combined metrics to single CSV'
    )
    parser.add_argument(
        '--baseline', '-b',
        action='store_true',
        help='Generate baseline metrics CSV'
    )
    parser.add_argument(
        '--output-dir', '-d',
        default='metrics_data',
        help='Output directory (default: metrics_data)'
    )
    
    args = parser.parse_args()
    
    # Generate baseline if requested
    if args.baseline:
        generate_baseline_csv(args.output_dir)
        return
    
    # Process input file if provided
    if args.input:
        analyzer = MetricsAnalyzer()
        
        try:
            with open(args.input, 'r') as f:
                content = f.read()
            analyzer.parse_kernel_output(content)
        except FileNotFoundError:
            print(f"Error: Input file '{args.input}' not found")
            sys.exit(1)
        
        # Create output directory
        Path(args.output_dir).mkdir(parents=True, exist_ok=True)
        
        if args.combined or args.output:
            if args.combined:
                output_file = Path(args.output_dir) / f"metrics_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
                analyzer.export_combined_csv(str(output_file))
            else:
                analyzer.export_process_csv(args.output + '.process.csv')
                analyzer.export_system_csv(args.output + '.system.csv')
        else:
            # Default: export both
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            analyzer.export_process_csv(f"{args.output_dir}/processes_{timestamp}.csv")
            analyzer.export_system_csv(f"{args.output_dir}/system_{timestamp}.csv")
    else:
        parser.print_help()

if __name__ == '__main__':
    main()
