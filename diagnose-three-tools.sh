#!/bin/bash

# 3个主体功能专项诊断脚本
# 针对贷款计算器、BMI计算器、汇率转换器进行全面诊断

echo "🔧 3个主体功能专项诊断"
echo "======================"
echo "诊断范围："
echo "1. 贷款计算器 (Loan Calculator) - 等额本息、等额本金算法"
echo "2. BMI计算器 (BMI Calculator) - BMI、BMR、健康分析算法"
echo "3. 汇率转换器 (Currency Converter) - 实时汇率、多货币支持"
echo "4. 前端JavaScript功能测试"
echo "5. 后端API接口测试"
echo "6. 数据验证和错误处理"
echo "7. 多语言功能测试"
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
REPORT_FILE="tools_diagnosis_$(date +%Y%m%d_%H%M%S).txt"
echo "3个主体功能专项诊断报告 - $(date)" > "$REPORT_FILE"
echo "==============================" >> "$REPORT_FILE"

log_step "第1步：贷款计算器功能诊断"
echo "-----------------------------------"

log_check "检查贷款计算器组件..."
echo "=== 贷款计算器诊断 ===" >> "$REPORT_FILE"

# 检查LoanCalculatorService
if [ -f "app/Services/LoanCalculatorService.php" ]; then
    log_success "LoanCalculatorService存在"
    echo "✓ LoanCalculatorService存在" >> "$REPORT_FILE"
    
    # 检查语法
    if php -l app/Services/LoanCalculatorService.php > /dev/null 2>&1; then
        echo "  语法正确" >> "$REPORT_FILE"
        log_success "LoanCalculatorService语法正确"
    else
        log_error "LoanCalculatorService语法错误"
        echo "✗ LoanCalculatorService语法错误" >> "$REPORT_FILE"
        php -l app/Services/LoanCalculatorService.php >> "$REPORT_FILE" 2>&1
    fi
    
    # 测试类加载
    if sudo -u besthammer_c_usr php -r "
        require_once 'vendor/autoload.php';
        try {
            \$service = new App\Services\LoanCalculatorService();
            echo 'SUCCESS: Class loaded';
        } catch (Exception \$e) {
            echo 'ERROR: ' . \$e->getMessage();
        }
    " 2>/dev/null | grep -q "SUCCESS"; then
        log_success "LoanCalculatorService可以实例化"
        echo "  可以实例化" >> "$REPORT_FILE"
    else
        log_error "LoanCalculatorService无法实例化"
        echo "✗ LoanCalculatorService无法实例化" >> "$REPORT_FILE"
    fi
    
    # 测试计算方法
    log_check "测试贷款计算算法..."
    test_result=$(sudo -u besthammer_c_usr php -r "
        require_once 'vendor/autoload.php';
        try {
            \$result = App\Services\LoanCalculatorService::calculate(100000, 5.0, 30, 'equal_payment');
            if (isset(\$result['success']) && \$result['success']) {
                echo 'CALCULATION_SUCCESS';
            } else {
                echo 'CALCULATION_FAILED: ' . (\$result['message'] ?? 'Unknown error');
            }
        } catch (Exception \$e) {
            echo 'CALCULATION_ERROR: ' . \$e->getMessage();
        }
    " 2>&1)
    
    if echo "$test_result" | grep -q "CALCULATION_SUCCESS"; then
        log_success "贷款计算算法正常"
        echo "✓ 贷款计算算法正常" >> "$REPORT_FILE"
    else
        log_error "贷款计算算法异常: $test_result"
        echo "✗ 贷款计算算法异常: $test_result" >> "$REPORT_FILE"
    fi
    
else
    log_error "LoanCalculatorService不存在"
    echo "✗ LoanCalculatorService不存在" >> "$REPORT_FILE"
fi

# 检查贷款计算器视图
if [ -f "resources/views/tools/loan-calculator.blade.php" ]; then
    log_success "贷款计算器视图存在"
    echo "✓ 贷款计算器视图存在" >> "$REPORT_FILE"
else
    log_error "贷款计算器视图不存在"
    echo "✗ 贷款计算器视图不存在" >> "$REPORT_FILE"
fi

# 测试贷款计算器API
log_check "测试贷款计算器API..."
api_test=$(curl -s -X POST "https://www.besthammer.club/tools/loan-calculator" \
    -H "Content-Type: application/json" \
    -H "X-CSRF-TOKEN: test" \
    -d '{"amount":100000,"rate":5.0,"years":30,"type":"equal_payment"}' \
    -w "HTTP_CODE:%{http_code}" 2>/dev/null || echo "CURL_ERROR")

if echo "$api_test" | grep -q "HTTP_CODE:200"; then
    log_success "贷款计算器API响应正常"
    echo "✓ 贷款计算器API响应正常" >> "$REPORT_FILE"
elif echo "$api_test" | grep -q "HTTP_CODE:419"; then
    log_warning "贷款计算器API需要CSRF令牌"
    echo "⚠ 贷款计算器API需要CSRF令牌" >> "$REPORT_FILE"
else
    http_code=$(echo "$api_test" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
    log_error "贷款计算器API异常: HTTP $http_code"
    echo "✗ 贷款计算器API异常: HTTP $http_code" >> "$REPORT_FILE"
fi

log_step "第2步：BMI计算器功能诊断"
echo "-----------------------------------"

log_check "检查BMI计算器组件..."
echo "=== BMI计算器诊断 ===" >> "$REPORT_FILE"

# 检查BMICalculatorService
if [ -f "app/Services/BMICalculatorService.php" ]; then
    log_success "BMICalculatorService存在"
    echo "✓ BMICalculatorService存在" >> "$REPORT_FILE"
    
    # 检查语法
    if php -l app/Services/BMICalculatorService.php > /dev/null 2>&1; then
        echo "  语法正确" >> "$REPORT_FILE"
        log_success "BMICalculatorService语法正确"
    else
        log_error "BMICalculatorService语法错误"
        echo "✗ BMICalculatorService语法错误" >> "$REPORT_FILE"
        php -l app/Services/BMICalculatorService.php >> "$REPORT_FILE" 2>&1
    fi
    
    # 测试BMI计算
    log_check "测试BMI计算算法..."
    bmi_test=$(sudo -u besthammer_c_usr php -r "
        require_once 'vendor/autoload.php';
        try {
            \$result = App\Services\BMICalculatorService::calculate(70, 175, 'metric');
            if (isset(\$result['success']) && \$result['success']) {
                echo 'BMI_SUCCESS';
            } else {
                echo 'BMI_FAILED: ' . (\$result['message'] ?? 'Unknown error');
            }
        } catch (Exception \$e) {
            echo 'BMI_ERROR: ' . \$e->getMessage();
        }
    " 2>&1)
    
    if echo "$bmi_test" | grep -q "BMI_SUCCESS"; then
        log_success "BMI计算算法正常"
        echo "✓ BMI计算算法正常" >> "$REPORT_FILE"
    else
        log_error "BMI计算算法异常: $bmi_test"
        echo "✗ BMI计算算法异常: $bmi_test" >> "$REPORT_FILE"
    fi
    
else
    log_error "BMICalculatorService不存在"
    echo "✗ BMICalculatorService不存在" >> "$REPORT_FILE"
fi

# 检查BMI计算器视图
if [ -f "resources/views/tools/bmi-calculator.blade.php" ]; then
    log_success "BMI计算器视图存在"
    echo "✓ BMI计算器视图存在" >> "$REPORT_FILE"
else
    log_error "BMI计算器视图不存在"
    echo "✗ BMI计算器视图不存在" >> "$REPORT_FILE"
fi

# 测试BMI计算器API
log_check "测试BMI计算器API..."
bmi_api_test=$(curl -s -X POST "https://www.besthammer.club/tools/bmi-calculator" \
    -H "Content-Type: application/json" \
    -H "X-CSRF-TOKEN: test" \
    -d '{"weight":70,"height":175,"unit":"metric"}' \
    -w "HTTP_CODE:%{http_code}" 2>/dev/null || echo "CURL_ERROR")

if echo "$bmi_api_test" | grep -q "HTTP_CODE:200"; then
    log_success "BMI计算器API响应正常"
    echo "✓ BMI计算器API响应正常" >> "$REPORT_FILE"
elif echo "$bmi_api_test" | grep -q "HTTP_CODE:419"; then
    log_warning "BMI计算器API需要CSRF令牌"
    echo "⚠ BMI计算器API需要CSRF令牌" >> "$REPORT_FILE"
else
    http_code=$(echo "$bmi_api_test" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
    log_error "BMI计算器API异常: HTTP $http_code"
    echo "✗ BMI计算器API异常: HTTP $http_code" >> "$REPORT_FILE"
fi

log_step "第3步：汇率转换器功能诊断"
echo "-----------------------------------"

log_check "检查汇率转换器组件..."
echo "=== 汇率转换器诊断 ===" >> "$REPORT_FILE"

# 检查CurrencyConverterService
if [ -f "app/Services/CurrencyConverterService.php" ]; then
    log_success "CurrencyConverterService存在"
    echo "✓ CurrencyConverterService存在" >> "$REPORT_FILE"
    
    # 检查语法
    if php -l app/Services/CurrencyConverterService.php > /dev/null 2>&1; then
        echo "  语法正确" >> "$REPORT_FILE"
        log_success "CurrencyConverterService语法正确"
    else
        log_error "CurrencyConverterService语法错误"
        echo "✗ CurrencyConverterService语法错误" >> "$REPORT_FILE"
        php -l app/Services/CurrencyConverterService.php >> "$REPORT_FILE" 2>&1
    fi
    
    # 测试汇率转换
    log_check "测试汇率转换算法..."
    currency_test=$(sudo -u besthammer_c_usr php -r "
        require_once 'vendor/autoload.php';
        try {
            \$result = App\Services\CurrencyConverterService::convert(100, 'USD', 'EUR');
            if (isset(\$result['success']) && \$result['success']) {
                echo 'CURRENCY_SUCCESS';
            } else {
                echo 'CURRENCY_FAILED: ' . (\$result['message'] ?? 'Unknown error');
            }
        } catch (Exception \$e) {
            echo 'CURRENCY_ERROR: ' . \$e->getMessage();
        }
    " 2>&1)
    
    if echo "$currency_test" | grep -q "CURRENCY_SUCCESS"; then
        log_success "汇率转换算法正常"
        echo "✓ 汇率转换算法正常" >> "$REPORT_FILE"
    else
        log_error "汇率转换算法异常: $currency_test"
        echo "✗ 汇率转换算法异常: $currency_test" >> "$REPORT_FILE"
    fi
    
else
    log_error "CurrencyConverterService不存在"
    echo "✗ CurrencyConverterService不存在" >> "$REPORT_FILE"
fi

# 检查汇率转换器视图
if [ -f "resources/views/tools/currency-converter.blade.php" ]; then
    log_success "汇率转换器视图存在"
    echo "✓ 汇率转换器视图存在" >> "$REPORT_FILE"
else
    log_error "汇率转换器视图不存在"
    echo "✗ 汇率转换器视图不存在" >> "$REPORT_FILE"
fi

# 测试汇率转换器API
log_check "测试汇率转换器API..."
currency_api_test=$(curl -s -X POST "https://www.besthammer.club/tools/currency-converter" \
    -H "Content-Type: application/json" \
    -H "X-CSRF-TOKEN: test" \
    -d '{"amount":100,"from":"USD","to":"EUR"}' \
    -w "HTTP_CODE:%{http_code}" 2>/dev/null || echo "CURL_ERROR")

if echo "$currency_api_test" | grep -q "HTTP_CODE:200"; then
    log_success "汇率转换器API响应正常"
    echo "✓ 汇率转换器API响应正常" >> "$REPORT_FILE"
elif echo "$currency_api_test" | grep -q "HTTP_CODE:419"; then
    log_warning "汇率转换器API需要CSRF令牌"
    echo "⚠ 汇率转换器API需要CSRF令牌" >> "$REPORT_FILE"
else
    http_code=$(echo "$currency_api_test" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
    log_error "汇率转换器API异常: HTTP $http_code"
    echo "✗ 汇率转换器API异常: HTTP $http_code" >> "$REPORT_FILE"
fi

log_step "第4步：前端页面和JavaScript功能诊断"
echo "-----------------------------------"

log_check "检查工具页面访问..."
echo "=== 前端页面诊断 ===" >> "$REPORT_FILE"

# 测试工具页面访问
tool_pages=(
    "/tools/loan-calculator"
    "/tools/bmi-calculator"
    "/tools/currency-converter"
)

for page in "${tool_pages[@]}"; do
    echo "测试页面: $page" >> "$REPORT_FILE"

    response=$(curl -s -w "HTTP_CODE:%{http_code}" "https://www.besthammer.club$page" 2>/dev/null || echo "CURL_ERROR")
    http_code=$(echo "$response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)

    if [ "$http_code" = "200" ]; then
        log_success "$page: 页面正常访问"
        echo "✓ $page: 页面正常访问" >> "$REPORT_FILE"

        # 检查页面内容
        page_content=$(echo "$response" | sed 's/HTTP_CODE:[0-9]*//g')

        # 检查是否包含计算表单
        if echo "$page_content" | grep -q "form\|input\|button"; then
            echo "  包含表单元素" >> "$REPORT_FILE"
        else
            log_warning "$page: 缺少表单元素"
            echo "⚠ $page: 缺少表单元素" >> "$REPORT_FILE"
        fi

        # 检查是否包含JavaScript
        if echo "$page_content" | grep -q "script\|function\|calculate"; then
            echo "  包含JavaScript代码" >> "$REPORT_FILE"
        else
            log_warning "$page: 缺少JavaScript代码"
            echo "⚠ $page: 缺少JavaScript代码" >> "$REPORT_FILE"
        fi

    else
        log_error "$page: HTTP $http_code"
        echo "✗ $page: HTTP $http_code" >> "$REPORT_FILE"
    fi
    echo "---" >> "$REPORT_FILE"
done

log_step "第5步：多语言功能诊断"
echo "-----------------------------------"

log_check "检查多语言工具页面..."
echo "=== 多语言功能诊断 ===" >> "$REPORT_FILE"

# 测试多语言工具页面
locales=("de" "fr" "es")
for locale in "${locales[@]}"; do
    echo "测试语言: $locale" >> "$REPORT_FILE"

    for tool in "loan-calculator" "bmi-calculator" "currency-converter"; do
        url="/$locale/tools/$tool"
        response=$(curl -s -o /dev/null -w "%{http_code}" "https://www.besthammer.club$url" 2>/dev/null || echo "000")

        if [ "$response" = "200" ]; then
            log_success "$locale/$tool: 正常"
            echo "✓ $locale/$tool: 正常" >> "$REPORT_FILE"
        else
            log_error "$locale/$tool: HTTP $response"
            echo "✗ $locale/$tool: HTTP $response" >> "$REPORT_FILE"
        fi
    done
    echo "---" >> "$REPORT_FILE"
done

log_step "第6步：Service类详细检查"
echo "-----------------------------------"

log_check "检查Service类的具体实现..."
echo "=== Service类实现检查 ===" >> "$REPORT_FILE"

# 检查Services目录
if [ -d "app/Services" ]; then
    log_success "Services目录存在"
    echo "✓ Services目录存在" >> "$REPORT_FILE"

    echo "Services目录内容:" >> "$REPORT_FILE"
    ls -la app/Services/ >> "$REPORT_FILE" 2>/dev/null

    # 检查每个Service文件的方法
    services=("LoanCalculatorService" "BMICalculatorService" "CurrencyConverterService")
    for service in "${services[@]}"; do
        service_file="app/Services/${service}.php"
        if [ -f "$service_file" ]; then
            echo "检查 $service 方法:" >> "$REPORT_FILE"

            # 检查是否有calculate方法
            if grep -q "function calculate\|public static function calculate" "$service_file"; then
                echo "  ✓ 包含calculate方法" >> "$REPORT_FILE"
            else
                echo "  ✗ 缺少calculate方法" >> "$REPORT_FILE"
                log_error "$service: 缺少calculate方法"
            fi

            # 检查是否有适当的返回格式
            if grep -q "return.*success\|return.*result" "$service_file"; then
                echo "  ✓ 有返回值处理" >> "$REPORT_FILE"
            else
                echo "  ⚠ 返回值处理可能有问题" >> "$REPORT_FILE"
                log_warning "$service: 返回值处理可能有问题"
            fi

        fi
    done

else
    log_error "Services目录不存在"
    echo "✗ Services目录不存在" >> "$REPORT_FILE"
fi

log_step "第7步：数据验证和错误处理检查"
echo "-----------------------------------"

log_check "检查ToolController中的验证逻辑..."
echo "=== 数据验证检查 ===" >> "$REPORT_FILE"

if [ -f "app/Http/Controllers/ToolController.php" ]; then
    echo "ToolController验证检查:" >> "$REPORT_FILE"

    # 检查验证规则
    if grep -q "Validator::make\|validate(" app/Http/Controllers/ToolController.php; then
        echo "✓ 包含数据验证" >> "$REPORT_FILE"
        log_success "ToolController包含数据验证"
    else
        echo "✗ 缺少数据验证" >> "$REPORT_FILE"
        log_error "ToolController缺少数据验证"
    fi

    # 检查错误处理
    if grep -q "try.*catch\|Exception" app/Http/Controllers/ToolController.php; then
        echo "✓ 包含异常处理" >> "$REPORT_FILE"
        log_success "ToolController包含异常处理"
    else
        echo "✗ 缺少异常处理" >> "$REPORT_FILE"
        log_error "ToolController缺少异常处理"
    fi

    # 检查返回格式
    if grep -q "response()->json\|JsonResponse" app/Http/Controllers/ToolController.php; then
        echo "✓ 使用JSON响应格式" >> "$REPORT_FILE"
        log_success "ToolController使用JSON响应格式"
    else
        echo "⚠ JSON响应格式可能有问题" >> "$REPORT_FILE"
        log_warning "ToolController JSON响应格式可能有问题"
    fi
fi

log_step "第8步：外部API依赖检查"
echo "-----------------------------------"

log_check "检查汇率API依赖..."
echo "=== 外部API依赖检查 ===" >> "$REPORT_FILE"

# 测试汇率API访问
if [ -f "app/Services/CurrencyConverterService.php" ]; then
    # 检查是否使用外部API
    if grep -q "curl\|http\|api\|fixer\|exchangerate" app/Services/CurrencyConverterService.php; then
        echo "✓ 使用外部汇率API" >> "$REPORT_FILE"
        log_success "使用外部汇率API"

        # 尝试测试API连接
        log_check "测试外部API连接..."
        api_test=$(timeout 10 curl -s "https://api.exchangerate-api.com/v4/latest/USD" 2>/dev/null || echo "API_ERROR")

        if echo "$api_test" | grep -q "rates\|USD"; then
            echo "✓ 外部API连接正常" >> "$REPORT_FILE"
            log_success "外部API连接正常"
        else
            echo "✗ 外部API连接失败" >> "$REPORT_FILE"
            log_error "外部API连接失败"
        fi
    else
        echo "- 使用静态汇率数据" >> "$REPORT_FILE"
        log_info "使用静态汇率数据"
    fi
fi

log_step "第9步：生成诊断总结和修复建议"
echo "-----------------------------------"

echo "" >> "$REPORT_FILE"
echo "=== 诊断总结 ===" >> "$REPORT_FILE"
echo "诊断完成时间: $(date)" >> "$REPORT_FILE"

# 统计问题
echo "" >> "$REPORT_FILE"
echo "发现的问题统计:" >> "$REPORT_FILE"

issues_count=0

# 检查Service文件
for service in "LoanCalculatorService" "BMICalculatorService" "CurrencyConverterService"; do
    if [ ! -f "app/Services/${service}.php" ]; then
        echo "- ${service}.php 文件缺失" >> "$REPORT_FILE"
        ((issues_count++))
    fi
done

# 检查视图文件
for tool in "loan-calculator" "bmi-calculator" "currency-converter"; do
    if [ ! -f "resources/views/tools/${tool}.blade.php" ]; then
        echo "- ${tool}.blade.php 视图缺失" >> "$REPORT_FILE"
        ((issues_count++))
    fi
done

echo "" >> "$REPORT_FILE"
echo "总计发现 $issues_count 个问题" >> "$REPORT_FILE"

echo ""
echo "🔧 3个主体功能诊断完成！"
echo "======================"
echo ""
echo "📋 诊断报告已生成: $REPORT_FILE"
echo ""
echo "📊 快速问题统计："

# 快速检查关键文件
missing_files=0
syntax_errors=0

# 检查Service文件
for service in "LoanCalculatorService" "BMICalculatorService" "CurrencyConverterService"; do
    service_file="app/Services/${service}.php"
    if [ ! -f "$service_file" ]; then
        echo "❌ $service 文件缺失"
        ((missing_files++))
    elif ! php -l "$service_file" > /dev/null 2>&1; then
        echo "❌ $service 语法错误"
        ((syntax_errors++))
    else
        echo "✅ $service 正常"
    fi
done

# 检查视图文件
for tool in "loan-calculator" "bmi-calculator" "currency-converter"; do
    view_file="resources/views/tools/${tool}.blade.php"
    if [ ! -f "$view_file" ]; then
        echo "❌ $tool 视图缺失"
        ((missing_files++))
    else
        echo "✅ $tool 视图存在"
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
echo "3. 如有缺失文件，运行修复脚本恢复"
echo "4. 测试每个工具的计算功能"
echo "5. 验证多语言功能是否正常"

if [ $((missing_files + syntax_errors)) -gt 0 ]; then
    echo ""
    echo "⚠️ 发现问题，建议运行修复脚本"
else
    echo ""
    echo "✅ 所有组件检查正常"
fi

echo ""
log_info "3个主体功能专项诊断脚本执行完成！"
