--1. viết stored procedure với đầu vào là Book_id, xem book_id này có tồn tại không. 
if object_id('TimSachCoSanTrong_DuLieu','P') is not null
drop procedure TimSachCoSanTrong_DuLieu
go
create procedure TimSachCoSanTrong_DuLieu @bookid int
as
begin
	if exists(select BOOK_ID from BOOK where BOOK_ID = @bookid)
	begin
		select BOOK_ID, BOOK_NAME, [STATUS] from BOOK
		where BOOK_ID = @bookid
	end
	else
		print N'DỮ LIỆU NHẬP VÀO KO TỒN TẠI'
end
--test case 1
exec TimSachCoSanTrong_DuLieu @bookid = 1025
--test case 2
exec TimSachCoSanTrong_DuLieu @bookid = 1001
--test case 3
exec TimSachCoSanTrong_DuLieu @bookid = 2981
select * from BOOK
--2. Viết stored procedure với tham số đầu vào là STAFF_ID. Tham số đầu ra là tổng số tiền
--thu được sau khi đã thanh toán thành công các đơn hàng trong bảng Order của Nhân viên.
if object_id('TinhTongSoTienThuDuoc_TuCacStaff','P') is not null
drop procedure TinhTongSoTienThuDuoc_TuCacStaff
go
CREATE PROCEDURE TinhTongSoTienThuDuoc_TuCacStaff @staff_id int, @tongsotiennhanduoc int output
as
begin
	if exists(select STAFF_ID from STAFF where STAFF_ID = @staff_id)
	begin
		set @tongsotiennhanduoc = (select sum(TOTAL_COST) as N'Tổng số tiền staff thu được' from [Order]
		group by STAFF_ID
		having STAFF_ID = @staff_id)
	end
	else
		print N'NHÂN VIÊN KHÔNG TỒN TẠI'
end
SELECT Staff_id FROM STAFF WHERE OFFICE = N'Dọn dẹp'
--test case 1
declare @tong int
declare @staff_id int
set @staff_id = 101
exec TinhTongSoTienThuDuoc_TuCacStaff @staff_id, @tongsotiennhanduoc = @tong output
print N'Tổng số tiền mà nhân viên ID ' + convert(char(6),@staff_id) + N'kiếm được là: ' + convert(char(10), @tong)
--test case 2
declare @tong int
declare @staff_id int
set @staff_id = 900
exec TinhTongSoTienThuDuoc_TuCacStaff @staff_id, @tongsotiennhanduoc = @tong output
print N'Tổng số tiền mà nhân viên ID ' + convert(char(6),@staff_id) + N'kiếm được là: ' + convert(char(10), @tong)
--test case 3
declare @tong int
declare @staff_id int
set @staff_id = 106
exec TinhTongSoTienThuDuoc_TuCacStaff @staff_id, @tongsotiennhanduoc = @tong output
print N'Tổng số tiền mà nhân viên ID ' + convert(char(6),@staff_id) + N'kiếm được là: ' + convert(char(10), @tong)

declare @tong int
declare @staff_id int
set @staff_id = 106
exec TinhTongSoTienThuDuoc_TuCacStaff @staff_id, @tongsotiennhanduoc = @tong output
print N'Tổng số tiền mà nhân viên ID ' + convert(char(6),@staff_id) + N'kiếm được là: ' + convert(char(10), @tong)
--thêm trường hợp nhân viên ko làm gì cả thì không thu nhập
select * from [ORDER]
select * from [STAFF]
--3. viết stored procedure cho tham số đầu vào là CUSTOMER_NAME, ORDER_ID, FEEDBACK_ID. Tham số
--đầu ra là lấy thông tin phản hồi của khách hàng. 

