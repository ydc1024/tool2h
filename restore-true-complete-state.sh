#!/bin/bash

# 恢复到true-complete-implementation.sh脚本的完整状态
# 修复home页面和about页面，添加右上角认证控件

echo "🔄 恢复到true-complete-implementation.sh状态"
echo "======================================="
echo "恢复内容："
echo "1. 恢复true-complete-implementation.sh的主布局设计"
echo "2. 恢复简洁的home页面和about页面"
echo "3. 在右上角添加注册和登录控件"
echo "4. 保持现有的认证功能"
echo "5. 修复路由命名一致性"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    log_error "请使用 root 用户或 sudo 运行此脚本"
    exit 1
fi

PROJECT_DIR="/var/www/besthammer_c_usr/data/www/besthammer.club"

cd "$PROJECT_DIR" || {
    log_error "无法进入项目目录: $PROJECT_DIR"
    exit 1
}

log_step "第1步：恢复true-complete-implementation.sh的主布局文件"
echo "-----------------------------------"

# 备份当前布局文件
cp resources/views/layouts/app.blade.php resources/views/layouts/app.blade.php.backup.$(date +%Y%m%d_%H%M%S)

# 恢复true-complete-implementation.sh的完整主布局文件
cat > resources/views/layouts/app.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="{{ isset($locale) && $locale ? $locale : app()->getLocale() }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>{{ $title ?? (isset($locale) && $locale ? __('common.site_title') : 'BestHammer Tools') }}</title>
    <meta name="description" content="{{ isset($locale) && $locale ? __('common.description') : 'Professional loan calculator, BMI calculator, and currency converter for European and American markets' }}">
    <meta name="keywords" content="loan calculator, BMI calculator, currency converter, financial tools, health tools">
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=inter:400,500,600,700&display=swap" rel="stylesheet" />
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
            line-height: 1.6;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            background: rgba(255,255,255,0.95);
            padding: 20px 30px;
            border-radius: 15px;
            margin-bottom: 20px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
            backdrop-filter: blur(10px);
        }
        
        .header-top {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
        }
        
        /* 修复logo样式 - 去除紫色背景，添加锤子图标 */
        .logo {
            width: 48px;
            height: 48px;
            margin-right: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: #667eea;
            font-weight: bold;
            flex-shrink: 0;
            text-decoration: none;
            transition: transform 0.3s ease;
        }
        
        .logo:hover {
            transform: scale(1.1);
            color: #764ba2;
        }
        
        /* 修复标题 - 简短且SEO友好 */
        .header h1 {
            color: #667eea;
            font-weight: 700;
            font-size: 1.8rem;
            margin: 0;
            flex-grow: 1;
        }
        
        /* 右上角认证控件 */
        .auth-controls {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-left: auto;
        }
        
        .auth-btn {
            color: #667eea;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 20px;
            background: rgba(102, 126, 234, 0.1);
            transition: all 0.3s ease;
            font-weight: 500;
            font-size: 0.9rem;
            border: none;
            cursor: pointer;
        }
        
        .auth-btn:hover {
            background: #667eea;
            color: white;
            transform: translateY(-1px);
        }
        
        .auth-btn.primary {
            background: #667eea;
            color: white;
        }
        
        .auth-btn.primary:hover {
            background: #764ba2;
        }
        
        .nav {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            align-items: center;
        }
        
        .nav a {
            color: #667eea;
            text-decoration: none;
            padding: 10px 20px;
            border-radius: 25px;
            background: rgba(102, 126, 234, 0.1);
            transition: all 0.3s ease;
            font-weight: 500;
        }
        
        .nav a:hover {
            background: #667eea;
            color: white;
            transform: translateY(-2px);
        }
        
        /* 修复语言选择器 - 确保国旗emoji正确显示 */
        .language-selector {
            margin-left: auto;
            display: flex;
            gap: 10px;
        }
        
        .language-selector select {
            padding: 8px 15px;
            border: 2px solid #667eea;
            border-radius: 20px;
            background: white;
            color: #667eea;
            font-weight: 500;
            cursor: pointer;
            font-family: 'Inter', sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Noto Color Emoji';
            font-size: 14px;
            line-height: 1.4;
        }
        
        /* 确保option中的emoji正确显示 */
        .language-selector option {
            font-family: 'Inter', sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Noto Color Emoji';
            font-size: 14px;
            padding: 5px;
        }
        
        .content {
            background: rgba(255,255,255,0.95);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
            backdrop-filter: blur(10px);
        }
        
        .tools-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        
        .tool-card {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 15px;
            border-left: 5px solid #667eea;
            transition: all 0.3s ease;
            text-align: center;
        }
        
        .tool-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        }
        
        .tool-card h3 {
            color: #667eea;
            margin-bottom: 15px;
            font-weight: 600;
        }
        
        .tool-card p {
            color: #666;
            margin-bottom: 20px;
        }
        
        .btn {
            display: inline-block;
            padding: 12px 25px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 500;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: #333;
        }
        
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e1e5e9;
            border-radius: 10px;
            font-size: 16px;
            transition: border-color 0.3s ease;
        }
        
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .result-card {
            background: linear-gradient(135deg, #00b894 0%, #00cec9 100%);
            color: white;
            padding: 20px;
            border-radius: 15px;
            margin-top: 20px;
            text-align: center;
        }
        
        .result-value {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 5px;
        }
        
        .calculator-form {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-top: 30px;
        }
        
        /* 加载动画 */
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid rgba(255,255,255,.3);
            border-radius: 50%;
            border-top-color: #fff;
            animation: spin 1s ease-in-out infinite;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        /* 响应式设计 */
        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }
            
            .header, .content {
                padding: 20px;
            }
            
            .header-top {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            
            .auth-controls {
                margin-left: 0;
                margin-top: 10px;
            }
            
            .nav {
                justify-content: center;
            }
            
            .language-selector {
                margin-left: 0;
                margin-top: 10px;
            }
            
            .calculator-form {
                grid-template-columns: 1fr;
                gap: 20px;
            }
        }
    </style>
    
    <!-- Alpine.js for interactivity -->
    <script defer src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js"></script>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="header-top">
                <a href="{{ isset($locale) && $locale ? route('home.locale', $locale) : route('home') }}" class="logo">🔨</a>
                <h1>{{ isset($locale) && $locale ? __('common.site_title') : 'BestHammer Tools' }}</h1>
                
                <!-- 右上角认证控件 -->
                <div class="auth-controls">
                    @auth
                        <a href="{{ isset($locale) && $locale ? route('dashboard.locale', $locale) : route('dashboard') }}" class="auth-btn">
                            {{ isset($locale) && $locale ? __('common.dashboard') : 'Dashboard' }}
                        </a>
                        <form method="POST" action="{{ route('logout') }}" style="display: inline;">
                            @csrf
                            <button type="submit" class="auth-btn">
                                {{ isset($locale) && $locale ? __('auth.logout') : 'Logout' }}
                            </button>
                        </form>
                    @else
                        <a href="{{ isset($locale) && $locale ? route('login.locale', $locale) : route('login') }}" class="auth-btn">
                            {{ isset($locale) && $locale ? __('auth.login') : 'Login' }}
                        </a>
                        <a href="{{ isset($locale) && $locale ? route('register.locale', $locale) : route('register') }}" class="auth-btn primary">
                            {{ isset($locale) && $locale ? __('auth.register') : 'Register' }}
                        </a>
                    @endauth
                </div>
            </div>
            <nav class="nav">
                <a href="{{ isset($locale) && $locale ? route('home.locale', $locale) : route('home') }}">
                    {{ isset($locale) && $locale ? __('common.home') : 'Home' }}
                </a>
                <a href="{{ isset($locale) && $locale ? route('tools.locale.loan', $locale) : route('tools.loan') }}">
                    {{ isset($locale) && $locale ? __('common.loan_calculator') : 'Loan Calculator' }}
                </a>
                <a href="{{ isset($locale) && $locale ? route('tools.locale.bmi', $locale) : route('tools.bmi') }}">
                    {{ isset($locale) && $locale ? __('common.bmi_calculator') : 'BMI Calculator' }}
                </a>
                <a href="{{ isset($locale) && $locale ? route('tools.locale.currency', $locale) : route('tools.currency') }}">
                    {{ isset($locale) && $locale ? __('common.currency_converter') : 'Currency Converter' }}
                </a>
                <a href="{{ isset($locale) && $locale ? route('about.locale', $locale) : route('about') }}">
                    {{ isset($locale) && $locale ? __('common.about') : 'About' }}
                </a>
                
                <!-- 修复后的语言选择器 - 影响整个网站内容 -->
                <div class="language-selector">
                    <select onchange="switchLanguage(this.value)">
                        <option value="en" {{ (isset($locale) ? $locale : 'en') == 'en' ? 'selected' : '' }}>🇺🇸 English</option>
                        <option value="de" {{ (isset($locale) ? $locale : 'en') == 'de' ? 'selected' : '' }}>🇩🇪 Deutsch</option>
                        <option value="fr" {{ (isset($locale) ? $locale : 'en') == 'fr' ? 'selected' : '' }}>🇫🇷 Français</option>
                        <option value="es" {{ (isset($locale) ? $locale : 'en') == 'es' ? 'selected' : '' }}>🇪🇸 Español</option>
                    </select>
                </div>
            </nav>
        </div>
        
        <div class="content">
            @yield('content')
        </div>
    </div>
    
    <script>
        function switchLanguage(locale) {
            const currentPath = window.location.pathname;
            const pathParts = currentPath.split('/').filter(part => part);
            
            // Remove current locale if exists
            if (['en', 'de', 'fr', 'es'].includes(pathParts[0])) {
                pathParts.shift();
            }
            
            // Add new locale (影响整个网站内容)
            let newPath;
            if (locale === 'en') {
                newPath = '/' + (pathParts.length ? pathParts.join('/') : '');
            } else {
                newPath = '/' + locale + (pathParts.length ? '/' + pathParts.join('/') : '');
            }
            
            window.location.href = newPath;
        }
        
        // CSRF token for AJAX requests
        window.Laravel = {
            csrfToken: '{{ csrf_token() }}'
        };
    </script>
    
    @stack('scripts')
