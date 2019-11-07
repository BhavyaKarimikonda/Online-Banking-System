USE Training_13Aug19_Pune
GO

--Creating a Schema for the Project

CREATE SCHEMA BMS
GO

--Creating Table for Storing User Details

CREATE TABLE BMS.Users
(
UserID INT IDENTITY(1000,1) PRIMARY KEY,
UserName VARCHAR(40) UNIQUE NOT NULL,
Email VARCHAR(40) UNIQUE NOT NULL,
PhoneNo VARCHAR(10) UNIQUE NOT NULL foreign key references BMS.AccountDetails(PhoneNo),
Name VARCHAR(50) NOT NULL,
PasswordHash VARBINARY(max) NOT NULL
)

create table BMS.AccountDetails(
AccountNo VARCHAR(15) primary key,
Balance bigint not null,
PhoneNo VARCHAR(10) UNIQUE not null,
Name VARCHAR(50) NOT NULL,
Email VARCHAR(40) NOT NULL,
IFSC varchar(10) not null
)




--Procedure to Check If Any User Credential Already Exists

CREATE PROCEDURE BMS.UserAlreadyExist
@username VARCHAR(40),
@phoneno VARCHAR(10)
AS
DECLARE @ret INT
    BEGIN
        SET @ret=0
        IF (SELECT COUNT(UserID) FROM BMS.Users WHERE UserName=@username)>0
            BEGIN
                SET @ret=@ret+1
            END
        IF (SELECT COUNT(UserID) FROM BMS.Users WHERE PhoneNo=@phoneno)>0
            BEGIN
                SET @ret=@ret+100
            END
        SELECT @ret
    END
GO

--Procedure for Registering the User

CREATE PROCEDURE BMS.RegisterUser
@username VARCHAR(40),
@email VARCHAR(40),
@phoneno VARCHAR(10),
@name VARCHAR(20),
@password VARCHAR(20)
AS
    BEGIN
        INSERT INTO BMS.Users VALUES(@username,@email,@phoneno,@name,EncryptByPassPhrase('2b|!2biet?',@password))
    END
GO

--Procedure for Verifying Login Credentials

CREATE PROCEDURE BMS.VerifyLogin
@loginid VARCHAR(40),
@password VARCHAR(20)
AS
    BEGIN
        SELECT * FROM BMS.Users WHERE (UserName=@loginid AND convert(varchar(20),DecryptByPassPhrase('2b|!2biet?', PasswordHash))=@password) OR (PhoneNo=@loginid AND convert(varchar(20),DecryptByPassPhrase('2b|!2biet?', PasswordHash))=@password)
    END
GO


--For Changing Password
CREATE PROCEDURE BMS.ChangePassword
@loginid VARCHAR(40),
@password VARCHAR(20),
@passwordnew VARCHAR(20)
AS
    BEGIN
        UPDATE BMS.Users SET PasswordHash=EncryptByPassPhrase('2b|!2biet?',@passwordnew) WHERE (UserName=@loginid AND convert(varchar(20),DecryptByPassPhrase('2b|!2biet?', PasswordHash))=@password)
    END
GO



create table BMS.TransactionDetails(
TransactionID int identity(1,1) primary key,
AccountNo VARCHAR(15) foreign key references BMS.AccountDetails(AccountNo),
PayeeID int foreign key references BMS.PayeeDetails(PayeeID),
Amount bigint not null
)




create table BMS.PayeeDetails(
PayeeID int primary key identity(2000,1),
AccountNo VARCHAR(15) foreign key references BMS.AccountDetails(AccountNo),
PayeeAccountNo VARCHAR(15) foreign key references BMS.AccountDetails(AccountNo),
PayeeName Varchar(50) not null,
IFSC Varchar(10) not null,
TransactionLimit bigint not null
)




create table BMS.ChequeBookRequest(
RequestID int primary key identity(3000,1),
AccountNo VARCHAR(15)  foreign key references BMS.AccountDetails(AccountNo),
Pages int not null,
Address Varchar(100) not null
)


drop table 
-----For adding a payee

create procedure BMS.AddPayee
@AccountNo VARCHAR(15),
@PayeeAccountNo VARCHAR(15),
@PayeeName VARCHAR(50),
@IFSC VARCHAR(10),
@TransactionLimit bigint
as
begin
 insert into BMS.PayeeDetails values(@AccountNo, @PayeeAccountNo,@PayeeName,@IFSC,@TransactionLimit)
end
go


-------for requesting checkbook

