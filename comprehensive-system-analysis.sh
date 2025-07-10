#!/bin/bash

# 网站全面环境和系统文件状态分析脚本
# 诊断500错误和系统问题

echo "🔍 BestHammer网站全面系统分析"
echo "============================="
echo "分析内容："
echo "1. 服务器环境状态"
echo "2. Laravel应用状态"
echo "3. 文件权限检查"
echo "4. 数据库连接测试"
echo "5. 错误日志分析"
echo "6. 配置文件验证"
echo "7. 依赖关系检查"
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

log_detail() {
    echo -e "${CYAN}[DETAIL]${NC} $1"
}

# 创建分析报告文件
REPORT_FILE="/tmp/besthammer_analysis_$(date +%Y%m%d_%H%M%S).txt"
exec > >(tee -a "$REPORT_FILE")
exec 2>&1

PROJECT_DIR="/var/www/besthammer_c_usr/data/www/besthammer.club"

echo "分析报告生成时间: $(date)"
echo "项目目录: $PROJECT_DIR"
echo "报告文件: $REPORT_FILE"
echo ""

log_step "第1步：服务器环境状态检查"
echo "========================================="

# 系统信息
log_info "系统信息："
echo "操作系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"')"
echo "内核版本: $(uname -r)"
echo "系统负载: $(uptime | awk -F'load average:' '{print $2}')"
echo "内存使用: $(free -h | grep Mem | awk '{print $3"/"$2" ("$3/$2*100"%)"}')"
echo "磁盘使用: $(df -h / | tail -1 | awk '{print $3"/"$2" ("$5")"}')"
echo ""

# 服务状态检查
log_info "关键服务状态："
services=("apache2" "mysql" "php8.3-fpm")
for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        log_success "$service: 运行中"
    else
        log_error "$service: 未运行"
        systemctl status "$service" --no-pager -l
    fi
done
echo ""

# PHP版本和模块
log_info "PHP环境："
echo "PHP版本: $(php -v | head -1)"
echo "PHP配置文件: $(php --ini | grep "Loaded Configuration File" | cut -d: -f2 | xargs)"
echo "PHP扩展检查："
required_extensions=("pdo" "pdo_mysql" "mbstring" "openssl" "tokenizer" "xml" "ctype" "json" "bcmath")
for ext in "${required_extensions[@]}"; do
    if php -m | grep -q "^$ext$"; then
        log_success "  $ext: 已安装"
    else
        log_error "  $ext: 未安装"
    fi
done
echo ""

log_step "第2步：Laravel应用状态检查"
echo "========================================="

cd "$PROJECT_DIR" || {
    log_error "无法进入项目目录: $PROJECT_DIR"
    exit 1
}

# 检查Laravel基本文件
log_info "Laravel核心文件检查："
core_files=("artisan" "composer.json" ".env" "app/Http/Kernel.php" "config/app.php" "routes/web.php")
for file in "${core_files[@]}"; do
    if [ -f "$file" ]; then
        log_success "  $file: 存在"
    else
        log_error "  $file: 缺失"
    fi
done
echo ""

# 检查.env文件内容
log_info ".env文件配置："
if [ -f ".env" ]; then
    echo "APP_ENV=$(grep "^APP_ENV=" .env | cut -d'=' -f2 || echo "未设置")"
    echo "APP_DEBUG=$(grep "^APP_DEBUG=" .env | cut -d'=' -f2 || echo "未设置")"
    echo "APP_KEY=$(grep "^APP_KEY=" .env | cut -d'=' -f2 | head -c 20)..."
    echo "DB_CONNECTION=$(grep "^DB_CONNECTION=" .env | cut -d'=' -f2 || echo "未设置")"
    echo "DB_DATABASE=$(grep "^DB_DATABASE=" .env | cut -d'=' -f2 || echo "未设置")"
    echo "DB_USERNAME=$(grep "^DB_USERNAME=" .env | cut -d'=' -f2 || echo "未设置")"
    echo "CACHE_DRIVER=$(grep "^CACHE_DRIVER=" .env | cut -d'=' -f2 || echo "未设置")"
    echo "SESSION_DRIVER=$(grep "^SESSION_DRIVER=" .env | cut -d'=' -f2 || echo "未设置")"
else
    log_error ".env文件不存在"
fi
echo ""

# Laravel命令测试
log_info "Laravel命令测试："
if sudo -u besthammer_c_usr php artisan --version 2>/dev/null; then
    log_success "artisan命令正常"
else
    log_error "artisan命令失败"
    sudo -u besthammer_c_usr php artisan --version
fi
echo ""

log_step "第3步：文件权限和所有权检查"
echo "========================================="

