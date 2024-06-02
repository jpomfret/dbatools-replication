--sql1

-- insert a row over on publisher on sql1
use AdventureWorksLT2022 
go

select *
from salesLT.customer
where lastname = 'gates'

INSERT INTO salesLT.customer (NameStyle,Title,FirstName,LastName,PasswordHash,PasswordSalt,rowguid)
values ('0','Mr.','Bill','Gates','ElzTpSNbUW1Ut+L5cWlfR7MF6nBZia8WpmGaQPjLOJA=','nm7D5e4=','949E9AC8-F8F6-4F7F-8888-87187AC56919')

-- go check it out on sql2