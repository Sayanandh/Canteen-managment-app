from app import app, db
from models import User, MenuItem, MealPlan, Transaction, MealConsumption
from datetime import datetime, timedelta

def init_db():
    with app.app_context():
        # Create all tables
        db.create_all()
        
        # Check if admin user exists
        admin = User.query.filter_by(username='admin').first()
        if not admin:
            # Create admin user
            admin = User(
                username='admin',
                email='admin@example.com',
                name='Admin User',
                role='admin'
            )
            admin.set_password('admin123')  # Set a default password
            db.session.add(admin)
            db.session.commit()
            print("Created admin user")
        
        # Check if there are any menu items
        if MenuItem.query.count() == 0:
            # Add sample menu items
            sample_items = [
                {
                    'name': 'Breakfast Combo',
                    'description': 'Eggs, toast, and coffee',
                    'price': 5.99,
                    'category': 'breakfast',
                    'is_available': True
                },
                {
                    'name': 'Lunch Special',
                    'description': 'Sandwich with fries and drink',
                    'price': 8.99,
                    'category': 'lunch',
                    'is_available': True
                },
                {
                    'name': 'Dinner Plate',
                    'description': 'Grilled chicken with vegetables',
                    'price': 12.99,
                    'category': 'dinner',
                    'is_available': True
                },
                {
                    'name': 'Vegetarian Bowl',
                    'description': 'Mixed vegetables with quinoa',
                    'price': 9.99,
                    'category': 'lunch',
                    'is_available': True
                },
                {
                    'name': 'Coffee',
                    'description': 'Freshly brewed coffee',
                    'price': 2.49,
                    'category': 'beverage',
                    'is_available': True
                }
            ]
            
            for item_data in sample_items:
                item = MenuItem(**item_data)
                db.session.add(item)
            
            db.session.commit()
            print("Added sample menu items")

if __name__ == '__main__':
    init_db()
