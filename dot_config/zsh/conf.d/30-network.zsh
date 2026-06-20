# 30-network.zsh — network diagnostics and monitoring aliases

# ── DNS ────────────────────────────────────────────────────────────────────────────
alias digx='dig +short'                      # compact: just the answer
alias diga='dig ANY +short'                  # all record types
alias dig6='dig AAAA +short'                 # IPv6 only
alias digr='dig +short -x'                   # reverse DNS lookup

# ── Connections & ports ────────────────────────────────────────────────────────────
alias ports='ss -tlnp'                       # listening TCP ports (also in 30-convenience)
alias ports6='ss -tlnp6'                     # listening IPv6 ports
alias conns='ss -tnp'                        # established TCP connections
alias sockstat='ss -s'                       # socket summary statistics
alias lsports='netstat -tulnp 2>/dev/null || ss -tlnp'  # fallback-safe

# ── Traffic capture & inspection ──────────────────────────────────────────────────
# sniff [host] — launch termshark on the default interface, optionally
#               filtering to traffic from/to a specific host.
#
# Examples:
#   sniff                      # all traffic, interactive TUI
#   sniff 192.168.1.50         # traffic from/to that host only
#   sniff 10.0.0.1 eth0        # specify interface as second arg
sniff() {
  if ! command -v termshark &>/dev/null; then
    echo "termshark not installed" >&2; return 1
  fi
  local host="${1:-}"
  local iface="${2:-}"
  local -a args=()
  [[ -n "${iface}" ]] && args+=(-i "${iface}")
  if [[ -n "${host}" ]]; then
    sudo termshark "${args[@]}" host "${host}"
  else
    sudo termshark "${args[@]}"
  fi
}

# cap [file] [filter] — quick tcpdump to a pcap file
# Examples:
#   cap /tmp/out.pcap
#   cap /tmp/out.pcap 'host 10.0.0.5'
#   cap /tmp/out.pcap 'port 443'
cap() {
  local file="${1:-/tmp/capture-$(date +%Y%m%d-%H%M%S).pcap}"
  local filter="${2:-}"
  echo "Capturing to ${file}${filter:+ (filter: ${filter})} — Ctrl+C to stop"
  sudo tcpdump -i any -w "${file}" ${filter:+"${filter}"}
}

# watch-host <ip> — pipe tcpdump into termshark filtered to one host
watch-host() {
  local host="${1:?watch-host requires a host IP or hostname}"
  if ! command -v termshark &>/dev/null; then
    echo "termshark not installed" >&2; return 1
  fi
  echo "Watching traffic for ${host} — Ctrl+C to stop"
  sudo tcpdump -i any host "${host}" -w - 2>/dev/null | termshark -r -
}

# ── Bandwidth monitoring ───────────────────────────────────────────────────────────
alias bw='bandwhich'                         # per-connection bandwidth (Rust)
alias bwh='sudo nethogs'                     # per-process bandwidth
alias bwi='sudo iftop'                       # per-interface with remote IPs

# ── Ping & routing ────────────────────────────────────────────────────────────────
alias pg='ping -c 4'                         # 4-packet ping
alias pgv='gping'                            # visual ping graph
alias trace='mtr --report-wide --show-ips'   # full-path analysis
alias tracec='mtr --curses --show-ips'       # interactive curses trace

# ── Scan ────────────────────────────────────────────────────────────────────────────
alias scan='nmap -sV --open'                 # version scan open ports
alias scan-quick='nmap -T4 -F'              # fast scan top 100 ports
alias scan-full='sudo nmap -sS -sV -O -p-'  # full stealth scan all ports
alias lan='nmap -sn'                         # ping sweep (host discovery)
