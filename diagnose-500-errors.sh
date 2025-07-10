#!/bin/bash

# 深度诊断500错误脚本
# 全环境和文件关联状态分析

echo "🔍 深度诊断500错误"
echo "=================="
echo "诊断范围："
echo "1. Laravel错误日志分析"
echo "2. Apache错误日志检查"
echo "3. PHP错误和配置检查"
echo "4. 文件权限和所有权验证"
echo "5. 路由和控制器完整性检查"
echo "6. 数据库连接状态"
echo "7. 缓存和配置状态"
echo "8. 依赖和自动加载检查"
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

# 环境预检查
log_info "执行环境预检查..."

# 检查项目目录是否存在
if [ ! -d "$PROJECT_DIR" ]; then
    log_error "项目目录不存在: $PROJECT_DIR"
    exit 1
fi

# 检查是否可以进入项目目录
if ! cd "$PROJECT_DIR" 2>/dev/null; then
    log_error "无法进入项目目录: $PROJECT_DIR"
    exit 1
fi

# 检查基本命令是否可用
for cmd in php mysql curl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_warning "$cmd 命令不可用"
    fi
done

log_success "环境预检查完成"

# 创建诊断报告文件
REPORT_FILE="diagnosis_500_errors_$(date +%Y%m%d_%H%M%S).txt"
echo "500错误深度诊断报告 - $(date)" > "$REPORT_FILE"
echo "==============================" >> "$REPORT_FILE"

log_step "第1步：Laravel错误日志分析"
echo "-----------------------------------"

log_check "检查Laravel日志文件..."
echo "=== Laravel错误日志分析 ===" >> "$REPORT_FILE"

if [ -f "storage/logs/laravel.log" ]; then
    log_success "Laravel日志文件存在"
    echo "✓ Laravel日志文件存在" >> "$REPORT_FILE"
    
    # 获取最近的错误
    echo "最近的Laravel错误（最后50行）:" >> "$REPORT_FILE"
    tail -50 storage/logs/laravel.log >> "$REPORT_FILE" 2>/dev/null
    
    # 查找500相关错误
    log_info "查找500相关错误..."
    if grep -i "error\|exception\|fatal" storage/logs/laravel.log | tail -10; then
        echo "发现Laravel错误，详情见报告文件"
    else
        log_warning "Laravel日志中未发现明显错误"
    fi
    
    # 检查特定错误模式
    echo "特定错误模式分析:" >> "$REPORT_FILE"
    grep -i "class.*not found\|undefined method\|syntax error\|fatal error" storage/logs/laravel.log | tail -5 >> "$REPORT_FILE" 2>/dev/null
    
else
    log_error "Laravel日志文件不存在"
    echo "✗ Laravel日志文件不存在" >> "$REPORT_FILE"
fi

log_step "第2步：Apache错误日志检查"
echo "-----------------------------------"

log_check "检查Apache错误日志..."
echo "=== Apache错误日志分析 ===" >> "$REPORT_FILE"

if [ -f "/var/log/apache2/error.log" ]; then
    log_success "Apache错误日志存在"
    echo "✓ Apache错误日志存在" >> "$REPORT_FILE"
    
    # 获取最近的Apache错误
    echo "最近的Apache错误（最后20行）:" >> "$REPORT_FILE"
    tail -20 /var/log/apache2/error.log >> "$REPORT_FILE" 2>/dev/null
    
    # 查找PHP相关错误
    log_info "查找PHP相关错误..."
    grep -i "php\|fatal\|error" /var/log/apache2/error.log | tail -5
    
else
    log_warning "Apache错误日志不存在或无法访问"
    echo "⚠ Apache错误日志不存在或无法访问" >> "$REPORT_FILE"
fi

log_step "第3步：PHP错误和配置检查"
echo "-----------------------------------"

log_check "检查PHP配置..."
echo "=== PHP配置检查 ===" >> "$REPORT_FILE"

# PHP版本检查
php_version=$(php -v | head -1)
echo "PHP版本: $php_version" >> "$REPORT_FILE"
log_info "PHP版本: $php_version"

