from app import app, db
from models import User, QRCode, MealPlan, MenuItem, Transaction
from werkzeug.security import generate_password_hash
from datetime import datetime, timedelta

def init_db():
    with app.app_context():
        # Create tables
        db.create_all()
        
        # Check if data already exists
        if User.query.count() > 0:
            print("Database already initialized. Skipping...")
            return
        
        # Create admin user
        admin = User(
            username='admin',
            email='admin@example.com',
            password_hash=generate_password_hash('admin123'),
            full_name='Admin User',
            role='admin',
            balance=1000.0
        )
        db.session.add(admin)
        db.session.commit()
        
        # Create QR code for admin
        admin_qr = QRCode(user_id=admin.id)
        db.session.add(admin_qr)
        
        # Create staff user
        staff = User(
            username='staff',
            email='staff@example.com',
            password_hash=generate_password_hash('staff123'),
            full_name='Staff User',
            role='staff',
            balance=500.0
        )
        db.session.add(staff)
        db.session.commit()
        
        # Create QR code for staff
        staff_qr = QRCode(user_id=staff.id)
        db.session.add(staff_qr)
        
        # Create regular users
        users = [
            {
                'username': 'user1',
                'email': 'user1@example.com',
                'password': 'user123',
                'full_name': 'John Doe',
                'balance': 200.0
            },
            {
                'username': 'user2',
                'email': 'user2@example.com',
                'password': 'user123',
                'full_name': 'Jane Smith',
                'balance': 150.0
            },
            {
                'username': 'user3',
                'email': 'user3@example.com',
                'password': 'user123',
                'full_name': 'Bob Johnson',
                'balance': 100.0
            }
        ]
        
        for user_data in users:
            user = User(
                username=user_data['username'],
                email=user_data['email'],
                password_hash=generate_password_hash(user_data['password']),
                full_name=user_data['full_name'],
                role='user',
                balance=user_data['balance']
            )
            db.session.add(user)
            db.session.commit()
            
            # Create QR code for user
            user_qr = QRCode(user_id=user.id)
            db.session.add(user_qr)
            
            # Create meal plan for user
            meal_plan = MealPlan(
                user_id=user.id,
                plan_type='monthly',
                meals_remaining=30,
                breakfast_allowed=True,
                lunch_allowed=True,
                dinner_allowed=True,
                start_date=datetime.utcnow(),
                end_date=datetime.utcnow() + timedelta(days=30)
            )
            db.session.add(meal_plan)
        
        # Create menu items
        menu_items = [
            # Breakfast items
            {
                'name': 'Eggs and Toast',
                'description': 'Scrambled eggs with toast and butter',
                'price': 3.50,
                'category': 'breakfast',
                'image_url': '/static/images/eggs_toast.jpg'
            },
            {
                'name': 'Pancakes',
                'description': 'Stack of fluffy pancakes with maple syrup',
                'price': 4.00,
                'category': 'breakfast',
                'image_url': '/static/images/pancakes.jpg'
            },
            {
                'name': 'Fruit Bowl',
                'description': 'Fresh seasonal fruits',
                'price': 2.50,
                'category': 'breakfast',
                'image_url': '/static/images/fruit_bowl.jpg'
            },
            
            # Lunch items
            {
                'name': 'Chicken Sandwich',
                'description': 'Grilled chicken with lettuce and mayo on whole wheat bread',
                'price': 5.50,
                'category': 'lunch',
                'image_url': '/static/images/chicken_sandwich.jpg'
            },
            {
                'name': 'Vegetable Soup',
                'description': 'Hearty vegetable soup with bread roll',
                'price': 4.00,
                'category': 'lunch',
                'image_url': '/static/images/vegetable_soup.jpg'
            },
            {
                'name': 'Caesar Salad',
                'description': 'Fresh romaine lettuce with Caesar dressing and croutons',
                'price': 4.50,
                'category': 'lunch',
                'image_url': '/static/images/caesar_salad.jpg'
            },
            
            # Dinner items
            {
                'name': 'Spaghetti Bolognese',
                'description': 'Spaghetti with rich meat sauce',
                'price': 6.50,
                'category': 'dinner',
                'image_url': '/static/images/spaghetti.jpg'
            },
            {
                'name': 'Grilled Chicken',
                'description': 'Grilled chicken breast with vegetables and rice',
                'price': 7.00,
                'category': 'dinner',
                'image_url': '/static/images/grilled_chicken.jpg'
            },
            {
                'name': 'Vegetable Curry',
                'description': 'Spicy vegetable curry with rice',
                'price': 6.00,
                'category': 'dinner',
                'image_url': '/static/images/vegetable_curry.jpg'
            },
            
            # Snacks
            {
                'name': 'Chips',
                'description': 'Bag of potato chips',
                'price': 1.50,
                'category': 'snack',
                'image_url': '/static/images/chips.jpg'
            },
            {
                'name': 'Chocolate Bar',
                'description': 'Milk chocolate bar',
                'price': 1.00,
                'category': 'snack',
                'image_url': '/static/images/chocolate.jpg'
            },
            {
                'name': 'Fruit Yogurt',
                'description': 'Creamy yogurt with fruit',
                'price': 2.00,
                'category': 'snack',
                'image_url': '/static/images/yogurt.jpg'
            }
        ]
        
        for item_data in menu_items:
            item = MenuItem(
                name=item_data['name'],
                description=item_data['description'],
                price=item_data['price'],
                category=item_data['category'],
                image_url=item_data['image_url']
            )
            db.session.add(item)
        
        db.session.commit()
        print("Database initialized successfully!")

if __name__ == '__main__':
    init_db() 