//------------------------------------------------------------------------------
// <auto-generated>
//     此代码已从模板生成。
//
//     手动更改此文件可能导致应用程序出现意外的行为。
//     如果重新生成代码，将覆盖对此文件的手动更改。
// </auto-generated>
//------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Linq;
using App.Models;
using App.Models.Sys;
using App.Common;
using Microsoft.Practices.Unity;
using System.Transactions;
using App.IBLL;
using App.IDAL;
using App.BLL;
using App.BLL.Core;
namespace App.BLL
{
	public partial class SysSampleBLL: Virtual_SysSampleBLL,ISysSampleBLL
	{
        

	}
	public class Virtual_SysSampleBLL
	{
        [Dependency]
        public ISysSampleRepository m_Rep { get; set; }

		public virtual List<SysSampleModel> GetList(ref GridPager pager, string queryStr)
        {

            IQueryable<SysSample> queryData = null;
            if (!string.IsNullOrWhiteSpace(queryStr))
            {
                queryData = m_Rep.GetList(
								a=>(a.Id!=null && a.Id.Contains(queryStr))
								|| (a.Name!=null && a.Name.Contains(queryStr))
								
								
								|| (a.Photo!=null && a.Photo.Contains(queryStr))
								|| (a.Note!=null && a.Note.Contains(queryStr))
								
								);
            }
            else
            {
                queryData = m_Rep.GetList();
            }
            pager.totalRows = queryData.Count();
            //排序
            queryData = LinqHelper.SortingAndPaging(queryData, pager.sort, pager.order, pager.page, pager.rows);
            return CreateModelList(ref queryData);
        }

        public virtual List<SysSampleModel> CreateModelList(ref IQueryable<SysSample> queryData)
        {

            List<SysSampleModel> modelList = (from r in queryData
                                              select new SysSampleModel
                                              {
													Id = r.Id,
													Name = r.Name,
													Age = r.Age,
													Bir = r.Bir,
													Photo = r.Photo,
													Note = r.Note,
													CreateTime = r.CreateTime,
          
                                              }).ToList();

            return modelList;
        }

        public virtual bool Create(ref ValidationErrors errors, SysSampleModel model)
        {
            try
            {
                SysSample entity = m_Rep.GetById(model.Id);
                if (entity != null)
                {
                    errors.Add(Suggestion.PrimaryRepeat);
                    return false;
                }
                entity = new SysSample();
               				entity.Id = model.Id;
				entity.Name = model.Name;
				entity.Age = model.Age;
				entity.Bir = model.Bir;
				entity.Photo = model.Photo;
				entity.Note = model.Note;
				entity.CreateTime = model.CreateTime;
  

                if (m_Rep.Create(entity))
                {
                    return true;
                }
                else
                {
                    errors.Add(Suggestion.InsertFail);
                    return false;
                }
            }
            catch (Exception ex)
            {
                errors.Add(ex.Message);
                ExceptionHandler.WriteException(ex);
                return false;
            }
        }



         public virtual bool Delete(ref ValidationErrors errors, string id)
        {
            try
            {
                if (m_Rep.Delete(id) == 1)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch (Exception ex)
            {
                errors.Add(ex.Message);
                ExceptionHandler.WriteException(ex);
                return false;
            }
        }

        public virtual bool Delete(ref ValidationErrors errors, string[] deleteCollection)
        {
            try
            {
                if (deleteCollection != null)
                {
                    using (TransactionScope transactionScope = new TransactionScope())
                    {
                        if (m_Rep.Delete(deleteCollection) == deleteCollection.Length)
                        {
                            transactionScope.Complete();
                            return true;
                        }
                        else
                        {
                            Transaction.Current.Rollback();
                            return false;
                        }
                    }
                }
                return false;
            }
            catch (Exception ex)
            {
                errors.Add(ex.Message);
                ExceptionHandler.WriteException(ex);
                return false;
            }
        }

		
       

        public virtual bool Edit(ref ValidationErrors errors, SysSampleModel model)
        {
            try
            {
                SysSample entity = m_Rep.GetById(model.Id);
                if (entity == null)
                {
                    errors.Add(Suggestion.Disable);
                    return false;
                }
                              				entity.Id = model.Id;
				entity.Name = model.Name;
				entity.Age = model.Age;
				entity.Bir = model.Bir;
				entity.Photo = model.Photo;
				entity.Note = model.Note;
				entity.CreateTime = model.CreateTime;
 


                if (m_Rep.Edit(entity))
                {
                    return true;
                }
                else
                {
                    errors.Add(Suggestion.EditFail);
                    return false;
                }

            }
            catch (Exception ex)
            {
                errors.Add(ex.Message);
                ExceptionHandler.WriteException(ex);
                return false;
            }
        }

      

        public virtual SysSampleModel GetById(string id)
        {
            if (IsExist(id))
            {
                SysSample entity = m_Rep.GetById(id);
                SysSampleModel model = new SysSampleModel();
                              				model.Id = entity.Id;
				model.Name = entity.Name;
				model.Age = entity.Age;
				model.Bir = entity.Bir;
				model.Photo = entity.Photo;
				model.Note = entity.Note;
				model.CreateTime = entity.CreateTime;
 
                return model;
            }
            else
            {
                return null;
            }
        }

        public virtual bool IsExist(string id)
        {
            return m_Rep.IsExist(id);
        }
		  public void Dispose()
        { 
            
        }

	}
}