log_info "关键目录权限检查："
critical_dirs=("storage" "bootstrap/cache" "config" "app" "resources" "routes")
for dir in "${critical_dirs[@]}"; do
    if [ -d "$dir" ]; then
        perms=$(stat -c "%a" "$dir")
        owner=$(stat -c "%U:%G" "$dir")
        log_detail "  $dir: 权限=$perms, 所有者=$owner"
        
        # 检查是否可写
        if [ -w "$dir" ]; then
            log_success "    可写: 是"
        else
            log_warning "    可写: 否"
        fi
    else
        log_error "  $dir: 目录不存在"
    fi
done
echo ""

# 检查storage目录结构
log_info "storage目录结构："
if [ -d "storage" ]; then
    find storage -type d | head -20 | while read dir; do
        perms=$(stat -c "%a" "$dir")
        owner=$(stat -c "%U:%G" "$dir")
        echo "  $dir: $perms $owner"
    done
else
    log_error "storage目录不存在"
fi
echo ""

log_step "第4步：数据库连接测试"
echo "========================================="

if [ -f ".env" ]; then
    DB_HOST=$(grep "^DB_HOST=" .env | cut -d'=' -f2)
    DB_PORT=$(grep "^DB_PORT=" .env | cut -d'=' -f2)
    DB_DATABASE=$(grep "^DB_DATABASE=" .env | cut -d'=' -f2)
    DB_USERNAME=$(grep "^DB_USERNAME=" .env | cut -d'=' -f2)
    
    log_info "数据库配置："
    echo "  主机: $DB_HOST"
    echo "  端口: $DB_PORT"
    echo "  数据库: $DB_DATABASE"
    echo "  用户名: $DB_USERNAME"
    
    # 测试MySQL服务
    if systemctl is-active --quiet mysql; then
        log_success "MySQL服务运行中"
        
        # 测试数据库连接（不需要密码的测试）
        if mysql -u "$DB_USERNAME" -e "SELECT 1;" 2>/dev/null; then
            log_success "数据库连接正常（无密码）"
        else
            log_warning "数据库连接需要密码或权限不足"
        fi
        
        # 检查数据库是否存在
        if mysql -u "$DB_USERNAME" -e "USE $DB_DATABASE; SELECT 1;" 2>/dev/null; then
            log_success "数据库 $DB_DATABASE 存在且可访问"
            
            # 检查表结构
            echo "  数据库表："
            mysql -u "$DB_USERNAME" -e "USE $DB_DATABASE; SHOW TABLES;" 2>/dev/null | tail -n +2 | while read table; do
                echo "    - $table"
            done
        else
            log_error "数据库 $DB_DATABASE 不存在或无法访问"
        fi
    else
        log_error "MySQL服务未运行"
    fi
else
    log_error "无法读取数据库配置"
fi
echo ""

log_step "第5步：错误日志分析"
echo "========================================="

