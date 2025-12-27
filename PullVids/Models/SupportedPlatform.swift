import Foundation

struct SupportedPlatform: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let examples: [String]
}

class SupportedPlatformsData {
    static let platforms = [
        SupportedPlatform(
            name: "YouTube",
            icon: "play.rectangle.fill",
            examples: ["youtube.com/watch?v=...", "youtu.be/..."]
        ),
        SupportedPlatform(
            name: "Vimeo",
            icon: "video.fill",
            examples: ["vimeo.com/..."]
        ),
        SupportedPlatform(
            name: "TikTok",
            icon: "music.note",
            examples: ["tiktok.com/@.../video/..."]
        ),
        SupportedPlatform(
            name: "Instagram",
            icon: "camera.fill",
            examples: ["instagram.com/p/...", "instagram.com/reel/..."]
        ),
        SupportedPlatform(
            name: "Twitter/X",
            icon: "at",
            examples: ["twitter.com/.../status/...", "x.com/.../status/..."]
        ),
        SupportedPlatform(
            name: "Twitch",
            icon: "gamecontroller.fill",
            examples: ["twitch.tv/videos/..."]
        ),
        SupportedPlatform(
            name: "Facebook",
            icon: "person.2.fill",
            examples: ["facebook.com/watch/..."]
        ),
        SupportedPlatform(
            name: "Reddit",
            icon: "bubble.left.and.bubble.right.fill",
            examples: ["reddit.com/r/.../comments/..."]
        ),
        SupportedPlatform(
            name: "Dailymotion",
            icon: "play.circle.fill",
            examples: ["dailymotion.com/video/..."]
        ),
        SupportedPlatform(
            name: "Other",
            icon: "globe",
            examples: ["1000+ supported sites"]
        )
    ]
}
