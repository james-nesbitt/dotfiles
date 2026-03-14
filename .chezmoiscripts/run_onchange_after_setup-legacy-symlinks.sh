#!/bin/bash
# Re-usable setup for legacy tools that don't support XDG natively

# Terraform
mkdir -p ~/.local/share/terraform
ln -sfn ~/.local/share/terraform ~/.terraform.d

# Pi Coding Agent
mkdir -p ~/.local/share/pi
ln -sfn ~/.local/share/pi ~/.pi

# Mozilla (Firefox)
mkdir -p ~/.local/share/mozilla
ln -sfn ~/.local/share/mozilla ~/.mozilla

# PKI (NSS/Chrome/Certificates)
mkdir -p ~/.local/share/pki
ln -sfn ~/.local/share/pki ~/.pki
