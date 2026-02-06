---
layout: default
---

<div class="home-layout">
    <!-- 头像/图片 -->
    <img src="/assets/images/avatar.jpg" alt="Percival" class="avatar">
    
    <h1>Percival</h1>
    
    <p class="typewriter-text" id="typewriter">
        <span id="type-text"></span><span class="cursor"></span>
    </p>
    
    <nav class="minimal-nav">
        <a href="/archive/">文章</a>
        <a href="/about/">关于</a>
        <a href="https://github.com/percival-06" target="_blank">GitHub</a>
    </nav>
    
    <!-- 添加的描述文字 -->
    <p class="tagline">记录技术，分享思考，保持好奇</p>
    <p class="tagline">keep calm and carry on</p>
</div>

<footer class="minimal-footer">© {{ site.time | date: "%Y" }} {{ site.title }}</footer>

<script>
    const texts = ["开发者", "创作者", "终身学习者"];
    let textIndex = 0;
    let charIndex = 0;
    let isDeleting = false;
    const typeText = document.getElementById('type-text');

    function type() {
        const currentText = texts[textIndex];
        
        if (isDeleting) {
            typeText.textContent = currentText.substring(0, charIndex - 1);
            charIndex--;
        } else {
            typeText.textContent = currentText.substring(0, charIndex + 1);
            charIndex++;
        }

        let typeSpeed = isDeleting ? 50 : 100;

        if (!isDeleting && charIndex === currentText.length) {
            typeSpeed = 2000;
            isDeleting = true;
        } else if (isDeleting && charIndex === 0) {
            isDeleting = false;
            textIndex = (textIndex + 1) % texts.length;
            typeSpeed = 500;
        }

        setTimeout(type, typeSpeed);
    }

    document.addEventListener('DOMContentLoaded', type);
</script>
