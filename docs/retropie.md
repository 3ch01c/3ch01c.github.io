# RetroPie

## Installation

This guide walks through how to install RetroPie on an existing Raspbian install.

Download and run the install script.

```sh
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup
sudo ./retropie_setup.sh
```

Optional: Enable TFT display.

```sh
curl https://raw.githubusercontent.com/adafruit/Raspberry-Pi-Installer-Scripts/master/pitft-fbcp.sh >pitft-fbcp.sh
sudo bash pitft-fbcp.sh
```