# Laravel日志
log_info "Laravel错误日志："
if [ -d "storage/logs" ]; then
    latest_log=$(ls -t storage/logs/*.log 2>/dev/null | head -1)
    if [ -n "$latest_log" ]; then
        echo "最新日志文件: $latest_log"
        echo "最近10条错误："
        tail -20 "$latest_log" | grep -i "error\|exception\|fatal" | tail -10
    else
        log_warning "没有找到Laravel日志文件"
    fi
else
    log_error "storage/logs目录不存在"
fi
echo ""

# Apache错误日志
log_info "Apache错误日志："
apache_error_log="/var/log/apache2/error.log"
if [ -f "$apache_error_log" ]; then
    echo "最近10条Apache错误："
    tail -20 "$apache_error_log" | grep -i "error\|fatal" | tail -10
else
    log_warning "Apache错误日志不存在或无权限访问"
fi
echo ""

# PHP错误日志
log_info "PHP错误日志："
php_error_log=$(php -i | grep "error_log" | grep -v "no value" | head -1 | cut -d'=' -f2 | xargs)
if [ -n "$php_error_log" ] && [ -f "$php_error_log" ]; then
    echo "PHP错误日志位置: $php_error_log"
    echo "最近5条PHP错误："
    tail -10 "$php_error_log" | tail -5
else
    log_warning "PHP错误日志未配置或不存在"
fi
echo ""

log_step "第6步：配置文件验证"
echo "========================================="

# 检查Apache虚拟主机配置
log_info "Apache虚拟主机配置："
vhost_files=$(find /etc/apache2/sites-enabled/ -name "*besthammer*" -o -name "*club*" 2>/dev/null)
if [ -n "$vhost_files" ]; then
    echo "找到虚拟主机配置文件:"
    echo "$vhost_files"
    for file in $vhost_files; do
        echo "配置文件: $file"
        grep -E "(DocumentRoot|ServerName|Directory)" "$file" | head -10
    done
else
    log_warning "未找到besthammer相关的虚拟主机配置"
fi
echo ""

# 检查PHP配置
log_info "PHP关键配置："
echo "memory_limit: $(php -i | grep "memory_limit" | head -1 | cut -d'=' -f2 | xargs)"
echo "max_execution_time: $(php -i | grep "max_execution_time" | head -1 | cut -d'=' -f2 | xargs)"
echo "upload_max_filesize: $(php -i | grep "upload_max_filesize" | head -1 | cut -d'=' -f2 | xargs)"
echo "post_max_size: $(php -i | grep "post_max_size" | head -1 | cut -d'=' -f2 | xargs)"
echo "display_errors: $(php -i | grep "display_errors" | head -1 | cut -d'=' -f2 | xargs)"
echo ""

log_step "第7步：依赖关系和Composer检查"
echo "========================================="

# Composer检查
log_info "Composer状态："
if command -v composer &> /dev/null; then
    echo "Composer版本: $(composer --version)"
    
    if [ -f "composer.json" ]; then
        log_success "composer.json存在"
        
        if [ -f "composer.lock" ]; then
            log_success "composer.lock存在"
        else
            log_warning "composer.lock不存在"
        fi
        
        if [ -d "vendor" ]; then
            log_success "vendor目录存在"
            echo "vendor目录大小: $(du -sh vendor | cut -f1)"
        else
            log_error "vendor目录不存在"
        fi
    else
        log_error "composer.json不存在"
    fi
else
    log_error "Composer未安装"
fi
echo ""

log_step "第8步：网站访问测试"
echo "========================================="

# 测试不同URL
log_info "网站访问测试："
urls=("https://www.besthammer.club" "https://www.besthammer.club/health" "https://www.besthammer.club/tools/loan-calculator")

for url in "${urls[@]}"; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    if [ "$response" = "200" ]; then
        log_success "$url: HTTP $response"
    else
        log_error "$url: HTTP $response"
        
        # 获取详细错误信息
        error_detail=$(curl -s "$url" 2>&1 | head -5)
        if [ -n "$error_detail" ]; then
            echo "  错误详情: $error_detail"
        fi
    fi
done
echo ""

log_step "第9步：问题诊断和建议"
echo "========================================="

log_info "问题诊断总结："

# 检查常见500错误原因
issues_found=0

# 1. 检查.env文件
if [ ! -f ".env" ]; then
    log_error "问题1: .env文件缺失"
    echo "  解决方案: 复制.env.example为.env并配置"
    ((issues_found++))
fi

# 2. 检查APP_KEY
if [ -f ".env" ]; then
    app_key=$(grep "^APP_KEY=" .env | cut -d'=' -f2)
    if [ -z "$app_key" ] || [ "$app_key" = "base64:" ]; then
        log_error "问题2: APP_KEY未设置"
        echo "  解决方案: 运行 php artisan key:generate"
        ((issues_found++))
    fi
fi

# 3. 检查storage权限
if [ ! -w "storage" ]; then
    log_error "问题3: storage目录不可写"
    echo "  解决方案: chown -R besthammer_c_usr:besthammer_c_usr storage && chmod -R 755 storage"
    ((issues_found++))
fi

# 4. 检查vendor目录
if [ ! -d "vendor" ]; then
    log_error "问题4: vendor目录缺失"
    echo "  解决方案: 运行 composer install"
    ((issues_found++))
fi

# 5. 检查配置缓存
if sudo -u besthammer_c_usr php artisan config:cache 2>&1 | grep -q "error\|Error\|ERROR"; then
    log_error "问题5: 配置缓存失败"
    echo "  解决方案: 检查配置文件语法错误"
    ((issues_found++))
fi

if [ $issues_found -eq 0 ]; then
    log_success "未发现明显的配置问题"
    echo "建议检查:"
    echo "1. 最新的Laravel日志文件"
    echo "2. Apache错误日志"
    echo "3. PHP错误日志"
    echo "4. 数据库连接配置"
else
    log_warning "发现 $issues_found 个潜在问题，请按建议解决"
fi

echo ""
echo "🎯 分析完成！"
echo "============="
echo "完整报告已保存到: $REPORT_FILE"
echo "请根据上述分析结果解决发现的问题"
echo ""
echo "快速修复命令："
echo "1. 修复权限: chown -R besthammer_c_usr:besthammer_c_usr $PROJECT_DIR && chmod -R 755 $PROJECT_DIR/storage"
echo "2. 清理缓存: cd $PROJECT_DIR && php artisan config:clear && php artisan cache:clear"
echo "3. 重新安装依赖: cd $PROJECT_DIR && composer install"
echo "4. 生成APP_KEY: cd $PROJECT_DIR && php artisan key:generate"
echo ""
