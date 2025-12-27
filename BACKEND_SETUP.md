# Backend Setup for PullVids iOS

The iOS app currently runs in **demo mode** and downloads a sample video. To enable real video downloads from YouTube, TikTok, Instagram, etc., you need to set up a backend service.

## Why a Backend is Needed

iOS apps cannot directly run Python tools like `yt-dlp`. You need a server that:
1. Receives video URLs from the iOS app
2. Runs yt-dlp to extract the actual video download URL
3. Returns the direct video URL to the iOS app
4. The iOS app then downloads the video

## Option 1: Deploy Your Own Backend (Recommended)

### Quick Start with Node.js

Create a simple Express server:

```bash
mkdir pullvids-backend
cd pullvids-backend
npm init -y
npm install express yt-dlp-wrap cors
```

**server.js:**
```javascript
const express = require('express');
const YTDlpWrap = require('yt-dlp-wrap').default;
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const ytDlp = new YTDlpWrap();

app.post('/api/video-info', async (req, res) => {
    try {
        const { url } = req.body;

        const info = await ytDlp.getVideoInfo(url);

        res.json({
            title: info.title,
            thumbnail: info.thumbnail,
            formats: info.formats
        });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

app.post('/api/download-url', async (req, res) => {
    try {
        const { url, quality } = req.body;

        const info = await ytDlp.getVideoInfo(url);

        // Get best format matching quality
        const format = info.formats.find(f =>
            f.height === parseInt(quality) && f.vcodec !== 'none'
        ) || info.formats[0];

        res.json({
            downloadUrl: format.url,
            title: info.title
        });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

app.listen(3000, () => {
    console.log('PullVids backend running on port 3000');
});
```

Run it:
```bash
node server.js
```

### Deploy to Cloud

**Heroku:**
```bash
heroku create pullvids-backend
git push heroku main
```

**Railway.app:**
1. Connect your GitHub repo
2. Railway auto-deploys

**Render.com:**
1. Create new Web Service
2. Connect repository
3. Deploy

## Option 2: Use Existing Services

### Cobalt API
- URL: `https://api.cobalt.tools/api/json`
- Free tier available
- Supports many platforms

### Invidious (YouTube only)
- Self-hosted YouTube frontend
- Provides direct video URLs

## Update iOS App

Once your backend is deployed, update `DownloadManager.swift`:

```swift
private let backendURL = "https://your-backend-url.com"

private func getDownloadURL(for download: VideoDownload) async throws -> String {
    guard let requestURL = URL(string: "\(backendURL)/api/download-url") else {
        throw DownloadError.invalidURL
    }

    var request = URLRequest(url: requestURL)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: [String: Any] = [
        "url": download.url,
        "quality": download.quality.height
    ]

    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw DownloadError.networkError
    }

    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
       let downloadUrl = json["downloadUrl"] as? String {
        return downloadUrl
    }

    throw DownloadError.downloadURLFetchFailed
}
```

## Security Considerations

1. **Rate Limiting**: Prevent abuse
2. **API Keys**: Require authentication
3. **HTTPS**: Always use SSL
4. **Validation**: Sanitize input URLs
5. **Logging**: Monitor for suspicious activity

## Cost Estimates

**Free Tier Options:**
- Railway: 500 hours/month free
- Render: 750 hours/month free
- Fly.io: 3 VMs free

**Paid (if needed):**
- Heroku: ~$7/month
- DigitalOcean: $5/month
- AWS Lambda: Pay per request

## Testing Locally

1. Run backend: `node server.js`
2. Update iOS app to use `http://localhost:3000`
3. Test on simulator (use `http://127.0.0.1:3000`)
4. For device testing, use your computer's IP address

## Troubleshooting

**"Connection refused"**
- Check backend is running
- Verify URL is correct
- Check firewall settings

**"Invalid URL"**
- Ensure platform is supported by yt-dlp
- Check URL format

**"Video unavailable"**
- Some videos may be region-locked
- Check video privacy settings
- DRM-protected content won't work

## Alternative: Direct URL Extraction

For simpler implementation (limited platforms):

```swift
// Example: Twitter/X direct video extraction
func extractTwitterVideo(url: String) async throws -> String {
    // Parse Twitter API or scrape page
    // This is platform-specific and fragile
}
```

This approach is **not recommended** as it:
- Only works for specific platforms
- Breaks when platforms change their APIs
- Violates some platforms' terms of service

## Recommended: Use yt-dlp Backend

The yt-dlp approach is best because:
- ✅ Supports 1000+ platforms
- ✅ Actively maintained
- ✅ Handles format selection
- ✅ Works with most sites
- ✅ Legal gray area but widely used

---

For questions or issues, check:
- [yt-dlp documentation](https://github.com/yt-dlp/yt-dlp)
- [yt-dlp-wrap npm package](https://www.npmjs.com/package/yt-dlp-wrap)
