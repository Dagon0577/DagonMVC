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
	public partial class SysLogModel : Virtual_SysLogModel
	{

	}
	public class Virtual_SysLogModel
	{
		public virtual string Id { get; set;}
		public virtual string Operator { get; set;}
		public virtual string Message { get; set;}
		public virtual string Result { get; set;}
		public virtual string Type { get; set;}
		public virtual string Module { get; set;}
		public virtual Nullable<System.DateTime> CreateTime { get; set;}
	}
}
