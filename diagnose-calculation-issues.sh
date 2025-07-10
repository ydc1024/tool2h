#!/bin/bash

# 针对贷款计算、BMI计算、汇率转换功能的深度诊断脚本
# 诊断前端、后端、环境等所有可能的问题

echo "🔍 3个计算功能深度诊断脚本"
echo "=========================="
echo "诊断目标："
echo "1. 贷款计算器 - Error calculating loan 弹窗问题"
echo "2. BMI计算器 - 计算功能异常问题"
echo "3. 汇率转换器 - 只显示div框架不显示数据问题"
echo "4. 前端JavaScript和AJAX请求诊断"
echo "5. 后端API路由和控制器诊断"
echo "6. Service类和数据处理诊断"
echo "7. 视图文件和前端元素诊断"
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

if [ ! -d "$PROJECT_DIR" ]; then
    log_error "项目目录不存在: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

# 创建诊断报告文件
REPORT_FILE="calculation_diagnosis_$(date +%Y%m%d_%H%M%S).txt"
echo "3个计算功能深度诊断报告 - $(date)" > "$REPORT_FILE"
echo "==============================" >> "$REPORT_FILE"

log_step "第1步：前端视图文件诊断"
echo "-----------------------------------"

log_check "检查工具视图文件是否存在..."
echo "=== 前端视图文件诊断 ===" >> "$REPORT_FILE"

tool_views=(
    "resources/views/tools/loan-calculator.blade.php"
    "resources/views/tools/bmi-calculator.blade.php"
    "resources/views/tools/currency-converter.blade.php"
)

view_files_exist=true
for view_file in "${tool_views[@]}"; do
    echo "检查视图文件: $view_file" >> "$REPORT_FILE"
    
    if [ -f "$view_file" ]; then
        log_success "$view_file: 文件存在"
        echo "  ✓ 文件存在" >> "$REPORT_FILE"
        
        # 检查视图文件内容
        if grep -q "csrf.*token\|@csrf" "$view_file"; then
            echo "    ✓ 包含CSRF令牌" >> "$REPORT_FILE"
        else
            log_warning "$view_file: 缺少CSRF令牌"
            echo "    ⚠ 缺少CSRF令牌" >> "$REPORT_FILE"
        fi
        
        if grep -q "Alpine\|x-data\|@click" "$view_file"; then
            echo "    ✓ 包含Alpine.js代码" >> "$REPORT_FILE"
        else
            log_warning "$view_file: 缺少Alpine.js代码"
            echo "    ⚠ 缺少Alpine.js代码" >> "$REPORT_FILE"
        fi
        
        if grep -q "fetch\|axios\|ajax" "$view_file"; then
            echo "    ✓ 包含AJAX请求代码" >> "$REPORT_FILE"
        else
            log_warning "$view_file: 缺少AJAX请求代码"
            echo "    ⚠ 缺少AJAX请求代码" >> "$REPORT_FILE"
        fi
        
        # 检查表单元素
        if grep -q "input.*name.*amount\|input.*name.*weight\|input.*name.*from" "$view_file"; then
            echo "    ✓ 包含表单输入元素" >> "$REPORT_FILE"
        else
            log_warning "$view_file: 缺少表单输入元素"
            echo "    ⚠ 缺少表单输入元素" >> "$REPORT_FILE"
        fi
        
        # 检查结果显示元素
        if grep -q "result\|output\|display" "$view_file"; then
            echo "    ✓ 包含结果显示元素" >> "$REPORT_FILE"
        else
            log_warning "$view_file: 缺少结果显示元素"
            echo "    ⚠ 缺少结果显示元素" >> "$REPORT_FILE"
        fi
        
    else
        log_error "$view_file: 文件不存在"
        echo "  ✗ 文件不存在" >> "$REPORT_FILE"
        view_files_exist=false
    fi
    echo "---" >> "$REPORT_FILE"
done

log_step "第2步：API路由和控制器诊断"
echo "-----------------------------------"

log_check "检查API路由配置..."
echo "=== API路由和控制器诊断 ===" >> "$REPORT_FILE"

