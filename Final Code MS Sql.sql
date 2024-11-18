Select * from [Data];
 
-- View Duplicates
select *, ROW_NUMBER() over(partition by [Timestamp],
 Gender,Degree,	BusinessMarket,	Title,	ProgrammingLanguages,
 BusinessSize,Yoe,YoeBuckets,BusinessFocus,	TotalCompensationEgp,
 BusinessLine,TotalCompensationEgpBuckets,Industries,WorkSetting,[Level],
 IsEgp,CompanyLocation order by Degree) as Number_Rows

 from [Data];


 with Depulectte AS
 (
select *, ROW_NUMBER() over(partition by [Timestamp],
 Gender,Degree,	BusinessMarket,	Title,	ProgrammingLanguages,
 BusinessSize,Yoe,YoeBuckets,BusinessFocus,	TotalCompensationEgp,
 BusinessLine,TotalCompensationEgpBuckets,Industries,WorkSetting,[Level],
 IsEgp,CompanyLocation order by Degree) as Number_Rows

 from [Data]

 )

 select * from Depulectte
 where Number_Rows>1;

 --Seeing and finding outliers

DECLARE @Q1 as float;
DECLARE @Q3 as float;
DECLARE @IoR as float;
SELECT MAX(TotalCompensationEgp) AS "Median" FROM (  SELECT TotalCompensationEgp, NTILE(4) OVER(ORDER BY TotalCompensationEgp) AS Quartile  
FROM [Data]) x
WHERE Quartile = 1;
Set @Q1 = (SELECT MAX(TotalCompensationEgp) AS "Median" FROM ( SELECT TotalCompensationEgp, NTILE(4) OVER(ORDER BY TotalCompensationEgp) AS Quartile
FROM [Data]) x
WHERE Quartile = 1);
Set @Q3 = (SELECT MAX(TotalCompensationEgp) AS "Median"FROM ( SELECT TotalCompensationEgp, NTILE(4) OVER(ORDER BY TotalCompensationEgp) AS Quartile 
FROM [Data]) x
WHERE Quartile = 3);
Set @IoR = (@Q3 - @Q1);
select  @Q1 as "Q1", @Q3 as "Q3", @IoR as "IoR" from [Data];
SELECT * FROM [Data] where TotalCompensationEgp <=( @Q1 - 1.5* @IoR) or TotalCompensationEgp >=( @Q3 + 1.5* @IoR)  ;

--Exploring empty values
 select sum(IIF([Timestamp] is null ,1,0)) as NumberOfNulls from [Data];
 select sum(IIF(Gender is null ,1,0)) as NumberOfNulls from [Data];
 select sum(IIF(Degree is null ,1,0)) as NumberOfNulls from [Data];
 select sum(IIF(BusinessMarket is null ,1,0)) as NumberOfNulls from [Data];
 select sum(IIF(ProgrammingLanguages is null ,1,0)) as NumberOfNulls from [Data];
 select sum(IIF(TotalCompensationEgpBuckets is null ,1,0)) as NumberOfNulls from [Data];
 select sum(IIF(Industries is null ,1,0)) as NumberOfNulls from [Data];
 select sum(IIF(CompanyLocation is null ,1,0)) as NumberOfNulls from [Data];
 
 select (CAST( sum(IIF([Timestamp] is null ,1,0)) AS float )/count(*) )*100 as [%NumberOfNulls] from [Data];
 select (CAST( sum(IIF(BusinessMarket is null ,1,0)) AS float )/count(*) )*100 as [%NumberOfNulls] from [Data];
 select (CAST( sum(IIF(ProgrammingLanguages is null ,1,0)) AS float )/count(*) )*100 as [%NumberOfNulls] from [Data];
 select (CAST( sum(IIF(TotalCompensationEgpBuckets is null ,1,0)) AS float )/count(*) )*100 as [%NumberOfNulls] from [Data];
 select (CAST( sum(IIF(Industries is null ,1,0)) AS float )/count(*) )*100 as [%NumberOfNulls] from [Data];
 select (CAST( sum(IIF(CompanyLocation is null ,1,0)) AS float )/count(*) )*100 as [%NumberOfNulls] from [Data];


 ----------------

 Select ProgrammingLanguages,Industries from [Data];

 SELECT *