# PHP错误报告设置
php_error_reporting=$(php -r "echo ini_get('error_reporting');")
php_display_errors=$(php -r "echo ini_get('display_errors');")
echo "PHP错误报告: $php_error_reporting" >> "$REPORT_FILE"
echo "PHP显示错误: $php_display_errors" >> "$REPORT_FILE"

# 检查PHP扩展
log_check "检查关键PHP扩展..."
echo "PHP扩展检查:" >> "$REPORT_FILE"

required_extensions=("pdo" "pdo_mysql" "mbstring" "openssl" "tokenizer" "xml" "ctype" "json")
for ext in "${required_extensions[@]}"; do
    if php -m | grep -q "$ext"; then
        echo "✓ $ext: 已安装" >> "$REPORT_FILE"
        log_success "$ext: 已安装"
    else
        echo "✗ $ext: 未安装" >> "$REPORT_FILE"
        log_error "$ext: 未安装"
    fi
done

# 检查Composer自动加载
log_check "检查Composer自动加载..."
if [ -f "vendor/autoload.php" ]; then
    log_success "Composer自动加载文件存在"
    echo "✓ Composer自动加载文件存在" >> "$REPORT_FILE"

    # 检查自动加载文件语法
    if php -l vendor/autoload.php > /dev/null 2>&1; then
        echo "  自动加载文件语法正确" >> "$REPORT_FILE"
    else
        log_error "自动加载文件语法错误"
        echo "✗ 自动加载文件语法错误" >> "$REPORT_FILE"
    fi

    # 检查composer.json
    if [ -f "composer.json" ]; then
        echo "✓ composer.json存在" >> "$REPORT_FILE"

        # 检查composer.json语法
        if php -r "json_decode(file_get_contents('composer.json')); if (json_last_error() !== JSON_ERROR_NONE) exit(1);" 2>/dev/null; then
            echo "  composer.json语法正确" >> "$REPORT_FILE"
        else
            log_error "composer.json语法错误"
            echo "✗ composer.json语法错误" >> "$REPORT_FILE"
        fi
    else
        log_error "composer.json不存在"
        echo "✗ composer.json不存在" >> "$REPORT_FILE"
    fi

    # 检查vendor目录权限
    vendor_owner=$(ls -ld vendor | awk '{print $3}')
    echo "vendor目录所有者: $vendor_owner" >> "$REPORT_FILE"

else
    log_error "Composer自动加载文件不存在"
    echo "✗ Composer自动加载文件不存在" >> "$REPORT_FILE"
    echo "建议运行: composer install" >> "$REPORT_FILE"
fi

log_step "第4步：文件权限和所有权验证"
echo "-----------------------------------"

log_check "检查文件权限..."
echo "=== 文件权限检查 ===" >> "$REPORT_FILE"

# 检查关键目录权限
critical_dirs=("storage" "bootstrap/cache" "vendor" "app" "config" "routes")
for dir in "${critical_dirs[@]}"; do
    if [ -d "$dir" ]; then
        permissions=$(ls -ld "$dir" | awk '{print $1, $3, $4}')
        echo "$dir: $permissions" >> "$REPORT_FILE"

        # 检查所有者
        owner=$(ls -ld "$dir" | awk '{print $3}')
        group=$(ls -ld "$dir" | awk '{print $4}')

        if [ "$owner" = "besthammer_c_usr" ]; then
            log_success "$dir: 所有者正确 ($owner)"
        else
            log_warning "$dir: 所有者不正确 ($owner, 应该是 besthammer_c_usr)"
        fi

        # 检查是否可写
        if [ -w "$dir" ]; then
            log_success "$dir: 可写"
        else
            log_error "$dir: 不可写"
            echo "✗ $dir: 不可写" >> "$REPORT_FILE"
        fi

        # 检查具体权限值
        perm_octal=$(stat -c "%a" "$dir" 2>/dev/null || echo "unknown")
        echo "  八进制权限: $perm_octal" >> "$REPORT_FILE"

    else
        log_error "$dir: 目录不存在"
        echo "✗ $dir: 目录不存在" >> "$REPORT_FILE"
    fi