</body>
</html>
EOF

log_success "true-complete-implementation.sh的主布局文件已恢复"

log_step "第2步：恢复简洁的HomeController"
echo "-----------------------------------"

# 备份当前HomeController
cp app/Http/Controllers/HomeController.php app/Http/Controllers/HomeController.php.backup.$(date +%Y%m%d_%H%M%S)

# 恢复true-complete-implementation.sh的简洁HomeController
cat > app/Http/Controllers/HomeController.php << 'EOF'
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class HomeController extends Controller
{
    private $supportedLocales = ['en', 'de', 'fr', 'es'];

    public function index()
    {
        return view('home', [
            'locale' => null,
            'title' => 'BestHammer Tools - Professional Financial & Health Tools'
        ]);
    }

    public function about()
    {
        return view('about', [
            'locale' => null,
            'title' => 'About BestHammer Tools'
        ]);
    }

    public function localeHome($locale)
    {
        if (!in_array($locale, $this->supportedLocales)) {
            abort(404);
        }

        app()->setLocale($locale);

        return view('home', [
            'locale' => $locale,
            'title' => $this->getLocalizedTitle($locale)
        ]);
    }

    public function localeAbout($locale)
    {
        if (!in_array($locale, $this->supportedLocales)) {
            abort(404);
        }

        app()->setLocale($locale);

        return view('about', [
            'locale' => $locale,
            'title' => $this->getLocalizedAboutTitle($locale)
        ]);
    }

    private function getLocalizedTitle($locale)
    {
        $titles = [
            'en' => 'BestHammer Tools - Professional Financial & Health Tools',
            'de' => 'BestHammer Tools - Professionelle Finanz- und Gesundheitstools',
            'fr' => 'BestHammer Tools - Outils Financiers et de Santé Professionnels',
            'es' => 'BestHammer Tools - Herramientas Profesionales Financieras y de Salud'
        ];

        return $titles[$locale] ?? $titles['en'];
    }

    private function getLocalizedAboutTitle($locale)
    {
        $titles = [
            'en' => 'About BestHammer Tools',
            'de' => 'Über BestHammer Tools',
            'fr' => 'À propos de BestHammer Tools',
            'es' => 'Acerca de BestHammer Tools'
        ];

        return $titles[$locale] ?? $titles['en'];
    }
}
EOF

