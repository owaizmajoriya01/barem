#!/bin/bash

# Setup paths for logging detailed and summarized benchmark results
detail_output="memoryBenchmarkDetails.txt"
summary_output="memorBbenchmarkOverview.txt"

# Define the array for various thread counts to be tested
memory_threads=(1 2 4 8 16 32 64)

# Indicate the type of environment being benchmarked
environment="Owaiz_Physical"

# Ensure the summary output file has a header if not already present
if [ ! -e "$summary_output" ] || [ ! -s "$summary_output" ]; then
    echo "Environment Threads Total_Events MB_per_Second" > "$summary_output"
fi

# Execute memory benchmarks for each thread configuration
for threads in "${memory_threads[@]}"; do
    # Notify start of the benchmark in the detailed log
    echo "Starting memory benchmark with $threads thread(s)..." >> "$detail_output"
    sysbench memory --memory-block-size=1024 --memory-total-size=120G --threads=$threads run >> "$detail_output"
    echo "Completed benchmark for $threads thread(s)." >> "$detail_output"

    # Extract necessary metrics from the detailed benchmark results
    total_operations=$(awk '/total number of events:/ {print $NF}' "$detail_output" | tail -1)
    mb_per_second=$(awk '/transferred \(.MB/sec\):/ {print $(NF-1)}' "$detail_output" | tail -1)

    # Format and log the extracted data into the summary
    echo "$environment $threads $total_operations $mb_per_second" >> "$summary_output"

    # Clear the system's cache to ensure accurate subsequent tests
    echo "Clearing system cache for clean benchmark environment..." >> "$detail_output"
    sudo sync && sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
    echo "Cache cleared after testing $threads threads." >> "$detail_output"
done

echo "All memory benchmarks have been executed. See $summary_output for a summary of results."

