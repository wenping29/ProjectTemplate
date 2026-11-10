using System.Security.Cryptography;
using System.Text;

namespace ChatServer.Utils;

public static class MD5Helper
{
    // MD5加密（密码存储）
    public static string MD5Encrypt(string input)
    {
        using (var md5 = MD5.Create())
        {
            var bytes = Encoding.UTF8.GetBytes(input);
            var hashBytes = md5.ComputeHash(bytes);
            
            // 转换为16进制字符串
            var sb = new StringBuilder();
            foreach (var b in hashBytes)
            {
                sb.Append(b.ToString("x2"));
            }
            return sb.ToString();
        }
    }
}