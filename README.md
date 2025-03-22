# Canteen Management System

<div align="center">
  <h3>A Modern Solution for Canteen Order Management</h3>
  <p>A comprehensive web-based system with QR code integration for streamlined ordering and management.</p>
</div>

## 🔍 Technical Overview

### System Architecture
```
┌─────────────────┐     ┌──────────────┐     ┌─────────────┐
│Flutter Frontend │ ←── │   Flask API  │ ←── │  SQLite DB  │
└─────────────────┘     └──────────────┘     └─────────────┘
        ↑                      ↑                    ↑
        │                      │                    │
    UI Widgets           REST Endpoints        Data Models
```

### Key Technical Features
- **Cross-Platform Development**: Flutter-based mobile-first approach
- **Stateless Authentication**: JWT-based token system
- **Real-time Updates**: WebSocket integration for live order tracking
- **Secure API Layer**: CORS-enabled endpoints with rate limiting
- **Database Management**: SQLAlchemy ORM with migration support

## 🛠️ Technology Stack

### Frontend Technologies
- **Core Framework**: Flutter 3.0+
- **State Management**: 
  - Provider/Riverpod
  - Bloc pattern for complex state flows
- **UI Components**: 
  - Material Design widgets
  - Custom Flutter widgets
  - Flutter themes
- **QR Integration**:
  - qr_flutter for generation
  - mobile_scanner for reading
- **Form Handling**:
  - Flutter Form widgets
  - Custom form validators

### Backend Technologies
- **Framework**: Flask 2.0+
- **Database**: 
  - SQLite for development
  - SQLAlchemy ORM
  - Alembic for migrations
- **Authentication**: 
  - JWT (PyJWT)
  - Bcrypt for password hashing
- **API Features**:
  - Flask-RESTful
  - Flask-CORS
  - Rate limiting

## 💾 Database Schema

```sql
Users (
  id INTEGER PRIMARY KEY,
  username TEXT UNIQUE,
  password_hash TEXT,
  role TEXT,
  created_at TIMESTAMP
)

Menu (
  id INTEGER PRIMARY KEY,
  name TEXT,
  price DECIMAL,
  category TEXT,
  availability BOOLEAN
)

Orders (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  total_amount DECIMAL,
  status TEXT,
  created_at TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users(id)
)

OrderItems (
  id INTEGER PRIMARY KEY,
  order_id INTEGER,
  menu_id INTEGER,
  quantity INTEGER,
  FOREIGN KEY (order_id) REFERENCES Orders(id),
  FOREIGN KEY (menu_id) REFERENCES Menu(id)
)
```

## 🔐 Security Implementation

### Authentication Flow
1. User login/registration
2. JWT token generation
3. Token validation middleware
4. Role-based access control

### Security Measures
- Password hashing using bcrypt
- JWT with expiration
- CORS policy configuration
- Input validation & sanitization
- SQL injection prevention
- XSS protection
- Rate limiting on sensitive endpoints

## 📡 API Endpoints

### Authentication
```
POST /api/auth/login
POST /api/auth/register
POST /api/auth/refresh-token
```

### Menu Management
```
GET    /api/menu
POST   /api/menu
PUT    /api/menu/:id
DELETE /api/menu/:id
```

### Order Management
```
GET    /api/orders
POST   /api/orders
PUT    /api/orders/:id
GET    /api/orders/:id/status
```

### Admin Operations
```
GET    /api/admin/dashboard
GET    /api/admin/users
PUT    /api/admin/orders/:id/status
GET    /api/admin/analytics
```

## 🚀 Development Setup

### Environment Requirements
```json
{
  "frontend": {
    "flutter": ">=3.0.0",
    "dart": ">=2.17.0"
  },
  "backend": {
    "python": ">=3.8.0",
    "pip": ">=20.0.0"
  }
}
```

### Frontend Setup
```bash
# Ensure Flutter is installed and configured
flutter --version

# Navigate to frontend directory
cd frontend

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Environment Variables
```env
# Backend (.env)
FLASK_APP=app.py
FLASK_ENV=development
SECRET_KEY=your_secret_key
DATABASE_URL=sqlite:///canteen.db
JWT_SECRET_KEY=your_jwt_secret

# Frontend (.env)
API_BASE_URL=http://localhost:5000
WS_URL=ws://localhost:5000
```
## 🌟 Features

- **QR Code Integration**
  - Scan & Order functionality
  - Dynamic QR code generation
  - Quick table identification
- **User Interface**
  - Modern, responsive design
  - Intuitive navigation
  - Real-time updates
- **Order Management**
  - Real-time tracking
  - Status updates
  - Order history
- **Admin Controls**
  - Menu management
  - User management
  - Analytics dashboard

## 🎨 Design Process

1. **Planning Phase**
   - Requirements gathering
   - User flow mapping
   - System architecture design
2. **Design Phase**
   - Figma wireframes
   - UI/UX prototyping
   - Component design
3. **Implementation**
   - Frontend development
   - Backend development
   - Integration & Testing

## 📋 Prerequisites

- Python 3.8+
- Flutter 3.0+
- Dart 2.17+
- SQLite

## 🚀 Installation & Setup

### Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python init_db.py
python app.py
```

### Frontend Setup
```bash
# Ensure Flutter is installed and configured
flutter --version

# Navigate to frontend directory
cd frontend

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## 📁 Project Structure

```
canteen_management_system/
├── frontend/
│   ├── lib/
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── models/
│   │   ├── services/
│   │   ├── utils/
│   │   └── main.dart
│   ├── test/
│   ├── pubspec.yaml
│   └── assets/
└── backend/
    ├── app.py
    ├── models.py
    ├── init_db.py
    ├── requirements.txt
    ├── static/
    └── templates/
```

## 🔧 Configuration

1. Backend configuration in `app.py`
2. Database initialization in `init_db.py`
3. Frontend configuration in frontend environment files

## 👥 User Roles

### Customer
- Browse menu items
- Place and track orders
- View order history
- Make payments

### Admin
- Manage menu items
- Process orders
- View analytics
- Manage users

## 🤝 Contributing

This is a hobby project but contributions are welcome! Please feel free to submit a Pull Request.

## 📝 Development Process

1. Requirement Analysis
2. Design Phase (Figma)
3. Frontend Development
4. Backend Development
5. Integration
6. Testing
7. Deployment

## 🚀 Future Enhancements

- [ ] Payment Gateway Integration
- [ ] Push Notifications
- [ ] Advanced Analytics Dashboard
- [ ] Mobile App Development
- [ ] Multi-language Support

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Author

Created as a hobby project to demonstrate full-stack development capabilities and modern web application design principles.

---

For any questions or suggestions, please feel free to open an issue or submit a pull request.

