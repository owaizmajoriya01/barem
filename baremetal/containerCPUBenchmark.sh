#!/bin/bash

# Define paths for output files related to benchmarking and analysis
results_file="cpu_benchmarks_in_containers.txt"
metrics_file="cpu_performance_summary.txt"
env_type="DockerEnv"

# Specify container configurations for testing
cpu_configs=(1 2 4 8 16 32 64)

# Ensure the results file has a starting header if it's being created anew
if [ ! -f "$results_file" ]; then
  echo "Benchmarking Results for Container Configurations" > "$results_file"
fi

# Check for the existence of the performance summary file and add a header if needed
if [ ! -f "$metrics_file" ]; then
  echo "Environment | CPU Threads | Average Latency (ms) | Events/Second" > "$metrics_file"
fi

# Iterate over each configuration to perform and record benchmarks
for cpu_setting in "${cpu_configs[@]}"; do
  container_id="OwaizContainer$cpu_setting"
  echo "Performing benchmark in $container_id with $cpu_setting CPU thread(s):" >> "$results_file"
  
  # Run the benchmark test within the specified container and log the output
  output=$(sudo lxc exec "$container_id" -- sysbench cpu --cpu-max-prime=100000 --threads=$cpu_setting run)
  echo "$output" >> "$results_file"

  # Extract performance metrics from the test results
  events_second=$(echo "$output" | awk '/events per second:/ {print $NF}')
  latency_avg=$(echo "$output" | awk '/avg:/ {print $NF}')

  # Record these metrics in the performance summary file
  echo "$env_type | $cpu_setting | $latency_avg | $events_second" >> "$metrics_file"
done

echo "Completed benchmarking in containers across specified CPU thread configurations."

