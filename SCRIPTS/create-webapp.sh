#!/bin/bash
# create-webapp.sh — Scaffold a modern web app with Bun + Next.js + Tailwind
# Usage: ./create-webapp.sh <app-name> [--api | --full]

set -euo pipefail

WORKSPACE="/root/jazz-workspace"
NAME="${1:?Usage: create-webapp.sh <app-name> [--api | --full]}"
TYPE="${2:-full}"
TARGET="$WORKSPACE/PROJECTS/$NAME"

if [ -d "$TARGET" ]; then
    echo "Project '$NAME' already exists at $TARGET"
    exit 1
fi

echo "Creating web app: $NAME (type: $TYPE)"

if [ "$TYPE" = "--api" ]; then
    # Hono API server
    mkdir -p "$TARGET"
    cd "$TARGET"
    bun init -y
    bun add hono
    cat > src/index.ts << 'EOF'
import { Hono } from 'hono'

const app = new Hono()

app.get('/', (c) => c.json({ message: 'Hello from Jazz🔥 API!' }))

export default app
EOF
    mkdir -p src
    # Adjust for bun init file structure
    if [ -f "index.ts" ]; then
        mv index.ts src/index.ts 2>/dev/null || true
    fi
    cat > src/index.ts << 'APIEOF'
import { Hono } from 'hono'

const app = new Hono()

app.get('/', (c) => c.json({ message: 'Hello from Jazz🔥 API!' }))

export default app
APIEOF
    # Update package.json scripts
    cat > package.json << 'PKGEOF'
{
  "name": "$NAME",
  "type": "module",
  "scripts": {
    "dev": "bun run --watch src/index.ts",
    "build": "bun build src/index.ts --outdir dist",
    "start": "bun run dist/index.js"
  },
  "dependencies": {
    "hono": "^4"
  }
}
PKGEOF
    sed -i "s/\$NAME/$NAME/g" package.json

elif [ "$TYPE" = "--full" ] || [ "$TYPE" = "full" ]; then
    # Full Next.js app with Tailwind
    mkdir -p "$TARGET"
    cd "$TARGET"
    bun create next-app . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" 2>&1 || {
        echo "Falling back to manual Next.js setup..."
        bun init -y
        bun add next react react-dom
        bun add -d typescript @types/react @types/node
        mkdir -p src/app
        cat > src/app/layout.tsx << 'EOF'
import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: '$NAME',
  description: 'Created by Jazz🔥 & Faisu🌪️',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
EOF
        cat > src/app/page.tsx << 'EOF'
export default function Home() {
  return (
    <main className="flex min-h-screen items-center justify-center">
      <h1 className="text-4xl font-bold">$NAME</h1>
    </main>
  )
}
EOF
        cat > src/app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF
    }
fi

# Add project template files
cd "$TARGET"
cat > .env.example << 'EOF'
# App Configuration
NODE_ENV=development
PORT=3000
EOF

cat > NOTES.md << 'EOF'
# $NAME — Notes

## Goals
- 

## Design Decisions
- 

## Log
- Created: $(date +%Y-%m-%d)
EOF

# Init git
git init 2>/dev/null
git add -A 2>/dev/null
git commit -q -m "Initial commit: $NAME" 2>/dev/null || true

echo "✅ Created web app: $NAME"
echo "   Location: $TARGET"
echo "   Dev:      cd $TARGET && bun run dev"
echo "   Build:    cd $TARGET && bun run build"