log_success "简洁的HomeController已恢复"

log_step "第3步：恢复true-complete-implementation.sh的home页面"
echo "-----------------------------------"

# 备份当前home页面
if [ -f "resources/views/home.blade.php" ]; then
    cp resources/views/home.blade.php resources/views/home.blade.php.backup.$(date +%Y%m%d_%H%M%S)
fi

# 恢复true-complete-implementation.sh的home页面
cat > resources/views/home.blade.php << 'EOF'
@extends('layouts.app')

@section('content')
<div>
    <!-- 修复标题 - 简短且SEO友好 -->
    <h1 style="text-align: center; color: #667eea; margin-bottom: 20px;">
        {{ isset($locale) && $locale ? __('common.welcome_message') : 'Professional Financial & Health Tools' }}
    </h1>

    <p style="text-align: center; font-size: 1.1rem; margin-bottom: 40px; color: #666;">
        {{ isset($locale) && $locale ? __('common.description') : 'Calculate loans, BMI, and convert currencies with precision for European and American markets' }}
    </p>

    <!-- 工具网格 -->
    <div class="tools-grid">
        <div class="tool-card">
            <h3>💰 {{ isset($locale) && $locale ? __('common.loan_calculator') : 'Loan Calculator' }}</h3>
            <p>{{ isset($locale) && $locale ? 'Berechnen Sie Monatsraten, Gesamtzinsen und Tilgungspläne mit präzisen Algorithmen.' : 'Calculate monthly payments, total interest, and amortization schedules with precise algorithms.' }}</p>
            <a href="{{ isset($locale) && $locale ? route('tools.locale.loan', $locale) : route('tools.loan') }}" class="btn">
                {{ isset($locale) && $locale ? __('common.calculate') : 'Calculate Now' }}
            </a>
        </div>

        <div class="tool-card">
            <h3>⚖️ {{ isset($locale) && $locale ? __('common.bmi_calculator') : 'BMI Calculator' }}</h3>
            <p>{{ isset($locale) && $locale ? 'Berechnen Sie BMI und BMR mit Ernährungsempfehlungen nach WHO-Standards.' : 'Calculate BMI and BMR with nutrition recommendations based on WHO standards.' }}</p>
            <a href="{{ isset($locale) && $locale ? route('tools.locale.bmi', $locale) : route('tools.bmi') }}" class="btn">
                {{ isset($locale) && $locale ? __('common.calculate') : 'Calculate BMI' }}
            </a>
        </div>

        <div class="tool-card">
            <h3>💱 {{ isset($locale) && $locale ? __('common.currency_converter') : 'Currency Converter' }}</h3>
            <p>{{ isset($locale) && $locale ? 'Konvertieren Sie zwischen 150+ Währungen mit Echtzeit-Wechselkursen.' : 'Convert between 150+ currencies with real-time exchange rates and historical trends.' }}</p>
            <a href="{{ isset($locale) && $locale ? route('tools.locale.currency', $locale) : route('tools.currency') }}" class="btn">
                {{ isset($locale) && $locale ? __('common.convert') : 'Convert Currency' }}
            </a>
        </div>
    </div>

    <!-- 特色功能展示 -->
    <div style="margin-top: 50px; text-align: center;">
        <h2 style="color: #667eea; margin-bottom: 30px;">
            {{ isset($locale) && $locale ? 'Warum BestHammer wählen?' : 'Why Choose BestHammer?' }}
        </h2>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 30px; margin-top: 30px;">
            <div style="padding: 20px;">
                <div style="font-size: 2rem; margin-bottom: 15px;">🎯</div>
                <h4 style="color: #667eea; margin-bottom: 10px;">
                    {{ isset($locale) && $locale ? 'Präzise Algorithmen' : 'Precise Algorithms' }}
                </h4>
                <p style="color: #666;">
                    {{ isset($locale) && $locale ? 'Mathematisch korrekte Berechnungen nach Industriestandards' : 'Mathematically accurate calculations following industry standards' }}
                </p>
            </div>

            <div style="padding: 20px;">
                <div style="font-size: 2rem; margin-bottom: 15px;">🌍</div>
                <h4 style="color: #667eea; margin-bottom: 10px;">
                    {{ isset($locale) && $locale ? 'Mehrsprachig' : 'Multi-Language' }}
                </h4>
                <p style="color: #666;">
                    {{ isset($locale) && $locale ? 'Unterstützung für Englisch, Deutsch, Französisch und Spanisch' : 'Support for English, German, French, and Spanish' }}
                </p>
            </div>

            <div style="padding: 20px;">
                <div style="font-size: 2rem; margin-bottom: 15px;">📱</div>
                <h4 style="color: #667eea; margin-bottom: 10px;">
                    {{ isset($locale) && $locale ? 'Responsiv' : 'Responsive' }}
                </h4>
                <p style="color: #666;">
                    {{ isset($locale) && $locale ? 'Optimiert für Desktop und mobile Geräte' : 'Optimized for desktop and mobile devices' }}
                </p>
            </div>
        </div>
    </div>
