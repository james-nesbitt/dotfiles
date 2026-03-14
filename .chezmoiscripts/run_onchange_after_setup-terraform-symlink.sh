#!/bin/bash
# Terraform legacy symlink
mkdir -p ~/.local/share/terraform
ln -sfn ~/.local/share/terraform ~/.terraform.d

# Pi legacy symlink
mkdir -p ~/.local/share/pi
ln -sfn ~/.local/share/pi ~/.pi
