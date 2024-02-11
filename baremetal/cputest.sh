#!/bin/bash

# Initialize file names
result_file="results_sysbench.txt"
analysis_file="analysis_sysbench.txt"
vm_type="Physical"

# Thread configurations to test
thread_settings=(1 2 4 8 16 32 64)

# Create result file with header if it doesn't exist
if [ ! -e "$result_file" ]; then
  echo "Sysbench Results" > "$result_file"
fi

# Ensure analysis file has a header if it's newly created
if [ ! -e "$analysis_file" ]; then
  echo "VM_Type Thread_Count Average_Latency Performance" > "$analysis_file"
fi

# Iterate over each thread configuration and execute sysbench
for thread_count in "${thread_settings[@]}"; do
  # Execute sysbench and save the output
  output=$(sysbench cpu --cpu-max-prime=100000 --threads=$thread_count run)
  echo "Execution with $thread_count thread(s):" >> "$result_file"
  echo "$output" >> "$result_file"

  # Parse the relevant metrics from sysbench output
  performance_metric=$(echo "$output" | awk '/events per second:/ {print $NF}')
  average_latency=$(echo "$output" | awk '/avg:/ {print $NF}')

  # Record the extracted data in the analysis file
  echo "$vm_type              $thread_count    $average_latency   $performance_metric" >> "$analysis_file"
done

echo "Sysbench evaluation completed across thread configurations."