</div>
@endsection
EOF

log_success "true-complete-implementation.sh的home页面已恢复"

log_step "第4步：恢复true-complete-implementation.sh的about页面"
echo "-----------------------------------"

# 备份当前about页面
if [ -f "resources/views/about.blade.php" ]; then
    cp resources/views/about.blade.php resources/views/about.blade.php.backup.$(date +%Y%m%d_%H%M%S)
fi

# 恢复true-complete-implementation.sh的about页面
cat > resources/views/about.blade.php << 'EOF'
@extends('layouts.app')

@section('content')
<div>
    <h1 style="text-align: center; color: #667eea; margin-bottom: 30px;">
        {{ isset($locale) && $locale ? __('common.about') : 'About BestHammer Tools' }}
    </h1>

    <div style="max-width: 800px; margin: 0 auto;">
        <p style="font-size: 1.1rem; margin-bottom: 30px; text-align: center; color: #666;">
            {{ isset($locale) && $locale ? 'BestHammer Tools bietet professionelle Finanz- und Gesundheitsrechner für europäische und amerikanische Märkte.' : 'BestHammer Tools provides professional financial and health calculators for European and American markets.' }}
        </p>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; margin: 40px 0;">
            <div style="background: #f8f9fa; padding: 25px; border-radius: 15px; border-left: 5px solid #667eea;">
                <h3 style="color: #667eea; margin-bottom: 15px;">
                    {{ isset($locale) && $locale ? '🎯 Unsere Mission' : '🎯 Our Mission' }}
                </h3>
                <p style="color: #666;">
                    {{ isset($locale) && $locale ? 'Präzise, benutzerfreundliche Finanzrechner bereitzustellen, die komplexe Berechnungen vereinfachen und fundierte Entscheidungen ermöglichen.' : 'To provide accurate, user-friendly financial calculators that simplify complex calculations and enable informed decision-making.' }}
                </p>
            </div>

            <div style="background: #f8f9fa; padding: 25px; border-radius: 15px; border-left: 5px solid #667eea;">
                <h3 style="color: #667eea; margin-bottom: 15px;">
                    {{ isset($locale) && $locale ? '🔧 Unsere Tools' : '🔧 Our Tools' }}
                </h3>
                <p style="color: #666;">
                    {{ isset($locale) && $locale ? 'Darlehensrechner, BMI-Rechner und Währungskonverter mit mathematisch korrekten Algorithmen und Industriestandards.' : 'Loan calculators, BMI calculators, and currency converters with mathematically accurate algorithms and industry standards.' }}
                </p>
            </div>
        </div>

        <div style="text-align: center; margin-top: 40px;">
            <h3 style="color: #667eea; margin-bottom: 20px;">
                {{ isset($locale) && $locale ? '📧 Kontakt' : '📧 Contact' }}
            </h3>
            <p style="color: #666;">
                {{ isset($locale) && $locale ? 'Haben Sie Fragen oder Feedback? Kontaktieren Sie uns unter:' : 'Have questions or feedback? Contact us at:' }}
            </p>
            <p style="font-weight: 600; color: #667eea;">web1234boy@gmail.com</p>
        </div>
    </div>
