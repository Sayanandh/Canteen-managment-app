# Canteen Management System Backend

This is the backend server for the Canteen Management System, built with Flask and SQLAlchemy.

## Features

- User authentication with JWT
- Menu management
- Meal plan management
- Transaction handling
- QR code generation
- Health check endpoint
- Detailed logging

## Setup

1. Create a virtual environment:
   ```bash
   python -m venv venv
   ```

2. Activate the virtual environment:
   - Windows:
     ```bash
     .\venv\Scripts\activate
     ```
   - Unix/MacOS:
     ```bash
     source venv/bin/activate
     ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Initialize the database:
   ```bash
   python init_db.py
   ```

## Running the Server

1. Start the Flask server:
   ```bash
   python app.py
   ```

The server will start on `http://localhost:5000` by default.

## API Endpoints

### Authentication
- POST `/api/auth/login` - User login
- POST `/api/auth/register` - User registration

### Menu
- GET `/api/menu` - Get all menu items
- POST `/api/menu` - Add a new menu item
- PUT `/api/menu/<item_id>` - Update a menu item
- DELETE `/api/menu/<item_id>` - Delete a menu item

### Meal Plans
- GET `/api/meal-plan` - Get user's meal plan
- POST `/api/meal-plan` - Create a new meal plan
- PUT `/api/meal-plan/<plan_id>` - Update a meal plan
- DELETE `/api/meal-plan/<plan_id>` - Delete a meal plan

### Transactions
- GET `/api/transactions` - Get user's transactions
- GET `/api/transactions/<transaction_id>` - Get a specific transaction

### System
- GET `/api/health` - Health check endpoint

## Environment Variables

Create a `.env` file in the root directory with the following variables:
```
JWT_SECRET_KEY=your-secret-key
FLASK_ENV=development
```

## Default Admin Account

The system creates a default admin account during initialization:
- Username: admin
- Password: admin123
- Email: admin@example.com

Make sure to change these credentials in production. 