if object_id('LayThongTinPhanHoiKhachHang','P') is not null
drop procedure LayThongTinPhanHoiKhachHang
go
CREATE PROCEDURE LayThongTinPhanHoiKhachHang @custName nvarchar(200), @feedbackid int, @phanhoi nvarchar(500) output
as
begin
	set @phanhoi = (select f.GRATE from CUSTOMER c
	join FEEDBACK f on f.FEEDBACK_ID = c.FEEDBACK_ID
	where c.CUSTOMER_NAME = @custName and c.FEEDBACK_ID = @feedbackid)
end
--test
declare @custname nvarchar(200)
declare @feedbackid int
declare @comment nvarchar(500)
set @custname = N'Trịnh Ớt Cay'
set @feedbackid = 1
exec LayThongTinPhanHoiKhachHang @custname, @feedbackid, @phanhoi= @comment output
print @comment
--test 2
declare @custname nvarchar(200)
declare @feedbackid int
declare @comment nvarchar(500)
set @custname = N'Nguyễn Minh Nguyệt'
set @feedbackid = 5
exec LayThongTinPhanHoiKhachHang @custname, @feedbackid, @phanhoi= @comment output
print @comment
--test 3
declare @custname nvarchar(200)
declare @feedbackid int
declare @comment nvarchar(500)
set @custname = N'ABCXYZ'
set @feedbackid = 5
exec LayThongTinPhanHoiKhachHang @custname, @feedbackid, @phanhoi= @comment output
print @comment
--sửa lại orderid không liên quan tới customer và feedback              
--4. Viết store procedure tìm những khách hàng đang sinh sống tại 1 địa điểm được nhập vào
if OBJECT_ID('NhungKhachHang_SinhSong','P') is not null
drop procedure NhungKhachHang_SinhSong
go
create procedure NhungKhachHang_SinhSong @diadiem nvarchar(200)
as
begin
	select * from CUSTOMER
	where [ADDRESS] = @diadiem
end
exec NhungKhachHang_SinhSong @diadiem = N'Đà Nẵng'

--5. Tham số đầu vào là Type sách, tìm ra những cuốn sách nằm trong thể loại được nhập vào
if OBJECT_ID('FindBooksOnTheBookLists','P') is not null
drop procedure FindBooksOnTheBookLists
go
CREATE PROCEDURE FindBooksOnTheBookLists @booktype nvarchar(200)
as
begin
	select * from BOOK
	where [TYPE] = @booktype
end

exec FindBooksOnTheBookLists N'Thiếu Nhi'
exec FindBooksOnTheBookLists N'Văn học'
exec FindBooksOnTheBookLists N'Văn học A'

--6. Nhập vào address, month1, month2. Lấy ra thông tin các khách hàng có tháng mua sách từ month1 đến month2.
if OBJECT_ID('Question6_Proc_Address_Month1_2','P') is not null
drop procedure Question6_Proc_Address_Month1_2
go
create procedure Question6_Proc_Address_Month1_2 @address nvarchar(200), @month1 int, @month2 int
as
begin
	select c.* from CUSTOMER c
	join [ORDER] o on c.ORDER_ID = o.ORDER_ID
	where c.[ADDRESS] = @address and month(o.BOOKING_DAY) >= @month1 and month(o.BOOKING_DAY) <= @month2
end
exec Question6_Proc_Address_Month1_2 @address=N'HCM', @month1=4, @month2=9  
/*
if OBJECT_ID('TimSoDon_DiaDiem','P') is not null
drop procedure TimSoDon_DiaDiem
go
CREATE PROCEDURE TimSoDon_DiaDiem @address nvarchar(200), @tongsodon int output
as
begin
	set @tongsodon = (select sum(o.TOTAL_AMOUNT) as NumberOfOrders from CUSTOMER c
	join [ORDER] o on o.ORDER_ID = c.ORDER_ID
	where c.[ADDRESS] = @address
	group by c.[ADDRESS])
end
--test case 1
declare @t int
exec TimSoDon_DiaDiem @address=N'HCM', @tongsodon = @t output
print N'Số lượng hoá đơn tại HCM là:' + convert(char(6), @t)
--test case 2
--declare @t int
exec TimSoDon_DiaDiem @address=N'Huế', @tongsodon = @t output
print N'Số lượng hoá đơn tại Huế là:' + convert(char(6), @t)
select * from CUSTOMER
*/
--7. Gõ vào tên tác giả, lấy thông tin tên các cuốn sách thuộc về tác giả của cuốn sách đó
if OBJECT_ID('TimSachThuoc_TacGia','P') is not null
drop procedure TimSachThuoc_TacGia
go
CREATE PROCEDURE TimSachThuoc_TacGia @author nvarchar(200)
as
begin
	select BOOK_ID,BOOK_NAME from BOOK
	where AUTHOR = @author