</div>
@endsection
EOF

log_success "true-complete-implementation.sh的about页面已恢复"

log_step "第5步：修复路由文件以匹配true-complete-implementation.sh"
echo "-----------------------------------"

# 备份当前路由文件
cp routes/web.php routes/web.php.backup.$(date +%Y%m%d_%H%M%S)

# 恢复true-complete-implementation.sh的路由结构
cat > routes/web.php << 'EOF'
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\ToolController;

/*
|--------------------------------------------------------------------------
| Web Routes - European & American Markets
|--------------------------------------------------------------------------
*/

// 默认英语路由
Route::get('/', [HomeController::class, 'index'])->name('home');
Route::get('/about', [HomeController::class, 'about'])->name('about');

// 工具路由 - 默认英语
Route::prefix('tools')->name('tools.')->group(function () {
    Route::get('/loan-calculator', [ToolController::class, 'loanCalculator'])->name('loan');
    Route::post('/loan-calculator', [ToolController::class, 'calculateLoan'])->name('loan.calculate');

    Route::get('/bmi-calculator', [ToolController::class, 'bmiCalculator'])->name('bmi');
    Route::post('/bmi-calculator', [ToolController::class, 'calculateBmi'])->name('bmi.calculate');

    Route::get('/currency-converter', [ToolController::class, 'currencyConverter'])->name('currency');
    Route::post('/currency-converter', [ToolController::class, 'convertCurrency'])->name('currency.convert');
});

