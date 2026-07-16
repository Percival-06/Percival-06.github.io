---
layout: default
---

<div class="home-page">
    <section class="profile-intro" aria-labelledby="profile-name">
        <img src="{{ '/assets/images/avatar.jpg' | relative_url }}" alt="Percival 的头像" class="avatar">
        <h1 id="profile-name">Percival</h1>
        <p class="profile-role">开发者 / 创作者 / 终身学习者</p>
        <div class="profile-meta" aria-label="个人信息">
            <span>北京</span>
            <span aria-hidden="true">/</span>
            <a href="https://github.com/percival-06" target="_blank" rel="noopener noreferrer">GitHub</a>
        </div>
    </section>

    <section class="home-intro" id="intro" aria-labelledby="intro-title">
        <p class="home-eyebrow">你好，我是 Percival</p>
        <h2 id="intro-title">北京大学信息科学技术学院 2025 级本科生。</h2>
        <p>记录计算机学习、校园生活，以及沿途真实发生的思考。</p>
    </section>

    <section class="home-section home-writing" id="recent-posts" aria-labelledby="recent-posts-title">
        <div class="home-section-heading">
            <h2 id="recent-posts-title">最近文章</h2>
            <a href="{{ '/archive/' | relative_url }}" aria-label="查看全部文章">查看全部</a>
        </div>
        <ul class="home-post-list">
            {% for post in site.posts limit: 5 %}
            {% assign excerpt_description = post.excerpt | strip_html | strip_newlines | truncate: 72 %}
            <li>
                <a class="home-post-link" href="{{ post.url | relative_url }}">
                    <span class="home-post-copy">
                        <span class="home-post-title">{{ post.title | escape }}</span>
                        {% if post.description %}
                        <span class="home-post-description">
                            {{ post.description | escape }}
                        </span>
                        {% elsif excerpt_description != empty %}
                        <span class="home-post-description">
                            {{ excerpt_description | escape }}
                        </span>
                        {% endif %}
                    </span>
                    <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%Y-%m-%d" }}</time>
                </a>
            </li>
            {% endfor %}
        </ul>
    </section>

    <footer class="home-footer">© {{ site.time | date: "%Y" }} {{ site.title }}</footer>
</div>