# 检查路由文件
if [ -f "routes/web.php" ]; then
    echo "✓ routes/web.php 存在" >> "$REPORT_FILE"
    
    # 检查具体路由
    routes_to_check=(
        "calculateLoan:POST /tools/loan-calculator"
        "calculateBmi:POST /tools/bmi-calculator"
        "convertCurrency:POST /tools/currency-converter"
    )
    
    for route_check in "${routes_to_check[@]}"; do
        method_name=$(echo "$route_check" | cut -d: -f1)
        route_path=$(echo "$route_check" | cut -d: -f2)
        
        echo "检查路由: $route_path -> $method_name" >> "$REPORT_FILE"
        
        if grep -q "$method_name\|$(echo $route_path | sed 's/POST //')" routes/web.php; then
            echo "  ✓ 路由配置存在" >> "$REPORT_FILE"
            log_success "$route_path: 路由已配置"
        else
            echo "  ✗ 路由配置缺失" >> "$REPORT_FILE"
            log_error "$route_path: 路由缺失"
        fi
    done
    
else
    echo "✗ routes/web.php 不存在" >> "$REPORT_FILE"
    log_error "routes/web.php 文件不存在"
fi

# 检查ToolController
echo "检查ToolController:" >> "$REPORT_FILE"
if [ -f "app/Http/Controllers/ToolController.php" ]; then
    echo "  ✓ ToolController文件存在" >> "$REPORT_FILE"
    log_success "ToolController文件存在"
    
    # 检查语法
    if php -l app/Http/Controllers/ToolController.php > /dev/null 2>&1; then
        echo "    ✓ PHP语法正确" >> "$REPORT_FILE"
        log_success "ToolController语法正确"
    else
        echo "    ✗ PHP语法错误" >> "$REPORT_FILE"
        log_error "ToolController语法错误"
        php -l app/Http/Controllers/ToolController.php >> "$REPORT_FILE" 2>&1
    fi
    
    # 检查方法
    controller_methods=("calculateLoan" "calculateBmi" "convertCurrency")
    for method in "${controller_methods[@]}"; do
        if grep -q "function $method\|public function $method" app/Http/Controllers/ToolController.php; then
            echo "    ✓ 包含$method方法" >> "$REPORT_FILE"
            log_success "ToolController包含$method方法"
        else
            echo "    ✗ 缺少$method方法" >> "$REPORT_FILE"
            log_error "ToolController缺少$method方法"
        fi
    done
    
else
    echo "  ✗ ToolController文件不存在" >> "$REPORT_FILE"
    log_error "ToolController文件不存在"
fi

log_step "第3步：Service类诊断"
echo "-----------------------------------"

log_check "检查Service类实现..."
echo "=== Service类诊断 ===" >> "$REPORT_FILE"

services=(
    "LoanCalculatorService:app/Services/LoanCalculatorService.php"
    "BMICalculatorService:app/Services/BMICalculatorService.php"
    "CurrencyConverterService:app/Services/CurrencyConverterService.php"
)

for service_info in "${services[@]}"; do
    service_name=$(echo "$service_info" | cut -d: -f1)
    service_file=$(echo "$service_info" | cut -d: -f2)
    
    echo "检查Service: $service_name" >> "$REPORT_FILE"
    
    if [ -f "$service_file" ]; then
        echo "  ✓ 文件存在: $service_file" >> "$REPORT_FILE"
        
        # 检查语法
        if php -l "$service_file" > /dev/null 2>&1; then
            echo "    ✓ PHP语法正确" >> "$REPORT_FILE"
        else
            echo "    ✗ PHP语法错误" >> "$REPORT_FILE"
            php -l "$service_file" >> "$REPORT_FILE" 2>&1
        fi
        
        # 检查calculate方法
        if grep -q "public static function calculate\|static function calculate" "$service_file"; then
            echo "    ✓ 包含静态calculate方法" >> "$REPORT_FILE"
            log_success "$service_name: 包含静态calculate方法"
        else
            echo "    ✗ 缺少静态calculate方法" >> "$REPORT_FILE"
            log_error "$service_name: 缺少静态calculate方法"
        fi
        
        # 检查返回格式
        if grep -q "success.*true\|success.*false" "$service_file"; then
            echo "    ✓ 包含标准返回格式" >> "$REPORT_FILE"
        else
            echo "    ⚠ 可能缺少标准返回格式" >> "$REPORT_FILE"
            log_warning "$service_name: 可能缺少标准返回格式"
        fi
        
    else
        echo "  ✗ 文件不存在: $service_file" >> "$REPORT_FILE"
        log_error "$service_name: 文件不存在"
    fi
    echo "---" >> "$REPORT_FILE"
