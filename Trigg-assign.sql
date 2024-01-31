--1 Bảng insert không được phép insert các book có status = 0
create trigger checkBookAvailability  
 on [insert]
 for INSERT
as
 begin
	declare @BookID int
	select @BookID = inserted.BOOK_ID
	from inserted
	declare @status bit
	select @status = BOOK.STATUS 
	from BOOK
	where book.BOOK_ID = @BookID
	if @status = 0 
	begin 
		rollback tran
		print N'The book you order is not available at the current time'
	end
 end 

 --test case
 insert into [INSERT] values (1001, 444, 10, 80000)
 insert into [INSERT] values (1002, 445, 5, 50000)
 delete from [INSERT] where [INSERT].ORDER_ID = 445
 select * from [INSERT]
 select * from BOOK

 --2 Khi thêm dữ liệu của sách vào bảng insert thì tổng tiền và tổng số lượng ở hoá đơn 
 -- sẽ thay đổi theo cho phù hợp
go
 create trigger checkInsertTotalCost 
 on [Insert]
 for insert 
 as 
 begin
	declare @Amount int
	select @Amount = [inserted].TOTAL_AMOUNT from inserted
	declare @TotalCost decimal(18,0)
	select @TotalCost =[inserted].TOTAL_COST from inserted
	declare @price  decimal(18,0)
	select @price = book.COST from BOOK, inserted
	where inserted.BOOK_ID = BOOK.BOOK_ID
	if @TotalCost != sum(@Amount * @price)
	begin
	rollback tran
	print N'The total money you inserted is wrong compare to the data '
	end
 end
 -- test case
 insert into [INSERT] values (1002,444,2,34000)

 -- cập nhật tổng tiền của hoá đơn khi thêm sách 
 go
 create trigger checkmoney
 on [Insert]
 for insert 
 as 
 begin 
	declare @TotalCost  decimal(18,0)
	select @TotalCost =[inserted].TOTAL_COST from inserted
	declare @Order_id int 
	select @Order_id = inserted.ORDER_ID from inserted
	declare @OrderMoney  decimal(18,0)
-- tính và update tiền order sau khi thêm
	select @OrderMoney = od.TOTAL_COST + @TotalCost
	from [ORDER] od, inserted
	where od.ORDER_ID = @Order_id
	update [ORDER]
	set TOTAL_COST = @OrderMoney
	where [ORDER].ORDER_ID = @Order_id 
-- tính và update số lượng order sau khi thêm
	declare @InsertAmount int 
	select @InsertAmount = sum(inserted.TOTAL_AMOUNT) from inserted, [ORDER] od1
	where @Order_id = od1.ORDER_ID

	declare @TotalAmount int
	select @TotalAmount = od.TOTAL_AMOUNT + @InsertAmount
	from [ORDER] od, inserted
	where od.ORDER_ID = @Order_id

	update [ORDER]
	set TOTAL_AMOUNT = @TotalAmount
	where [ORDER].ORDER_ID = @Order_id 
 end 

 --test case 
 insert into [ORDER] values (444,0,0,'20231212', 101)
 insert into [INSERT] values (1002,444,2,34000)
 insert into [INSERT] values (1003,444,3,51000)

 --3 Không được phép insert bất cứ hoá đơn nào có ngày xuất 
 --là trước ngày hôm nay
 go 
 create trigger checkBookingDay
 on [order]
 for insert 
 as 
 begin
	declare @Insert_Day date
	select @Insert_Day = inserted.BOOKING_DAY from inserted
	if @Insert_Day < convert(date,getdate())
	begin 
	rollback tran
	print N'Cannot insert order that has booking day is before current day'
 end
 end

 --test case 
 insert into [ORDER] values (421,5, 57000,'20231012',101)
 select * from [ORDER]

 --4. update tên sách không được phép trùng với tên sách khác 
go
create trigger BookCanNotBeDuplicated
on book
for update 
as 
begin 
	declare @BookName nvarchar(100)
	select @BookName = (Select inserted.BOOK_NAME from inserted)
	declare @Count int 
	select @Count = (select count(*) from BOOK where BOOK.BOOK_NAME = @BookName)
	if (@Count > 1)
	begin 
	rollback tran 
	print N'Book can not be duplicate'
	return 
	end 
end
--test case
update BOOK
set BOOK_NAME = N'Doraemon tập 2'
where BOOK_ID = 1001

select * from BOOK
 --5 Không được phép update author của bất cứ cuốn sách nào
 drop trigger prevent_author_update
 CREATE TRIGGER prevent_author_update
ON Book
AFTER UPDATE
AS
BEGIN
    IF UPDATE(author)
    BEGIN
		PRINT N'Cannot update the author of a book!!!'
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;

-- test case
update BOOK
set AUTHOR = N'Uchiha Itachi'
where BOOK.BOOK_ID = 1001

select * from BOOK

--6 Không được phép update bất cứ hoá đơn nào trước ngày hôm nay

create trigger updateOrder
on [Order]
for update
as
begin
declare @Insert_Day date
	select @Insert_Day = inserted.BOOKING_DAY from inserted
	if @Insert_Day < convert(date,getdate())
	begin 
	rollback tran
	print N'Cannot update order that has booking day is before current day'
end
end

--test case 
insert into [ORDER] values (424,3,150000,'20230110',102)
update [ORDER]
set TOTAL_AMOUNT = 10
where ORDER_ID = 424


--7 Không được phép xoá chức vụ quản lý
drop trigger prevent_Manager_deletion
create trigger prevent_Manager_deletion
on staff
instead of delete
as 
begin
if exists (select 1 from deleted where OFFICE = N'Quản lý')
begin
	print N'Quản lý cannot be delete'
	rollback tran
	return; --Dừng lệnh trigger
end
else
begin
delete from STAFF 
where STAFF_ID in (select STAFF_ID from deleted) 
end
end

--test case
insert into STAFF values(108,N'Lê Văn Luyến',N'Quản Lý')

select * from STAFF


--8 Không được phép xoá hoá đơn nào có mã nhân viên của nhân viên có
-- chức vụ là thu ngân

create trigger prevent_deleting_order_of_ThuNgan
on [order]
for delete
as 
begin
	declare @staff_id int 
	select @staff_id = STAFF_ID from deleted
	declare @office nvarchar(100)
	select @office = OFFICE from STAFF 
	where STAFF_ID = @staff_id 
	if @office = N'Thu ngân'
	begin
		rollback tran
		print N'You can not delete bill that make by Thu ngân'
	end
end

--test case
insert into [ORDER] values (444,0,0,'20231213', 102)
delete from [ORDER] where ORDER_ID = 401

-- 9 không được phép xoá các hoá đơn có tổng tiền trên 50k

create trigger notDelete50KAbove
on [order]
instead of delete 
as
begin 
	declare @TotalCost decimal(18,0) 
	select @TotalCost = [ORDER].TOTAL_COST from deleted, [ORDER] where deleted.ORDER_ID = [ORDER].ORDER_ID
	if (@TotalCost > 50000)
	begin 
		rollback tran
		print N'Can not delete any order that has total cost over 50K'
		return
	end
	else
	begin
		delete from [order] where ORDER_ID in (select ORDER_ID from deleted)
	end
end
-- test case 
delete from [ORDER] where ORDER_ID = 403
select * from [ORDER]
