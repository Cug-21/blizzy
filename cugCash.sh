# Check if app name is provided
if [ -z "$1" ]; then
    echo "Usage: ./create-app.sh <app_name>"
    echo "Example: ./create-app.sh twitter"
    exit 1
fi

APP_NAME=$1
PROJECT_DIR="$APP_NAME"
BACKEND_DIR="${PROJECT_DIR}/${APP_NAME}-backend"
FRONTEND_DIR="${PROJECT_DIR}/${APP_NAME}-frontend"

echo "Creating ${APP_NAME} application..."

# Create main project directory
mkdir -p "$PROJECT_DIR"

# Ask about frontend framework
echo ""
echo "Choose frontend setup:"
echo "1) Vite (React)"
echo "2) Create React App (npx)"
read -p "Enter choice (1 or 2): " FRONTEND_CHOICE

# ==========================================
# BACKEND STRUCTURE
# ==========================================
echo ""
echo "Creating backend structure..."

mkdir -p "$BACKEND_DIR/app/routes"
mkdir -p "$BACKEND_DIR/app/service"
mkdir -p "$BACKEND_DIR/app/util"

# Create backend __init__.py
cat > "$BACKEND_DIR/app/__init__.py" << 'EOF'
from flask import Flask
from flask_cors import CORS

def create_app():
    app = Flask(__name__)
    
    app.config['SECRET_KEY'] = 'your-secret-key'
    
    CORS(app, 
         origins=['http://localhost:3000', 'http://localhost:5173'],
         supports_credentials=True,
         allow_headers=['Content-Type', 'Authorization'],
         methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']
    )
    
    # Register blueprints here
    
    return app
EOF

# Create app.py in root
cat > "$BACKEND_DIR/app.py" << 'EOF'
from app import create_app

app = create_app()

if __name__ == '__main__':
    app.run(debug=False, host='127.0.0.1', port=5000)
EOF

# Create requirements.txt
cat > "$BACKEND_DIR/requirements.txt" << 'EOF'
Flask==3.0.0
Flask-CORS==4.0.0
python-dotenv==1.0.0
EOF

# Create .gitignore for backend
cat > "$BACKEND_DIR/.gitignore" << 'EOF'
__pycache__/
*.pyc
venv/
.env
*.db
EOF

# Install Python packages
echo ""
echo "Installing Python packages..."
cd "$BACKEND_DIR"
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate
cd ../..

# ==========================================
# FRONTEND STRUCTURE
# ==========================================
echo ""
echo "Creating frontend structure..."

if [ "$FRONTEND_CHOICE" == "1" ]; then
    # Vite setup
    echo "Setting up Vite React app..."
    cd "$PROJECT_DIR"
    npm create vite@latest "${APP_NAME}-frontend" -- --template react
    cd "${APP_NAME}-frontend"
    
    # Create src subdirectories
    mkdir -p src/pages
    mkdir -p src/components
    mkdir -p src/services
    mkdir -p src/config
    
    # Install dependencies
    npm install
    npm install axios react-router-dom
    
    cd ../..
    
elif [ "$FRONTEND_CHOICE" == "2" ]; then
    # Create React App setup
    echo "Setting up Create React App..."
    cd "$PROJECT_DIR"
    npx create-react-app "${APP_NAME}-frontend"
    cd "${APP_NAME}-frontend"
    
    # Create src subdirectories
    mkdir -p src/pages
    mkdir -p src/components
    mkdir -p src/services
    mkdir -p src/config
    
    # Install additional dependencies
    npm install axios react-router-dom
    
    cd ../..
else
    echo "Invalid choice. Skipping frontend setup."
fi

echo ""
echo "✅ Done! Your app structure:"
echo "📁 ${APP_NAME}/"
echo "   ├── ${APP_NAME}-backend/"
echo "   │   ├── app/"
echo "   │   │   ├── __init__.py"
echo "   │   │   ├── routes/"
echo "   │   │   ├── service/"
echo "   │   │   └── util/"
echo "   │   ├── app.py"
echo "   │   └── requirements.txt"
echo "   └── ${APP_NAME}-frontend/"
echo "       └── src/"
echo "           ├── pages/"
echo "           ├── components/"
echo "           ├── services/"
echo "           └── config/"
echo ""
echo "To start backend: cd ${APP_NAME}/${APP_NAME}-backend && source venv/bin/activate && python app.py"
if [ "$FRONTEND_CHOICE" == "1" ]; then
    echo "To start frontend: cd ${APP_NAME}/${APP_NAME}-frontend && npm run dev"
else
    echo "To start frontend: cd ${APP_NAME}/${APP_NAME}-frontend && npm start"
fi