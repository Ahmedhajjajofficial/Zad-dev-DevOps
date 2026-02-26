#!/bin/bash
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb
# sudo might not be available or needed in some container environments, but included as per plan
sudo dpkg -i cloudflared.deb || dpkg -x cloudflared.deb .
# These commands require interactive login or existing tokens
# cloudflared tunnel login
# cloudflared tunnel create hajjaj-cloud
# cloudflared tunnel route dns hajjaj-cloud code.hajjaj-enterprise.tech
