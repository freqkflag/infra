#!/bin/bash
# Import Starter Content into Ghost via Admin API

set -e

API_KEY="691e6c1a92778f00014b9ebd:ffdb16ec163e3955e6cb3ccf7ca368bdd247d296d"
GHOST_URL="https://cultofjoey.com"
AUTH_HEADER="Authorization: Ghost ${API_KEY}"
API_BASE="${GHOST_URL}/ghost/api/admin"

echo "🚀 Starting Ghost starter content import..."
echo "📍 Ghost URL: ${GHOST_URL}"
echo ""

# Function to create tag
create_tag() {
    local name=$1
    local slug=$2
    local desc=$3
    echo -n "  Creating tag: ${name}... "
    response=$(curl -s -X POST "${API_BASE}/tags/" \
        -H "${AUTH_HEADER}" \
        -H "Content-Type: application/json" \
        -H "Accept-Version: v5.0" \
        -d "{\"tags\":[{\"name\":\"${name}\",\"slug\":\"${slug}\",\"description\":\"${desc}\"}]}")
    
    if echo "$response" | grep -q "\"name\":\"${name}\""; then
        echo "✅"
    elif echo "$response" | grep -q "already exists\|duplicate"; then
        echo "✅ (already exists)"
    else
        echo "❌"
        echo "    Error: $response" | head -3
    fi
}

# Function to create post
create_post() {
    local title=$1
    local slug=$2
    local mobiledoc=$3
    local excerpt=$4
    local tags=$5
    local published_at=$6
    local featured=${7:-false}
    
    echo -n "  Creating post: ${title}... "
    
    response=$(curl -s -X POST "${API_BASE}/posts/" \
        -H "${AUTH_HEADER}" \
        -H "Content-Type: application/json" \
        -H "Accept-Version: v5.0" \
        -d "{
            \"posts\":[{
                \"title\":\"${title}\",
                \"slug\":\"${slug}\",
                \"mobiledoc\":${mobiledoc},
                \"status\":\"published\",
                \"custom_excerpt\":\"${excerpt}\",
                \"featured\":${featured},
                \"tags\":${tags},
                \"published_at\":\"${published_at}\"
            }]
        }")
    
    if echo "$response" | grep -q "\"title\":\"${title}\""; then
        echo "✅"
    else
        echo "❌"
        echo "    Error: $response" | head -3
    fi
}

# Function to create page
create_page() {
    local title=$1
    local slug=$2
    local mobiledoc=$3
    
    echo -n "  Creating page: ${title}... "
    
    response=$(curl -s -X POST "${API_BASE}/pages/" \
        -H "${AUTH_HEADER}" \
        -H "Content-Type: application/json" \
        -H "Accept-Version: v5.0" \
        -d "{
            \"pages\":[{
                \"title\":\"${title}\",
                \"slug\":\"${slug}\",
                \"mobiledoc\":${mobiledoc},
                \"status\":\"published\"
            }]
        }")
    
    if echo "$response" | grep -q "\"title\":\"${title}\""; then
        echo "✅"
    else
        echo "❌"
        echo "    Error: $response" | head -3
    fi
}

echo "📋 Step 1: Creating tags..."
create_tag "calm" "calm" "For calm, peaceful posts (teal tint)"
create_tag "manic" "manic" "For energetic, intense posts (magenta tint)"
create_tag "reflective" "reflective" "For thoughtful, introspective posts (indigo tint)"
create_tag "defiant" "defiant" "For bold, rebellious posts (orange tint)"
create_tag "workshop" "workshop" "For workshop/project posts"
create_tag "gallery" "gallery" "For gallery posts"
create_tag "Tech" "tech" "Technology and homelab content"
create_tag "Cosplay" "cosplay" "Cosplay projects"
echo ""

echo "📝 Step 2: Creating posts..."

# Calculate dates (relative to now)
POST1_DATE=$(date -u -d "2 days ago" +"%Y-%m-%dT%H:%M:%S.000Z" 2>/dev/null || date -u -v-2d +"%Y-%m-%dT%H:%M:%S.000Z" 2>/dev/null || echo "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)")
POST2_DATE=$(date -u -d "7 days ago" +"%Y-%m-%dT%H:%M:%S.000Z" 2>/dev/null || date -u -v-7d +"%Y-%m-%dT%H:%M:%S.000Z" 2>/dev/null || echo "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)")
POST3_DATE=$(date -u -d "14 days ago" +"%Y-%m-%dT%H:%M:%S.000Z" 2>/dev/null || date -u -v-14d +"%Y-%m-%dT%H:%M:%S.000Z" 2>/dev/null || echo "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)")

