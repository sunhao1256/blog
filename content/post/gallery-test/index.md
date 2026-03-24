---
title: "画廊功能测试"
description: "使用 hugo-shortcode-gallery 组件实现图片画廊效果。"
date: 2026-03-03T15:30:00+08:00
image: "images/IMG_5454.jpeg"
categories:
    - 技术分享
tags:
    - Hugo
    - 画廊
    - 博客
readingTime: true
---

## 画廊展示

下面是使用 `hugo-shortcode-gallery` 组件渲染的图片画廊，包含风景、城市、自然等多种主题的摄影作品。点击图片可以全屏查看，支持左右滑动浏览。

{{< gallery match="images/*" sortOrder="asc" rowHeight="150" margins="5" thumbnailResizeOptions="600x600 q90 Lanczos" previewType="blur" embedPreview=true loadJQuery=true thumbnailHoverEffect="enlarge" lastRow="justify" >}}

## 关于画廊组件

这个画廊使用了 [hugo-shortcode-gallery](https://github.com/mfg92/hugo-shortcode-gallery) 主题组件，它提供了以下功能：

- **自适应网格布局**：图片自动排列成美观的网格
- **缩略图预加载**：使用模糊预览图，提升页面加载速度
- **全屏灯箱**：点击图片可全屏查看，支持手势滑动
- **悬停动画**：鼠标悬停时图片会有放大效果
- **图片标题**：通过 sidecar `.meta` 文件为每张图片添加标题
