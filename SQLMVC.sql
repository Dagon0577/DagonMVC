USE [master]
GO
/****** Object:  Database [DB]    Script Date: 2017/10/1 20:03:22 ******/
CREATE DATABASE [DB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\DB.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'DB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\DB_log.ldf' , SIZE = 3136KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [DB] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [DB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [DB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [DB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [DB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [DB] SET ARITHABORT OFF 
GO
ALTER DATABASE [DB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [DB] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [DB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [DB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [DB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [DB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [DB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [DB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [DB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [DB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [DB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [DB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [DB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [DB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [DB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [DB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [DB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [DB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [DB] SET RECOVERY FULL 
GO
ALTER DATABASE [DB] SET  MULTI_USER 
GO
ALTER DATABASE [DB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [DB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [DB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [DB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'DB', N'ON'
GO
USE [DB]
GO
/****** Object:  StoredProcedure [dbo].[P_Sys_ClearUnusedRightOperate]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[P_Sys_ClearUnusedRightOperate]
as
--清理权限中的无用项目
delete from SysRightOperate where Id not in(
    select a.RoleId+a.ModuleId+b.KeyCode from SysRight a,SysModuleOperate b
        where a.ModuleId = b.ModuleId
)

GO
/****** Object:  StoredProcedure [dbo].[P_Sys_DeleteSysRoleSysUserByRoleId]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[P_Sys_DeleteSysRoleSysUserByRoleId]
@roleId varchar(50)
AS
--更新角色用户中间关系表,前删除关联
BEGIN
    delete SysRoleSysUser where SysRoleId=@roleId
END
GO
/****** Object:  StoredProcedure [dbo].[P_Sys_DeleteSysRoleSysUserByUserId]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[P_Sys_DeleteSysRoleSysUserByUserId]
@userId varchar(50)
AS
--更新角色用户中间关系表,前删除关联
BEGIN
    delete SysRoleSysUser where SysUserId=@userId
END
GO
/****** Object:  StoredProcedure [dbo].[P_Sys_GetRightByRoleAndModule]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[P_Sys_GetRightByRoleAndModule]
@roleId varchar(50),@moduleId varchar(50)
as
--按选择的角色及模块加载模块的权限项
begin
select a.Id,a.Name,a.KeyCode,a.ModuleId,ISNULL(b.IsValid,0) as isvalid,a.Sort,@roleId+@moduleId as RightId
    from SysModuleOperate a
    left outer join(
        select c.Id,a.IsValid from SysRightOperate a,SysRight b, SysModuleOperate c
        where RightId in
        (select Id From SysRight where RoleId =@roleId and ModuleId =@moduleId)
         and a.RightId=b.Id
         and b.ModuleId=c.ModuleId
         and a.KeyCode =c.KeyCode) b
     on a.Id = b.Id
     where a.ModuleId =@moduleId
end
GO
/****** Object:  StoredProcedure [dbo].[P_Sys_GetRightOperate]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:        <Author,,Name>
-- Create date: <Create Date,,>
-- Description:    <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Sys_GetRightOperate]
@userId varchar(50),@url varchar(200)
AS
--取模块的当前用户操作权限
select distinct KeyCode,IsValid from SysRightOperate where RightId in(
select a.id from SysRight a, SysModule b where RoleId in(
    select SysRoleId from SysRoleSysUser where SysUserId =@userId)
    and a.ModuleId = b.Id
    and b.Url =@url)
    and IsValid=1



GO
/****** Object:  StoredProcedure [dbo].[P_Sys_GetRoleByUserId]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[P_Sys_GetRoleByUserId]
@UserId varchar(50)
as
begin
--读取用户所包含的角色
select a.*,ISNULL(b.SysUserId,0) as flag from SysRole a left join
    SysRoleSysUser b 
    on a.Id = b.SysRoleId
    and b.SysUserId = @UserId
    order by b.SysUserId desc
end 
GO
/****** Object:  StoredProcedure [dbo].[P_Sys_GetUserByRoleId]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[P_Sys_GetUserByRoleId]
@RoleId varchar(50)
as
begin
--读取角色所包含的用户
select a.*,ISNULL(b.SysUserId,0) as flag from SysUser a left join
SysRoleSysUser b on a.Id=b.SysUserId
and b.SysRoleId=@RoleId
order by b.SysRoleId desc
end 
GO
/****** Object:  StoredProcedure [dbo].[P_Sys_InsertSysRight]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[P_Sys_InsertSysRight]
as
--将设置好的模块分配到角色组
    insert into SysRight(Id,ModuleId,RoleId,Rightflag)
        select distinct b.Id+a.Id,a.Id,b.Id,0 from SysModule a,SysRole b
        where a.Id+b.Id not in(select ModuleId+RoleId from SysRight)
GO
/****** Object:  StoredProcedure [dbo].[P_Sys_UpdateSysRightRightFlag]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[P_Sys_UpdateSysRightRightFlag]
@moduleId varchar(200),@roleId varchar(200)
as
begin
--计算上级模块的rightflag标识
declare @count int
--第一层：由操作权限项计算模块权限
select @count=COUNT(*) from SysRightOperate where RightId=@roleId+@moduleId and IsValid=1

if(@count>0)
begin
    update SysRight set Rightflag=1 where ModuleId=@moduleId and RoleId=@roleId
end
else
begin
    update SysRight set Rightflag=0 where ModuleId=@moduleId and RoleId=@roleId
end
--计算下一层
declare @parentId varchar(50)
set @parentId=@moduleId

while(@parentId<>'0')
begin
    select @parentid=ParentId from SysModule where Id=@parentId
    if (@parentId is null)
    begin
        return
    end
    
    select @count=COUNT(*) from SysRight where ModuleId in
        (select Id from SysModule where ParentId=@parentId)
        and RoleId =@roleId
        and Rightflag=1
    
    if(@count>0)
    begin
        update SysRight set Rightflag=1 where ModuleId=@parentId and RoleId=@roleId
    end
    else
    begin
        update SysRight set Rightflag=0 where ModuleId=@parentId and RoleId=@roleId
    end
end
end
GO
/****** Object:  StoredProcedure [dbo].[P_Sys_UpdateSysRoleSysUser]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[P_Sys_UpdateSysRoleSysUser]
@roleId varchar(50),@userId varchar(50)
AS
--更新角色用户中间关系表
BEGIN
    insert into SysRoleSysUser(SysRoleId,SysUserId)
        values(@roleId,@userId)
END
GO
/****** Object:  Table [dbo].[SysException]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SysException](
	[Id] [varchar](50) NOT NULL,
	[HelpLink] [varchar](500) NULL,
	[Message] [varchar](500) NULL,
	[Source] [varchar](500) NULL,
	[StackTrace] [text] NULL,
	[TargetSite] [varchar](500) NULL,
	[Data] [varchar](500) NULL,
	[CreateTime] [datetime] NULL,
 CONSTRAINT [PK_SysException] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SysLog]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SysLog](
	[Id] [varchar](50) NOT NULL,
	[Operator] [varchar](50) NULL,
	[Message] [varchar](500) NULL,
	[Result] [varchar](20) NULL,
	[Type] [varchar](20) NULL,
	[Module] [varchar](20) NULL,
	[CreateTime] [datetime] NULL,
 CONSTRAINT [PK_SysLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SysModule]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SysModule](
	[Id] [varchar](50) NOT NULL,
	[Name] [varchar](200) NOT NULL,
	[EnglishName] [varchar](200) NULL,
	[ParentId] [varchar](50) NULL,
	[Url] [varchar](200) NULL,
	[Iconic] [varchar](200) NULL,
	[Sort] [int] NULL,
	[Remark] [varchar](4000) NULL,
	[Enable] [bit] NOT NULL,
	[CreatePerson] [varchar](200) NULL,
	[CreateTime] [datetime] NULL,
	[IsLast] [bit] NOT NULL,
	[Version] [timestamp] NULL,
 CONSTRAINT [PK_SysModule] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SysModuleOperate]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[SysModuleOperate](
	[Id] [varchar](200) NOT NULL,
	[Name] [varchar](200) NOT NULL,
	[KeyCode] [varchar](200) NOT NULL,
	[ModuleId] [varchar](50) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[Sort] [int] NOT NULL,
 CONSTRAINT [PK_SysModuleOperate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SysRight]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[SysRight](
	[Id] [varchar](200) NOT NULL,
	[ModuleId] [varchar](50) NOT NULL,
	[RoleId] [varchar](50) NOT NULL,
	[Rightflag] [bit] NOT NULL,
 CONSTRAINT [PK_SysRight] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SysRightOperate]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[SysRightOperate](
	[Id] [varchar](200) NOT NULL,
	[RightId] [varchar](200) NOT NULL,
	[KeyCode] [varchar](200) NOT NULL,
	[IsValid] [bit] NOT NULL,
 CONSTRAINT [PK_SysRightOperate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SysRole]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[SysRole](
	[Id] [varchar](50) NOT NULL,
	[Name] [varchar](200) NOT NULL,
	[Description] [varchar](4000) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[CreatePerson] [varchar](200) NOT NULL,
 CONSTRAINT [PK_SysRole] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SysRoleSysUser]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[SysRoleSysUser](
	[SysUserId] [varchar](50) NOT NULL,
	[SysRoleId] [varchar](50) NOT NULL,
 CONSTRAINT [PK_SysRoleSysUser] PRIMARY KEY CLUSTERED 
(
	[SysUserId] ASC,
	[SysRoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SysSample]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SysSample](
	[Id] [varchar](50) NOT NULL,
	[Name] [varchar](50) NULL,
	[Age] [int] NULL,
	[Bir] [datetime] NULL,
	[Photo] [varchar](50) NULL,
	[Note] [text] NULL,
	[CreateTime] [datetime] NULL,
 CONSTRAINT [PK__SysSampl__3214EC075AEE82B9] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SysUser]    Script Date: 2017/10/1 20:03:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[SysUser](
	[Id] [varchar](50) NOT NULL,
	[UserName] [varchar](200) NOT NULL,
	[Password] [varchar](200) NOT NULL,
	[TrueName] [varchar](200) NULL,
	[Card] [varchar](50) NULL,
	[MobileNumber] [varchar](200) NULL,
	[PhoneNumber] [varchar](200) NULL,
	[QQ] [varchar](50) NULL,
	[EmailAddress] [varchar](200) NULL,
	[OtherContact] [varchar](200) NULL,
	[Province] [varchar](200) NULL,
	[City] [varchar](200) NULL,
	[Village] [varchar](200) NULL,
	[Address] [varchar](200) NULL,
	[State] [bit] NULL,
	[CreateTime] [datetime] NULL,
	[CreatePerson] [varchar](200) NULL,
	[Sex] [varchar](10) NULL,
	[Birthday] [datetime] NULL,
	[JoinDate] [datetime] NULL,
	[Marital] [varchar](10) NULL,
	[Political] [varchar](50) NULL,
	[Nationality] [varchar](20) NULL,
	[Native] [varchar](20) NULL,
	[School] [varchar](50) NULL,
	[Professional] [varchar](100) NULL,
	[Degree] [varchar](20) NULL,
	[DepId] [varchar](50) NOT NULL,
	[PosId] [varchar](50) NOT NULL,
	[Expertise] [varchar](3000) NULL,
	[JobState] [varchar](20) NULL,
	[Photo] [varchar](200) NULL,
	[Attach] [varchar](200) NULL,
 CONSTRAINT [PK_SysUser] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[SysModule]  WITH NOCHECK ADD  CONSTRAINT [FK_SysModule_SysModule] FOREIGN KEY([ParentId])
REFERENCES [dbo].[SysModule] ([Id])
GO
ALTER TABLE [dbo].[SysModule] NOCHECK CONSTRAINT [FK_SysModule_SysModule]
GO
ALTER TABLE [dbo].[SysModuleOperate]  WITH CHECK ADD  CONSTRAINT [FK_SysModuleOperate_SysModule] FOREIGN KEY([ModuleId])
REFERENCES [dbo].[SysModule] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SysModuleOperate] CHECK CONSTRAINT [FK_SysModuleOperate_SysModule]
GO
ALTER TABLE [dbo].[SysRight]  WITH CHECK ADD  CONSTRAINT [FK_SysRight_SysModule] FOREIGN KEY([ModuleId])
REFERENCES [dbo].[SysModule] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SysRight] CHECK CONSTRAINT [FK_SysRight_SysModule]
GO
ALTER TABLE [dbo].[SysRight]  WITH CHECK ADD  CONSTRAINT [FK_SysRight_SysRole] FOREIGN KEY([RoleId])
REFERENCES [dbo].[SysRole] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SysRight] CHECK CONSTRAINT [FK_SysRight_SysRole]
GO
ALTER TABLE [dbo].[SysRightOperate]  WITH CHECK ADD  CONSTRAINT [FK_SysRightOperate_SysRight] FOREIGN KEY([RightId])
REFERENCES [dbo].[SysRight] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SysRightOperate] CHECK CONSTRAINT [FK_SysRightOperate_SysRight]
GO
ALTER TABLE [dbo].[SysRoleSysUser]  WITH CHECK ADD  CONSTRAINT [FK_SysRoleSysUser_SysRole] FOREIGN KEY([SysRoleId])
REFERENCES [dbo].[SysRole] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SysRoleSysUser] CHECK CONSTRAINT [FK_SysRoleSysUser_SysRole]
GO
ALTER TABLE [dbo].[SysRoleSysUser]  WITH CHECK ADD  CONSTRAINT [FK_SysRoleSysUser_SysUser] FOREIGN KEY([SysUserId])
REFERENCES [dbo].[SysUser] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SysRoleSysUser] CHECK CONSTRAINT [FK_SysRoleSysUser_SysUser]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'身份证' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SysUser', @level2type=N'COLUMN',@level2name=N'MobileNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'婚姻' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SysUser', @level2type=N'COLUMN',@level2name=N'Marital'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'党派' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SysUser', @level2type=N'COLUMN',@level2name=N'Political'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'民族' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SysUser', @level2type=N'COLUMN',@level2name=N'Nationality'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'籍贯' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SysUser', @level2type=N'COLUMN',@level2name=N'Native'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'毕业学校' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SysUser', @level2type=N'COLUMN',@level2name=N'School'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'就读专业' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SysUser', @level2type=N'COLUMN',@level2name=N'Professional'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'学历' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SysUser', @level2type=N'COLUMN',@level2name=N'Degree'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'部门' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SysUser', @level2type=N'COLUMN',@level2name=N'DepId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'职位' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SysUser', @level2type=N'COLUMN',@level2name=N'PosId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'个人简介' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SysUser', @level2type=N'COLUMN',@level2name=N'Expertise'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'在职状况' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SysUser', @level2type=N'COLUMN',@level2name=N'JobState'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'照片' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SysUser', @level2type=N'COLUMN',@level2name=N'Photo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'附件' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SysUser', @level2type=N'COLUMN',@level2name=N'Attach'
GO
USE [master]
GO
ALTER DATABASE [DB] SET  READ_WRITE 
GO