FROM [Data]
    CROSS APPLY STRING_SPLIT(REPLACE( ProgrammingLanguages, '/',','),',')
	    CROSS APPLY STRING_SPLIT(REPLACE( Industries, '/',','),',') ;













-- 
  Alter Table [Data]
 Add  ID int identity;
 create table Main_1( [Timestamp] date,[Gender]   varchar(255),[Degree]	varchar(255),[BusinessMarket]	varchar(255),[Title]	varchar(255)
,[ProgrammingLanguages]	varchar(255),[BusinessSize]	varchar(255),[Yoe] int,[BusinessFocus] varchar(255),[TotalCompensationEgp] float
,[BusinessLine] varchar(255),[Industries] varchar(Max),[WorkSetting]	varchar(255),[Level]	varchar(255),[IsEgp]	varchar(255)
,[CompanyLocation] varchar(255),[MinCompensationRange] varchar(255),[MaxCompensationRange] varchar(255),[ID] int ,[Programming_Language] varchar(255));
 
 insert into Main_1
  Select * FROM [Data]
    CROSS APPLY STRING_SPLIT(REPLACE( ProgrammingLanguages, '/',','),',');
  Create Table Programing_Languages(ID_PL int ,	[Programing Language] Varchar(255));
 select * from Main_1;
 insert into Programing_Languages
  SELECT ID, Programming_Language FROM Main_1;
 update Programing_Languages
 set [Programing Language] = TRIM([Programing Language]);
Select * from Programing_Languages;


create table Main_2([Timestamp] date,[Gender] varchar(255),[Degree]	varchar(255),[BusinessMarket]	varchar(255),[Title] varchar(255),[ProgrammingLanguages]	 varchar(255)
,[BusinessSize]	varchar(255),[Yoe] int,[BusinessFocus] varchar(255),[TotalCompensationEgp] float,[BusinessLine] varchar(255),[Industries] varchar(Max),[WorkSetting] varchar(255)
,[Level] varchar(255),[IsEgp] varchar(255),[CompanyLocation] varchar(255),[MinCompensationRange] varchar(255),[MaxCompensationRange] varchar(255),[ID] int,[Industry] varchar(255));

insert into Main_2
  Select *  FROM [Data]
    CROSS APPLY STRING_SPLIT( Industries,',');
Create Table Industries(ID_In int ,[Industry] Varchar(255));

insert into Industries
  SELECT ID, [Industry] FROM Main_2;
Alter Table [Data]
 Drop Column [Industries], [ProgrammingLanguages];

 select * from Industries;
 select * from [Data];


Alter Table Programing_Languages
add constraint FK_PL_To_Main
foreign key (ID_PL) References [Data](ID);

Alter Table Industries
add constraint FK_In_To_Main
foreign key (ID_In) References [Data](ID);





 Create Table Employees(Emp_ID int Primary Key identity,Gender Varchar(255),[Level] Varchar(255),Degree  Varchar(255));
 insert into Employees
 select distinct Gender, [Level], Degree
 from [Data];
Alter Table [Data]
add ID_Employee int;

Update [Data] 
 set [Data].ID_Employee = Employees.Emp_ID from Employees
 where Employees.Degree = [Data].Degree and Employees.Gender = [Data].Gender and Employees.[Level] = [Data].[Level];
Alter Table [Data]
 Drop Column Degree,Gender,[Level];
select * from Employees;
select * from [Data];


Create Table Company(Comp_ID int Primary Key identity,[BusinessMarket] Varchar(255),[BusinessSize] Varchar(255)
 ,[BusinessFocus] Varchar(255),[BusinessLine] Varchar(255),[Location] Varchar(255));

insert into Company
 select distinct [BusinessMarket], [BusinessSize], [BusinessFocus],[BusinessLine],[CompanyLocation] from [Data];
Alter Table [Data]
 Add ID_Company int ;
Update [Data] 
 set [Data].ID_Company = Company.Comp_ID  from Company
 where Company.[BusinessMarket] = [Data].[BusinessMarket] and Company.[BusinessSize] = [Data].[BusinessSize]
 and Company.[BusinessFocus] = [Data].[BusinessFocus] and Company.[BusinessLine] = [Data].[BusinessLine]
 and Company.[Location] = [Data].[CompanyLocation];
