#!/bin/bash

# 3个主体功能综合性诊断脚本
# 深度分析前端、后端、API、路由、Service等所有环节

echo "🔍 3个主体功能综合性诊断"
echo "======================"
echo "诊断范围："
echo "1. 前端页面访问和JavaScript功能"
echo "2. API路由和控制器响应"
echo "3. Service类方法和计算逻辑"
echo "4. 数据库连接和配置"
echo "5. CSRF令牌和安全设置"
echo "6. Laravel错误日志分析"
echo "7. 实际计算功能测试"
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
fi

# 创建诊断报告文件
REPORT_FILE="comprehensive_diagnosis_$(date +%Y%m%d_%H%M%S).txt"
echo "3个主体功能综合性诊断报告 - $(date)" > "$REPORT_FILE"
echo "==============================" >> "$REPORT_FILE"

log_step "第1步：前端页面访问诊断"
echo "-----------------------------------"

log_check "检查工具页面HTTP状态..."
echo "=== 前端页面访问诊断 ===" >> "$REPORT_FILE"

tool_pages=(
    "/tools/loan-calculator"
    "/tools/bmi-calculator"
    "/tools/currency-converter"
)

for page in "${tool_pages[@]}"; do
    echo "测试页面: $page" >> "$REPORT_FILE"
    
    # 测试HTTP状态
    response=$(curl -s -w "HTTP_CODE:%{http_code}|SIZE:%{size_download}|TIME:%{time_total}" "https://www.besthammer.club$page" 2>/dev/null || echo "CURL_ERROR")
    
    if echo "$response" | grep -q "HTTP_CODE:200"; then
        log_success "$page: 页面正常访问"
        echo "✓ $page: 页面正常访问" >> "$REPORT_FILE"
        
        # 检查页面内容
        page_content=$(echo "$response" | sed 's/HTTP_CODE:[^|]*|SIZE:[^|]*|TIME:[^|]*//g')
        
        # 检查关键元素
        if echo "$page_content" | grep -q "csrf-token\|_token"; then
            echo "  ✓ 包含CSRF令牌" >> "$REPORT_FILE"
        else
            log_warning "$page: 缺少CSRF令牌"
            echo "  ⚠ 缺少CSRF令牌" >> "$REPORT_FILE"
        fi
        
        if echo "$page_content" | grep -q "calculate\|convert"; then
            echo "  ✓ 包含计算按钮" >> "$REPORT_FILE"
        else
            log_warning "$page: 缺少计算按钮"
            echo "  ⚠ 缺少计算按钮" >> "$REPORT_FILE"
        fi
        
        if echo "$page_content" | grep -q "script\|javascript"; then
            echo "  ✓ 包含JavaScript代码" >> "$REPORT_FILE"
        else
            log_warning "$page: 缺少JavaScript代码"
            echo "  ⚠ 缺少JavaScript代码" >> "$REPORT_FILE"
        fi
        
    else
        http_code=$(echo "$response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
        log_error "$page: HTTP $http_code"
        echo "✗ $page: HTTP $http_code" >> "$REPORT_FILE"
    fi
    echo "---" >> "$REPORT_FILE"
done

log_step "第2步：API路由诊断"
echo "-----------------------------------"

log_check "检查API路由配置..."
echo "=== API路由诊断 ===" >> "$REPORT_FILE"

# 检查路由文件
if [ -f "routes/web.php" ]; then
    echo "✓ routes/web.php 存在" >> "$REPORT_FILE"
    
    # 检查关键路由
    if grep -q "loan.*calculate\|calculateLoan" routes/web.php; then
        echo "  ✓ 贷款计算路由存在" >> "$REPORT_FILE"
        log_success "贷款计算路由已配置"
    else
        echo "  ✗ 贷款计算路由缺失" >> "$REPORT_FILE"
        log_error "贷款计算路由缺失"
    fi
    
    if grep -q "bmi.*calculate\|calculateBmi" routes/web.php; then
        echo "  ✓ BMI计算路由存在" >> "$REPORT_FILE"
        log_success "BMI计算路由已配置"
    else
        echo "  ✗ BMI计算路由缺失" >> "$REPORT_FILE"
        log_error "BMI计算路由缺失"
    fi
    
    if grep -q "currency.*convert\|convertCurrency" routes/web.php; then
        echo "  ✓ 汇率转换路由存在" >> "$REPORT_FILE"
        log_success "汇率转换路由已配置"
    else
        echo "  ✗ 汇率转换路由缺失" >> "$REPORT_FILE"
        log_error "汇率转换路由缺失"
    fi
    
else
    echo "✗ routes/web.php 不存在" >> "$REPORT_FILE"
    log_error "routes/web.php 文件不存在"
fi

# 测试API端点
log_check "测试API端点响应..."

api_endpoints=(
    "/tools/loan-calculator"
    "/tools/bmi-calculator" 
    "/tools/currency-converter"
)

for endpoint in "${api_endpoints[@]}"; do
    echo "测试API: POST $endpoint" >> "$REPORT_FILE"
    
    # 获取CSRF令牌
    csrf_token=$(curl -s "https://www.besthammer.club$endpoint" | grep -o 'csrf-token.*content="[^"]*"' | grep -o 'content="[^"]*"' | cut -d'"' -f2)
    
    if [ -n "$csrf_token" ]; then
        echo "  ✓ CSRF令牌获取成功: ${csrf_token:0:10}..." >> "$REPORT_FILE"
        
        # 测试POST请求
        case "$endpoint" in
            "/tools/loan-calculator")
                test_data='{"amount":100000,"rate":5.0,"years":30,"type":"equal_payment"}'
                ;;
            "/tools/bmi-calculator")
                test_data='{"weight":70,"height":175,"unit":"metric"}'
                ;;
            "/tools/currency-converter")
                test_data='{"amount":100,"from":"USD","to":"EUR"}'
                ;;
        esac
        
        api_response=$(curl -s -X POST "https://www.besthammer.club$endpoint" \
            -H "Content-Type: application/json" \
            -H "X-CSRF-TOKEN: $csrf_token" \
            -H "X-Requested-With: XMLHttpRequest" \
            -d "$test_data" \
            -w "HTTP_CODE:%{http_code}" 2>/dev/null || echo "CURL_ERROR")
        
        if echo "$api_response" | grep -q "HTTP_CODE:200"; then
            log_success "$endpoint: API响应正常"
            echo "  ✓ API响应正常 (HTTP 200)" >> "$REPORT_FILE"
            
            # 检查响应内容
            response_content=$(echo "$api_response" | sed 's/HTTP_CODE:[0-9]*//g')
            if echo "$response_content" | grep -q '"success".*true'; then
                echo "    ✓ 返回成功结果" >> "$REPORT_FILE"
            elif echo "$response_content" | grep -q '"success".*false'; then
                echo "    ⚠ 返回失败结果" >> "$REPORT_FILE"
                echo "    错误信息: $(echo "$response_content" | grep -o '"message":"[^"]*"')" >> "$REPORT_FILE"
            else
                echo "    ⚠ 响应格式异常" >> "$REPORT_FILE"
            fi
            
        else
            http_code=$(echo "$api_response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
            log_error "$endpoint: API异常 (HTTP $http_code)"
            echo "  ✗ API异常 (HTTP $http_code)" >> "$REPORT_FILE"
            
            # 记录错误响应内容
            error_content=$(echo "$api_response" | sed 's/HTTP_CODE:[0-9]*//g')
            if [ -n "$error_content" ]; then
                echo "    错误内容: $error_content" >> "$REPORT_FILE"
            fi
        fi
        
    else
        echo "  ✗ CSRF令牌获取失败" >> "$REPORT_FILE"
        log_error "$endpoint: CSRF令牌获取失败"
    fi
    echo "---" >> "$REPORT_FILE"
done

log_step "第3步：控制器和Service类诊断"
echo "-----------------------------------"

log_check "检查控制器文件..."
echo "=== 控制器和Service类诊断 ===" >> "$REPORT_FILE"

# 检查ToolController
if [ -f "app/Http/Controllers/ToolController.php" ]; then
    echo "✓ ToolController存在" >> "$REPORT_FILE"
    log_success "ToolController文件存在"
    
    # 检查语法
    if php -l app/Http/Controllers/ToolController.php > /dev/null 2>&1; then
        echo "  ✓ 语法正确" >> "$REPORT_FILE"
        log_success "ToolController语法正确"
    else
        echo "  ✗ 语法错误" >> "$REPORT_FILE"
        log_error "ToolController语法错误"
        php -l app/Http/Controllers/ToolController.php >> "$REPORT_FILE" 2>&1
    fi
    
    # 检查方法
    if grep -q "calculateLoan\|function.*loan" app/Http/Controllers/ToolController.php; then
        echo "  ✓ 包含贷款计算方法" >> "$REPORT_FILE"
    else
        echo "  ✗ 缺少贷款计算方法" >> "$REPORT_FILE"
        log_error "ToolController缺少贷款计算方法"
    fi
    
    if grep -q "calculateBmi\|function.*bmi" app/Http/Controllers/ToolController.php; then
        echo "  ✓ 包含BMI计算方法" >> "$REPORT_FILE"
    else
        echo "  ✗ 缺少BMI计算方法" >> "$REPORT_FILE"
        log_error "ToolController缺少BMI计算方法"
    fi
    
    if grep -q "convertCurrency\|function.*currency" app/Http/Controllers/ToolController.php; then
        echo "  ✓ 包含汇率转换方法" >> "$REPORT_FILE"
    else
        echo "  ✗ 缺少汇率转换方法" >> "$REPORT_FILE"
        log_error "ToolController缺少汇率转换方法"
    fi
    
else
    echo "✗ ToolController不存在" >> "$REPORT_FILE"
    log_error "ToolController文件不存在"
fi

# 检查Service类
services=("LoanCalculatorService" "BMICalculatorService" "CurrencyConverterService")
for service in "${services[@]}"; do
    service_file="app/Services/${service}.php"
    echo "检查 $service:" >> "$REPORT_FILE"
    
    if [ -f "$service_file" ]; then
        echo "  ✓ 文件存在" >> "$REPORT_FILE"
        
        # 检查语法
        if php -l "$service_file" > /dev/null 2>&1; then
            echo "    ✓ 语法正确" >> "$REPORT_FILE"
        else
            echo "    ✗ 语法错误" >> "$REPORT_FILE"
            php -l "$service_file" >> "$REPORT_FILE" 2>&1
        fi
        
        # 检查calculate方法
        if grep -q "function calculate\|public static function calculate" "$service_file"; then
            echo "    ✓ 包含calculate方法" >> "$REPORT_FILE"
        else
            echo "    ✗ 缺少calculate方法" >> "$REPORT_FILE"
            log_error "$service: 缺少calculate方法"
        fi
        
    else
        echo "  ✗ 文件不存在" >> "$REPORT_FILE"
        log_error "$service: 文件不存在"
    fi
done

log_step "第4步：实际计算功能测试"
echo "-----------------------------------"

log_check "测试Service类计算功能..."
echo "=== 实际计算功能测试 ===" >> "$REPORT_FILE"

# 创建测试PHP脚本
cat > test_calculations.php << 'TESTEOF'
<?php
require_once 'vendor/autoload.php';

echo "=== 贷款计算测试 ===\n";
try {
    if (class_exists('App\Services\LoanCalculatorService')) {
        $result = App\Services\LoanCalculatorService::calculate(100000, 5.0, 30, 'equal_payment');
        if (isset($result['success']) && $result['success']) {
            echo "SUCCESS: 贷款计算正常\n";
            echo "月供: " . $result['data']['monthly_payment'] . "\n";
            echo "总利息: " . $result['data']['total_interest'] . "\n";
        } else {
            echo "FAILED: " . ($result['message'] ?? 'Unknown error') . "\n";
        }
    } else {
        echo "ERROR: LoanCalculatorService类不存在\n";
    }
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}

echo "\n=== BMI计算测试 ===\n";
try {
    if (class_exists('App\Services\BMICalculatorService')) {
        $result = App\Services\BMICalculatorService::calculate(70, 175, 'metric');
        if (isset($result['success']) && $result['success']) {
            echo "SUCCESS: BMI计算正常\n";
            echo "BMI值: " . $result['data']['bmi'] . "\n";
            echo "分类: " . $result['data']['category']['name'] . "\n";
        } else {
            echo "FAILED: " . ($result['message'] ?? 'Unknown error') . "\n";
        }
    } else {
        echo "ERROR: BMICalculatorService类不存在\n";
    }
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}

echo "\n=== 汇率转换测试 ===\n";
try {
    if (class_exists('App\Services\CurrencyConverterService')) {
        $result = App\Services\CurrencyConverterService::calculate(100, 'USD', 'EUR');
        if (isset($result['success']) && $result['success']) {
            echo "SUCCESS: 汇率转换正常\n";
            echo "转换金额: " . $result['data']['converted_amount'] . "\n";
            echo "汇率: " . $result['data']['exchange_rate'] . "\n";
        } else {
            echo "FAILED: " . ($result['message'] ?? 'Unknown error') . "\n";
        }
    } else {
        echo "ERROR: CurrencyConverterService类不存在\n";
    }
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
TESTEOF

# 运行测试
test_output=$(sudo -u besthammer_c_usr php test_calculations.php 2>&1)
echo "$test_output" >> "$REPORT_FILE"

# 分析测试结果
if echo "$test_output" | grep -q "SUCCESS.*贷款计算正常"; then
    log_success "贷款计算功能正常"
else
    log_error "贷款计算功能异常"
fi

if echo "$test_output" | grep -q "SUCCESS.*BMI计算正常"; then
    log_success "BMI计算功能正常"
else
    log_error "BMI计算功能异常"
fi

if echo "$test_output" | grep -q "SUCCESS.*汇率转换正常"; then
    log_success "汇率转换功能正常"
else
    log_error "汇率转换功能异常"
fi

# 清理测试文件
rm -f test_calculations.php

log_step "第5步：Laravel错误日志分析"
echo "-----------------------------------"

log_check "分析Laravel错误日志..."
echo "=== Laravel错误日志分析 ===" >> "$REPORT_FILE"

if [ -f "storage/logs/laravel.log" ]; then
    echo "✓ Laravel日志文件存在" >> "$REPORT_FILE"

    # 获取最近的错误
    recent_errors=$(tail -50 storage/logs/laravel.log | grep -i "error\|exception\|fatal" | tail -10)

    if [ -n "$recent_errors" ]; then
        echo "最近的错误信息:" >> "$REPORT_FILE"
        echo "$recent_errors" >> "$REPORT_FILE"
        log_warning "发现Laravel错误，详见报告"
    else
        echo "✓ 没有发现最近的错误" >> "$REPORT_FILE"
        log_success "Laravel日志正常"
    fi
else
    echo "✗ Laravel日志文件不存在" >> "$REPORT_FILE"
    log_warning "Laravel日志文件不存在"
fi

log_step "第6步：配置和环境检查"
echo "-----------------------------------"

log_check "检查Laravel配置..."
echo "=== 配置和环境检查 ===" >> "$REPORT_FILE"

# 检查.env文件
if [ -f ".env" ]; then
    echo "✓ .env文件存在" >> "$REPORT_FILE"

    # 检查关键配置
    if grep -q "APP_DEBUG=true" .env; then
        echo "  ✓ 调试模式已启用" >> "$REPORT_FILE"
    else
        echo "  ⚠ 调试模式未启用" >> "$REPORT_FILE"
    fi

    if grep -q "APP_ENV=local\|APP_ENV=development" .env; then
        echo "  ✓ 开发环境配置" >> "$REPORT_FILE"
    else
        echo "  ⚠ 生产环境配置" >> "$REPORT_FILE"
    fi

else
    echo "✗ .env文件不存在" >> "$REPORT_FILE"
    log_error ".env文件不存在"
fi

# 检查Composer自动加载
log_check "检查Composer自动加载..."
if [ -f "vendor/autoload.php" ]; then
    echo "✓ Composer自动加载文件存在" >> "$REPORT_FILE"
    log_success "Composer自动加载正常"
else
    echo "✗ Composer自动加载文件不存在" >> "$REPORT_FILE"
    log_error "Composer自动加载文件不存在"
fi

# 检查缓存状态
log_check "检查Laravel缓存状态..."
cache_status=$(sudo -u besthammer_c_usr php artisan config:show 2>&1 | head -5)
if echo "$cache_status" | grep -q "Configuration"; then
    echo "✓ Laravel配置缓存正常" >> "$REPORT_FILE"
    log_success "Laravel配置正常"
else
    echo "⚠ Laravel配置可能有问题" >> "$REPORT_FILE"
    echo "配置状态: $cache_status" >> "$REPORT_FILE"
    log_warning "Laravel配置可能有问题"
fi

log_step "第7步：生成诊断总结"
echo "-----------------------------------"

echo "" >> "$REPORT_FILE"
echo "=== 诊断总结 ===" >> "$REPORT_FILE"
echo "诊断完成时间: $(date)" >> "$REPORT_FILE"

# 统计问题
echo "" >> "$REPORT_FILE"
echo "发现的问题统计:" >> "$REPORT_FILE"

issues_count=0

# 检查关键文件
critical_files=(
    "app/Http/Controllers/ToolController.php"
    "app/Services/LoanCalculatorService.php"
    "app/Services/BMICalculatorService.php"
    "app/Services/CurrencyConverterService.php"
    "routes/web.php"
    ".env"
    "vendor/autoload.php"
)

for file in "${critical_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "- 关键文件缺失: $file" >> "$REPORT_FILE"
        ((issues_count++))
    fi
done

echo "" >> "$REPORT_FILE"
echo "总计发现 $issues_count 个关键问题" >> "$REPORT_FILE"

echo ""
echo "🔍 综合性诊断完成！"
echo "=================="
echo ""
echo "📋 诊断报告已生成: $REPORT_FILE"
echo ""
echo "📊 快速问题统计："

# 快速检查关键问题
missing_files=0
syntax_errors=0
api_errors=0

# 检查文件
for file in "${critical_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ 缺失: $file"
        ((missing_files++))
    else
        if [[ "$file" == *.php ]]; then
            if ! php -l "$file" > /dev/null 2>&1; then
                echo "❌ 语法错误: $file"
                ((syntax_errors++))
            else
                echo "✅ 正常: $file"
            fi
        else
            echo "✅ 存在: $file"
        fi
    fi
done

echo ""
echo "📈 问题统计："
echo "   缺失文件: $missing_files"
echo "   语法错误: $syntax_errors"
echo "   总计问题: $((missing_files + syntax_errors))"

echo ""
echo "🔧 建议的修复步骤："
echo "1. 查看完整诊断报告: cat $REPORT_FILE"
echo "2. 检查Laravel错误日志: tail -20 storage/logs/laravel.log"
echo "3. 检查Apache错误日志: tail -10 /var/log/apache2/error.log"
echo "4. 根据诊断结果运行相应的修复脚本"

if [ $((missing_files + syntax_errors)) -gt 0 ]; then
    echo ""
    echo "⚠️ 发现关键问题，需要立即修复"
else
    echo ""
    echo "✅ 基础文件检查正常，问题可能在配置或逻辑层面"
fi

echo ""
log_info "综合性诊断脚本执行完成！"
