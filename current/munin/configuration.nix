# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix = {
    package = pkgs.nixVersions.stable;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "munin"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  #   useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Fixes for longhorn
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];
  virtualisation.docker.logDriver = "json-file";

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";
  services.k3s = {
    enable = true;
    role = "server";
    # tokenFile = "/var/lib/rancher/k3s/server/token";
    token = "KedjC7m3tXf5Td79";
    extraFlags = toString ([
	    "--write-kubeconfig-mode \"0644\""
	    "--cluster-init"
	    "--disable servicelb"
	    "--disable traefik"
	    "--disable local-storage"
    ] ++ (if config.networking.hostName == "hugin" then [] else [
	      "--server https://hugin:6443"
    ]));
    clusterInit = (config.networking.hostName == "hugin");
  };

  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:${config.networking.hostName}";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.artur = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    hashedPassword = "$6$l6AAOVY.u9WoF7Br$MptWQn6nMdQw28UPDiW840pO6Yh8vYh2KcVWJURwdodxJdqxly1nWNij1f7MiGgYcVjbN9xdo6.zI1TQIuvAa1";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHBPoCDAyJXU/o9QUK52/4bHP+y5STiw6i5KnGJo7LcyubljHPPiyHRb+JwtZ2unCgZZ/DLsluEtqfKqmUEc3uaGISQvpac4i392bS0S89yJDYl2qfZ6/vpTURSGfXkjvYinc4iY0OpkCuiIqv/t5rYL8SigQKUtxZsEWUO3gpLk7b6I611UiElnhPAYL1GZDRHETT8EapoYLxP6h3Wn6xLQ8iS9xK2Mw+DRtuJSZRPrG1sjmLEUt9vCUWigDw/+iLdQ/rlUPEXgdfQ91wnhzaurVkvXsZBBCGEm1mha84zxYqFxbe3Nd1Sghx/gdxWN8KvOUe1EYMBCO1CRg20AaYBj9DNhLLGSYmV91u7ypqv7LbdzJnE2LNE+xCG5+g80jTqIHZ6QBR+p7kWHd6SHV1+tiqpzjD6ON1rCmGldOdfbBsJx43TWm1lxm5bck+4rordwh3rfwVud7B2Y8tkXIxY/j/sbtyiQqhmzcmhgk3WnelPnqt87615ryugUaBalv5P0WhXitBFlxK7xVP1Aa71W1ykIwRQdeu/nILZCLDn4CCXwb9LewK7Y8rbr0TOJ0wfLZdX/5JZKr5F09/T55RNT/cfnH6lsIlCsWQnmTvdrbObDco6ZIKRIDDMyyJFeeXUSVGNtoIsP/2/4IYqt6ET3yC9TlD4QxPeaCKKFX5aw== artur@ak-aeon"
    ];
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    curl
    k3s
    htop
    cifs-utils
    nfs-utils
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

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
  # system.copySystemConfiguration = true;

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
  system.stateVersion = "25.05"; # Did you read the comment?

}