// 多语言路由组 (DE/FR/ES)
Route::prefix('{locale}')->where(['locale' => '(de|fr|es)'])->group(function () {
    Route::get('/', [HomeController::class, 'localeHome'])->name('home.locale');
    Route::get('/about', [HomeController::class, 'localeAbout'])->name('about.locale');

    // 多语言工具路由
    Route::prefix('tools')->name('tools.locale.')->group(function () {
        Route::get('/loan-calculator', [ToolController::class, 'localeLoanCalculator'])->name('loan');
        Route::post('/loan-calculator', [ToolController::class, 'calculateLoan'])->name('loan.calculate');

        Route::get('/bmi-calculator', [ToolController::class, 'localeBmiCalculator'])->name('bmi');
        Route::post('/bmi-calculator', [ToolController::class, 'calculateBmi'])->name('bmi.calculate');

        Route::get('/currency-converter', [ToolController::class, 'localeCurrencyConverter'])->name('currency');
        Route::post('/currency-converter', [ToolController::class, 'convertCurrency'])->name('currency.convert');
    });
});

// 手动认证路由（保持现有认证功能）
Route::get('/login', [App\Http\Controllers\Auth\LoginController::class, 'showLoginForm'])->name('login');
Route::post('/login', [App\Http\Controllers\Auth\LoginController::class, 'login']);
Route::post('/logout', [App\Http\Controllers\Auth\LoginController::class, 'logout'])->name('logout');

Route::get('/register', [App\Http\Controllers\Auth\RegisterController::class, 'showRegistrationForm'])->name('register');
Route::post('/register', [App\Http\Controllers\Auth\RegisterController::class, 'register']);

Route::get('/password/reset', [App\Http\Controllers\Auth\ForgotPasswordController::class, 'showLinkRequestForm'])->name('password.request');
Route::post('/password/email', [App\Http\Controllers\Auth\ForgotPasswordController::class, 'sendResetLinkEmail'])->name('password.email');
Route::get('/password/reset/{token}', [App\Http\Controllers\Auth\ResetPasswordController::class, 'showResetForm'])->name('password.reset');
Route::post('/password/reset', [App\Http\Controllers\Auth\ResetPasswordController::class, 'reset'])->name('password.update');

// 认证后的路由
Route::middleware(['auth'])->group(function () {
    Route::get('/dashboard', [App\Http\Controllers\DashboardController::class, 'index'])->name('dashboard');
});

// 多语言认证路由
Route::prefix('{locale}')->where(['locale' => '(de|fr|es)'])->group(function () {
    Route::get('/login', [App\Http\Controllers\Auth\LoginController::class, 'showLoginForm'])->name('login.locale');
    Route::get('/register', [App\Http\Controllers\Auth\RegisterController::class, 'showRegistrationForm'])->name('register.locale');

    Route::middleware(['auth'])->group(function () {
        Route::get('/dashboard', [App\Http\Controllers\DashboardController::class, 'localeIndex'])->name('dashboard.locale');
    });
});

// API路由
Route::prefix('api')->middleware(['throttle:60,1'])->group(function () {
    Route::get('/exchange-rates', [ToolController::class, 'getExchangeRates']);
});

// 健康检查路由
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'market' => 'European & American',
        'languages' => ['en', 'de', 'fr', 'es'],
        'tools' => ['loan_calculator', 'bmi_calculator', 'currency_converter'],
        'auth' => 'enabled',
        'timestamp' => now()->toISOString()
    ]);
});
EOF

log_success "路由文件已恢复到true-complete-implementation.sh状态"

