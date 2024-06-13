-- mssql1

-- insert a row over on publisher on sql1
use Northwind 
go

select *
from dbo.Customers
where City = 'Dublin'

INSERT INTO dbo.Customers
(CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax)
VALUES
('DUBAI', 'Dublin AI Innovations', 'Alice Murphy', 'CEO', '987 Dublin Plaza', 'Dublin', 'Leinster', 'D06', 'Ireland', '0678912345', '0678912345'),
('DUBDS', 'Dublin Data Science', 'Bob Walsh', 'CTO', '876 Dublin Heights', 'Dublin', 'Leinster', 'D07', 'Ireland', '0789123456', '0789123456');

-- go check it out on sql2