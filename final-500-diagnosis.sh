#!/bin/bash

# 最终500错误诊断和修复
# 深度分析并解决所有可能的500错误原因

echo "🔍 最终500错误诊断"
echo "=================="
echo "目标：找出并解决500错误的真正原因"
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

PROJECT_DIR="/var/www/besthammer_c_usr/data/www/besthammer.club"

log_step "第1步：检查Laravel核心文件"
echo "-----------------------------------"

cd "$PROJECT_DIR"

# 检查关键文件
log_info "检查Laravel核心文件..."

MISSING_FILES=()

if [ ! -f "vendor/autoload.php" ]; then
    MISSING_FILES+=("vendor/autoload.php")
fi

if [ ! -f "bootstrap/app.php" ]; then
    MISSING_FILES+=("bootstrap/app.php")
fi

if [ ! -f "public/index.php" ]; then
    MISSING_FILES+=("public/index.php")
fi

if [ ! -f "routes/web.php" ]; then
    MISSING_FILES+=("routes/web.php")
fi

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    log_error "缺失关键文件："
    for file in "${MISSING_FILES[@]}"; do
        echo "  - $file"
    done
else
    log_success "Laravel核心文件完整"
fi

log_step "第2步：检查PHP语法错误"
echo "-----------------------------------"

# 检查PHP文件语法
log_info "检查PHP文件语法..."

PHP_ERRORS=()

# 检查主要PHP文件
for file in "public/index.php" "bootstrap/app.php" "routes/web.php" "app/Http/Controllers/HomeController.php" "app/Http/Controllers/ToolController.php"; do
    if [ -f "$file" ]; then
        if ! php -l "$file" >/dev/null 2>&1; then
            PHP_ERRORS+=("$file")
        fi
    fi
done

