---BÀI TẬP STORE PROCEDURE------
/*Viết store procedure theo yêu cầu sau:
Câu 1: Tham số vào là TenPB, lấy ra thông tin của những dự án mà phòng ban đó phụ trách
Câu 2: tham số vào là MaNhanVien, TenNV. Tham số ra là tổng số giờ mà nhân viên đó đã thực hiện mọi dự án
Câu 3: Tham số vào là MaDD, TenDD. Tính tổng số dự án triển khai tại địa điểm đó
Câu 4: Tham số vào là 1 quý và năm bất kỳ. Tham số ra là tổng số nhân viên có ngày sinh thuộc quý đó
Câu 5: Tham số vào là MaPB, TenPB, TenDiaDiem.
Tính tổng số dự án triển khai tại địa điểm do phòng ban đó phụ trách
*/
--question 1
--create procedure ThongTinDuAn_PhongBan
create procedure ThongTinPhongBan_PhuTrachDuAn @tenpb NVARCHAR(200)
as
begin
	if exists (select TenPHG from PhongBan where TenPHG = @tenpb)
	begin
		select distinct da.MaPHG, pb.TenPHG, da.MaDuAn, da.TenDA from PhongBan pb
		join PhanCongDiaDiem pcdd on pcdd.MaPHG = pb.MaPHG
		join DiaDiem dd on dd.MaDiaDiem = pcdd.MaDiaDiem
		join DuAn da on da.MaDiaDiem = dd.MaDiaDiem
		where pb.TenPHG = @tenpb
	end
	else
		print N'Không tồn tại'
end

exec ThongTinPhongBan_PhuTrachDuAn @tenpb=N'Phòng phần mềm trong nước'
--question 2
create procedure SoGioLamViec_NhanVien @tennv nvarchar(200), @manv decimal(18,0), @tongsogio int output
as
begin
	set @tongsogio = (select sum(pc.SoGio) as NumberOfHours from NhanVien nv
	join PhanCong pc on nv.MaNhanVien = pc.MaNhanVien
	where nv.MaNhanVien = @manv and nv.TenNV = @tennv
	group by nv.MaNhanVien, nv.TenNV)
end

declare @gio int, @tennv nvarchar(200), @manv decimal(18,0)
set @tennv = N'Trần Nguyễn Phương Bình'
set @manv = 30121050049
exec SoGioLamViec_NhanVien @tennv = @tennv, @manv = @manv, @tongsogio = @gio output
print @tennv
print @manv
print N'Số giờ của nhân viên' + ' ' + convert(nvarchar(30),@tennv) +' đó là:' + convert(char(6), @gio)
--question 3
create procedure SoDuAnTheo_DiaDiem @madd int, @tendd nvarchar(200), @tongduan int output
as
begin
	set @tongduan = (select count(da.MaDuAn) as NumOfProjects from DiaDiem dd
	join DuAn da on da.MaDiaDiem = dd.MaDiaDiem
	where dd.TenDiaDiem = @tendd and dd.MaDiaDiem = @madd
	group by dd.MaDiaDiem, dd.TenDiaDiem)
end

select * from DiaDiem
declare @soduan int
exec SoDuAnTheo_DiaDiem @madd = 1, @tendd = N'TP.Hà Nội', @tongduan = @soduan output
select @soduan as NumOfProjects
--question 4: Lấy ra quý
create procedure Cau4_BT_Proc @quy int, @nam int
as
begin
	declare @tongnhanvien int
	set @tongnhanvien = (select count(nv.MaNhanVien) from NhanVien nv
						where datepart(QQ,nv.NgaySinh) = @quy and year(nv.NgaySinh) = @nam)
	return @tongnhanvien
end

declare @tongnv2 int
exec @tongnv2 = Cau4_BT_Proc @quy = 1, @nam = 1968
print @tongnv2