# Quản lý nhà thuốc

Ứng dụng quản lý thuốc, nhập kho, bán hàng và tồn kho cho một nhà thuốc.

## Công nghệ hiện có

- Frontend: React, TypeScript, Vite, React Router, Axios.
- Backend: Express, TypeScript.
- Database dự kiến: PostgreSQL, kết nối bằng pg.
- Đăng nhập dự kiến: mật khẩu băm bằng bcrypt, xác thực bằng JWT.

Project hiện là bộ khung, chưa triển khai nghiệp vụ hoặc kết nối database.
File backend/src/index.ts đang được xây dựng lại từ đầu.

## Phạm vi phiên bản đầu

Các lựa chọn dưới đây là phương án ban đầu để thiết kế, có thể điều chỉnh trước khi viết database.
Ứng dụng phục vụ một nhà thuốc, một kho; chưa hỗ trợ nhiều chi nhánh.

| Chức năng | Nội dung |
| --- | --- |
| Tài khoản | Đăng nhập; quản lý tài khoản nhân viên; phân quyền quản lý và nhân viên |
| Danh mục thuốc | Mã thuốc, tên, hoạt chất, hàm lượng, dạng bào chế, hãng sản xuất, đơn vị và giá bán |
| Nhà cung cấp | Mã, tên, số điện thoại, địa chỉ |
| Nhập kho | Lập phiếu nhập, ghi nhận nhà cung cấp, lô, hạn sử dụng, số lượng và giá nhập |
| Bán hàng | Chọn thuốc và đơn vị, kiểm tra tồn, tính tiền, xác nhận hóa đơn và trừ kho |
| Tồn kho | Xem tồn theo thuốc và lô, cảnh báo tồn thấp và sắp hết hạn |
| Tra cứu | Xem lịch sử nhập kho, hóa đơn và chi tiết giao dịch |

Chưa triển khai trong phiên bản đầu: trả hàng, công nợ, bảo hiểm, đơn thuốc điện tử,
thanh toán trực tuyến và tích hợp hóa đơn điện tử. Báo cáo ban đầu chỉ tổng hợp doanh thu bán hàng;
chưa tính lợi nhuận hoặc báo cáo kế toán.

## Vai trò

- Quản lý: quản lý tài khoản, danh mục, nhà cung cấp, nhập kho; xem toàn bộ hóa đơn và tồn kho.
- Nhân viên: tra cứu thuốc và tồn kho, lập hóa đơn, xem hóa đơn do mình tạo.
- Tài khoản ngừng hoạt động không được đăng nhập; lịch sử giao dịch vẫn được giữ lại.

## Quy tắc dữ liệu và tồn kho

### Thuốc, lô và đơn vị

- Danh mục thuốc mô tả sản phẩm; số lượng tồn được quản lý riêng theo từng lô.
- Mỗi lô gắn với một thuốc, số lô và hạn sử dụng. Một thuốc có thể có nhiều lô.
- Mỗi thuốc có một đơn vị cơ sở, ví dụ viên, chai hoặc tuýp. Tồn kho lưu theo đơn vị cơ sở.
- Đơn vị bán có hệ số quy đổi nguyên dương về đơn vị cơ sở, cấu hình riêng cho từng thuốc.
  Ví dụ: 1 vỉ = 10 viên, 1 hộp = 100 viên; bán 2 vỉ thì trừ 20 viên.
- Giá bán được cấu hình theo từng đơn vị bán; giá nhập lưu theo từng dòng phiếu nhập.
- Khi đơn vị đã phát sinh giao dịch, không sửa hệ số quy đổi; ngừng dùng và tạo đơn vị mới khi cần.
- Chi tiết giao dịch lưu lại đơn vị, hệ số quy đổi và đơn giá tại thời điểm giao dịch.
  Thay đổi danh mục về sau không làm đổi hóa đơn cũ.

### Nhập và xuất kho

