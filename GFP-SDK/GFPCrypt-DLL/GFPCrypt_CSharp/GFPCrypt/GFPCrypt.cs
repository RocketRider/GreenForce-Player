using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;

namespace GFPCrypt
{
    class GFPCryptClass
    {

        [DllImport("GPFCrypt.dll")]
        public static extern int SetMediaHint(string HintText);
        public static extern int SetMediaInterpreter(string InterpreterText);
        public static extern int SetMediaComment(string CommentText);
        public static extern int SetMediaTitel(string TitleText);
        public static extern int SetMediaAlbum(string AlbumText);
        public static extern int SetMediaCodecName(string CodecNameText);
        public static extern int SetMediaCodecLink(string CodecLinkText);
        public static extern int SetMediaAllowRestore(int Allow);
        public static extern int SetMediaContentProtection(int ContentProtectionOption);
        public static extern int SetMediaLength(long MediaLength);
        public static extern int SetMediaCoverFile(string Cover);
        public static extern int SetMediaOemText(string OEMText);
        public static extern int CheckMedia(string File);
        public static extern int InitCheckMedia();
        public static extern int FreeCheckMedia();
        public static extern int EncryptMediaFile(string Source, string Output, string Password, int Flags, int cbCallback);
        public static extern int DecryptMediaFile(string Source, string Output, string Password, int Flags, int cbCallback);

    }
}
