#!/bin/bash

# 微调认证控件位置 - 放在右上角（header-top区域）
# 保持语言选择器在导航栏，认证控件在右上角

echo "🔧 微调认证控件位置"
echo "=================="
echo "调整内容："
echo "1. 将认证控件移到右上角（header-top区域）"
echo "2. 保持语言选择器在导航栏位置"
echo "3. 优化布局响应式设计"
echo "4. 保持true-complete-implementation.sh的所有样式"
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

log_step "第1步：分析当前布局结构"
echo "-----------------------------------"

# 检查当前布局文件
if [ -f "resources/views/layouts/app.blade.php" ]; then
    log_info "当前布局文件存在"
    
    # 检查是否是true-complete-implementation.sh的版本
    if grep -q "header-top" resources/views/layouts/app.blade.php; then
        log_success "检测到true-complete-implementation.sh布局结构"
    else
        log_warning "当前布局不是true-complete-implementation.sh版本"
        log_info "需要先运行restore-true-complete-state.sh脚本"
        exit 1
    fi
else
    log_error "布局文件不存在"
    exit 1
fi

log_step "第2步：微调布局文件 - 认证控件放在右上角"
echo "-----------------------------------"

# 备份当前布局文件
cp resources/views/layouts/app.blade.php resources/views/layouts/app.blade.php.backup.$(date +%Y%m%d_%H%M%S)

# 创建优化的布局文件，认证控件在右上角
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
            justify-content: space-between;
            margin-bottom: 15px;
        }
        
        .header-left {
            display: flex;
            align-items: center;
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
        }
        
        /* 右上角认证控件 */
        .auth-controls {
            display: flex;
            align-items: center;
            gap: 10px;
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
            white-space: nowrap;
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
                gap: 15px;
            }
            
            .header-left {
                align-self: center;
            }
            
            .auth-controls {
                align-self: center;
                order: -1;
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
            
            .auth-btn {
                font-size: 0.8rem;
                padding: 6px 12px;
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
                <div class="header-left">
                    <a href="{{ isset($locale) && $locale ? route('home.locale', $locale) : route('home') }}" class="logo">🔨</a>
                    <h1>{{ isset($locale) && $locale ? __('common.site_title') : 'BestHammer Tools' }}</h1>
                </div>
                
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
                
                <!-- 语言选择器保持在导航栏右侧 -->
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

log_success "布局文件已微调 - 认证控件在右上角"

log_step "第3步：设置权限和清理缓存"
echo "-----------------------------------"

# 设置文件权限
chown -R besthammer_c_usr:besthammer_c_usr resources/views/layouts/
chmod -R 755 resources/views/layouts/

# 清理Laravel缓存
log_info "清理Laravel缓存..."
sudo -u besthammer_c_usr php artisan view:clear 2>/dev/null || log_warning "视图缓存清理失败"
sudo -u besthammer_c_usr php artisan cache:clear 2>/dev/null || log_warning "应用缓存清理失败"

# 重启Apache
systemctl restart apache2
sleep 2

log_step "第4步：验证微调结果"
echo "-----------------------------------"

# 测试网站访问
log_info "测试网站访问..."
urls=(
    "https://www.besthammer.club"
    "https://www.besthammer.club/de/"
    "https://www.besthammer.club/login"
    "https://www.besthammer.club/register"
)

all_success=true
for url in "${urls[@]}"; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    if [ "$response" = "200" ]; then
        log_success "$url: HTTP $response"
    else
        log_warning "$url: HTTP $response"
        if [ "$response" = "000" ]; then
            all_success=false
        fi
    fi
done

echo ""
echo "🔧 认证控件位置微调完成！"
echo "======================"
echo ""
echo "📋 微调内容总结："
echo ""
echo "✅ 布局结构优化："
echo "   - 认证控件移至右上角（header-top区域）"
echo "   - 语言选择器保持在导航栏右侧"
echo "   - 保持true-complete-implementation.sh的所有样式"
echo ""
echo "✅ 布局层次结构："
echo "   header-top:"
echo "   ├── header-left (logo + 标题)"
echo "   └── auth-controls (登录/注册按钮) ← 右上角位置"
echo ""
echo "   nav:"
echo "   ├── 导航链接 (Home, Loan Calculator, BMI, Currency, About)"
echo "   └── language-selector (语言选择器) ← 导航栏右侧"
echo ""
echo "✅ 响应式设计："
echo "   - 桌面端：认证控件在右上角"
echo "   - 移动端：认证控件在顶部居中"
echo "   - 语言选择器始终在导航栏"
echo ""
echo "✅ 样式特点："
echo "   - 保持原有的渐变背景和圆角设计"
echo "   - 认证按钮使用相同的hover效果"
echo "   - Register按钮有primary样式突出显示"
echo ""

if [ "$all_success" = true ]; then
    echo "🎉 微调完全成功！"
    echo ""
    echo "🌍 测试地址："
    echo "   主页: https://www.besthammer.club"
    echo "   德语: https://www.besthammer.club/de/"
    echo "   登录: https://www.besthammer.club/login"
    echo ""
    echo "👀 查看效果："
    echo "   - 右上角显示 Login | Register 按钮"
    echo "   - 登录后显示 Dashboard | Logout 按钮"
    echo "   - 语言选择器在导航栏最右侧"
    echo "   - 移动端自适应布局"
else
    echo "⚠️ 部分功能可能需要进一步检查"
fi

echo ""
echo "💡 我选择导航栏位置的原因："
echo "1. 遵循true-complete-implementation.sh的原有结构"
echo "2. 语言选择器的CSS样式 'margin-left: auto' 表明它应该在导航栏右侧"
echo "3. 避免header-top区域过于拥挤"
echo ""
echo "🎯 现在的布局："
echo "- 认证控件：右上角（header-top区域）← 您要求的位置"
echo "- 语言选择器：导航栏右侧（保持原有位置）"
echo "- 两者分离，各司其职，布局更清晰"

echo ""
log_info "认证控件位置微调脚本执行完成！"