- Phiếu nhập và hóa đơn có trạng thái nháp và đã xác nhận. Bản nháp chưa thay đổi tồn kho.
- Xác nhận phiếu nhập làm tăng tồn; xác nhận hóa đơn làm giảm tồn.
- Giao dịch đã xác nhận không được sửa hoặc xóa trực tiếp. Chức năng điều chỉnh sẽ thiết kế riêng.
- Không nhập số lượng hoặc giá nhập âm; số lượng phải lớn hơn 0, giá nhập có thể bằng 0.
- Không xác nhận nhập lô đã hết hạn; không bán thuốc ngừng kinh doanh hoặc lô đã hết hạn.
- Quy ước ban đầu: lô hết hạn khi ngày hiện tại lớn hơn ngày hết hạn, tính theo Asia/Ho_Chi_Minh.
- Ưu tiên xuất lô còn sử dụng được có hạn gần nhất (FEFO); nếu bằng hạn thì ưu tiên nhập trước.
- Một dòng bán có thể lấy từ nhiều lô; phải lưu được số lượng đã xuất của từng lô.
- Không cho tồn âm. Khi xác nhận, backend kiểm tra lại tồn và cập nhật trong cùng transaction
  để tránh hai nhân viên cùng bán vượt số lượng còn lại.
- Mỗi phiếu chỉ được xác nhận một lần, kể cả khi người dùng bấm lại hoặc gửi lại yêu cầu.
- Ngưỡng tồn thấp cấu hình theo thuốc, tính bằng đơn vị cơ sở. Cảnh báo sắp hết hạn mặc định 90 ngày.

### Tiền và lịch sử

- Dùng VND, không dùng số thực dấu phẩy động để lưu tiền.
- Phiên bản đầu chưa áp dụng giảm giá hoặc tách thuế; tổng tiền bằng tổng các dòng số lượng × đơn giá.
- Lưu người tạo, thời điểm tạo và thời điểm xác nhận của mỗi giao dịch.
- Thuốc và nhà cung cấp đã có giao dịch chỉ được ngừng hoạt động, không xóa mất lịch sử.
- Bán lẻ không bắt buộc lưu thông tin khách hàng trong phiên bản đầu.

## Luồng sử dụng chính

### Nhập kho

1. Quản lý chọn nhà cung cấp và tạo phiếu nhập nháp.
2. Thêm thuốc, đơn vị nhập, số lượng, giá nhập, số lô và hạn sử dụng.
3. Kiểm tra thông tin và xác nhận phiếu.
4. Backend lưu phiếu, chi tiết và tăng tồn theo lô trong cùng transaction.

### Bán hàng

1. Nhân viên tìm thuốc và chọn đơn vị, số lượng cần bán.
2. Hệ thống hiển thị giá và kiểm tra lượng tồn có thể bán.
3. Nhân viên kiểm tra tổng tiền, nhận thanh toán và xác nhận hóa đơn.
4. Backend kiểm tra lại tồn, phân bổ lô theo FEFO, lưu hóa đơn và trừ kho trong cùng transaction.
5. Hiển thị hóa đơn đã xác nhận; không tự tạo giao dịch mới khi gửi lại yêu cầu xác nhận.

## Thứ tự triển khai

1. Rà soát phạm vi, quy đổi đơn vị và quy tắc nhập/xuất trong README này.
2. Thiết kế database: tài khoản, thuốc, đơn vị thuốc, nhà cung cấp, lô,
   phiếu nhập và chi tiết, hóa đơn và chi tiết, phân bổ lô xuất.
3. Dựng backend: index.ts khởi động server, app.ts cấu hình Express,
   routes/index.ts tập hợp router và health router tại GET /api/health.
4. Kết nối PostgreSQL, tạo schema và dữ liệu mẫu.
5. Làm đăng nhập, phân quyền và danh mục thuốc/nhà cung cấp.
6. Làm nhập kho, tồn kho rồi bán hàng; kiểm tra quy đổi, hạn sử dụng và bán đồng thời.
7. Kết nối frontend theo từng chức năng, hoàn thiện tra cứu và cảnh báo.

## Chạy project

Cài dependency bằng npm ci trong từng thư mục backend và frontend.
Nếu chưa có .env, sao chép từ .env.example rồi điền cấu hình riêng.
Không ghi đè .env đang dùng hoặc đưa thông tin bí mật vào Git.

Backend, sau khi đã dựng lại server:

```powershell
cd backend
npm run dev
```

Frontend, trong terminal khác:

```powershell
cd frontend
npm run dev
```

Dùng địa chỉ Local do Vite in ra; FRONTEND_URL trong backend/.env cần khớp địa chỉ đó.
Sau khi triển khai health router, kiểm tra backend tại http://localhost:3000/api/health
(hoặc cổng PORT đã cấu hình).

Build: chạy npm run build trong từng thư mục. Backend dùng npm start để chạy dist;
frontend dùng npm run preview để xem bản build.

## Tài liệu

- [Sơ đồ database](docs/database-diagram.md)
