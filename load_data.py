"""
Data Loading Script for Superstore Sales Analysis
Loads CSV data into MySQL database, bypassing secure-file-priv restrictions

INSTRUCTIONS:
1. Install required package: pip install pandas mysql-connector-python
2. Update DB_CONFIG with your MySQL credentials
3. Update CSV_FILE_PATH with your file location
4. Run: python load_data.py
"""

import pandas as pd
import mysql.connector
from mysql.connector import Error

# =====================================================
# Configuration - UPDATE THESE VALUES
# =====================================================
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'madeonearthbyhumans',
    'database': 'retail_analysis'
}

CSV_FILE_PATH = 'data/Sample_Superstore.csv' 

# =====================================================
# Load and Prepare Data
# =====================================================
print("Loading CSV file...")
try:
    # Try cp1252 encoding first (common for Windows Excel exports)
    df = pd.read_csv(CSV_FILE_PATH, encoding='cp1252')
    print(f"✓ Loaded {len(df)} rows")
except UnicodeDecodeError:
    try:
        # Fallback to latin1 if cp1252 fails
        print("  Trying alternate encoding...")
        df = pd.read_csv(CSV_FILE_PATH, encoding='latin1')
        print(f"✓ Loaded {len(df)} rows")
    except Exception as e:
        print(f"ERROR loading CSV with alternate encoding: {e}")
        exit(1)
except FileNotFoundError:
    print(f"ERROR: File not found at '{CSV_FILE_PATH}'")
    print("Please update CSV_FILE_PATH with the correct path to your CSV file")
    exit(1)
except Exception as e:
    print(f"ERROR loading CSV: {e}")
    exit(1)

# Convert date columns to proper format
print("Converting date formats...")
df['Order Date'] = pd.to_datetime(df['Order Date'])
df['Ship Date'] = pd.to_datetime(df['Ship Date'])

# Clean column names to match database schema (handle the exact CSV headers)
column_mapping = {
    'Row ID': 'row_id',
    'Order ID': 'order_id',
    'Order Date': 'order_date',
    'Ship Date': 'ship_date',
    'Ship Mode': 'ship_mode',
    'Customer ID': 'customer_id',
    'Customer Name': 'customer_name',
    'Segment': 'segment',
    'Country': 'country',
    'City': 'city',
    'State': 'state',
    'Postal Code': 'postal_code',
    'Region': 'region',
    'Product ID': 'product_id',
    'Category': 'category',
    'Sub-Category': 'sub_category',
    'Product Name': 'product_name',
    'Sales': 'sales',
    'Quantity': 'quantity',
    'Discount': 'discount',
    'Profit': 'profit'
}

df.rename(columns=column_mapping, inplace=True)

print(f"✓ Columns prepared: {df.columns.tolist()}")

# =====================================================
# Connect to MySQL and Insert Data
# =====================================================
print("\nConnecting to MySQL...")
try:
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    print("✓ Connected successfully")
except Error as e:
    print(f"ERROR connecting to MySQL: {e}")
    print("\nPlease check:")
    print("1. MySQL server is running")
    print("2. Database credentials are correct")
    print("3. Database exists (or create it first)")
    exit(1)

# Check if table exists and is empty
cursor.execute("""
    SELECT COUNT(*) FROM superstore_sales
""")
existing_count = cursor.fetchone()[0]

if existing_count > 0:
    print(f"\n⚠ WARNING: Table already contains {existing_count} rows")
    response = input("Do you want to clear the table first? (yes/no): ")
    if response.lower() == 'yes':
        print("Clearing existing data...")
        cursor.execute("DELETE FROM superstore_sales")
        conn.commit()
        print("✓ Table cleared")
    else:
        print("Appending to existing data...")

# Insert data in batches for better performance
print("\nInserting data...")
batch_size = 1000
total_rows = len(df)
rows_inserted = 0

insert_query = """
INSERT INTO superstore_sales 
(row_id, order_id, order_date, ship_date, ship_mode, customer_id, 
 customer_name, segment, country, city, state, postal_code, region, 
 product_id, category, sub_category, product_name, sales, quantity, 
 discount, profit)
VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 
        %s, %s, %s, %s, %s, %s)
"""

try:
    for i in range(0, total_rows, batch_size):
        batch = df.iloc[i:i+batch_size]
        data = [tuple(row) for row in batch.values]
        
        cursor.executemany(insert_query, data)
        conn.commit()
        rows_inserted += len(data)
        
        print(f"  Progress: {rows_inserted}/{total_rows} rows ({(rows_inserted/total_rows)*100:.1f}%)")
    
    print(f"\n✓ Successfully inserted {rows_inserted} rows!")
    
except Error as e:
    print(f"\nERROR during insert: {e}")
    conn.rollback()
    cursor.close()
    conn.close()
    exit(1)

# =====================================================
# Verification
# =====================================================
cursor.execute("SELECT COUNT(*) FROM superstore_sales")
count = cursor.fetchone()[0]
print(f"Total records in database: {count}")

cursor.execute("""
    SELECT 
        MIN(order_date) as earliest_date,
        MAX(order_date) as latest_date,
        SUM(sales) as total_sales
    FROM superstore_sales
""")
stats = cursor.fetchone()
print(f"Date range: {stats[0]} to {stats[1]}")
print(f"Total sales: ${stats[2]:,.2f}")

# Close connection
cursor.close()
conn.close()

print("\n✓ All done! You can now run your analysis queries.")
