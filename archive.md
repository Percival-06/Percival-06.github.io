---
layout: default
title: 文章
permalink: /archive/
---

<div class="post-list-page">
  <a href="/" class="back-link">← 返回</a>
  
  <h1>文章</h1>
  
  <ul class="post-list">
    {% for post in site.posts %}
    <li>
      <div class="post-meta">{{ post.date | date: "%Y-%m-%d" }}</div>
      <a href="{{ post.url }}" class="post-link">{{ post.title }}</a>
    </li>
    {% endfor %}
  </ul>
</div>
