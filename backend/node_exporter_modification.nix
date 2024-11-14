# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true; 

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  services.xserver.desktopManager.xfce.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kinn = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      tree
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    coreutils
    bash
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
  

  # Below is all of the config changes required for labmap2 to work on NixOS

  services.envfs.enable = true;

  # Create the textfile collector directory
  systemd.tmpfiles.rules = [
    "d /var/lib/node_exporter/textfile_collector 0755 root root -"
    "d /etc/prometheus_scripts 0755 root root -"  
    "z /etc/prometheus_scripts/logged_in_users_exporter.sh 0755 root root -"  
  ];

  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        port = 9100;
        enabledCollectors = [ "systemd" "textfile"];
        extraFlags = [ "--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" "--collector.wifi" "--collector.textfile.directory=/var/lib/node_exporter/textfile_collector"];
      };
    };
  };

  systemd.timers."logged_in_users_exporter" = {
    description = "Run logged_in_users_exporter.sh every 5 seconds";
    wantedBy = [ "multi-user.target" ];
      timerConfig = {
        OnBootSec = "5s";
        OnUnitActiveSec = "5s";
        Unit = "logged_in_users_exporter.service";
      };
  };

  systemd.services."logged_in_users_exporter" = {
    description = "Logged in users exporter";
    script = "bash /etc/prometheus_scripts/logged_in_users_exporter.sh";
    serviceConfig = {
      Environment = "PATH=/run/current-system/sw/bin";
      Type = "oneshot";
    };
    wantedBy = [ "multi-user.target" ];
  };

    environment.etc = {
    "prometheus_scripts/logged_in_users_exporter.sh" = {
      mode = "0555";
      text = ''
        #!/bin/bash
        OUTPUT_FILE="/var/lib/node_exporter/textfile_collector/logged_in_users.prom"
	> "$OUTPUT_FILE"
	loginctl list-sessions --no-legend | while read -r session_id uid user seat leader class tty idle since; do
          if [[ $class == "user" ]]; then
            state=$(loginctl show-session "$session_id" -p State --value)
            if [[ $state == "active" ]]; then
              locked_status="unlocked"
            else
              locked_status="locked"
            fi
         echo "node_logged_in_user{name=\"$user\", state=\"$locked_status\"} 1" > $OUTPUT_FILE
         fi
       done
       '';
    };
  };
}