done

# 检查storage目录的具体权限
if [ -d "storage" ]; then
    echo "Storage目录详细权限:" >> "$REPORT_FILE"
    find storage -type d -exec ls -ld {} \; | head -10 >> "$REPORT_FILE"
fi

log_step "第5步：路由和控制器完整性检查"
echo "-----------------------------------"

log_check "检查路由文件..."
echo "=== 路由和控制器检查 ===" >> "$REPORT_FILE"

# 检查路由文件语法
if [ -f "routes/web.php" ]; then
    log_success "路由文件存在"
    echo "✓ 路由文件存在" >> "$REPORT_FILE"
    
    # 检查路由文件语法
    if php -l routes/web.php > /dev/null 2>&1; then
        log_success "路由文件语法正确"
        echo "✓ 路由文件语法正确" >> "$REPORT_FILE"
    else
        log_error "路由文件语法错误"
        echo "✗ 路由文件语法错误" >> "$REPORT_FILE"
        php -l routes/web.php >> "$REPORT_FILE" 2>&1
    fi
    
    # 检查路由文件中的控制器引用
    echo "路由文件中的控制器引用:" >> "$REPORT_FILE"
    grep -n "Controller::" routes/web.php >> "$REPORT_FILE" 2>/dev/null || echo "未找到控制器引用" >> "$REPORT_FILE"
    
else
    log_error "路由文件不存在"
    echo "✗ 路由文件不存在" >> "$REPORT_FILE"
fi

# 检查关键控制器文件
log_check "检查控制器文件..."
controllers=("HomeController" "ToolController" "Auth/LoginController" "Auth/RegisterController")
for controller in "${controllers[@]}"; do
    controller_file="app/Http/Controllers/${controller}.php"
    if [ -f "$controller_file" ]; then
        log_success "$controller: 存在"
        echo "✓ $controller: 存在" >> "$REPORT_FILE"
        
        # 检查控制器语法
        if php -l "$controller_file" > /dev/null 2>&1; then
            echo "  语法正确" >> "$REPORT_FILE"
        else
            log_error "$controller: 语法错误"
            echo "✗ $controller: 语法错误" >> "$REPORT_FILE"
            php -l "$controller_file" >> "$REPORT_FILE" 2>&1
        fi
    else
        log_error "$controller: 不存在"
        echo "✗ $controller: 不存在" >> "$REPORT_FILE"
    fi
done

log_step "第6步：数据库连接状态"
echo "-----------------------------------"

log_check "检查数据库连接..."
echo "=== 数据库连接检查 ===" >> "$REPORT_FILE"

