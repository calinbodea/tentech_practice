#!/bin/bash
#
#list of child nodes

child_nodes=("ec2-user@172.31.29.220" "ec2-user@172.31.85.62")

#define the thresholds for memory, CPU and disk utilization.

cpu_threshold="5"

mem_threshold="10"

disk_threshold="10"

# thentech batch 9 webhook
tentech_webhook="https://hooks.slack.com/services/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"

#check nodes memory utilization
for node in "${child_nodes[@]}"; do

node_mem=$(ssh $node '/home/ec2-user/bash_project/mem_health.sh')
        if [[ $node_mem -gt $mem_threshold ]]; then
                echo "Warning!!! Memory utilization $node_mem% on $node is above  the threshold - $mem_threshold%"
                echo "Warning!!! Memory utilization $node_mem% on $node is above  the threshold - $mem_threshold%"  | curl -X POST -H 'Content-type: application/json' --data '{"text":"'"$(cat)"'"}' https://hooks.slack.com/services/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



        fi
done

# check nodes for cpu utilization
#
for node in "${child_nodes[@]}"; do

node_cpu=$(ssh $node '/home/ec2-user/bash_project/cpu_health.sh')
"nodes_health_check.sh" 56L, 2193B                                                                                         9,16          Top
#!/bin/bash
#
child_nodes=("ec2-user@172.31.29.220" "ec2-user@172.31.85.62")
                echo "Warning!!! Memory utilization $node_mem% on $node is above  the threshold - $mem_threshold%"  | curl -X POST -H 'Content-type: application/json' --data '{"text":"'"$(cat)"'"}' https://hooks.slack.com/services/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



        fi
done

# check nodes for cpu utilization
#
for node in "${child_nodes[@]}"; do

node_cpu=$(ssh $node '/home/ec2-user/bash_project/cpu_health.sh')
        if [[ $node_mem -gt $cpu_threshold ]]; then
                echo "Warning!!! CPU  utilization $node_cpu% on $node is above  the threshold - $cpu_threshold%"
                echo "Warning!!! Memory utilization $node_cpu% on $node is above  the threshold - $cpu_threshold%"  | curl -X POST -H 'Content-type: application/json' --data '{"text":"'"$(cat)"'"}' https://hooks.slack.com/services/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



        fi
done
# check nodes for disk utilization
#
for node in "${child_nodes[@]}"; do

 node_disk=$(ssh $node '/home/ec2-user/bash_project/disk_health.sh')
        if [[ $node_disk -gt $disk_threshold ]]; then
                echo "Warning!!! Memory utilization $node_disk% on $node is above  the threshold - $disk_threshold%"
                echo "Warning!!! Memory utilization $node_disk% on $node is above  the threshold - $disk_threshold%"  | curl -X POST -H 'Content-type: application/json' --data '{"text":"'"$(cat)"'"}' https://hooks.slack.com/services/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



        fi
done
