namespace ChatServer.DTOs;

public class ResponseDto<T>
{
    public int Code { get; set; } // 200成功，500失败，401未授权
    public string Message { get; set; } = string.Empty;
    public T? Data { get; set; }

    // 快捷方法
    public static ResponseDto<T> Success(T data, string message = "操作成功")
    {
        return new ResponseDto<T> { Code = 200, Message = message, Data = data };
    }

    public static ResponseDto<T> Fail(string message = "操作失败", int code = 500)
    {
        return new ResponseDto<T> { Code = code, Message = message, Data = default };
    }
}

// 无数据返回
public class ResponseDto : ResponseDto<object>
{
    public static ResponseDto Success(string message = "操作成功")
    {
        return new ResponseDto { Code = 200, Message = message };
    }
}