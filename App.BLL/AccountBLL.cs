using System.Linq;
using System.Text;
using App.IBLL;
using App.BLL.Core;
using Microsoft.Practices.Unity;
using App.IDAL;
using App.Models;
using App.Common;
namespace App.BLL
{
    public class AccountBLL : BaseBLL, IAccountBLL
    {
        [Dependency]
        public IAccountRepository accountRepository { get; set; }
        public SysUser Login(string username, string pwd)
        {
            return accountRepository.Login(username, pwd);

        }
    }
}