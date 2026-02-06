---
layout: default
---

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ site.title }}</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #0f172a 100%);
            color: #f8fafc;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            padding: 2rem;
        }
        
        h1 {
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 1rem;
            letter-spacing: -0.02em;
            color: #f8fafc;
        }
        
        .subtitle {
            font-size: 1.25rem;
            color: #94a3b8;
            margin-bottom: 2rem;
            min-height: 1.6em;
        }
        
        .cursor {
            display: inline-block;
            width: 2px;
            height: 1.2em;
            background-color: #f8fafc;
            margin-left: 2px;
            animation: blink 1s infinite;
            vertical-align: text-bottom;
        }
        
        @keyframes blink {
            0%, 50% { opacity: 1; }
            51%, 100% { opacity: 0; }
        }
        
        nav {
            margin-top: 2rem;
        }
        
        nav a {
            color: #94a3b8;
            text-decoration: none;
            margin: 0 1rem;
            font-size: 0.875rem;
            transition: color 0.2s;
        }
        
        nav a:hover {
            color: #f8fafc;
        }
        
        footer {
            position: fixed;
            bottom: 2rem;
            font-size: 0.75rem;
            color: #64748b;
        }
        
        @media (max-width: 600px) {
            h1 { font-size: 2.5rem; }
            .subtitle { font-size: 1.125rem; }
            nav a { margin: 0 0.75rem; }
        }
    </style>
</head>
<body>
    <h1>Percival</h1>
    
    <p class="subtitle" id="typewriter">
        <span id="type-text"></span><span class="cursor"></span>
    </p>
    
    <nav>
        <a href="/archive/">文章</a>
        <a href="/about/">关于</a>
        <a href="https://github.com/percival-06" target="_blank">GitHub</a>
    </nav>
    
    <footer>© {{ site.time | date: "%Y" }} {{ site.title }}</footer>

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
</body>
</html>
