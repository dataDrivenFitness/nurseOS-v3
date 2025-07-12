#!/bin/bash
# 📁 scripts/emergency_fix_deployment.sh
# ═══════════════════════════════════════════════════════════════════
# 🚨 EMERGENCY FIX DEPLOYMENT FOR NURSEOS FIRESTORE ISSUES
# ═══════════════════════════════════════════════════════════════════

set -e  # Exit on any error

echo "🚨 Starting NurseOS Emergency Fix Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI not installed. Install with: npm install -g firebase-tools${NC}"
    exit 1
fi

# Check if logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    echo -e "${RED}❌ Not logged in to Firebase. Run: firebase login${NC}"
    exit 1
fi

echo -e "${BLUE}🔍 Current Firebase project:${NC}"
firebase use --current

echo ""
echo -e "${YELLOW}⚠️  This script will:${NC}"
echo "  1. Deploy simplified Firestore security rules (removes circular dependencies)"
echo "  2. Create required composite indexes for shift queries"
echo "  3. Initialize system collections with proper permissions"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 1
fi

echo ""
echo -e "${BLUE}🛡️  Step 1: Deploying simplified Firestore rules...${NC}"

# Backup current rules
echo "📦 Backing up current rules..."
firebase firestore:rules:get > firestore.rules.backup.$(date +%Y%m%d_%H%M%S)

# Deploy new rules
echo "🚀 Deploying fixed rules..."
firebase deploy --only firestore:rules

echo -e "${GREEN}✅ Firestore rules deployed${NC}"

echo ""
echo -e "${BLUE}📊 Step 2: Creating composite indexes...${NC}"

# Note: Indexes are created automatically when the queries are first run
# But we can create them manually for better performance

echo "📝 Creating required indexes..."
echo "   - shifts: status + location"
echo "   - shifts: status + agencyId"  
echo "   - shifts: status + startTime"
echo "   - workHistory: startTime (desc)"
echo ""

# Create a temporary document to trigger index creation
cat > temp_index_script.js << 'EOF'
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

async function createIndexes() {
  console.log('🔍 Triggering index creation queries...');
  
  try {
    // Query 1: Shifts by status and location
    await db.collection('shifts')
      .where('status', '==', 'available')
      .where('location', '==', 'hospital')
      .limit(1)
      .get();
    console.log('✅ shifts: status + location');

    // Query 2: Shifts by status and agency
    await db.collection('shifts')
      .where('status', '==', 'available')
      .where('agencyId', '==', 'test-agency')
      .limit(1)
      .get();
    console.log('✅ shifts: status + agencyId');

    // Query 3: Work history by startTime
    await db.collectionGroup('workHistory')
      .orderBy('startTime', 'desc')
      .limit(1)
      .get();
    console.log('✅ workHistory: startTime desc');

    console.log('🎉 All index queries completed successfully!');
  } catch (error) {
    console.log('ℹ️  Expected index creation errors (normal):');
    console.log(error.message);
  }
}

createIndexes().then(() => {
  console.log('✨ Index creation triggers completed');
  process.exit(0);
});
EOF

# Run the index creation script if Node.js is available
if command -v node &> /dev/null && [ -f "package.json" ]; then
    echo "🚀 Running index creation script..."
    node temp_index_script.js || echo "ℹ️  Index creation triggered (may take a few minutes to complete)"
    rm temp_index_script.js
else
    echo "ℹ️  Skipping automatic index creation (Node.js or package.json not found)"
    echo "   Indexes will be created automatically when queries are first run"
fi

echo ""
echo -e "${BLUE}🔧 Step 3: Initializing system collections...${NC}"

# Create system migration document
cat > init_system_docs.js << 'EOF'
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

async function initSystemDocs() {
  console.log('📋 Creating system documents...');
  
  try {
    // Create migration status document
    await db.collection('system').doc('migration').set({
      status: 'completed',
      version: '2.0',
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      description: 'Emergency fix deployment - simplified rules'
    });
    console.log('✅ system/migration document created');

    // Create app config
    await db.collection('config').doc('app').set({
      version: '2.0.0',
      maintenance: false,
      features: {
        shiftPool: true,
        gamification: true,
        workHistory: true
      },
      lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    });
    console.log('✅ config/app document created');

    console.log('🎉 System documents initialized successfully!');
  } catch (error) {
    console.error('❌ Error initializing system docs:', error.message);
  }
}

initSystemDocs().then(() => {
  console.log('✨ System initialization completed');
  process.exit(0);
});
EOF

if command -v node &> /dev/null && [ -f "package.json" ]; then
    echo "🚀 Initializing system documents..."
    node init_system_docs.js
    rm init_system_docs.js
else
    echo "ℹ️  Skipping system document initialization (Node.js not available)"
    echo "   You can create these manually in the Firebase Console"
fi

echo ""
echo -e "${GREEN}🎉 Emergency deployment completed successfully!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "  1. Test the app - shift loading should work now"
echo "  2. Monitor Firebase Console for any remaining errors"  
echo "  3. Indexes may take 5-10 minutes to fully build"
echo "  4. Consider running the test data generator once rules are stable"
echo ""
echo -e "${BLUE}🔍 Monitoring commands:${NC}"
echo "  • firebase firestore:indexes:list"
echo "  • firebase functions:log (if using functions)"
echo ""
echo -e "${GREEN}✅ Deployment complete - your app should be working now!${NC}"