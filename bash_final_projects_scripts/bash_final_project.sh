#!/bin/bash

echo
echo "####################################################################################################"
echo
echo $(date)
#cpu use threshold
cpu_threshold="80"
 #mem idle threshold
mem_threshold="80"
 #disk use threshold
disk_threshold="90"

#tentech_webhook="https://hooks.slack.com/services/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"

echo -e "\n#################### Checking Memory, Disk space, and CPU on $HOSTNAME ####################"
echo
#---mem
#check memory utilization
check_memory_utilization() {

mem=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }' | cut -f 1 -d ".")
        if [[ $mem -lt $mem_threshold ]]; then
        echo "Memory utilization $mem% is bellow the threshold - $mem_threshold%"
        else
        echo "warning: Memory utilization $mem% is above the threshold - $mem_threshold%"
        fi
}
#---disk
#!/bin/bash
echo "####################################################################################################"
echo
echo $(date)
#cpu use threshold
cpu_threshold="80"
 #mem idle threshold
mem_threshold="80"
 #disk use threshold
disk_threshold="90"

#tentech_webhook="https://hooks.slack.com/services/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"

echo -e "\n#################### Checking Memory, Disk space, and CPU on $HOSTNAME ####################"
echo
#---mem
#check memory utilization
check_memory_utilization() {

mem=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }' | cut -f 1 -d ".")
        if [[ $mem -lt $mem_threshold ]]; then
        echo "Memory utilization $mem% is bellow the threshold - $mem_threshold%"
        else
        echo "warning: Memory utilization $mem% is above the threshold - $mem_threshold%"
        fi
#check disk utilization
check_disk_utilization() {
disk=$(df -h | awk '$NF == "/" { print $5 }' | cut -d '%' -f 1 )
        if [[ $disk -lt $disk_threshold ]];then
        echo "Disk utilization $disk% is bellow the threshold - $disk_threshold%"
        else
        echo "warning: disk utilization $disk% is above the threshold - $disk_threshold%"
        fi
        }
#---cpu
#check CPU utilization
check_CPU_utilization() {
cpu_use=$(top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}' | cut -f 1 -d ".")
if [[ $cpu_utilization -lt $cpu_threshold ]]; then
        echo "CPU utilization $cpu_use % is bellow the threshold - $cpu_threshold%";else
        echo "warning: CPU utilization $cpu_use% is above the threshold - $cpu_threshold%"
fi
}

check_memory_utilization

echo "Memory usage : $mem" >> node.log

export -f check_memory_utilization

check_disk_utilization

echo "Disk usage : $disk" >> node.log

export -f check_disk_utilization

check_CPU_utilization

echo "CPU usage : $cpu_use" >> node.log

export -f check_CPU_utilization
