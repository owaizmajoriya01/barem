#!/bin/bash

# Set file names for capturing benchmark results with a custom prefix
cpu_benchmark_file="CPU_benchmarks_virtualmachines_final.txt"
benchmark_summary_file="summary_owaiz_vm.txt"
virtualization_label="Owaiz_VM_Type"
thread_arrangements=(1 2 4 8 16 32 64)

# Verify and add headers to the benchmark files if they are newly created
if [ ! -e "$cpu_benchmark_file" ]; then
  echo "Sysbench CPU Benchmarks Detail" > "$cpu_benchmark_file"
fi

if [ ! -e "$benchmark_summary_file" ]; then
  echo "Type_of_Virtualization | VM_Identifier | Thread_Count | Latency_Avg(ms) | Events_Per_Sec" > "$benchmark_summary_file"
fi

# Function to conduct sysbench tests within a specified VM and gather results
perform_sysbench_in_vm() {
    local vm_identifier=$1
    local threads=$2
    local execution_output=$(sudo lxc exec "$vm_identifier" -- sysbench cpu --cpu-max-prime=100000 --threads=$threads run)
    echo "Test run in $vm_identifier with $threads thread(s):" >> "$cpu_benchmark_file"
    echo "$execution_output" >> "$cpu_benchmark_file"

    # Extract and log the key performance indicators from the sysbench output
    local throughput=$(echo "$execution_output" | awk '/events per second:/ {print $NF}')
    local latency=$(echo "$execution_output" | awk '/avg:/ {print $NF}')

    # Log these metrics into the summary file
    echo "$virtualization_label | $vm_identifier | $threads | $latency | $throughput" >> "$benchmark_summary_file"
}

# Loop through VMs and their respective thread configurations for benchmarking
for thread_setting in "${thread_arrangements[@]}"; do
    vm_id="OwaizVM$thread_setting"  # Constructing VM identifier based on thread count
    for thread in "${thread_arrangements[@]}"; do
        perform_sysbench_in_vm $vm_id $thread
    done
done

echo "Completed CPU benchmarking for all VM setups."

