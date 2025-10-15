#!/bin/bash
set -e

VM_NAME="RDP-VM$(date +%s | tail -c 2)"
echo "🚀 Creating $VM_NAME..."

# تشغيل الحاوية من الصورة المخصصة
docker run -d --name $VM_NAME --hostname $VM_NAME ubuntu-tailscale

echo "🛡️ Starting Tailscale inside $VM_NAME..."
docker exec -d $VM_NAME tailscaled
docker exec $VM_NAME tailscale up --authkey="${TAILSCALE_AUTH_KEY}" --hostname="$VM_NAME"

TS_IP=$(docker exec $VM_NAME tailscale ip -4 | head -n1)
echo "✅ $VM_NAME created with Tailscale IP: $TS_IP"

# Gmail notification
echo "📧 Sending Gmail notification..."
python3 - <<'PYCODE'
import smtplib, ssl, os
from email.mime.text import MIMEText

user = os.getenv("GMAIL_USER")
pwd = os.getenv("GMAIL_PASS")
vm_name = os.getenv("VM_NAME", "RDP-VM")

msg = MIMEText(f"Machine {vm_name} created successfully.")
msg["Subject"] = "🚀 RDP VM Created"
msg["From"] = user
msg["To"] = user

context = ssl.create_default_context()
with smtplib.SMTP("smtp.gmail.com", 587) as server:
    server.starttls(context=context)
    server.login(user, pwd)
    server.send_message(msg)
PYCODE
