using System.Text;
using System.Runtime.InteropServices;
using System.Threading;
using System.Net.Http;
using System;
using System.Collections.Generic;

namespace ClientConnection
{
    public class DllMain
    {
        static Dictionary<string, string> returns = new Dictionary<string, string>();

        [DllExport("RVExtensionVersion", CallingConvention = System.Runtime.InteropServices.CallingConvention.Winapi)]
        public static void RvExtensionVersion(StringBuilder output, int outputSize)
        {
            output.Append("Test-Extension v1.0");
        }

        [DllExport("RVExtension", CallingConvention = System.Runtime.InteropServices.CallingConvention.Winapi)]
        public static void RvExtension(StringBuilder output, int outputSize,
            [MarshalAs(UnmanagedType.LPStr)] string function)
        {
            //Request - 1:key:data
            //Get - 2:key
            string[] parts  = function.Split(':');
            int mode        = int.Parse(parts[0]);
            string dictKey  = parts[1];
            string data     = "";

            if (parts.Length > 2)
            {
                data = parts[2];
            }

            if (mode == 1)
            {
                Thread thread = new Thread(CallApiRequest);
                string[] packedData = {data, dictKey};
                thread.Start(packedData);
                output.Append($"API called - Type: FirstReq ID: {dictKey} Data: {data}");
            }
            else if (mode == 2)
            {
                if (!returns.ContainsKey(dictKey))
                {
                    output.Append("NoData");
                }
                else
                {
                    string returnToArma = returns[dictKey];
                    returns.Remove(dictKey);
                    output.Append(returnToArma);
                }
            }
        }

        static async void CallApiRequest(object inputData) {
            string[] data = (string[])inputData;
            //ловить ошибку если сервер не отвечает
            string parameters = data[0];
            string key = data[1];
            using (HttpClient client = new HttpClient())
            {
                HttpResponseMessage response = await client.GetAsync($"http://127.0.0.1:5000/request/{key}/{parameters}");
                string returnValue = await response.Content.ReadAsStringAsync();
                returns[key] = returnValue;
            }
        }

        [DllExport("RVExtensionArgs", CallingConvention = System.Runtime.InteropServices.CallingConvention.Winapi)]
        public static int RvExtensionArgs(StringBuilder output, int outputSize,
            [MarshalAs(UnmanagedType.LPStr)] string function,
            [MarshalAs(UnmanagedType.LPArray, ArraySubType = UnmanagedType.LPStr, SizeParamIndex = 4)] string[] args, int argCount)
        {
            foreach (var arg in args)
            {
                output.Append(arg);
            }
            return 0;
        }
    }
}