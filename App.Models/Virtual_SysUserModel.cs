//------------------------------------------------------------------------------
// <auto-generated>
//     此代码已从模板生成。
//
//     手动更改此文件可能导致应用程序出现意外的行为。
//     如果重新生成代码，将覆盖对此文件的手动更改。
// </auto-generated>
//------------------------------------------------------------------------------

using System;

namespace App.Models.Sys
{
	public partial class SysUserModel : Virtual_SysUserModel
	{

	}
	public class Virtual_SysUserModel
	{
		public virtual string Id { get; set;}
		public virtual string UserName { get; set;}
		public virtual string Password { get; set;}
		public virtual string TrueName { get; set;}
		public virtual string Card { get; set;}
		public virtual string MobileNumber { get; set;}
		public virtual string PhoneNumber { get; set;}
		public virtual string QQ { get; set;}
		public virtual string EmailAddress { get; set;}
		public virtual string OtherContact { get; set;}
		public virtual string Province { get; set;}
		public virtual string City { get; set;}
		public virtual string Village { get; set;}
		public virtual string Address { get; set;}
		public virtual Nullable<bool> State { get; set;}
		public virtual Nullable<System.DateTime> CreateTime { get; set;}
		public virtual string CreatePerson { get; set;}
		public virtual string Sex { get; set;}
		public virtual Nullable<System.DateTime> Birthday { get; set;}
		public virtual Nullable<System.DateTime> JoinDate { get; set;}
		public virtual string Marital { get; set;}
		public virtual string Political { get; set;}
		public virtual string Nationality { get; set;}
		public virtual string Native { get; set;}
		public virtual string School { get; set;}
		public virtual string Professional { get; set;}
		public virtual string Degree { get; set;}
		public virtual string DepId { get; set;}
		public virtual string PosId { get; set;}
		public virtual string Expertise { get; set;}
		public virtual string JobState { get; set;}
		public virtual string Photo { get; set;}
		public virtual string Attach { get; set;}
	}
}