log_step "第6步：设置权限和清理缓存"
echo "-----------------------------------"

# 设置文件权限
chown -R besthammer_c_usr:besthammer_c_usr routes/
chown -R besthammer_c_usr:besthammer_c_usr app/Http/Controllers/
chown -R besthammer_c_usr:besthammer_c_usr resources/
chmod -R 755 routes/
chmod -R 755 app/Http/Controllers/
chmod -R 755 resources/

# 清理Laravel缓存
log_info "清理Laravel缓存..."
sudo -u besthammer_c_usr php artisan config:clear 2>/dev/null || log_warning "配置缓存清理失败"
sudo -u besthammer_c_usr php artisan cache:clear 2>/dev/null || log_warning "应用缓存清理失败"
sudo -u besthammer_c_usr php artisan route:clear 2>/dev/null || log_warning "路由缓存清理失败"
sudo -u besthammer_c_usr php artisan view:clear 2>/dev/null || log_warning "视图缓存清理失败"

# 重新缓存配置
sudo -u besthammer_c_usr php artisan config:cache 2>/dev/null || log_warning "配置缓存失败"

# 重启Apache
systemctl restart apache2
sleep 3

log_step "第7步：验证恢复结果"
echo "-----------------------------------"

# 测试网站访问
log_info "测试网站访问..."
urls=(
    "https://www.besthammer.club"
    "https://www.besthammer.club/about"
    "https://www.besthammer.club/tools/loan-calculator"
    "https://www.besthammer.club/tools/bmi-calculator"
    "https://www.besthammer.club/tools/currency-converter"
    "https://www.besthammer.club/de/"
    "https://www.besthammer.club/de/about"
    "https://www.besthammer.club/login"
    "https://www.besthammer.club/register"
    "https://www.besthammer.club/health"
)

all_success=true
for url in "${urls[@]}"; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    if [ "$response" = "200" ]; then
        log_success "$url: HTTP $response"
    else
        log_error "$url: HTTP $response"
        all_success=false
    fi
done

echo ""
echo "🔄 恢复到true-complete-implementation.sh状态完成！"
echo "============================================="
echo ""
echo "📋 恢复内容总结："
echo ""
echo "✅ 主布局文件已恢复："
echo "   - true-complete-implementation.sh的完整CSS设计"
echo "   - 渐变背景和工具网格布局"
echo "   - 右上角认证控件（登录/注册按钮）"
echo "   - 修复的语言选择器和国旗显示"
echo ""
echo "✅ 页面内容已恢复："
echo "   - 简洁的home页面（工具网格和特色功能）"
echo "   - 简洁的about页面（使命和联系信息）"
echo "   - 简化的HomeController（无复杂逻辑）"
echo ""
echo "✅ 路由结构已恢复："
echo "   - true-complete-implementation.sh的路由命名"
echo "   - tools.loan, tools.bmi, tools.currency"
echo "   - 保持现有认证功能"
echo ""
echo "✅ 认证功能保持："
echo "   - 右上角显示登录/注册按钮"
echo "   - 认证后显示Dashboard和Logout"
echo "   - 多语言认证支持"
echo ""

if [ "$all_success" = true ]; then
    echo "🎉 完全恢复成功！"
    echo ""
    echo "🌍 测试地址："
    echo "   主页: https://www.besthammer.club"
    echo "   关于页面: https://www.besthammer.club/about"
    echo "   德语主页: https://www.besthammer.club/de/"
    echo "   登录页面: https://www.besthammer.club/login"
    echo "   注册页面: https://www.besthammer.club/register"
    echo ""
    echo "✨ 功能特点："
    echo "   - true-complete-implementation.sh的完整UI设计 ✓"
    echo "   - 简洁的home和about页面内容 ✓"
    echo "   - 右上角认证控件 ✓"
    echo "   - 保持所有工具功能 ✓"
    echo "   - 多语言支持 ✓"
    echo "   - 用户认证功能 ✓"
else
    echo "⚠️ 部分功能可能需要进一步检查"
    echo "建议检查："
    echo "1. Laravel日志: tail -50 storage/logs/laravel.log"
    echo "2. Apache错误日志: tail -20 /var/log/apache2/error.log"
fi

echo ""
log_info "恢复到true-complete-implementation.sh状态脚本执行完成！"