if [ ${#PHP_ERRORS[@]} -gt 0 ]; then
    log_error "发现PHP语法错误："
    for file in "${PHP_ERRORS[@]}"; do
        echo "  - $file"
        php -l "$file" 2>&1 | head -3
    done
else
    log_success "PHP语法检查通过"
fi

log_step "第3步：检查视图文件"
echo "-----------------------------------"

# 检查视图文件
log_info "检查视图文件..."

MISSING_VIEWS=()

REQUIRED_VIEWS=(
    "resources/views/layouts/app.blade.php"
    "resources/views/home.blade.php"
    "resources/views/about.blade.php"
    "resources/views/tools/loan-calculator.blade.php"
    "resources/views/tools/bmi-calculator.blade.php"
    "resources/views/tools/currency-converter.blade.php"
)

for view in "${REQUIRED_VIEWS[@]}"; do
    if [ ! -f "$view" ]; then
        MISSING_VIEWS+=("$view")
    fi
done

if [ ${#MISSING_VIEWS[@]} -gt 0 ]; then
    log_error "缺失视图文件："
    for view in "${MISSING_VIEWS[@]}"; do
        echo "  - $view"
    done
else
    log_success "视图文件完整"
fi

log_step "第4步：检查Apache错误日志"
echo "-----------------------------------"

# 检查Apache错误日志
log_info "检查Apache错误日志..."

if [ -f "/var/log/apache2/error.log" ]; then
    log_info "最近的Apache错误："
    tail -10 /var/log/apache2/error.log | grep -E "(besthammer|500|Fatal|Error)" || echo "  无相关错误"
else
    log_warning "Apache错误日志不存在"
fi

# 检查Laravel日志
if [ -f "storage/logs/laravel.log" ]; then
    log_info "最近的Laravel错误："
    tail -10 storage/logs/laravel.log | grep -E "(ERROR|CRITICAL|Fatal)" || echo "  无相关错误"
else
    log_warning "Laravel日志不存在"
fi

log_step "第5步：创建最小化测试页面"
echo "-----------------------------------"

# 创建最小化PHP测试页面
log_info "创建最小化测试页面..."

cat > public/test-basic.php << 'EOF'
<?php
// 最基础的PHP测试
echo "PHP基础测试: OK<br>";
echo "PHP版本: " . PHP_VERSION . "<br>";
echo "时间: " . date('Y-m-d H:i:s') . "<br>";

// 测试autoload
if (file_exists(__DIR__ . '/../vendor/autoload.php')) {
    echo "Autoload文件: 存在<br>";
    try {
        require_once __DIR__ . '/../vendor/autoload.php';
        echo "Autoload加载: 成功<br>";
    } catch (Exception $e) {
        echo "Autoload加载: 失败 - " . $e->getMessage() . "<br>";
    }
} else {
    echo "Autoload文件: 不存在<br>";
}

// 测试Laravel bootstrap
if (file_exists(__DIR__ . '/../bootstrap/app.php')) {
    echo "Bootstrap文件: 存在<br>";
    try {
        $app = require_once __DIR__ . '/../bootstrap/app.php';
        echo "Laravel启动: 成功<br>";
    } catch (Exception $e) {
        echo "Laravel启动: 失败 - " . $e->getMessage() . "<br>";
    }
} else {
    echo "Bootstrap文件: 不存在<br>";
}
?>
EOF

# 创建简单的Laravel测试页面
cat > public/test-laravel.php << 'EOF'
<?php
try {
    require_once __DIR__ . '/../vendor/autoload.php';
    $app = require_once __DIR__ . '/../bootstrap/app.php';
    
    echo "Laravel测试页面<br>";
    echo "框架版本: " . $app->version() . "<br>";
    echo "环境: " . $app->environment() . "<br>";
    
    // 测试配置
    $config = $app->make('config');
    echo "应用名称: " . $config->get('app.name') . "<br>";
    echo "调试模式: " . ($config->get('app.debug') ? '开启' : '关闭') . "<br>";
    
} catch (Exception $e) {
    echo "Laravel测试失败: " . $e->getMessage() . "<br>";
    echo "错误文件: " . $e->getFile() . ":" . $e->getLine() . "<br>";
}
?>
EOF

chown besthammer_c_usr:besthammer_c_usr public/test-*.php

log_success "测试页面创建完成"

log_step "第6步：测试不同层级的功能"
echo "-----------------------------------"

# 测试基础PHP
log_info "测试基础PHP..."
PHP_TEST=$(curl -s -o /dev/null -w "%{http_code}" "https://www.besthammer.club/test-basic.php" 2>/dev/null || echo "000")
log_info "基础PHP测试: HTTP $PHP_TEST"

# 测试Laravel
log_info "测试Laravel..."
LARAVEL_TEST=$(curl -s -o /dev/null -w "%{http_code}" "https://www.besthammer.club/test-laravel.php" 2>/dev/null || echo "000")
log_info "Laravel测试: HTTP $LARAVEL_TEST"

# 获取详细错误信息
if [ "$PHP_TEST" = "200" ]; then
    log_success "基础PHP功能正常"
    
    # 获取基础测试的输出
    log_info "基础测试输出："
    curl -s "https://www.besthammer.club/test-basic.php" 2>/dev/null | head -10
else
    log_error "基础PHP功能异常"
fi

if [ "$LARAVEL_TEST" = "200" ]; then
    log_success "Laravel功能正常"
    
    # 获取Laravel测试的输出
    log_info "Laravel测试输出："
    curl -s "https://www.besthammer.club/test-laravel.php" 2>/dev/null | head -10
else
    log_error "Laravel功能异常"
    
    # 尝试获取错误信息
    log_info "Laravel错误信息："
    curl -s "https://www.besthammer.club/test-laravel.php" 2>/dev/null | head -10
fi

log_step "第7步：根据诊断结果提供解决方案"
echo "-----------------------------------"

echo ""
echo "🔍 诊断结果分析"
echo "==============="
echo ""

# 分析结果并提供建议
if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo "❌ 问题：缺失Laravel核心文件"
    echo "解决方案：重新安装Laravel或恢复缺失文件"
    echo ""
elif [ ${#PHP_ERRORS[@]} -gt 0 ]; then
    echo "❌ 问题：PHP语法错误"
    echo "解决方案：修复PHP文件中的语法错误"
    echo ""
elif [ ${#MISSING_VIEWS[@]} -gt 0 ]; then
    echo "❌ 问题：缺失视图文件"
    echo "解决方案：创建缺失的Blade模板文件"
    echo ""
elif [ "$PHP_TEST" != "200" ]; then
    echo "❌ 问题：基础PHP功能异常"
    echo "解决方案：检查Apache配置和PHP设置"
    echo ""
elif [ "$LARAVEL_TEST" != "200" ]; then
    echo "❌ 问题：Laravel框架异常"
    echo "解决方案：检查Laravel配置和依赖"
    echo ""
else
    echo "✅ 基础功能正常，问题可能在路由或控制器"
    echo "解决方案：检查路由配置和控制器代码"
    echo ""
fi

echo "🧪 测试页面："
echo "   基础PHP测试: https://www.besthammer.club/test-basic.php"
echo "   Laravel测试: https://www.besthammer.club/test-laravel.php"
echo ""

# 提供具体的修复建议
if [ ${#MISSING_VIEWS[@]} -gt 0 ]; then
    echo "🔧 立即修复：创建缺失的视图文件"
    read -p "是否立即创建缺失的视图文件？(y/N): " CREATE_VIEWS
    if [[ $CREATE_VIEWS =~ ^[Yy]$ ]]; then
        log_info "创建缺失的视图文件..."
        
        # 运行视图创建脚本
        if [ -f "$(dirname "$0")/deploy-european-views.sh" ]; then
            bash "$(dirname "$0")/deploy-european-views.sh"
        elif [ -f "$(dirname "$0")/create-tool-views.sh" ]; then
            bash "$(dirname "$0")/create-tool-views.sh"
        else
            log_warning "视图创建脚本不存在，需要手动创建"
        fi
    fi
fi

echo ""
echo "📋 下一步建议："
echo "1. 访问测试页面查看详细错误信息"
echo "2. 根据诊断结果修复具体问题"
echo "3. 如果基础功能正常，重新部署视图文件"
echo "4. 检查Apache和PHP错误日志"
echo ""

log_info "500错误诊断完成！"
