#!/bin/bash

# 检查系统工具
if ! command -v sips &> /dev/null; then
    echo "错误: 找不到 sips 工具。"
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "错误: 找不到 ffmpeg 工具。"
    exit 1
fi

echo "🚀 开始全站媒体转换 (强力压缩版，适配 Cloudflare 25MB 限制)..."

# --- 1. 处理图片 (HEIC -> JPG) ---
# ... (保持原样)
find content -type f \( -iname "*.heic" \) -print0 | while read -r -d '' file; do
    dir=$(dirname "$file")
    base=$(basename "$file")
    filename="${base%.*}"
    target="$dir/$filename.webp"
    if ! sips -s format webp "$file" --out "$target" &> /dev/null; then
         target="$dir/$filename.jpg"
         sips -s format jpeg "$file" --out "$target" &> /dev/null
    fi
    if [ -f "$target" ]; then
        new_ext="${target##*.}"
        find content -name "*.md" -exec sed -i '' "s/$(basename "$file")/$filename.$new_ext/g" {} +
        rm "$file"
    fi
done

# --- 2. 处理视频 (强力压缩 MOV -> MP4 以及 压缩现有大 MP4) ---
echo "--- 🎥 处理视频 ---"

# 先处理所有的 .mov 转换并压缩
find content -type f \( -iname "*.mov" \) -print0 | while read -r -d '' file; do
    dir=$(dirname "$file")
    base=$(basename "$file")
    filename="${base%.*}"
    target="$dir/$filename.mp4"
    echo "正在转换并压缩视频: $file"
    # -vf "scale='min(1280,iw)':-2": 限制最大宽度 1280 像素 (720p 级别)
    # -crf 28: 较强的压缩率
    # -pix_fmt yuv420p: 兼容性处理
    if ffmpeg -i "$file" -vcodec libx264 -crf 28 -vf "scale='min(1280,iw)':-2" -acodec aac -pix_fmt yuv420p -loglevel error -n "$target" < /dev/null; then
        echo "✅ 成功: $filename.mp4"
        find content -name "*.md" -exec sed -i '' "s/$(basename "$file")/$filename.mp4/g" {} +
        rm "$file"
    fi
done

# 再检查现有的 .mp4，如果超过 20MB 就进行原地压缩
find content -type f -name "*.mp4" -size +20M -print0 | while read -r -d '' file; do
    echo "发现超大视频 (需压缩): $file"
    temp_file="${file%.*}_tmp.mp4"
    if ffmpeg -i "$file" -vcodec libx264 -crf 28 -vf "scale='min(1280,iw)':-2" -acodec aac -pix_fmt yuv420p -loglevel error -y "$temp_file" < /dev/null; then
        mv "$temp_file" "$file"
        echo "✅ 已压缩超大视频: $file"
    else
        rm -f "$temp_file"
        echo "❌ 压缩失败: $file"
    fi
done

echo "✨ 处理完成！所有媒体已适配 Cloudflare Pages 限制。"