# 检查.env文件中的数据库配置
if [ -f ".env" ]; then
    echo "数据库配置:" >> "$REPORT_FILE"
    grep "^DB_" .env >> "$REPORT_FILE" 2>/dev/null
    
    # 获取数据库配置
    DB_HOST=$(grep "^DB_HOST=" .env | cut -d'=' -f2)
    DB_DATABASE=$(grep "^DB_DATABASE=" .env | cut -d'=' -f2)
    DB_USERNAME=$(grep "^DB_USERNAME=" .env | cut -d'=' -f2)
    DB_PASSWORD=$(grep "^DB_PASSWORD=" .env | cut -d'=' -f2)
    
    # 测试数据库连接
    if [ -n "$DB_HOST" ] && [ -n "$DB_DATABASE" ] && [ -n "$DB_USERNAME" ]; then
        if [ -n "$DB_PASSWORD" ]; then
            # 有密码的连接
            if mysql -h"$DB_HOST" -u"$DB_USERNAME" -p"$DB_PASSWORD" -e "USE $DB_DATABASE;" 2>/dev/null; then
                log_success "数据库连接正常"
                echo "✓ 数据库连接正常" >> "$REPORT_FILE"
            else
                log_error "数据库连接失败"
                echo "✗ 数据库连接失败" >> "$REPORT_FILE"
                # 尝试获取连接错误信息
                mysql -h"$DB_HOST" -u"$DB_USERNAME" -p"$DB_PASSWORD" -e "USE $DB_DATABASE;" >> "$REPORT_FILE" 2>&1 || true
            fi
        else
            # 无密码的连接
            if mysql -h"$DB_HOST" -u"$DB_USERNAME" -e "USE $DB_DATABASE;" 2>/dev/null; then
                log_success "数据库连接正常"
                echo "✓ 数据库连接正常" >> "$REPORT_FILE"
            else
                log_error "数据库连接失败"
                echo "✗ 数据库连接失败" >> "$REPORT_FILE"
                mysql -h"$DB_HOST" -u"$DB_USERNAME" -e "USE $DB_DATABASE;" >> "$REPORT_FILE" 2>&1 || true
            fi
        fi
    else
        log_warning "数据库配置不完整"
        echo "⚠ 数据库配置不完整" >> "$REPORT_FILE"
        echo "缺少的配置项:" >> "$REPORT_FILE"
        [ -z "$DB_HOST" ] && echo "- DB_HOST" >> "$REPORT_FILE"
        [ -z "$DB_DATABASE" ] && echo "- DB_DATABASE" >> "$REPORT_FILE"
        [ -z "$DB_USERNAME" ] && echo "- DB_USERNAME" >> "$REPORT_FILE"
    fi
else
    log_error ".env文件不存在"
    echo "✗ .env文件不存在" >> "$REPORT_FILE"
fi

log_step "第7步：缓存和配置状态"
echo "-----------------------------------"

log_check "检查Laravel缓存状态..."
echo "=== 缓存和配置状态 ===" >> "$REPORT_FILE"

# 检查配置缓存
if [ -f "bootstrap/cache/config.php" ]; then
    log_info "配置缓存存在"
    echo "✓ 配置缓存存在" >> "$REPORT_FILE"
    
    # 检查配置缓存是否有效
    if php -l bootstrap/cache/config.php > /dev/null 2>&1; then
        echo "  配置缓存语法正确" >> "$REPORT_FILE"
    else
        log_error "配置缓存语法错误"
        echo "✗ 配置缓存语法错误" >> "$REPORT_FILE"
    fi
else
    log_info "配置缓存不存在"
    echo "- 配置缓存不存在" >> "$REPORT_FILE"
fi

# 检查路由缓存
if [ -f "bootstrap/cache/routes-v7.php" ]; then
    log_info "路由缓存存在"
    echo "✓ 路由缓存存在" >> "$REPORT_FILE"
else
    log_info "路由缓存不存在"
    echo "- 路由缓存不存在" >> "$REPORT_FILE"
fi

# 尝试运行Laravel命令检查
log_check "测试Laravel命令..."

# 首先检查artisan文件是否存在
if [ ! -f "artisan" ]; then
    log_error "artisan文件不存在"
    echo "✗ artisan文件不存在" >> "$REPORT_FILE"
elif [ ! -x "artisan" ]; then
    log_warning "artisan文件不可执行"
    echo "⚠ artisan文件不可执行" >> "$REPORT_FILE"
    # 尝试修复权限
    chmod +x artisan 2>/dev/null || true
else
    # 测试Laravel命令
    if timeout 30 sudo -u besthammer_c_usr php artisan --version > /dev/null 2>&1; then
        log_success "Laravel命令可以执行"
        echo "✓ Laravel命令可以执行" >> "$REPORT_FILE"

        # 获取Laravel版本
        laravel_version=$(timeout 30 sudo -u besthammer_c_usr php artisan --version 2>/dev/null || echo "版本获取失败")
        echo "Laravel版本: $laravel_version" >> "$REPORT_FILE"

        # 测试其他关键命令
        echo "测试其他Laravel命令:" >> "$REPORT_FILE"
        if timeout 30 sudo -u besthammer_c_usr php artisan route:list --compact > /dev/null 2>&1; then
            echo "✓ route:list 命令正常" >> "$REPORT_FILE"
        else
            echo "✗ route:list 命令失败" >> "$REPORT_FILE"
        fi

    else
        log_error "Laravel命令执行失败"
        echo "✗ Laravel命令执行失败" >> "$REPORT_FILE"

        # 尝试获取错误信息
        echo "Laravel命令错误信息:" >> "$REPORT_FILE"
        timeout 30 sudo -u besthammer_c_usr php artisan --version >> "$REPORT_FILE" 2>&1 || echo "命令超时或失败" >> "$REPORT_FILE"
    fi