end

select * from BOOK
--test case 1
exec TimSachThuoc_TacGia @author=N'Nguyễn Nhật Ánh'
--test case 2
exec TimSachThuoc_TacGia @author=N'Nam Cao'
--test case 3
exec TimSachThuoc_TacGia @author=N'Fujiko Fujio'
--test case 4
exec TimSachThuoc_TacGia @author='Napoleon'

--8. Từ bảng order, 
--Viết store procedure với tham số đầu vào là THÁNG1, THÁNG2. Tham số đầu ra là tổng thu nhập bán được theo từng tháng
--từ tháng n1 đến tháng n2.
if OBJECT_ID('SoSachBanDuoc_TuThangN1DenThangN2','P') is not null
drop procedure SoSachBanDuoc_TuThangN1DenThangN2
go
create procedure SoSachBanDuoc_TuThangN1DenThangN2 @month1 int, @month2 int
as
begin
	select MONTH(BOOKING_DAY) as MonthOfOrders, sum(TOTAL_COST) as TotalMoney from [ORDER]
	where MONTH(BOOKING_DAY) >= @month1 and MONTH(BOOKING_DAY) <= @month2
	group by MONTH(BOOKING_DAY)
end
exec SoSachBanDuoc_TuThangN1DenThangN2 @month1 = 4, @month2 = 8
exec SoSachBanDuoc_TuThangN1DenThangN2 @month1 = 1, @month2 = 5
--9. Viết stored procedure tìm ra tên nhân viên đã thực hiện giao dịch với input là ORDER_ID
if OBJECT_ID('TimNhanVienDaGiaoDich','P') is not null
drop procedure TimNhanVienDaGiaoDich
go
CREATE PROCEDURE TimNhanVienDaGiaoDich @order_id int
as
begin
	select o.ORDER_ID, s.STAFF_ID, s.STAFF_NAME from [ORDER] o
	join STAFF s on s.STAFF_ID = o.STAFF_ID
	where o.ORDER_ID = @order_id
end
exec TimNhanVienDaGiaoDich @order_id = 401
exec TimNhanVienDaGiaoDich @order_id = 404
exec TimNhanVienDaGiaoDich @order_id = 444
--10. Viết stored procedure tham số đầu vào là: price1, price2. đầu ra là tìm những cuốn sách 
--hiện có bán trong khung giá đã nhập vào từ bàn phím
if OBJECT_ID('TimSachTheoKhoangGia','P') is not null
drop procedure TimSachTheoKhoangGia
go
CREATE PROCEDURE TimSachTheoKhoangGia @gia1 int, @gia2 int
as
begin
	select distinct b.BOOK_ID, b.BOOK_NAME, b.PUBLISHER, b.AUTHOR, b.COST, b.[STATUS] from [INSERT] i
	join BOOK b on b.BOOK_ID = i.BOOK_ID
	where b.COST > @gia1 and b.COST < @gia2 and b.[STATUS] = 1
	order by b.COST ASC
end
--test
exec TimSachTheoKhoangGia @gia1 = 18000, @gia2 = 25000
exec TimSachTheoKhoangGia @gia1 = 20000, @gia2 = 40000
exec TimSachTheoKhoangGia @gia1 = 30000, @gia2 = 80000

select * from [BOOK]
select * from [Order]