# Post 1: Signal in the Static
MOBILEDOC1='{"version":"0.3.1","atoms":[],"cards":[],"markups":[],"sections":[[1,"p",[[0,[],0,"The hum of the server rack is a comfort. It'\''s a consistent, white noise that drowns out the chaotic frequency of the outside world. Yesterday, I tore down the entire cluster."]]],[1,"p",[[0,[],0,"Why? Because sometimes you need to burn it down to build it right. The dependencies were tangled, the legacy configurations were haunting the logs, and frankly, it just didn'\''t feel clean anymore."]]],[1,"p",[[0,[],0,"Recovery isn'\''t a straight line. It'\''s a recursive function with no exit condition sometimes."]]],[1,"p",[[0,[],0,"Rebuilding the Kubernetes cluster felt like a ritual. Flashing the ISOs, bootstrapping the nodes, watching the pods come alive one by one. Green status lights in the dark."]]]]}'

create_post "Signal in the Static" "signal-in-the-static" "${MOBILEDOC1}" \
    "Navigating the noise of modern existence while rebuilding a homelab from scratch. A metaphor for mental recovery." \
    '[{"name":"reflective"},{"name":"Tech"}]' \
    "${POST1_DATE}" false

# Post 2: Cyber-Samurai Armor V2
MOBILEDOC2='{"version":"0.3.1","atoms":[],"cards":[],"markups":[],"sections":[[1,"h2",[[0,[],0,"Summary"]]],[1,"p",[[0,[],0,"This project combines traditional cosplay fabrication with modern electronics to create a fully illuminated armor set."]]],[1,"h2",[[0,[],0,"Specs"]]],[1,"ul",[[[0,[],0,"EVA Foam base structure"]],[[0,[],0,"Arduino Nano for control"]],[[0,[],0,"WS2812B LED strips"]],[[0,[],0,"Custom C++ firmware"]],[[0,[],0,"Battery-powered for portability"]]]],[1,"h2",[[0,[],0,"Process"]]],[1,"p",[[0,[],0,"Your process documentation here"]]]]}'

create_post "Cyber-Samurai Armor V2" "cyber-samurai-armor-v2" "${MOBILEDOC2}" \
    "Full body EVA foam armor with integrated Arduino-controlled RGB lighting." \
    '[{"name":"workshop"},{"name":"Cosplay"}]' \
    "${POST2_DATE}" false

# Post 3: Welcome to the Signal
MOBILEDOC3='{"version":"0.3.1","atoms":[],"cards":[],"markups":[],"sections":[[1,"p",[[0,[],0,"This is your space. A place where queer rave culture meets technical homelab energy, where mental health storytelling finds its voice, and where creative workshops come to life."]]],[1,"p",[[0,[],0,"The Cult of Joey isn'\''t a cult—it'\''s a community. It'\''s a frequency. It'\''s the static between channels where the real signal lives."]]]]}'

create_post "Welcome to the Signal" "welcome-to-the-signal" "${MOBILEDOC3}" \
    "Your first transmission. Welcome to the frequency." \
    '[{"name":"calm"}]' \
    "${POST3_DATE}" true

echo ""

echo "📄 Step 3: Creating pages..."

# Contact page
MOBILEDOC_PAGE='{"version":"0.3.1","atoms":[],"cards":[],"markups":[],"sections":[[1,"h2",[[0,[],0,"SUMMON ME"]]],[1,"p",[[0,[],0,"Open for collaborations on:"]]],[1,"ul",[[[0,[],0,"Creative Coding / Web Dev"]],[[0,[],0,"Cosplay fabrication advice"]],[[0,[],0,"Homelab architecture"]],[[0,[],0,"Speaking on mental health & tech"]]]],[1,"h3",[[0,[],0,"SECURE CHANNEL:"]]],[1,"p",[[0,[],0,"joey@cultofjoey.com"]]]]}'

create_page "Summon Me" "contact" "${MOBILEDOC_PAGE}"

echo ""
echo "✅ Starter content imported successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Go to Ghost Admin → Settings → Navigation"
echo "   2. Add menu items: Journal, Workshops, Gallery, Contact"
echo "   3. Customize your content as needed"
echo ""

