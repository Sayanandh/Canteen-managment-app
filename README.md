# Canteen Management System

<div align="center">
  <h3>A Modern Solution for Canteen Order Management</h3>
  <p>A comprehensive web-based system with QR code integration for streamlined ordering and management.</p>
</div>

## 📸 Project Screenshots

![Login Page](Login](https://github.com/user-attachments/assets/8ed9367a-9cc6-444f-b261-1958c596cd53)), ![](https://github.com/user-attachments/assets/e61ae594-271c-4562-8be4-d6c166cd2cc7)

![Menu Management](![](https://github.com/user-attachments/assets/6d4188d1-4f1e-4e27-bb2f-64b8623a4d46))


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

## 🛠️ Technology Stack

### Frontend
- **React.js** - UI development
- **Material-UI** - Styling components
- **QR Code Library** - QR code functionality
- **Axios** - API integration
- **React Router** - Navigation
- **Context API** - State management

### Backend
- **Python Flask** - Server framework
- **SQLite** - Database
- **JWT** - Authentication
- **RESTful API** - Architecture
- **SQLAlchemy** - ORM

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
- Node.js 14+
- npm or yarn
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
cd frontend/canteen_qr_new
npm install
npm start
```

## 📁 Project Structure

```
canteen_management_system/
├── frontend/
│   └── canteen_qr_new/
│       ├── src/
│       ├── public/
│       └── package.json
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

## 🌐 API Endpoints

The backend provides RESTful API endpoints for:
- User authentication
- Menu management
- Order processing
- Admin operations
- Analytics and reporting

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

## 🔒 Security Features

- JWT Authentication
- Password Hashing
- Input Sanitization
- CORS Protection
- Session Management

## 📱 Mobile Responsiveness

The application is fully responsive across:
- 💻 Desktop (1024px and above)
- 📱 Tablet (768px to 1023px)
- 📱 Mobile (320px to 767px)

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

