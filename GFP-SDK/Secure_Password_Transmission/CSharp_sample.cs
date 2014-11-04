using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO.Pipes;
using System.IO;
using System.Security.Cryptography;
using System.Diagnostics;
using Microsoft.Win32.SafeHandles;
using System.Runtime.InteropServices;


namespace RunGFP_CSharp
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }


        [return: MarshalAs(UnmanagedType.Bool)]
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern bool WaitNamedPipe(string name, int timeout);

        static public bool NamedPipeDoesNotExist(string pipeName)
        {
            try
            {
                int timeout = 10;
                string normalizedPath = System.IO.Path.GetFullPath(
                 string.Format(@"\\.\pipe\{0}", pipeName));
                bool exists = WaitNamedPipe(normalizedPath, timeout);
                if (!exists)
                {
                    int error = Marshal.GetLastWin32Error();
                    if (error == 0) // pipe does not exist
                        return true;
                    else if (error == 2) // win32 error code for file not found
                        return true;
                    // all other errors indicate other issues
                }
                return false;
            }
            catch (Exception ex)
            {
                return true; // assume it exists
            }
        }

        public void RSA_SendData(String pipe, String Data)
        {
            
            using (NamedPipeClientStream pipeClient = new NamedPipeClientStream(".", pipe, PipeDirection.InOut))
            {
                

             
             //Connect to pipe
             pipeClient.Connect();

                using (StreamReader sr = new StreamReader(pipeClient))
                {
                    //read the public key
                    byte[] temp = new byte[1024*1024];
                    sr.BaseStream.Read(temp, 0, 1024 * 1024);



                    //Create a UnicodeEncoder to convert between byte array and string.
                    UnicodeEncoding ByteConverter = new UnicodeEncoding();

                    //Create byte arrays to hold original, encrypted, and decrypted data.
                    byte[] dataToEncrypt = ByteConverter.GetBytes(Data);
                    byte[] encryptedData;

                    //Pass the data to ENCRYPT, the public key information 
                    //(using RSACryptoServiceProvider.ExportParameters(false),
                    //and a boolean flag specifying for OAEP padding.
                    encryptedData = RSAEncrypt(dataToEncrypt, temp, true);


                    sr.BaseStream.Write(encryptedData, 0, encryptedData.Count());
                }
            }


        }


        static public byte[] RSAEncrypt(byte[] DataToEncrypt, byte[] RSAKey, bool DoOAEPPadding)
        {

                byte[] encryptedData;
                //Create a new instance of RSACryptoServiceProvider.
                using (RSACryptoServiceProvider RSA = new RSACryptoServiceProvider())
                {

                    //Import the RSA Key information. This only needs
                    //toinclude the public key information.
                    //RSA.ImportParameters(RSA.ExportParameters(false));
                    RSA.PersistKeyInCsp = false;
                    RSA.ImportCspBlob(RSAKey);
                   

                    //Encrypt the passed byte array and specify OAEP padding.  
                    //OAEP padding is only available on Microsoft Windows XP or
                    //later.  
                    encryptedData = RSA.Encrypt(DataToEncrypt, DoOAEPPadding);
                }
                Array.Reverse(encryptedData);
                return encryptedData;

        }


        private void run()
        {
            Process.Start("GreenForce-Player.exe", "video.gfp /passwordpipe MYPIPE_1234567 /database [APPDATA]\\YOURPROJECT\\DB.dat");//starts the player and plays video.gfp and uses the database [APPDATA]\\YOURPROJECT\\DB.dat

            RSA_SendData("MYPIPE_1234567", "password");//Sends the password "password" to the player over the named pipe
        }


        private void button1_Click(object sender, EventArgs e)
        {
            run();


        }
    }
}
