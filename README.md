# MedicineManagementSystem
This project simulates a basic medicine shopping and invoicing system using 8086 Assembly language. It was built using the EMU8086 software.



Features:


🗂️ Main Features

1. Main Menu System
   - Displays options:
     - View medicine categories
     - Search medicine by first letter
     - Exit the program

2. Display Medicine Categories
   - Lists available categories:
     - Painkillers
     - Antibiotics
   - User can navigate back to the main menu

3. Show Medicines with Prices
   - Lists medicines in selected category along with unit prices



🛒 Cart & Purchase Workflow

4. Select a Medicine
   - User chooses a medicine from the list

5. Input Quantity
   - Accepts quantity values from **1 to 9**

6. Apply Discount
   - Offers discount options:
     - `0` → No discount
     - `1` → 10% off
     - `2` → 15% off
     - `3` → 20% off
     - `4` → 25% off
   - Applies discount to individual item's total before adding to cart

7. Add to Cart & Calculate Totals
   - Calculates and stores:
     - Unit total before discount
     - Discounted effective cost
   - Updates:
     - `cart_original_total` (before discount)
     - `cart_total` (after discount)

8. Cart Options After Each Addition
   - 1 → Confirm purchase (generate invoice)
   - 2 → Add another medicine (loops back to category selection)
   - Any other key → Discard cart (resets all data)



🧾 Invoice Generation

9. Record Purchase Details
   - Stores each item in `invoice_table`:
     - Medicine code
     - Quantity

10. Generate Invoice Upon Confirmation
    - Includes:
      - **Two blank lines** before the invoice
      - Invoice header: ` INVOICE `
      - Columns: Medicine & Quantity (formatted in one line)
      - All purchased items
      - Final total (after all discounts)
      - Total discount savings

11. Clean Up After Purchase
    - Resets:
      - `cart_total`
      - `cart_original_total`
      - `invoice_index`



🔍 Search Feature

12. Find Medicine by First Letter
    - User inputs a letter
    - Displays all medicine names starting with that letter
    - Handles case with no matches



✅ Additional Features

13. Input Validation
    - Checks for:
      - Valid main menu options
      - Medicine selections
      - Quantity range
      - Discount code
    - Displays error messages when needed

14. Total Tracking
    - Tracks total value before and after applying discounts

15. Formatted Output
    - Uses newline and tab spacing for readable interface and invoices

16. Exit Program
    - DOS interrupt `INT 21h` service 4Ch used to exit safely

---
