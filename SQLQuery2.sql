CREATE database powerQuery;
use  powerQuery
 select * from Churn_Modelling
 select count(*) from Churn_Modelling

 
 --FUNCTION--
 CREATE FUNCTION CustomerDetails (@customerID int,@isActiveMember int)
 RETURNS table
 AS
 RETURN 
 select CustomerID,Surname,Geography,Age,Gender,IsActiveMember from Churn_Modelling
 WHERE CustomerID=@customerID and IsActiveMember=@isActiveMember

 SELECT * FROM dbo.CustomerDetails(15634602,1)
 
 ---Multi statement Function---
 create function Fn_CustomerDetails(@customerId int)
returns @table table 
	(
		Surname varchar(50),
		Gender varchar(50),	
		Age varchar(50)
	)
as 
begin
declare @active_member int;
set @active_member=(select IsActiveMember from Churn_Modelling where CustomerId = @customerId);
	if @active_member = 1
		insert into @table
		select Surname,Gender,Age from Churn_Modelling where CustomerId = @customerId and IsActiveMember = 1
	else
		insert into @table
		select Surname,Gender,Age from Churn_Modelling where CustomerId = @customerId and IsActiveMember = 0
return
end
select * from Fn_CustomerDetails(15634602)

 --VIEW--
 CREATE VIEW vwCustomerDetails
 As
 select CustomerID,Surname,Geography,Age,Gender,IsActiveMember from Churn_Modelling

 SELECT * FROM vwCustomerDetails
 
 --CURSOR--

 select * from Churn_Modelling
 
DECLARE @Customer_id int  
DECLARE @surname varchar(80)  
DECLARE @gender varchar(80)
DECLARE @geography varchar(80)
DECLARE @estimatedSalary decimal
  
DECLARE customerDetails_CURSOR CURSOR  
FOR  SELECT   CustomerId,surname,gender,geography,estimatedSalary FROM Churn_Modelling
OPEN  customerDetails_CURSOR 
FETCH NEXT FROM customerDetails_CURSOR INTO  @Customer_id,@surname,@gender,@geography, @estimatedSalary
WHILE @@FETCH_STATUS = 0  
BEGIN  
PRINT  'CUSTOMER_ID: ' +CAST(@Customer_id AS varchar) +  '  SURNAME:' +@surname +'  GENDER:' +@gender+  ' GEOGRAPHY:' +@geography+  'ESTIMATED SALARY:' +CAST(@estimatedSalary AS varchar)
FETCH NEXT FROM customerDetails_CURSOR INTO  @Customer_id,@surname,@gender,@geography,@estimatedSalary 
END  
CLOSE customerDetails_CURSOR  
DEALLOCATE customerDetails_CURSOR

 -- Customer Details using STORED PROCEDURE
  select * from Churn_Modelling
 
  create procedure sp_customerDetailsIDWise (@customerID as int)
  AS
  BEGIN try 
   SELECT   CustomerId,surname,gender,geography,estimatedSalary FROM Churn_Modelling
   where CustomerId = @customerID
  END try
  begin catch
	SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
  end catch

 execute sp_customerDetailsIDWise
 @customerID= 15701354

 create procedure getDBStatus
@DatabaseID int 
as
begin
declare @DBStatus varchar(20)
set @DBStatus=(select state_desc from sys.databases where database_id=@DatabaseID)
if @DBStatus='ONLINE'
Print ' Database is ONLINE'
else
Print 'Database is in ERROR state.'
End

exec getDBStatus
@DatabaseID = 5

select * from sys.databases

create procedure sp_countOfProducts
@geography varchar (50) ,
@active_member int
as
begin try
if @active_member =1
Select MIN(NumOfProducts) as minProduct,MAX(NumOfProducts) as maxProduct from Churn_Modelling WHERE Geography=@geography AND IsActiveMember=@active_member
else
Select MIN(NumOfProducts) as minProduct,MAX(NumOfProducts) as maxProduct from Churn_Modelling
End try
 begin catch
	SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
  end catch

exec sp_countOfProducts
@geography ='France',@active_member=1


--Transaction--
SELECT * FROM Churn_Modelling
SET IMPLICIT_TRANSACTIONS ON
 UPDATE Churn_Modelling SET Balance = 105362 WHERE CustomerId = 15634602
 DECLARE @ch int ;
 SET @ch=1
 if @ch=1
 BEGIN 
       COMMIT
 END
 ELSE 
 BEGIN 
       ROLLBACK
END

------------Savepoint TRANSACTION-------
select *from Churn_Modelling;

BEGIN TRANSACTION
UPDATE Churn_Modelling SET CreditScore =650 WHERE CustomerId = 1563460
SAVE TRANSACTION DeletePoint
DELETE FROM  Churn_Modelling WHERE CustomerId = 15647311
DELETE FROM  Churn_Modelling WHERE CustomerId = 15619304
ROLLBACK TRANSACTION DeletePoint
COMMIT

--find the sum of estimated salary group by active member

SELECT SUM(EstimatedSalary)  as 'Total Estimated Salary',IsActiveMember  FROM Churn_Modelling group by IsActiveMember

