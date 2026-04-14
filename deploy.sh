#!/bin/bash
# ═══════════════════════════════════════════════════════
# deploy-wo-portal.sh
# Run this on your EC2 instance after SCPing the wo-portal folder
# ═══════════════════════════════════════════════════════

set -e

echo "══════════════════════════════════════"
echo "  Work Order Portal — Deployment"
echo "══════════════════════════════════════"
echo ""

# ── Step 1: Copy files to web root ──
echo "[1/4] Creating web directory..."
sudo mkdir -p /var/www/wo-portal
sudo cp index.html /var/www/wo-portal/
sudo cp assets.json /var/www/wo-portal/
sudo chown -R www-data:www-data /var/www/wo-portal
sudo chmod -R 755 /var/www/wo-portal
echo "      Files copied to /var/www/wo-portal"

# ── Step 2: Add nginx config ──
echo "[2/4] Checking nginx config..."
NGINX_CONF=$(sudo nginx -T 2>/dev/null | grep "server_name" | head -1 | awk '{print $NF}' | tr -d ';')
echo "      Server name detected: $NGINX_CONF"
echo ""
echo "      You need to add the following location block"
echo "      inside your existing server { } block:"
echo ""
echo "      ────────────────────────────────────"
cat nginx-snippet.conf
echo ""
echo "      ────────────────────────────────────"
echo ""
read -p "      Have you added the nginx snippet? (y/n): " answer
if [ "$answer" != "y" ]; then
    echo ""
    echo "      Add it manually to your nginx config, then run:"
    echo "        sudo nginx -t && sudo nginx -s reload"
    echo ""
    echo "      Your portal files are ready at /var/www/wo-portal/"
    exit 0
fi

# ── Step 3: Test and reload nginx ──
echo "[3/4] Testing nginx config..."
sudo nginx -t
echo "[3/4] Reloading nginx..."
sudo nginx -s reload
echo "      Nginx reloaded"

# ── Step 4: Verify ──
echo "[4/4] Verifying..."
echo ""
echo "══════════════════════════════════════"
echo "  DEPLOYMENT COMPLETE"
echo "══════════════════════════════════════"
echo ""
echo "  Portal URL:  https://$NGINX_CONF/wo-portal"
echo "  Files:       /var/www/wo-portal/"
echo ""
echo "  Next steps:"
echo "    1. Open the URL above in a browser"
echo "    2. Edit index.html to set your n8n webhook URL:"
echo "       sudo nano /var/www/wo-portal/index.html"
echo "       Find CONFIG.webhookUrl and update it"
echo "    3. Test a submission"
echo ""
echo "  To update the portal later:"
echo "    sudo cp index.html /var/www/wo-portal/"
echo "    sudo cp assets.json /var/www/wo-portal/"
echo ""
