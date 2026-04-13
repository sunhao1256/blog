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

echo "🚀 开始全站媒体转换 (修复循环输入问题)..."

# --- 1. 处理图片 (HEIC) ---
echo "--- 📸 处理图片 ---"
# 使用 find -print0 配合 read -d '' 是最稳妥的，防止空格路径报错
find content -type f \( -iname "*.heic" \) -print0 | while read -r -d '' file; do
    dir=$(dirname "$file")
    base=$(basename "$file")
    filename="${base%.*}"
    target="$dir/$filename.webp"

    echo "正在转换图片: $file"
    if ! sips -s format webp "$file" --out "$target" &> /dev/null; then
         target="$dir/$filename.jpg"
         sips -s format jpeg "$file" --out "$target" &> /dev/null
    fi
    
    if [ -f "$target" ]; then
        new_ext="${target##*.}"
        echo "✅ 图片成功: $filename.$new_ext"
        find content -name "*.md" -exec sed -i '' "s/$(basename "$file")/$filename.$new_ext/g" {} +
        rm "$file"
    fi
done

# --- 2. 处理视频 (MOV -> MP4) ---
echo "--- 🎥 处理视频 ---"
find content -type f \( -iname "*.mov" \) -print0 | while read -r -d '' file; do
    dir=$(dirname "$file")
    base=$(basename "$file")
    filename="${base%.*}"
    target="$dir/$filename.mp4"

    if [ -f "$target" ]; then
        echo "⏭️  MP4 已存在: $target"
        continue
    fi

    echo "正在使用 ffmpeg 转换视频: $file"
    # 核心修复点：加上 < /dev/null 放置 ffmpeg 吞掉循环的输入
    if ffmpeg -n -i "$file" -vcodec libx264 -acodec aac -pix_fmt yuv420p -loglevel error "$target" < /dev/null; then
        echo "✅ 视频成功: $filename.mp4"
        find content -name "*.md" -exec sed -i '' "s/$(basename "$file")/$filename.mp4/g" {} +
        rm "$file"
        echo "🗑️  已清理 MOV"
    else
        echo "❌ 视频转换失败: $file"
    fi
done

echo "✨ 处理完成！"