create procedure BMS.RequestingCB
@AccountNo VARCHAR(15),
@Pages int,
@Address Varchar(100)
as
begin
 insert into BMS.ChequeBookRequest values(@AccountNo,@Pages,@Address)
end
go



-------transactions 

--create procedure BMS.Transactions
--@AccountNo varchar(15),
--@PayeeAccountNo varchar(15),
--@Amount varchar(15)
--as
--begin
--	update BMS.AccountDetails set Balance = Balance - @Amount where AccountNo = @AccountNo ;
--	update BMS.AccountDetails set Balance = Balance + @Amount where AccountNo = @PayeeAccountNo;
--	insert into BMS.TransactionDetails values(@AccountNo, @PayeeAccountNo, @Amount);
--end
--go


create procedure BMS.Transactions
@AccountNo varchar(15),
@PayeeID int,
@Amount bigint
as
declare @PayeeAccountNo varchar(15)
begin
	
	update BMS.AccountDetails set Balance = Balance - @Amount where AccountNo = @AccountNo ;
	select @PayeeAccountNo = PayeeAccountNo from BMS.PayeeDetails where PayeeID = @PayeeID ;
	update BMS.AccountDetails set Balance = Balance + @Amount where AccountNo = @PayeeAccountNo;
	insert into BMS.TransactionDetails values(@AccountNo, @PayeeID, @Amount);
end
go

drop table BMS.TransactionDetails

drop procedure BMS.Transactions

Exec BMS.Transactions '12345678912', 2000, 1000



create procedure BMS.ViewDetails
@PhoneNo varchar(15)
as
begin
	select * from BMS.AccountDetails where PhoneNo = @PhoneNo
end
go

exec BMS.ViewDetails 8888888888


create procedure BMS.ViewPayeeDetails
@AccountNo varchar(15)
as
begin
	select * from BMS.PayeeDetails where AccountNo = @AccountNo
end
go

select * from BMS.AccountDetails


exec BMS.ViewPayeeDetails '12345678912'


create procedure BMS.GetChequeBookRequests
@AccountNo varchar(15)
as
begin
 select * from BMS.ChequeBookRequest where AccountNo = @AccountNo
end
go


create procedure BMS.GetTransactions
@AccountNo varchar(15)
as
begin
	 select * from BMS.TransactionDetails where AccountNo = @AccountNo
end
go


create procedure BMS.GetBalance
@AccountNo varchar(15)
as
begin
	 select Balance from BMS.AccountDetails where AccountNo = @AccountNo
end
go


select * from BMS.PayeeDetails

delete from BMS.Payeedetails where PayeeID = 2001


select * from bms.transactiondetails

delete from BMS.transactiondetails where PayeeID = 2001

select * from BMS.accountdetails


create procedure BMS.CheckPhoneNumber
@PhoneNo varchar(15)
as
begin
	select * from BMS.AccountDetails where PhoneNo = @PhoneNo
end
go

create procedure BMS.CheckPayee
@PayeeAccountNo varchar(15)
as
begin
	select * from BMS.AccountDetails where AccountNo = @PayeeAccountNo
end
go


create procedure BMS.CheckLoan
@AccountNo varchar(15)
as
begin
	select * from BMS.LoanDetails where AccountNo = @AccountNo
end
go

drop procedure BMS.CheckLoan
drop table BMS.LoanDetails


create table BMS.LoanDetails(
LoanAccNo bigint  primary key identity(10000,1),
AccountNo VARCHAR(15)  foreign key references BMS.AccountDetails(AccountNo),
LoanBalance bigint not null,
PrincipleAmount bigint not null,
TypeId int foreign key references BMS.LoanTypeTable(TypeId)
)


create table BMS.LoanTypeTable(
TypeId int primary key identity(700,1) ,
LoanType varchar(30) not null unique,
InterestRate int not null
)


drop table BMS.LoanDetails


create procedure BMS.GetLoanTypes
as
begin
	select * from BMS.LoanTypeTable
end
go

create procedure BMS.GetInterestRate
@TypeId int
as
begin
	select InterestRate from BMS.LoanTypeTable where TypeId = @TypeId
end
go


create procedure BMS.TakeLoan
@AccountNo VARCHAR(15),
@LoanBalance bigint ,
@PrincipleAmount bigint ,
@TypeId int
as
begin
	insert into BMS.LoanDetails values(@AccountNo,@LoanBalance,@PrincipleAmount,@TypeId )
end
go

select * from BMS.LoanDetails

delete from BMS.LoanDetails where LoanAccNo = 10000


create procedure BMS.GetLoanDetails
@AccountNo varchar(15)
as
begin
	select * from BMS.LoanDetails 
end
go