fi

log_step "第8步：特定500错误URL测试"
echo "-----------------------------------"

log_check "测试具体的500错误URL..."
echo "=== 特定URL错误分析 ===" >> "$REPORT_FILE"

# 测试工具页面
error_urls=(
    "/tools/loan-calculator"
    "/tools/bmi-calculator"
    "/tools/currency-converter"
    "/api/features/status?feature=basic_calculation"
)

for url in "${error_urls[@]}"; do
    echo "测试URL: $url" >> "$REPORT_FILE"

    # 使用curl获取详细错误信息
    response=$(curl -s -w "HTTP_CODE:%{http_code}" "https://www.besthammer.club$url" 2>&1 || echo "CURL_ERROR")

    if echo "$response" | grep -q "CURL_ERROR"; then
        echo "CURL连接错误" >> "$REPORT_FILE"
        log_error "$url: CURL连接失败"
    else
        http_code=$(echo "$response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)

        if [ -z "$http_code" ]; then
            http_code="UNKNOWN"
        fi

        echo "HTTP状态码: $http_code" >> "$REPORT_FILE"

        if [ "$http_code" = "500" ]; then
            log_error "$url: HTTP 500"
            echo "✗ $url: HTTP 500" >> "$REPORT_FILE"

            # 尝试获取错误页面内容
            error_content=$(echo "$response" | sed 's/HTTP_CODE:[0-9]*//g')
            if [ -n "$error_content" ] && [ ${#error_content} -gt 10 ]; then
                echo "错误页面内容（前500字符）:" >> "$REPORT_FILE"
                echo "$error_content" | head -c 500 >> "$REPORT_FILE"
                echo "" >> "$REPORT_FILE"
            fi
        else
            log_success "$url: HTTP $http_code"
            echo "✓ $url: HTTP $http_code" >> "$REPORT_FILE"
        fi
    fi
    echo "---" >> "$REPORT_FILE"
done

log_step "第9步：依赖和类加载检查"
echo "-----------------------------------"

log_check "检查关键类和服务..."
echo "=== 类和服务检查 ===" >> "$REPORT_FILE"

# 检查关键类是否可以加载
critical_classes=(
    "App\\Http\\Controllers\\ToolController"
    "App\\Http\\Controllers\\HomeController"
    "App\\Services\\FeatureService"
    "App\\Models\\User"
)

for class in "${critical_classes[@]}"; do
    echo "检查类: $class" >> "$REPORT_FILE"

    # 创建临时PHP脚本来测试类加载
    temp_script="/tmp/class_test_$$.php"
    cat > "$temp_script" << EOF
<?php
try {
    require_once '$PROJECT_DIR/vendor/autoload.php';
    if (class_exists('$class')) {
        echo 'SUCCESS: Class exists';
        exit(0);
    } else {
        echo 'ERROR: Class not found';
        exit(1);
    }
} catch (Exception \$e) {
    echo 'ERROR: ' . \$e->getMessage();
    exit(1);
} catch (Error \$e) {
    echo 'FATAL: ' . \$e->getMessage();
    exit(1);
}
EOF

    # 运行测试脚本
    if sudo -u besthammer_c_usr php "$temp_script" 2>/dev/null | grep -q "SUCCESS"; then
        log_success "$class: 可以加载"
        echo "✓ $class: 可以加载" >> "$REPORT_FILE"
    else
        log_error "$class: 无法加载"
        echo "✗ $class: 无法加载" >> "$REPORT_FILE"

        # 获取具体错误
        error_msg=$(sudo -u besthammer_c_usr php "$temp_script" 2>&1)
        echo "错误信息: $error_msg" >> "$REPORT_FILE"
    fi

    # 清理临时文件
    rm -f "$temp_script"
done

log_step "第10步：配置文件完整性检查"
echo "-----------------------------------"

log_check "检查配置文件..."
echo "=== 配置文件检查 ===" >> "$REPORT_FILE"

# 检查关键配置文件
config_files=("app.php" "database.php" "features.php")
for config in "${config_files[@]}"; do
    config_file="config/$config"
    if [ -f "$config_file" ]; then
        log_success "$config: 存在"
        echo "✓ $config: 存在" >> "$REPORT_FILE"

        # 检查语法
        if php -l "$config_file" > /dev/null 2>&1; then
            echo "  语法正确" >> "$REPORT_FILE"
        else
            log_error "$config: 语法错误"
            echo "✗ $config: 语法错误" >> "$REPORT_FILE"
            php -l "$config_file" >> "$REPORT_FILE" 2>&1
        fi
    else
        log_warning "$config: 不存在"
        echo "⚠ $config: 不存在" >> "$REPORT_FILE"
    fi
done

log_step "第11步：环境变量和.env文件检查"
echo "-----------------------------------"

log_check "检查环境变量配置..."
echo "=== 环境变量检查 ===" >> "$REPORT_FILE"

if [ -f ".env" ]; then
    log_success ".env文件存在"
    echo "✓ .env文件存在" >> "$REPORT_FILE"

    # 检查关键环境变量
    echo "关键环境变量检查:" >> "$REPORT_FILE"

    env_vars=("APP_ENV" "APP_DEBUG" "APP_KEY" "DB_CONNECTION" "DB_HOST" "DB_DATABASE")
    for var in "${env_vars[@]}"; do
        if grep -q "^${var}=" .env; then
            value=$(grep "^${var}=" .env | cut -d'=' -f2)
            if [ -n "$value" ]; then
                echo "✓ $var: 已设置" >> "$REPORT_FILE"
            else
                echo "⚠ $var: 已定义但为空" >> "$REPORT_FILE"
                log_warning "$var: 已定义但为空"
            fi
        else
            echo "✗ $var: 未设置" >> "$REPORT_FILE"
            log_error "$var: 未设置"
        fi
    done

    # 检查APP_KEY
    if grep -q "^APP_KEY=" .env; then
        app_key=$(grep "^APP_KEY=" .env | cut -d'=' -f2)
        if [ -z "$app_key" ] || [ "$app_key" = "base64:" ]; then
            echo "⚠ APP_KEY未正确生成" >> "$REPORT_FILE"
            log_warning "APP_KEY未正确生成，建议运行: php artisan key:generate"
        else
            echo "✓ APP_KEY已正确设置" >> "$REPORT_FILE"
        fi
    fi

else
    log_error ".env文件不存在"
    echo "✗ .env文件不存在" >> "$REPORT_FILE"
    echo "建议从.env.example复制: cp .env.example .env" >> "$REPORT_FILE"
fi

log_step "第12步：生成诊断总结和建议"
echo "-----------------------------------"

echo "" >> "$REPORT_FILE"
echo "=== 诊断总结和建议 ===" >> "$REPORT_FILE"
echo "诊断完成时间: $(date)" >> "$REPORT_FILE"

# 分析可能的问题原因
echo "" >> "$REPORT_FILE"
echo "可能的500错误原因分析:" >> "$REPORT_FILE"

# 检查是否是类加载问题
temp_test="/tmp/feature_test_$$.php"
cat > "$temp_test" << 'EOF'
<?php
try {
    require_once '/var/www/besthammer_c_usr/data/www/besthammer.club/vendor/autoload.php';
    if (class_exists('App\Services\FeatureService')) {
        exit(0);
    } else {
        exit(1);
    }
} catch (Exception $e) {
    exit(1);
}
EOF

if ! sudo -u besthammer_c_usr php "$temp_test" 2>/dev/null; then
    echo "1. FeatureService类无法加载 - 可能是自动加载问题" >> "$REPORT_FILE"
fi
rm -f "$temp_test"

# 检查是否是配置问题
if [ ! -f "config/features.php" ]; then
    echo "2. features.php配置文件缺失" >> "$REPORT_FILE"
fi

# 检查是否是权限问题
if [ ! -w "storage" ]; then
    echo "3. storage目录权限问题" >> "$REPORT_FILE"
fi

# 检查是否是语法错误
if ! php -l routes/web.php > /dev/null 2>&1; then
    echo "4. 路由文件语法错误" >> "$REPORT_FILE"
fi

# 检查是否是APP_KEY问题
if [ -f ".env" ]; then
    app_key=$(grep "^APP_KEY=" .env | cut -d'=' -f2 2>/dev/null)
    if [ -z "$app_key" ] || [ "$app_key" = "base64:" ]; then
        echo "5. APP_KEY未正确设置" >> "$REPORT_FILE"
    fi
fi

# 检查是否是FeatureService相关问题
if grep -q "FeatureService" storage/logs/laravel.log 2>/dev/null; then
    echo "6. FeatureService相关错误（检查日志）" >> "$REPORT_FILE"
fi

echo ""
echo "🔍 诊断完成！"
echo "============"
echo ""
echo "📋 诊断报告已生成: $REPORT_FILE"
echo ""
echo "🚨 发现的主要问题："

# 快速问题检查
issues_found=0

# 检查FeatureService
temp_check="/tmp/quick_check_$$.php"
cat > "$temp_check" << 'EOF'
<?php
try {
    require_once '/var/www/besthammer_c_usr/data/www/besthammer.club/vendor/autoload.php';
    if (class_exists('App\Services\FeatureService')) {
        exit(0);
    } else {
        exit(1);
    }
} catch (Exception $e) {
    exit(1);
}
EOF

if ! sudo -u besthammer_c_usr php "$temp_check" 2>/dev/null; then
    echo "❌ FeatureService类无法加载"
    ((issues_found++))
fi
rm -f "$temp_check"

# 检查配置文件
if [ ! -f "config/features.php" ]; then
    echo "❌ features.php配置文件缺失"
    ((issues_found++))
fi

# 检查路由语法
if ! php -l routes/web.php > /dev/null 2>&1; then
    echo "❌ 路由文件语法错误"
    ((issues_found++))
fi

# 检查权限
if [ ! -w "storage" ]; then
    echo "❌ storage目录权限问题"
    ((issues_found++))
fi

# 检查Laravel命令
if ! sudo -u besthammer_c_usr php artisan --version > /dev/null 2>&1; then
    echo "❌ Laravel命令执行失败"
    ((issues_found++))
fi

echo ""
echo "📊 问题统计: 发现 $issues_found 个主要问题"

echo ""
echo "🔧 建议的修复步骤："
echo "1. 查看完整诊断报告: cat $REPORT_FILE"
echo "2. 检查Laravel错误日志: tail -50 storage/logs/laravel.log"
echo "3. 检查Apache错误日志: tail -20 /var/log/apache2/error.log"
echo "4. 清理所有缓存: php artisan cache:clear && php artisan config:clear && php artisan route:clear"
echo "5. 重新生成自动加载: composer dump-autoload"
echo "6. 检查文件权限: chown -R besthammer_c_usr:besthammer_c_usr storage bootstrap/cache"
echo "7. 如果APP_KEY为空: php artisan key:generate"
echo "8. 如果FeatureService错误: 检查config/features.php是否存在且语法正确"

if [ $issues_found -gt 0 ]; then
    echo ""
    echo "⚠️ 建议运行修复脚本解决发现的问题"
else
    echo ""
    echo "✅ 未发现明显的配置问题，可能是临时性错误"
fi

echo ""
log_info "深度诊断脚本执行完成！"
