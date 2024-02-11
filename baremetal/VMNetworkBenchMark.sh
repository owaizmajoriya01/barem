#!/bin/bash

# Specify the file for capturing test outcomes
test_results_file="network_performance_vms.txt"

# Define a procedure for executing iperf evaluations
conduct_iperf_evaluation() {
    virtual_machine=$1
    num_threads=$2
    evaluation_results=$(sudo lxc exec "$virtual_machine" -- iperf -c localhost -e -i 1 --nodelay -l 8M -w 2560K --trip-times --parallel $num_threads)
    extract_latency=$(echo "$evaluation_results" | awk -F'/' '/ ms/ {print $(NF-1)}')
    extract_throughput=$(echo "$evaluation_results" | awk '/Gbits\/sec/ {print $NF}' | tail -n 1)
    echo "$extract_latency $extract_throughput"
}

# Initialize the results file with headers
echo "Type | Host | Thread Count | Latency (Milliseconds) | Throughput (Gbps)" > "$test_results_file"

# Define a function to initiate tests across virtual machines
initiate_vm_tests() {
    for thread_variation in 1 2 4 8 16 32 64; do
        virtual_machine_id="OwaizVM$thread_variation"

        # Launch the iperf server within the virtual machine
        sudo lxc exec "$virtual_machine_id" -- iperf -s -w 1M &

        # Allow the server a moment to become operational
        sleep 5

        # Iterate through thread counts for testing
        for thread_count in 1 2 4 8 16 32 64; do
            # Retrieve latency and throughput measurements
            read latency_measurement throughput_measurement <<< $(conduct_iperf_evaluation $virtual_machine_id $thread_count)

            # Record the findings in the designated file
            echo "Virtual Machine | $thread_variation | $thread_count | $latency_measurement | $throughput_measurement" >> "$test_results_file"
        done

        # Cease the iperf server process within the virtual machine
        sudo lxc exec "$virtual_machine_id" -- pkill iperf

        echo "Completed tests for $virtual_machine_id."
    done
}

# Execute the network performance tests on each virtual machine
initiate_vm_tests

echo "Finished network performance evaluations for all virtual machines."

