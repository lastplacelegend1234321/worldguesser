#!/bin/bash
# Fix Nginx API Routes - Add missing location endpoints

set -e

NGINX_CONFIG="/etc/nginx/sites-available/worldguessr"
BACKUP_FILE="/etc/nginx/sites-available/worldguessr.backup.$(date +%Y%m%d_%H%M%S)"

echo "🔧 Fixing Nginx API Routes Configuration..."
echo ""

# Backup current config
echo "1️⃣ Creating backup..."
sudo cp "$NGINX_CONFIG" "$BACKUP_FILE"
echo "✅ Backup created: $BACKUP_FILE"
echo ""

# Check if routes already exist
if grep -q "location /allCountries.json" "$NGINX_CONFIG"; then
    echo "⚠️  /allCountries.json route already exists"
else
    echo "2️⃣ Adding missing API routes..."
    
    # Find the line with "location /api/" and add routes after it
    # We'll add them right after the /api/ location block
    
    # Create a temporary file with the new routes
    cat > /tmp/nginx_routes.txt << 'EOF'
    # Location data endpoints (NOT under /api/)
    location /allCountries.json {
        proxy_pass http://api_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /clueCountries.json {
        proxy_pass http://api_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location ~ ^/countryLocations/(.+)$ {
        proxy_pass http://api_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location ~ ^/mapLocations/(.+)$ {
        proxy_pass http://api_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

EOF

    # Insert after /api/ location block
    # Find the closing brace of /api/ location block and insert after it
    sudo sed -i '/location \/api\/ {/,/^    }$/ {
        /^    }$/ r /tmp/nginx_routes.txt
    }' "$NGINX_CONFIG"
    
    echo "✅ Added API routes"
fi

echo ""
echo "3️⃣ Testing Nginx configuration..."
if sudo nginx -t; then
    echo "✅ Nginx configuration is valid"
    echo ""
    echo "4️⃣ Reloading Nginx..."
    sudo systemctl reload nginx
    echo "✅ Nginx reloaded"
else
    echo "❌ Nginx configuration has errors!"
    echo "Restoring backup..."
    sudo cp "$BACKUP_FILE" "$NGINX_CONFIG"
    exit 1
fi

echo ""
echo "5️⃣ Testing endpoints..."
echo "Testing /allCountries.json..."
if curl -s -o /dev/null -w "%{http_code}" https://proguessr.com/allCountries.json | grep -q "200"; then
    echo "✅ /allCountries.json is accessible"
else
    echo "⚠️  /allCountries.json returned non-200 status"
fi

echo ""
echo "✅ Fix complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Test the site on a different computer/incognito"
echo "   2. Check browser console for any errors"
echo "   3. Verify API endpoints are working"

