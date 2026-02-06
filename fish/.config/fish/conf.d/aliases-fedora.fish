# ~/.config/fish/conf.d/aliases-fedora.fish
# Fedora / RHEL specific aliases

if test -f /etc/fedora-release; or test -f /etc/redhat-release

    # Detect dnf vs yum
    if command -v dnf &>/dev/null
        # DNF (modern Fedora/RHEL)
        alias update='sudo dnf upgrade'
        alias install='sudo dnf install'
        alias remove='sudo dnf remove'
        alias search='dnf search'
        alias cleanpkg='sudo dnf clean all'
        alias info='dnf info'

        # Safer cleanup function
        function cleanup
            echo "Packages that can be auto-removed:"
            dnf list autoremove 2>/dev/null
            read -P "Remove these packages? [y/N] " -l response
            if test "$response" = y; or test "$response" = Y
                sudo dnf autoremove
            else
                echo "Cancelled."
            end
        end

    else
        # YUM (older RHEL/CentOS)
        alias update='sudo yum update'
        alias install='sudo yum install'
        alias remove='sudo yum remove'
        alias search='yum search'
        alias cleanpkg='sudo yum clean all'
        alias info='yum info'
    end

    # System information
    alias services='systemctl list-units --type=service'
    alias logs='journalctl -xe'
    alias firewall='sudo firewall-cmd --list-all'

    # SELinux helpers
    if command -v getenforce &>/dev/null
        alias selinux-status='getenforce'
        alias selinux-permissive='sudo setenforce 0'
        alias selinux-enforcing='sudo setenforce 1'
    end

end
