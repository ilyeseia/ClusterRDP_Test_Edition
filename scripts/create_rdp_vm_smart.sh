#!/bin/bash
set -e
VM_NAME="RDP-VM$(date +%s | tail -c 2)"
echo "ðŸš€ Creating $VM_NAME..."
docker run -d --name $VM_NAME --hostname $VM_NAME ubuntu sleep infinity
echo "ðŸ”— Starting Tailscale inside $VM_NAME..."
docker exec -d $VM_NAME tailscaled
docker exec -d $VM_NAME tailscale up --authkey=${{ secrets.TAILSCALE_AUTH_KEY }} --hostname=$VM_NAME
TS_IP=$(docker exec $VM_NAME tailscale ip -4 | head -n1)
echo "âœ… $VM_NAME created with Tailscale IP: $TS_IP"

# Gmail notification
echo "ðŸ“§ Sending Gmail notification..."
python3 - <<'PYCODE'
import smtplib, ssl, os
from email.mime.text import MIMEText

user = os.getenv("GMAIL_USER")
pwd = os.getenv("GMAIL_PASS")
msg = MIMEText(f"Machine {os.getenv('VM_NAME','RDP-VM')} created successfully.")
msg["Subject"] = "ðŸ–¥ï¸ RDP VM Created"
msg["From"] = user
msg["To"] = user

context = ssl.create_default_context()
with smtplib.SMTP("smtp.gmail.com", 587) as server:
    server.starttls(context=context)
    server.login(user, pwd)
    server.send_message(msg)
PYCODE