Alter Table [Data]
 Drop Column  [BusinessMarket], [BusinessSize], [BusinessFocus],[BusinessLine],[CompanyLocation] ;

select * from Company;
select * from [Data];



Create Table Job(Job_ID int Primary Key identity,Company_ID int,[Title] Varchar(255),[MinCompensationRange] Float,[MaxCompensationRange] Float
	,[WorkSetting] Varchar(255),[YoE] int,[TotalCompensationEgp] Float,[IsEgp] Varchar(255));

insert into Job
 select distinct [ID_Company], [Title], [MinCompensationRange],[MaxCompensationRange],[WorkSetting],[Yoe],[TotalCompensationEgp],[IsEgp]
 from [Data];

Alter Table [Data]
 add ID_Job int ;
Update [Data] 
 set [Data].ID_Job = Job.Job_ID from Job
 where Job.[Company_ID] = [Data].[ID_Company] and Job.[Title] = [Data].[Title] and Job.[MinCompensationRange] = [Data].[MinCompensationRange]
 and Job.[MaxCompensationRange] = [Data].[MaxCompensationRange] and Job.[WorkSetting] = [Data].[WorkSetting] 
 and Job.[YoE] = [Data].[Yoe] and Job.[TotalCompensationEgp] = [Data].[TotalCompensationEgp] and  Job.[IsEgp] = [Data].[IsEgp];

Alter Table [Data]
 Drop Column [ID_Company], [Title], [MinCompensationRange],[MaxCompensationRange],[WorkSetting],[Yoe],[TotalCompensationEgp],[IsEgp];

select * from Job;
select * from Company;
select * from [Data];


 Declare @StartDate date = (select Min([Timestamp]) From [Data]);
Declare @EndDate date = (select Max([Timestamp]) From [Data]);

With Calendarr As
(
select @StartDate as [Date]
Union All
Select DATEADD(dd,1,[Date])
from Calendarr 
Where DATEADD(dd,1,[Date]) <= @EndDate
)
Select [Date] From Calendarr

OPTION (MAXRECURSION 0)

select Month([Date]) , DATEPART(quarter, [Date]),Year([Date])
from Calendarr 
OPTION (MAXRECURSION 0)
------------------------------------
Create Table Calendar( [Date]    date Primary Key,[Year]  int  not null,[Quarter] varchar(10)  not null,[MonthName]   varchar(10)  not null,[MonthNum] int,
[Weekday] Varchar(50),[WeekNum] int)
  
Declare @StartDate date = (select Min([Timestamp]) From [Data]);
Declare @EndDate date = (select Max([Timestamp]) From [Data]);

With Calendarr As( select @StartDate as [Date] Union All Select DATEADD(dd,1,[Date]) from Calendarr Where DATEADD(dd,1,[Date]) <= @EndDate)
insert into Calendar([Date],[Year],[Quarter],[MonthName],[MonthNum],[Weekday],[WeekNum])

select [Date],Year([Date]), DATEPART(quarter, [Date]),SUBSTRING( DateName( month ,[Date]),1,3),Month([Date]),SUBSTRING( DATENAME(dw,[Date]) ,1,3),
DATEPART(dw,[Date]) from Calendarr 
OPTION (MAXRECURSION 0)

update Calendar 
set [Quarter] = 'Q'+[Quarter];

select * from Calendar


Alter Table [Data]
add constraint FK_data_To_Data 
foreign key ([Timestamp]) References Calendar([Date]);

Alter Table [Data]
add constraint FK_job_To_data
foreign key (ID_Job) References Job(Job_ID);


Alter Table Job
add constraint FK_company_To_job
foreign key (Company_ID) References Company(Comp_ID);


Alter Table [Data]
add constraint FK_emp_To_data
foreign key (ID_Employee) References Employees(Emp_ID);





Select count(Employees.Emp_ID)
from Industries,Employees,[Data]
where [Data].ID = Industries.ID_In and [Data].ID_Employee = Employees.Emp_ID;












