#!/bin/bash
# Check if extension files exist before installing
if [ -f /tmp/antigravity_core.vsix ]; then
    code-server --install-extension /tmp/antigravity_core.vsix
fi
if [ -f /tmp/agent_autonomy_module.vsix ]; then
    code-server --install-extension /tmp/agent_autonomy_module.vsix
fi

mkdir -p ~/.local/share/code-server/User/
cat <<EOF > ~/.local/share/code-server/User/settings.json
{
    "antigravity.agent.enabled": true,
    "antigravity.cloud.sync": "high-priority",
    "editor.fontFamily": "Fira Code",
    "terminal.integrated.gpuAcceleration": "on"
}
EOF
