# Sơ đồ database

Sơ đồ quan hệ của 10 bảng trong `backend/sql/schema.sql`.
Các trường `created_at` và `updated_at` được lược bỏ để dễ đọc.

```mermaid
classDiagram
    direction TB

    class users {
        +SERIAL id PK
        +VARCHAR username UK
        +TEXT password_hash
        +VARCHAR full_name
        +VARCHAR role
        +BOOLEAN is_active
    }
    class medicines {
        +SERIAL id PK
        +VARCHAR code UK
        +VARCHAR name
        +VARCHAR active_ingredient
        +VARCHAR strength
        +VARCHAR dosage_form
        +VARCHAR manufacturer
        +VARCHAR base_unit
        +INTEGER low_stock_threshold
        +BOOLEAN is_active
    }
    class medicine_units {
        +SERIAL id PK
        +INTEGER medicine_id FK
        +VARCHAR unit_name
        +INTEGER conversion_factor
        +NUMERIC selling_price
        +BOOLEAN is_active
    }
    class suppliers {
        +SERIAL id PK
        +VARCHAR code UK
        +VARCHAR name
        +VARCHAR phone
        +TEXT address
        +BOOLEAN is_active
    }
    class medicine_batches {
        +SERIAL id PK
        +INTEGER medicine_id FK
        +VARCHAR batch_number
        +DATE expiry_date
        +INTEGER quantity_on_hand
        +TIMESTAMPTZ first_received_at
    }
    class purchase_receipts {
        +SERIAL id PK
        +VARCHAR code UK
        +INTEGER supplier_id FK
        +INTEGER created_by FK
        +VARCHAR status
        +TEXT note
        +TIMESTAMPTZ confirmed_at
    }
    class purchase_receipt_items {
        +SERIAL id PK
        +INTEGER purchase_receipt_id FK
        +INTEGER medicine_id FK
        +INTEGER medicine_unit_id FK
        +VARCHAR unit_name
        +INTEGER conversion_factor
        +INTEGER quantity
        +NUMERIC unit_price
        +VARCHAR batch_number
        +DATE expiry_date
    }
    class sales_invoices {
        +SERIAL id PK
        +VARCHAR code UK
        +INTEGER created_by FK
        +VARCHAR status
        +TEXT note
        +TIMESTAMPTZ confirmed_at
    }
    class sales_invoice_items {
        +SERIAL id PK
        +INTEGER sales_invoice_id FK
        +INTEGER medicine_id FK
        +INTEGER medicine_unit_id FK
        +VARCHAR unit_name
        +INTEGER conversion_factor
        +INTEGER quantity
        +NUMERIC unit_price
    }
    class sales_item_batches {
        +SERIAL id PK
        +INTEGER sales_invoice_item_id FK
        +INTEGER medicine_batch_id FK
        +INTEGER quantity_base
    }

    users "1" --> "0..*" purchase_receipts : tạo
    users "1" --> "0..*" sales_invoices : tạo
    medicines "1" --> "0..*" medicine_units : có đơn vị
    medicines "1" --> "0..*" medicine_batches : có lô
    suppliers "1" --> "0..*" purchase_receipts : cung cấp
    purchase_receipts "1" --> "0..*" purchase_receipt_items : gồm
    medicines "1" --> "0..*" purchase_receipt_items : được nhập
    medicine_units "1" --> "0..*" purchase_receipt_items : đơn vị nhập
    sales_invoices "1" --> "0..*" sales_invoice_items : gồm
    medicines "1" --> "0..*" sales_invoice_items : được bán
    medicine_units "1" --> "0..*" sales_invoice_items : đơn vị bán
    sales_invoice_items "1" --> "0..*" sales_item_batches : phân bổ
    medicine_batches "1" --> "0..*" sales_item_batches : xuất từ lô
```

## Cách đọc và giới hạn

- PK: khóa chính; FK: khóa ngoại; UK: giá trị duy nhất.
- `1` và `0..*`: mỗi bản ghi con thuộc đúng một bản ghi cha; một bản ghi cha có thể chưa có hoặc có nhiều bản ghi con.
- Phiếu nháp có thể chưa có dòng chi tiết. Backend phải kiểm tra có dòng hợp lệ trước khi xác nhận.
- `medicine_batches` có ràng buộc duy nhất theo bộ `(medicine_id, batch_number, expiry_date)`.
- `sales_item_batches` có ràng buộc duy nhất theo cặp `(sales_invoice_item_id, medicine_batch_id)`.
- `purchase_receipt_items` chưa có khóa ngoại đến lô. Khi xác nhận nhập, backend tìm hoặc tạo lô theo thuốc, số lô và hạn sử dụng.
- Backend cần kiểm tra đơn vị thuộc đúng thuốc, lô xuất thuộc đúng thuốc và tổng lượng phân bổ khớp lượng bán; các khóa ngoại riêng lẻ chưa đảm bảo các quy tắc này.
- Cập nhật sơ đồ khi thay đổi cấu trúc database.
