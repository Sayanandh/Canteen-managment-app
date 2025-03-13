# QR Code-Based Canteen Management System - Backend

This is the backend for the QR Code-Based Canteen Management System, built with Flask and SQLite.

## Features

- User authentication and authorization
- QR code generation and verification
- Meal plan management
- Extra item purchase tracking
- Balance management
- Transaction history

## Setup

1. Create a virtual environment:
   ```
   python -m venv venv
   ```

2. Activate the virtual environment:
   - Windows:
     ```
     venv\Scripts\activate
     ```
   - macOS/Linux:
     ```
     source venv/bin/activate
     ```

3. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

4. Initialize the database with sample data:
   ```
   python init_db.py
   ```

5. Run the application:
   ```
   python app.py
   ```

The API will be available at `http://localhost:5000`.

## API Endpoints

### Authentication

- `POST /api/auth/login` - Login with username and password
- `POST /api/auth/register` - Register a new user

### QR Code

- `GET /api/qrcode/<user_id>` - Get QR code for a user
- `POST /api/qrcode/regenerate/<user_id>` - Regenerate QR code for a user

### Meal Verification

- `POST /api/meal/verify` - Verify a meal using QR code

### Extra Item Purchase

- `POST /api/purchase/extra` - Purchase extra items using QR code

### Balance Management

- `POST /api/balance/add` - Add balance to a user account

### Menu Management

- `GET /api/menu` - Get all menu items
- `POST /api/menu` - Add a new menu item (admin only)
- `PUT /api/menu/<item_id>` - Update a menu item (admin only)

### User Management

- `GET /api/users` - Get all users (admin only)
- `GET /api/users/<user_id>` - Get user details

### Meal Plan Management

- `POST /api/meal-plans` - Create a meal plan for a user (admin only)
- `PUT /api/meal-plans/<user_id>` - Update a user's meal plan (admin only)

### Transaction History

- `GET /api/transactions/<user_id>` - Get transaction history for a user

## Default Users

- Admin:
  - Username: admin
  - Password: admin123

- Staff:
  - Username: staff
  - Password: staff123

- Regular Users:
  - Username: user1, user2, user3
  - Password: user123 