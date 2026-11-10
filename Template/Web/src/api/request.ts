import axios, { type AxiosResponse } from 'axios';
import { ElMessage } from 'element-plus';

const baseURL = (import.meta.env.VITE_API_BASE as string) ?? '/api';

export interface ApiResult<T = unknown> {
  code: number;
  message: string;
  data: T;
}

const request = axios.create({ baseURL, timeout: 15000 });

request.interceptors.request.use((cfg) => {
  const token = localStorage.getItem('token');
  if (token) cfg.headers.Authorization = `Bearer ${token}`;
  return cfg;
});

request.interceptors.response.use(
  (resp: AxiosResponse<ApiResult>) => {
    const body = resp.data;
    if (body && body.code !== 0) {
      ElMessage.error(body.message || '请求失败');
      return Promise.reject(new Error(body.message));
    }
    return resp;
  },
  (err) => {
    if (err.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    ElMessage.error(err.response?.data?.message || '网络错误');
    return Promise.reject(err);
  },
);

export async function get<T>(url: string, params?: object) {
  const r = await request.get<ApiResult<T>>(url, { params });
  return r.data.data;
}
export async function post<T>(url: string, data?: object) {
  const r = await request.post<ApiResult<T>>(url, data);
  return r.data.data;
}
export async function put<T>(url: string, data?: object) {
  const r = await request.put<ApiResult<T>>(url, data);
  return r.data.data;
}
export async function del<T>(url: string) {
  const r = await request.delete<ApiResult<T>>(url);
  return r.data.data;
}

export default request;
