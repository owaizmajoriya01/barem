#!/bin/bash

# Define the filename for recording test outcomes
result_file_name="network_test_results_khizar.txt"

# Function for executing network performance evaluation
execute_network_test() {
    thread_number=$1
    test_result=$(iperf -c localhost -e -i 1 --nodelay -l 8M -w 2500K --trip-times --parallel $thread_number)
    measured_latency=$(echo "$test_result" | awk -F'/' '/ms/ {print $(NF-1)}')
    achieved_throughput=$(echo "$test_result" | awk '/Gbits\/sec/ {print $NF}' | tail -n 1)
    echo "$measured_latency $achieved_throughput"
}

# Setup the header in the results file
echo "Type of Virtualization | Host | Threads Used | Latency (Milliseconds) | Throughput (Gbits/Second) | Performance Efficiency" > "$result_file_name"

# Initialize iperf in server mode with specified settings
iperf -s -w 1024K &

# Establish a reference throughput for later efficiency comparisons
reference_throughput=0

# Iterate through specified thread counts for testing
for thread_count in 1 2 4 8 16 32 48 64; do
    # Retrieve latency and throughput from network test
    read latency_value throughput_value <<< $(execute_network_test $thread_count)

    # Determine the reference throughput at the initial test
    if [ "$thread_count" -eq 1 ]; then
        reference_throughput=$throughput_value
    fi

    # Set efficiency as 100% for baseline comparison
    test_efficiency=100  # Using bare metal as the standard for 100% efficiency

    # Log the detailed results for each test
    echo "Metal | Single Host | $thread_count | $latency_value | $throughput_value | $test_efficiency" >> "$result_file_name"
done

# Terminate the iperf server process
killall iperf