done

log_step "第4步：实际API请求测试"
echo "-----------------------------------"

log_check "测试实际API请求..."
echo "=== 实际API请求测试 ===" >> "$REPORT_FILE"

# 测试API端点
api_tests=(
    "loan:/tools/loan-calculator:{\"amount\":100000,\"rate\":5.0,\"years\":30,\"type\":\"equal_payment\"}"
    "bmi:/tools/bmi-calculator:{\"weight\":70,\"height\":175,\"unit\":\"metric\"}"
    "currency:/tools/currency-converter:{\"amount\":100,\"from\":\"USD\",\"to\":\"EUR\"}"
)

for api_test in "${api_tests[@]}"; do
    test_name=$(echo "$api_test" | cut -d: -f1)
    test_endpoint=$(echo "$api_test" | cut -d: -f2)
    test_data=$(echo "$api_test" | cut -d: -f3)

    echo "测试API: $test_name -> POST $test_endpoint" >> "$REPORT_FILE"
    log_check "测试$test_name API..."

    # 首先获取CSRF令牌
    csrf_token=$(curl -s "https://www.besthammer.club$test_endpoint" | grep -o 'csrf-token.*content="[^"]*"' | grep -o 'content="[^"]*"' | cut -d'"' -f2 2>/dev/null)

    if [ -n "$csrf_token" ]; then
        echo "  ✓ CSRF令牌获取成功: ${csrf_token:0:10}..." >> "$REPORT_FILE"

        # 发送POST请求
        api_response=$(curl -s -X POST "https://www.besthammer.club$test_endpoint" \
            -H "Content-Type: application/json" \
            -H "X-CSRF-TOKEN: $csrf_token" \
            -H "X-Requested-With: XMLHttpRequest" \
            -H "Accept: application/json" \
            -d "$test_data" \
            -w "HTTP_CODE:%{http_code}" 2>/dev/null || echo "CURL_ERROR")

        if echo "$api_response" | grep -q "HTTP_CODE:200"; then
            echo "  ✓ API响应正常 (HTTP 200)" >> "$REPORT_FILE"
            log_success "$test_name API: HTTP 200"

            # 检查响应内容
            response_content=$(echo "$api_response" | sed 's/HTTP_CODE:[0-9]*//g')
            if echo "$response_content" | grep -q '"success".*true'; then
                echo "    ✓ 返回成功结果" >> "$REPORT_FILE"
                log_success "$test_name API: 计算成功"

                # 检查具体数据
                case "$test_name" in
                    "loan")
                        if echo "$response_content" | grep -q "monthly_payment\|total_payment"; then
                            echo "      ✓ 包含贷款计算数据" >> "$REPORT_FILE"
                        else
                            echo "      ⚠ 缺少贷款计算数据" >> "$REPORT_FILE"
                        fi
                        ;;
                    "bmi")
                        if echo "$response_content" | grep -q "bmi\|category"; then
                            echo "      ✓ 包含BMI计算数据" >> "$REPORT_FILE"
                        else
                            echo "      ⚠ 缺少BMI计算数据" >> "$REPORT_FILE"
                        fi
                        ;;
                    "currency")
                        if echo "$response_content" | grep -q "converted_amount\|exchange_rate"; then
                            echo "      ✓ 包含汇率转换数据" >> "$REPORT_FILE"
                        else
                            echo "      ⚠ 缺少汇率转换数据" >> "$REPORT_FILE"
                        fi
                        ;;
                esac

            elif echo "$response_content" | grep -q '"success".*false'; then
                echo "    ✗ 返回失败结果" >> "$REPORT_FILE"
                log_error "$test_name API: 计算失败"

                # 提取错误信息
                error_msg=$(echo "$response_content" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
                if [ -n "$error_msg" ]; then
                    echo "      错误信息: $error_msg" >> "$REPORT_FILE"
                    log_error "$test_name API错误: $error_msg"
                fi

            else
                echo "    ⚠ 响应格式异常" >> "$REPORT_FILE"
                log_warning "$test_name API: 响应格式异常"
                echo "      响应内容: ${response_content:0:200}..." >> "$REPORT_FILE"
            fi

        else
            http_code=$(echo "$api_response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
            echo "  ✗ API异常 (HTTP $http_code)" >> "$REPORT_FILE"
            log_error "$test_name API: HTTP $http_code"

            # 记录错误响应
            error_content=$(echo "$api_response" | sed 's/HTTP_CODE:[0-9]*//g')
            if [ -n "$error_content" ]; then
                echo "    错误内容: ${error_content:0:200}..." >> "$REPORT_FILE"
            fi
        fi

    else
        echo "  ✗ CSRF令牌获取失败" >> "$REPORT_FILE"
        log_error "$test_name API: CSRF令牌获取失败"
    fi
    echo "---" >> "$REPORT_FILE"
done

log_step "第5步：Service类功能测试"
echo "-----------------------------------"

log_check "测试Service类计算功能..."
echo "=== Service类功能测试 ===" >> "$REPORT_FILE"

# 创建Service测试脚本
cat > test_services_detailed.php << 'SERVICE_TEST_EOF'
<?php
require_once 'vendor/autoload.php';

echo "=== Service类详细功能测试 ===\n";

// 测试LoanCalculatorService
echo "\n1. 测试LoanCalculatorService:\n";
try {
    if (class_exists('App\Services\LoanCalculatorService')) {
        echo "  ✓ LoanCalculatorService类存在\n";

        if (method_exists('App\Services\LoanCalculatorService', 'calculate')) {
            echo "  ✓ calculate方法存在\n";

            $result = App\Services\LoanCalculatorService::calculate(100000, 5.0, 30, 'equal_payment');

            if (is_array($result)) {
                echo "  ✓ 返回数组格式\n";

                if (isset($result['success'])) {
                    if ($result['success']) {
                        echo "  ✓ 计算成功\n";
                        if (isset($result['data']['monthly_payment'])) {
                            echo "    月供: " . $result['data']['monthly_payment'] . "\n";
                        }
                        if (isset($result['data']['total_interest'])) {
                            echo "    总利息: " . $result['data']['total_interest'] . "\n";
                        }
                    } else {
                        echo "  ✗ 计算失败: " . ($result['message'] ?? 'Unknown error') . "\n";
                    }
                } else {
                    echo "  ⚠ 缺少success字段\n";
                }
            } else {
                echo "  ✗ 返回格式错误，不是数组\n";
            }
        } else {
            echo "  ✗ calculate方法不存在\n";
        }
    } else {
        echo "  ✗ LoanCalculatorService类不存在\n";
    }
} catch (Exception $e) {
    echo "  ✗ 异常: " . $e->getMessage() . "\n";
}

// 测试BMICalculatorService
echo "\n2. 测试BMICalculatorService:\n";
try {
    if (class_exists('App\Services\BMICalculatorService')) {
        echo "  ✓ BMICalculatorService类存在\n";

        if (method_exists('App\Services\BMICalculatorService', 'calculate')) {
            echo "  ✓ calculate方法存在\n";

            $result = App\Services\BMICalculatorService::calculate(70, 175, 'metric');

            if (is_array($result)) {
                echo "  ✓ 返回数组格式\n";

                if (isset($result['success'])) {
                    if ($result['success']) {
                        echo "  ✓ 计算成功\n";
                        if (isset($result['data']['bmi'])) {
                            echo "    BMI值: " . $result['data']['bmi'] . "\n";
                        }
                        if (isset($result['data']['category']['name'])) {
                            echo "    分类: " . $result['data']['category']['name'] . "\n";
                        }
                    } else {
                        echo "  ✗ 计算失败: " . ($result['message'] ?? 'Unknown error') . "\n";
                    }
                } else {
                    echo "  ⚠ 缺少success字段\n";
                }
            } else {
                echo "  ✗ 返回格式错误，不是数组\n";
            }
        } else {
            echo "  ✗ calculate方法不存在\n";
        }
    } else {
        echo "  ✗ BMICalculatorService类不存在\n";
    }
} catch (Exception $e) {
    echo "  ✗ 异常: " . $e->getMessage() . "\n";
}

// 测试CurrencyConverterService
echo "\n3. 测试CurrencyConverterService:\n";
try {
    if (class_exists('App\Services\CurrencyConverterService')) {
        echo "  ✓ CurrencyConverterService类存在\n";

        if (method_exists('App\Services\CurrencyConverterService', 'convert')) {
            echo "  ✓ convert方法存在\n";

            $result = App\Services\CurrencyConverterService::convert(100, 'USD', 'EUR');

            if (is_array($result)) {
                echo "  ✓ 返回数组格式\n";

                if (isset($result['success'])) {
                    if ($result['success']) {
                        echo "  ✓ 转换成功\n";
                        if (isset($result['data']['converted_amount'])) {
                            echo "    转换金额: " . $result['data']['converted_amount'] . "\n";
                        }
                        if (isset($result['data']['exchange_rate'])) {
                            echo "    汇率: " . $result['data']['exchange_rate'] . "\n";
                        }
                    } else {
                        echo "  ✗ 转换失败: " . ($result['message'] ?? 'Unknown error') . "\n";
                    }
                } else {
                    echo "  ⚠ 缺少success字段\n";
                }
            } else {
                echo "  ✗ 返回格式错误，不是数组\n";
            }
        } else {
            echo "  ✗ convert方法不存在\n";
        }

        // 测试calculate方法（别名）
        if (method_exists('App\Services\CurrencyConverterService', 'calculate')) {
            echo "  ✓ calculate方法存在（别名）\n";
        } else {
            echo "  ⚠ calculate方法不存在（可能影响ToolController调用）\n";
        }

    } else {
        echo "  ✗ CurrencyConverterService类不存在\n";
    fi
} catch (Exception $e) {
    echo "  ✗ 异常: " . $e->getMessage() . "\n";
}
SERVICE_TEST_EOF

# 运行Service测试
service_test_output=$(sudo -u besthammer_c_usr php test_services_detailed.php 2>&1)
echo "$service_test_output" >> "$REPORT_FILE"

# 分析测试结果
if echo "$service_test_output" | grep -q "✓.*计算成功\|✓.*转换成功"; then
    log_success "Service类功能测试部分通过"
else
    log_error "Service类功能测试失败"
fi

# 清理测试文件
rm -f test_services_detailed.php

log_step "第6步：Laravel环境和配置诊断"
echo "-----------------------------------"

log_check "检查Laravel环境配置..."
echo "=== Laravel环境和配置诊断 ===" >> "$REPORT_FILE"

# 检查.env文件
if [ -f ".env" ]; then
    echo "✓ .env文件存在" >> "$REPORT_FILE"

    if grep -q "APP_DEBUG=true" .env; then
        echo "  ✓ 调试模式已启用" >> "$REPORT_FILE"
        log_success "Laravel调试模式已启用"
    else
        echo "  ⚠ 调试模式未启用" >> "$REPORT_FILE"
        log_warning "Laravel调试模式未启用"
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
if [ -f "vendor/autoload.php" ]; then
    echo "✓ Composer自动加载文件存在" >> "$REPORT_FILE"
    log_success "Composer自动加载正常"
else
    echo "✗ Composer自动加载文件不存在" >> "$REPORT_FILE"
    log_error "Composer自动加载文件不存在"
fi

# 检查Laravel日志
if [ -f "storage/logs/laravel.log" ]; then
    echo "✓ Laravel日志文件存在" >> "$REPORT_FILE"

    # 获取最近的错误
    recent_errors=$(tail -20 storage/logs/laravel.log | grep -i "error\|exception\|fatal" | tail -5)

    if [ -n "$recent_errors" ]; then
        echo "最近的错误信息:" >> "$REPORT_FILE"
        echo "$recent_errors" >> "$REPORT_FILE"
        log_warning "发现Laravel错误，详见报告"
    else
        echo "  ✓ 没有发现最近的错误" >> "$REPORT_FILE"
        log_success "Laravel日志正常"
    fi
else
    echo "✗ Laravel日志文件不存在" >> "$REPORT_FILE"
    log_warning "Laravel日志文件不存在"
fi

log_step "第7步：生成诊断总结和建议"
echo "-----------------------------------"

echo "" >> "$REPORT_FILE"
echo "=== 诊断总结和修复建议 ===" >> "$REPORT_FILE"
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
    "resources/views/tools/loan-calculator.blade.php"
    "resources/views/tools/bmi-calculator.blade.php"
    "resources/views/tools/currency-converter.blade.php"
)

missing_files=()
for file in "${critical_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "- 关键文件缺失: $file" >> "$REPORT_FILE"
        missing_files+=("$file")
        ((issues_count++))
    fi
done

echo "" >> "$REPORT_FILE"
echo "总计发现 $issues_count 个关键问题" >> "$REPORT_FILE"

# 生成修复建议
echo "" >> "$REPORT_FILE"
echo "修复建议:" >> "$REPORT_FILE"

if [ ${#missing_files[@]} -gt 0 ]; then
    echo "1. 缺失文件修复:" >> "$REPORT_FILE"
    for file in "${missing_files[@]}"; do
        echo "   - 需要创建: $file" >> "$REPORT_FILE"
    done
fi

echo "2. 建议运行的修复脚本:" >> "$REPORT_FILE"
echo "   - bash fix-calculation-final.sh" >> "$REPORT_FILE"
echo "3. 建议检查的日志:" >> "$REPORT_FILE"
echo "   - tail -f storage/logs/laravel.log" >> "$REPORT_FILE"
echo "   - tail -f /var/log/apache2/error.log" >> "$REPORT_FILE"

echo ""
echo "🔍 深度诊断完成！"
echo "=================="
echo ""
echo "📋 诊断报告已生成: $REPORT_FILE"
echo ""
echo "📊 快速问题统计："

# 快速检查关键问题
missing_count=0
syntax_errors=0

for file in "${critical_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ 缺失: $file"
        ((missing_count++))
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
echo "   缺失文件: $missing_count"
echo "   语法错误: $syntax_errors"
echo "   总计问题: $((missing_count + syntax_errors))"

echo ""
echo "🔧 建议的修复步骤："
echo "1. 查看完整诊断报告: cat $REPORT_FILE"
echo "2. 运行修复脚本: bash fix-calculation-final.sh"
echo "3. 检查Laravel错误日志: tail -20 storage/logs/laravel.log"
echo "4. 检查Apache错误日志: tail -10 /var/log/apache2/error.log"
echo "5. 在浏览器开发者工具中检查JavaScript错误"

if [ $((missing_count + syntax_errors)) -gt 0 ]; then
    echo ""
    echo "⚠️ 发现关键问题，需要立即修复"
    echo "   主要问题可能是："
    echo "   - 视图文件缺失导致前端无法正常显示"
    echo "   - Service类或Controller缺失导致API调用失败"
    echo "   - 路由配置错误导致请求无法到达后端"
else
    echo ""
    echo "✅ 基础文件检查正常，问题可能在逻辑或配置层面"
    echo "   建议检查："
    echo "   - 前端JavaScript代码是否正确"
    echo "   - CSRF令牌是否正确传递"
    echo "   - API请求格式是否正确"
fi

echo ""
log_info "深度诊断脚本执行完成！"
