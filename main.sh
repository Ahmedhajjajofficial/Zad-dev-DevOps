export DISPLAY=:1
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
/home/kasm-user/.local/bin/zed --foreground --wait


code-server --install-extension /tmp/antigravity_core.vsix
code-server --install-extension /tmp/agent_autonomy_module.vsix

mkdir -p ~/.local/share/code-server/User/
cat <<EOF > ~/.local/share/code-server/User/settings.json
{
    "antigravity.agent.enabled": true,
    "antigravity.cloud.sync": "high-priority",
    "editor.fontFamily": "Fira Code",
    "terminal.integrated.gpuAcceleration": "on"
}
EOF


curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb
sudo dpkg -i cloudflared.deb
cloudflared tunnel login
cloudflared tunnel create hajjaj-cloud
cloudflared tunnel route dns hajjaj-cloud code.hajjaj-enterprise.tech


while true; do
    if ! pgrep -x "zed" > /dev/null; then
        /home/kasm-user/.local/bin/zed &
    fi
    if ! pgrep -f "code-server" > /dev/null; then
        code-server --bind-addr 0.0.0.0:8080 &
    fi
    sleep 60
done