#!/usr/bin/env bash
# System info popup for waybar — shows CPU, MEM, DISK, GPU usage
# Displayed via notify-send for simplicity (swaync will style it)

cpu=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.0f", $2}')
mem=$(free -m | awk '/Mem:/ {printf "%.0f", $3/$2*100}')
mem_used=$(free -h | awk '/Mem:/ {print $3}')
mem_total=$(free -h | awk '/Mem:/ {print $2}')
disk=$(df -h / | awk 'NR==2 {printf "%s/%s (%s)", $3, $2, $5}')

# GPU info (nvidia-smi if available, otherwise skip)
if command -v nvidia-smi &>/dev/null; then
    gpu_util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)
    gpu_mem=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | head -1)
    gpu_mem_used=$(echo "$gpu_mem" | cut -d',' -f1 | xargs)
    gpu_mem_total=$(echo "$gpu_mem" | cut -d',' -f2 | xargs)
    gpu_line="\n  GPU Compute: ${gpu_util}%\n  GPU VRAM: ${gpu_mem_used}/${gpu_mem_total} MiB"
else
    gpu_line=""
fi

notify-send -a "System Monitor" "System Resources" \
    "  CPU: ${cpu}%\n  Memory: ${mem_used}/${mem_total} (${mem}%)\n  Disk (/): ${disk}${gpu_line}" \
    -t 10000
