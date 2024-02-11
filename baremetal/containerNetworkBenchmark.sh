#!/bin/bash

# Define the result storage file
results_file="network_metrics_containers.txt"

# Define function for conducting network analysis via iperf
perform_network_analysis() {
    target_container=$1
    concurrent_threads=$2
    analysis_output=$(sudo lxc exec "$target_container" -- iperf -c localhost -e -i 1 --nodelay -l 8M -w 2560K --trip-times --parallel $concurrent_threads)
    calculated_latency=$(echo "$analysis_output" | awk -F'/' '/ ms/ {print $(NF-1)}')
    recorded_throughput=$(echo "$analysis_output" | awk '/Gbits\/sec/ {print $NF}' | tail -n 1)
    echo "$calculated_latency $recorded_throughput"
}

# Set up the results file with headers
echo "Type of Virtualization | Container CPU Size | Threads | Latency (Milliseconds) | Throughput (Gbps)" > "$results_file"

# Function to initiate network tests within containers
initiate_container_network_tests() {
    for container_cpu in 1 2 4 8 16 32 64; do
        target_container="OwaizContainer$container_cpu"

        # Launch the iperf server in the background within the specified container
        sudo lxc exec "$target_container" -- iperf -s -w 1024K &

        # Allow a brief delay for the server to initialize
        sleep 5

        # Execute the network performance tests for varied thread counts
        for thread_count in 1 2 4 8 16 32 64; do
            # Retrieve the latency and throughput for each test
            read test_latency test_throughput <<< $(perform_network_analysis $target_container $thread_count)

            # Log the results to the designated file
            echo "LXC Container | $container_cpu | $thread_count | $test_latency | $test_throughput" >> "$results_file"
        done

        # Terminate the iperf server process within the container
        sudo lxc exec "$target_container" -- pkill iperf

        echo "Completed tests for $target_container."
    done
}

# Execute the network tests across containers
initiate_container_network_tests

echo "Finished all network performance analyses on containers."

