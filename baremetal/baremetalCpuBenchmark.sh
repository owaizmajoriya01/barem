#!/bin/bash

# Define file paths for output
benchmark_detail_file="cpu_benchmark_details_owaiz.txt"
benchmark_overview_file="cpu_performance_overview_owaiz.txt"
environment_type="Metal_Owaiz"
thread_options=(1 2 4 8 16 32 64)

# Check and create detailed benchmark file with header if not present
if [ ! -f "$benchmark_detail_file" ]; then
  echo "In-depth Benchmarking Data" > "$benchmark_detail_file"
fi

# Check and create summary benchmark file with header if not present
if [ ! -f "$benchmark_overview_file" ]; then
  echo "Env_Type | Thread_Count | Mean_Latency(ms) | Operations_Second" > "$benchmark_overview_file"
fi

# Perform benchmarks for different CPU thread counts
for num_threads in "${thread_options[@]}"; do
  # Execute the benchmark using sysbench and save the output
  result=$(sysbench cpu --cpu-max-prime=20000 --threads=$num_threads run)
  echo "Benchmark for $num_threads thread(s):" >> "$benchmark_detail_file"
  echo "$result" >> "$benchmark_detail_file"

  # Extract key metrics from the benchmark result
  ops_per_second=$(echo "$result" | awk '/events per second:/ {print $NF}')
  avg_latency=$(echo "$result" | awk '/avg:/ {print $NF}')

  # Append these metrics to the summary file
  echo "$environment_type | $num_threads | $avg_latency | $ops_per_second" >> "$benchmark_overview_file"
done

echo "CPU benchmarking task completed for varied thread counts."

