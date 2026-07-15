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

    <section class="home-section" id="about" aria-labelledby="about-title">
        <h2 id="about-title">关于</h2>
        <div class="home-prose">
            <p>Hi，我是 Percival，北京大学信息科学技术学院 2025 级本科生。</p>
            <p>在这里记录学习、技术与生活中的思考。</p>
        </div>
    </section>

    <section class="home-section" id="recent-posts" aria-labelledby="recent-posts-title">
        <div class="home-section-heading">
            <h2 id="recent-posts-title">最近文章</h2>
            <a href="{{ '/archive/' | relative_url }}" aria-label="查看全部文章">查看全部</a>
        </div>
        <ul class="home-post-list">
            {% for post in site.posts limit: 3 %}
            <li>
                <a class="home-post-link" href="{{ post.url | relative_url }}">
                    <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%Y-%m-%d" }}</time>
                    <span>{{ post.title | escape }}</span>
                </a>
            </li>
            {% endfor %}
        </ul>
    </section>

    <section class="home-section" id="education" aria-labelledby="education-title">
        <h2 id="education-title">教育经历</h2>
        <div class="education-item">
            <div>
                <strong>北京大学</strong>
                <p>信息科学技术学院 · 本科生</p>
            </div>
            <span>2025 - 至今</span>
        </div>
    </section>

    <section class="home-section" id="skills" aria-labelledby="skills-title">
        <h2 id="skills-title">技能</h2>
        <ul class="skill-list">
            <li>C++</li>
        </ul>
    </section>

    <footer class="home-footer">© {{ site.time | date: "%Y" }} {{ site.title }}</footer>
</div>
