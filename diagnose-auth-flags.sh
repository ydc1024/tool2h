#!/bin/bash

# 精确诊断用户认证和国旗显示问题
# 深度分析系统状态，找出问题根本原因

echo "🔍 精确诊断用户认证和国旗显示问题"
echo "================================="
echo "诊断内容："
echo "1. 用户认证系统完整性检查"
echo "2. 国旗图标显示问题分析"
echo "3. 路由配置检查"
echo "4. 视图文件完整性验证"
echo "5. 浏览器兼容性测试"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

log_check() {
    echo -e "${CYAN}[CHECK]${NC} $1"
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

# 创建诊断报告文件
REPORT_FILE="diagnosis_report_$(date +%Y%m%d_%H%M%S).txt"
echo "诊断报告 - $(date)" > "$REPORT_FILE"
echo "======================" >> "$REPORT_FILE"

log_step "第1步：用户认证系统诊断"
echo "-----------------------------------"

log_check "检查Laravel Auth配置..."
echo "=== Laravel Auth配置检查 ===" >> "$REPORT_FILE"

# 检查config/auth.php
if [ -f "config/auth.php" ]; then
    log_success "config/auth.php 存在"
    echo "✓ config/auth.php 存在" >> "$REPORT_FILE"
    
    # 检查默认guard配置
    default_guard=$(grep -o "'default' => '[^']*'" config/auth.php | cut -d"'" -f4)
    echo "默认Guard: $default_guard" >> "$REPORT_FILE"
    log_info "默认Guard: $default_guard"
else
    log_error "config/auth.php 不存在"
    echo "✗ config/auth.php 不存在" >> "$REPORT_FILE"
fi

# 检查User模型
log_check "检查User模型..."
if [ -f "app/Models/User.php" ]; then
    log_success "User模型存在"
    echo "✓ User模型存在" >> "$REPORT_FILE"
    
    # 检查User模型是否实现了正确的接口
    if grep -q "Authenticatable" app/Models/User.php; then
        log_success "User模型实现了Authenticatable接口"
        echo "✓ User模型实现了Authenticatable接口" >> "$REPORT_FILE"
    else
        log_error "User模型未实现Authenticatable接口"
        echo "✗ User模型未实现Authenticatable接口" >> "$REPORT_FILE"
    fi
else
    log_error "User模型不存在"
    echo "✗ User模型不存在" >> "$REPORT_FILE"
fi

# 检查认证路由
log_check "检查认证路由..."
echo "=== 认证路由检查 ===" >> "$REPORT_FILE"

if [ -f "routes/web.php" ]; then
    log_success "routes/web.php 存在"
    echo "✓ routes/web.php 存在" >> "$REPORT_FILE"
    
    # 检查Auth::routes()
    if grep -q "Auth::routes" routes/web.php; then
        log_success "发现 Auth::routes() 配置"
        echo "✓ 发现 Auth::routes() 配置" >> "$REPORT_FILE"
        grep -n "Auth::routes" routes/web.php >> "$REPORT_FILE"
    else
        log_error "未发现 Auth::routes() 配置"
        echo "✗ 未发现 Auth::routes() 配置" >> "$REPORT_FILE"
    fi
    
    # 检查登录路由
    if grep -q "login" routes/web.php; then
        log_success "发现登录相关路由"
        echo "✓ 发现登录相关路由" >> "$REPORT_FILE"
        grep -n "login" routes/web.php >> "$REPORT_FILE"
    else
        log_error "未发现登录相关路由"
        echo "✗ 未发现登录相关路由" >> "$REPORT_FILE"
    fi
else
    log_error "routes/web.php 不存在"
    echo "✗ routes/web.php 不存在" >> "$REPORT_FILE"
fi

# 检查认证控制器
log_check "检查认证控制器..."
echo "=== 认证控制器检查 ===" >> "$REPORT_FILE"

auth_controllers=(
    "app/Http/Controllers/Auth/LoginController.php"
    "app/Http/Controllers/Auth/RegisterController.php"
    "app/Http/Controllers/Auth/ForgotPasswordController.php"
    "app/Http/Controllers/Auth/ResetPasswordController.php"
)

for controller in "${auth_controllers[@]}"; do
    if [ -f "$controller" ]; then
        log_success "$(basename "$controller") 存在"
        echo "✓ $(basename "$controller") 存在" >> "$REPORT_FILE"
    else
        log_error "$(basename "$controller") 不存在"
        echo "✗ $(basename "$controller") 不存在" >> "$REPORT_FILE"
    fi
done

# 检查认证视图
log_check "检查认证视图..."
echo "=== 认证视图检查 ===" >> "$REPORT_FILE"

auth_views=(
    "resources/views/auth/login.blade.php"
    "resources/views/auth/register.blade.php"
    "resources/views/auth/passwords/email.blade.php"
    "resources/views/auth/passwords/reset.blade.php"
)

for view in "${auth_views[@]}"; do
    if [ -f "$view" ]; then
        log_success "$(basename "$view") 存在"
        echo "✓ $(basename "$view") 存在" >> "$REPORT_FILE"
    else
        log_error "$(basename "$view") 不存在"
        echo "✗ $(basename "$view") 不存在" >> "$REPORT_FILE"
    fi
done

# 检查数据库连接和用户表
log_check "检查数据库和用户表..."
echo "=== 数据库检查 ===" >> "$REPORT_FILE"

# 获取数据库配置
DB_HOST=$(grep "^DB_HOST=" .env | cut -d'=' -f2)
DB_DATABASE=$(grep "^DB_DATABASE=" .env | cut -d'=' -f2)
DB_USERNAME=$(grep "^DB_USERNAME=" .env | cut -d'=' -f2)
DB_PASSWORD=$(grep "^DB_PASSWORD=" .env | cut -d'=' -f2)

echo "数据库配置:" >> "$REPORT_FILE"
echo "Host: $DB_HOST" >> "$REPORT_FILE"
echo "Database: $DB_DATABASE" >> "$REPORT_FILE"
echo "Username: $DB_USERNAME" >> "$REPORT_FILE"

# 测试数据库连接
if mysql -h"$DB_HOST" -u"$DB_USERNAME" -p"$DB_PASSWORD" -e "USE $DB_DATABASE;" 2>/dev/null; then
    log_success "数据库连接正常"
    echo "✓ 数据库连接正常" >> "$REPORT_FILE"
    
    # 检查用户表是否存在
    if mysql -h"$DB_HOST" -u"$DB_USERNAME" -p"$DB_PASSWORD" -e "USE $DB_DATABASE; DESCRIBE users;" 2>/dev/null; then
        log_success "用户表存在"
        echo "✓ 用户表存在" >> "$REPORT_FILE"
        
        # 获取用户表结构
        echo "用户表结构:" >> "$REPORT_FILE"
        mysql -h"$DB_HOST" -u"$DB_USERNAME" -p"$DB_PASSWORD" -e "USE $DB_DATABASE; DESCRIBE users;" >> "$REPORT_FILE" 2>/dev/null
    else
        log_error "用户表不存在"
        echo "✗ 用户表不存在" >> "$REPORT_FILE"
    fi
else
    log_error "数据库连接失败"
    echo "✗ 数据库连接失败" >> "$REPORT_FILE"
fi

log_step "第2步：国旗图标显示问题诊断"
echo "-----------------------------------"

log_check "检查语言选择器组件..."
echo "=== 语言选择器诊断 ===" >> "$REPORT_FILE"

# 检查主布局文件中的语言选择器
if [ -f "resources/views/layouts/app.blade.php" ]; then
    log_success "主布局文件存在"
    echo "✓ 主布局文件存在" >> "$REPORT_FILE"
    
    # 检查语言选择器实现方式
    if grep -q "language-selector" resources/views/layouts/app.blade.php; then
        log_success "发现语言选择器"
        echo "✓ 发现语言选择器" >> "$REPORT_FILE"
        
        # 提取语言选择器代码
        echo "语言选择器代码:" >> "$REPORT_FILE"
        grep -A 10 -B 2 "language-selector" resources/views/layouts/app.blade.php >> "$REPORT_FILE"
        
        # 检查emoji使用方式
        if grep -q "🇺🇸\|🇩🇪\|🇫🇷\|🇪🇸" resources/views/layouts/app.blade.php; then
            log_warning "使用直接emoji字符"
            echo "⚠ 使用直接emoji字符（可能导致显示问题）" >> "$REPORT_FILE"
        elif grep -q "\\\\u" resources/views/layouts/app.blade.php; then
            log_success "使用Unicode编码"
            echo "✓ 使用Unicode编码" >> "$REPORT_FILE"
        else
            log_error "未发现emoji实现"
            echo "✗ 未发现emoji实现" >> "$REPORT_FILE"
        fi
        
        # 检查字体CSS
        if grep -q "font-family.*emoji\|Apple Color Emoji\|Segoe UI Emoji" resources/views/layouts/app.blade.php; then
            log_success "发现emoji字体CSS"
            echo "✓ 发现emoji字体CSS" >> "$REPORT_FILE"
        else
            log_error "缺少emoji字体CSS"
            echo "✗ 缺少emoji字体CSS" >> "$REPORT_FILE"
        fi
    else
        log_error "未发现语言选择器"
        echo "✗ 未发现语言选择器" >> "$REPORT_FILE"
    fi
else
    log_error "主布局文件不存在"
    echo "✗ 主布局文件不存在" >> "$REPORT_FILE"
fi

# 检查独立的语言选择器组件
if [ -f "resources/views/components/language-selector.blade.php" ]; then
    log_success "独立语言选择器组件存在"
    echo "✓ 独立语言选择器组件存在" >> "$REPORT_FILE"
    
    # 分析组件实现
    echo "组件emoji实现:" >> "$REPORT_FILE"
    grep -n "flag\|emoji\|🇺🇸\|🇩🇪\|🇫🇷\|🇪🇸" resources/views/components/language-selector.blade.php >> "$REPORT_FILE"
else
    log_warning "独立语言选择器组件不存在"
    echo "⚠ 独立语言选择器组件不存在" >> "$REPORT_FILE"
fi

log_step "第3步：浏览器兼容性测试"
echo "-----------------------------------"

log_check "生成浏览器测试页面..."
echo "=== 浏览器兼容性测试 ===" >> "$REPORT_FILE"

# 创建测试页面
cat > public/emoji-test.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Emoji Display Test</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .test-section { margin: 20px 0; padding: 15px; border: 1px solid #ccc; }
        .emoji-test { font-size: 24px; margin: 10px 0; }
        .method1 { font-family: 'Apple Color Emoji', 'Segoe UI Emoji', 'Noto Color Emoji', sans-serif; }
        .method2 { font-family: 'Segoe UI Emoji', 'Apple Color Emoji', 'Noto Color Emoji', sans-serif; }
        .method3 { font-family: 'Noto Color Emoji', 'Apple Color Emoji', 'Segoe UI Emoji', sans-serif; }
    </style>
</head>
<body>
    <h1>Emoji Display Test for BestHammer</h1>
    
    <div class="test-section">
        <h2>Method 1: Direct Emoji</h2>
        <div class="emoji-test">🇺🇸 English | 🇩🇪 Deutsch | 🇫🇷 Français | 🇪🇸 Español</div>
    </div>
    
    <div class="test-section">
        <h2>Method 2: Unicode Escape</h2>
        <div class="emoji-test">
            <span id="unicode-flags"></span>
        </div>
    </div>
    
    <div class="test-section">
        <h2>Method 3: Apple Font Priority</h2>
        <div class="emoji-test method1">🇺🇸 English | 🇩🇪 Deutsch | 🇫🇷 Français | 🇪🇸 Español</div>
    </div>
    
    <div class="test-section">
        <h2>Method 4: Segoe UI Font Priority</h2>
        <div class="emoji-test method2">🇺🇸 English | 🇩🇪 Deutsch | 🇫🇷 Français | 🇪🇸 Español</div>
    </div>
    
    <div class="test-section">
        <h2>Method 5: Noto Font Priority</h2>
        <div class="emoji-test method3">🇺🇸 English | 🇩🇪 Deutsch | 🇫🇷 Français | 🇪🇸 Español</div>
    </div>
    
    <div class="test-section">
        <h2>Browser Information</h2>
        <div id="browser-info"></div>
    </div>
    
    <script>
        // Unicode method
        const flags = {
            'en': '\uD83C\uDDFA\uD83C\uDDF8',
            'de': '\uD83C\uDDE9\uD83C\uDDEA',
            'fr': '\uD83C\uDDEB\uD83C\uDDF7',
            'es': '\uD83C\uDDEA\uD83C\uDDF8'
        };
        
        document.getElementById('unicode-flags').innerHTML = 
            flags.en + ' English | ' + 
            flags.de + ' Deutsch | ' + 
            flags.fr + ' Français | ' + 
            flags.es + ' Español';
        
        // Browser info
        document.getElementById('browser-info').innerHTML = 
            '<strong>User Agent:</strong> ' + navigator.userAgent + '<br>' +
            '<strong>Platform:</strong> ' + navigator.platform + '<br>' +
            '<strong>Language:</strong> ' + navigator.language;
    </script>
</body>
</html>
EOF

log_success "浏览器测试页面已创建: /emoji-test.html"
echo "✓ 浏览器测试页面已创建: /emoji-test.html" >> "$REPORT_FILE"

log_step "第4步：Laravel路由诊断"
echo "-----------------------------------"

log_check "检查Laravel路由缓存..."
echo "=== Laravel路由诊断 ===" >> "$REPORT_FILE"

# 清理并重新生成路由缓存
sudo -u besthammer_c_usr php artisan route:clear 2>/dev/null
if sudo -u besthammer_c_usr php artisan route:list --compact 2>/dev/null > route_list.tmp; then
    log_success "路由列表生成成功"
    echo "✓ 路由列表生成成功" >> "$REPORT_FILE"
    
    # 检查认证相关路由
    echo "认证相关路由:" >> "$REPORT_FILE"
    grep -i "login\|register\|password" route_list.tmp >> "$REPORT_FILE" 2>/dev/null || echo "未发现认证路由" >> "$REPORT_FILE"
    
    # 检查工具路由
    echo "工具相关路由:" >> "$REPORT_FILE"
    grep -i "tools\|loan\|bmi\|currency" route_list.tmp >> "$REPORT_FILE" 2>/dev/null || echo "未发现工具路由" >> "$REPORT_FILE"
    
    rm -f route_list.tmp
else
    log_error "路由列表生成失败"
    echo "✗ 路由列表生成失败" >> "$REPORT_FILE"
fi

log_step "第5步：生成诊断总结和建议"
echo "-----------------------------------"

echo "" >> "$REPORT_FILE"
echo "=== 诊断总结 ===" >> "$REPORT_FILE"
echo "诊断完成时间: $(date)" >> "$REPORT_FILE"

# 显示诊断报告
echo ""
echo "📋 诊断报告已生成: $REPORT_FILE"
echo ""
echo "🔍 快速诊断结果："

# 快速检查关键问题
auth_issues=0
flag_issues=0

# 检查认证问题
if [ ! -f "app/Http/Controllers/Auth/LoginController.php" ]; then
    echo "❌ 认证控制器缺失"
    ((auth_issues++))
fi

if [ ! -f "resources/views/auth/login.blade.php" ]; then
    echo "❌ 认证视图缺失"
    ((auth_issues++))
fi

if ! grep -q "Auth::routes" routes/web.php 2>/dev/null; then
    echo "❌ 认证路由未配置"
    ((auth_issues++))
fi

# 检查国旗问题
if ! grep -q "font-family.*emoji\|Apple Color Emoji" resources/views/layouts/app.blade.php 2>/dev/null; then
    echo "❌ 缺少emoji字体CSS"
    ((flag_issues++))
fi

if grep -q "🇺🇸\|🇩🇪" resources/views/layouts/app.blade.php 2>/dev/null && ! grep -q "\\\\u" resources/views/layouts/app.blade.php 2>/dev/null; then
    echo "❌ 使用直接emoji字符而非Unicode编码"
    ((flag_issues++))
fi

echo ""
echo "📊 问题统计："
echo "认证问题数量: $auth_issues"
echo "国旗显示问题数量: $flag_issues"

echo ""
echo "🌐 浏览器测试："
echo "请访问 https://www.besthammer.club/emoji-test.html 测试emoji显示效果"

echo ""
echo "📄 完整诊断报告请查看: $REPORT_FILE"

log_info "诊断脚本执行完成！"
