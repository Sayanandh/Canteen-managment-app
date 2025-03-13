# Canteen Management System

A comprehensive web-based Canteen Management System with QR code integration for streamlined ordering and management. This project was developed as a hobby project to demonstrate full-stack development capabilities and modern web application design principles.

## 🌟 Features

- QR Code-based ordering system
- User-friendly interface designed with Figma
- Separate frontend and backend architecture
- Real-time order tracking
- Menu management system
- User authentication and authorization
- Admin dashboard for canteen management
- Order history and analytics

## 🛠️ Technology Stack

### Frontend
- React.js
- Material-UI/CSS for styling
- QR Code integration
- Responsive design
- State management
- API integration

### Backend
- Python Flask framework
- SQLite database
- RESTful API architecture
- Authentication middleware
- Database models and relationships

## 🎨 Design Process

The project started with a comprehensive design phase:
1. Requirements gathering and analysis
2. User flow mapping
3. UI/UX design using Figma
4. Wireframing and prototyping
5. Design implementation

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

1. **Customer**
   - View menu
   - Place orders
   - Track order status
   - View order history

2. **Admin**
   - Manage menu items
   - Process orders
   - View analytics
   - Manage users

## 🔒 Security Features

- User authentication
- Session management
- Input validation
- Data encryption
- Secure API endpoints

## 📱 Mobile Responsiveness

The application is designed to be fully responsive across:
- Desktop browsers
- Tablets
- Mobile devices

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

- Payment gateway integration
- Real-time notifications
- Advanced analytics
- Mobile app development
- Multi-language support

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Author

Created as a hobby project to demonstrate full-stack development capabilities and modern web application design principles.

---

For any questions or suggestions, please feel free to open an issue or submit a pull request. #   C a n t e e n - m a n a g m e n t - a p p  
 