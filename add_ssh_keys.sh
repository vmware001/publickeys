#!/usr/bin/env bash
set -euo pipefail

# 把公钥直接粘贴到下面双引号之间，每行一条；后续新增直接加行即可
paste_here="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJl7jqc1dUeXAtjjYt99GmFGDxOS+muwOSru1qw21H/d vm001@admin
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObzPFegQQDjF/i9nyBJgFKPkNK3jKedyBBKLKsUt1ol mac-mini
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5AzNlxdjEH/gKLuHncuHG16ALel06xm90ZGU8Uhdhf lenovo
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB8R+/1Ypa+hNmxhJ6GnRLNRltFQpG1fjVckaUMBUXft u0_a439@localhost
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIy+t4sZkh5rf4DLhgpEbKHdKho1ldQNXwdrm9yue+8 u0_a330@localhost"

SSH_DIR="$HOME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

touch "$AUTH_KEYS"
chmod 600 "$AUTH_KEYS"

added=0
skipped=0

while IFS= read -r line || [[ -n "$line" ]]; do
    key=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    [[ -z "$key" ]] && continue
    [[ "$key" =~ ^# ]] && continue

    label=$(echo "$key" | awk '{print $1" "$2}')

    if grep -qxF "$key" "$AUTH_KEYS"; then
        echo "已存在，跳过: $label"
        skipped=$((skipped + 1))
    else
        printf '%s\n' "$key" >> "$AUTH_KEYS"
        echo "已添加: $label"
        added=$((added + 1))
    fi
done <<< "$paste_here"

echo "完成。新增 $added 条，跳过 $skipped 条。authorized_keys 总行数: $(wc -l < "$AUTH_KEYS")"
