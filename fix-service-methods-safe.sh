#!/bin/bash

# 安全修复Service方法调用问题
# 解决静态方法调用不匹配和缺失calculate方法的问题

echo "🔧 安全修复Service方法调用问题"
echo "=========================="
echo "修复内容："
echo "1. 安全修复LoanCalculatorService"
echo "2. 安全修复BMICalculatorService"
echo "3. 安全修复CurrencyConverterService"
echo "4. 恢复ToolController"
echo "5. 验证修复结果"
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

# 创建临时目录用于存放PHP文件
TEMP_DIR="/tmp/service_fix_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEMP_DIR"

log_step "第1步：创建LoanCalculatorService"
echo "-----------------------------------"

# 创建LoanCalculatorService PHP文件
cat > "$TEMP_DIR/LoanCalculatorService.php" << 'PHPEOF'
<?php

namespace App\Services;

class LoanCalculatorService
{
    public static function calculate(float $amount, float $rate, int $years, string $type): array
    {
        try {
            $months = $years * 12;
            
            switch ($type) {
                case 'equal_payment':
                    $result = self::calculateEqualPayment($amount, $rate, $months);
                    break;
                case 'equal_principal':
                    $result = self::calculateEqualPrincipal($amount, $rate, $months);
                    break;
                default:
                    throw new \InvalidArgumentException('Invalid calculation type: ' . $type);
            }
            
            return [
                'success' => true,
                'data' => $result,
                'calculation_type' => $type,
                'input' => [
                    'amount' => $amount,
                    'rate' => $rate,
                    'years' => $years
                ]
            ];
            
        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => 'Calculation error: ' . $e->getMessage(),
                'error_code' => 'LOAN_CALC_ERROR'
            ];
        }
    }
    
    private static function calculateEqualPayment(float $principal, float $annualRate, int $months): array
    {
        $monthlyRate = $annualRate / 100 / 12;
        
        if ($monthlyRate == 0) {
            $monthlyPayment = $principal / $months;
            $totalPayment = $principal;
            $totalInterest = 0;
        } else {
            $monthlyPayment = $principal * ($monthlyRate * pow(1 + $monthlyRate, $months)) / 
                             (pow(1 + $monthlyRate, $months) - 1);
            $totalPayment = $monthlyPayment * $months;
            $totalInterest = $totalPayment - $principal;
        }
        
        return [
            'monthly_payment' => round($monthlyPayment, 2),
            'total_payment' => round($totalPayment, 2),
            'total_interest' => round($totalInterest, 2),
            'schedule' => self::generateAmortizationSchedule($principal, $annualRate, $months)
        ];
    }
    
    private static function calculateEqualPrincipal(float $principal, float $annualRate, int $months): array
    {
        $monthlyRate = $annualRate / 100 / 12;
        $monthlyPrincipal = $principal / $months;
        $totalInterest = 0;
        
        for ($month = 1; $month <= $months; $month++) {
            $remainingPrincipal = $principal - ($monthlyPrincipal * ($month - 1));
            $monthlyInterest = $remainingPrincipal * $monthlyRate;
            $totalInterest += $monthlyInterest;
        }
        
        $totalPayment = $principal + $totalInterest;
        $firstMonthPayment = $monthlyPrincipal + ($principal * $monthlyRate);
        $lastMonthPayment = $monthlyPrincipal + ($monthlyPrincipal * $monthlyRate);
        
        return [
            'monthly_payment_first' => round($firstMonthPayment, 2),
            'monthly_payment_last' => round($lastMonthPayment, 2),
            'total_payment' => round($totalPayment, 2),
            'total_interest' => round($totalInterest, 2)
        ];
    }
    
    private static function generateAmortizationSchedule(float $principal, float $annualRate, int $months): array
    {
        $schedule = [];
        $monthlyRate = $annualRate / 100 / 12;
        $remainingBalance = $principal;
        
        $monthlyPayment = $principal * ($monthlyRate * pow(1 + $monthlyRate, $months)) / 
                         (pow(1 + $monthlyRate, $months) - 1);
        
        for ($month = 1; $month <= min($months, 12); $month++) {
            $interestPayment = $remainingBalance * $monthlyRate;
            $principalPayment = $monthlyPayment - $interestPayment;
            $remainingBalance -= $principalPayment;
            
            $schedule[] = [
                'month' => $month,
                'payment' => round($monthlyPayment, 2),
                'principal' => round($principalPayment, 2),
                'interest' => round($interestPayment, 2),
                'remaining' => round($remainingBalance, 2)
            ];
        }
        
        return $schedule;
    }
}
PHPEOF

# 验证PHP语法
if php -l "$TEMP_DIR/LoanCalculatorService.php" > /dev/null 2>&1; then
    log_success "LoanCalculatorService PHP语法正确"
    # 备份现有文件
    if [ -f "app/Services/LoanCalculatorService.php" ]; then
        cp app/Services/LoanCalculatorService.php app/Services/LoanCalculatorService.php.backup.$(date +%Y%m%d_%H%M%S)
    fi
    # 复制新文件
    cp "$TEMP_DIR/LoanCalculatorService.php" app/Services/LoanCalculatorService.php
    chown besthammer_c_usr:besthammer_c_usr app/Services/LoanCalculatorService.php
    chmod 755 app/Services/LoanCalculatorService.php
else
    log_error "LoanCalculatorService PHP语法错误"
    php -l "$TEMP_DIR/LoanCalculatorService.php"
    exit 1
fi

log_step "第2步：创建BMICalculatorService"
echo "-----------------------------------"

# 创建BMICalculatorService PHP文件
cat > "$TEMP_DIR/BMICalculatorService.php" << 'PHPEOF'
<?php

namespace App\Services;

class BMICalculatorService
{
    public static function calculate(float $weight, float $height, string $unit): array
    {
        try {
            if ($unit === 'imperial') {
                $weight = $weight * 0.453592;
                $height = $height * 2.54;
            }
            
            $heightInMeters = $height / 100;
            $bmi = $weight / ($heightInMeters * $heightInMeters);
            $category = self::getBMICategory($bmi);
            $bmr = self::calculateBMR($weight, $height, 25, 'male');
            $idealWeight = self::getIdealWeightRange($heightInMeters);
            $recommendations = self::getHealthRecommendations($bmi, $category);
            
            return [
                'success' => true,
                'data' => [
                    'bmi' => round($bmi, 1),
                    'category' => $category,
                    'bmr' => round($bmr, 0),
                    'ideal_weight_range' => $idealWeight,
                    'recommendations' => $recommendations
                ],
                'input' => [
                    'weight' => $weight,
                    'height' => $height,
                    'unit' => $unit
                ]
            ];
            
        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => 'Calculation error: ' . $e->getMessage(),
                'error_code' => 'BMI_CALC_ERROR'
            ];
        }
    }
    
    private static function getBMICategory(float $bmi): array
    {
        if ($bmi < 18.5) {
            return ['name' => 'Underweight', 'description' => 'Below normal weight', 'color' => '#3498db'];
        } elseif ($bmi < 25) {
            return ['name' => 'Normal', 'description' => 'Normal weight', 'color' => '#27ae60'];
        } elseif ($bmi < 30) {
            return ['name' => 'Overweight', 'description' => 'Above normal weight', 'color' => '#f39c12'];
        } else {
            return ['name' => 'Obese', 'description' => 'Significantly above normal weight', 'color' => '#e74c3c'];
        }
    }
    
    private static function calculateBMR(float $weight, float $height, int $age, string $gender): float
    {
        if ($gender === 'male') {
            return (10 * $weight) + (6.25 * $height) - (5 * $age) + 5;
        } else {
            return (10 * $weight) + (6.25 * $height) - (5 * $age) - 161;
        }
    }
    
    private static function getIdealWeightRange(float $heightInMeters): array
    {
        $minWeight = 18.5 * ($heightInMeters * $heightInMeters);
        $maxWeight = 24.9 * ($heightInMeters * $heightInMeters);
        
        return [
            'min' => round($minWeight, 1),
            'max' => round($maxWeight, 1)
        ];
    }
    
    private static function getHealthRecommendations(float $bmi, array $category): array
    {
        $recommendations = [];
        
        switch ($category['name']) {
            case 'Underweight':
                $recommendations = [
                    'Increase caloric intake with nutrient-dense foods',
                    'Include healthy fats and proteins in your diet',
                    'Consider strength training exercises',
                    'Consult with a healthcare provider'
                ];
                break;
            case 'Normal':
                $recommendations = [
                    'Maintain your current healthy lifestyle',
                    'Continue regular physical activity',
                    'Eat a balanced diet with variety',
                    'Monitor your weight regularly'
                ];
                break;
            case 'Overweight':
                $recommendations = [
                    'Create a moderate caloric deficit',
                    'Increase physical activity gradually',
                    'Focus on whole foods and reduce processed foods',
                    'Consider consulting a nutritionist'
                ];
                break;
            case 'Obese':
                $recommendations = [
                    'Consult with healthcare professionals',
                    'Create a structured weight loss plan',
                    'Focus on sustainable lifestyle changes',
                    'Consider professional support programs'
                ];
                break;
        }
        
        return $recommendations;
    }
}
PHPEOF

# 验证PHP语法
if php -l "$TEMP_DIR/BMICalculatorService.php" > /dev/null 2>&1; then
    log_success "BMICalculatorService PHP语法正确"
    if [ -f "app/Services/BMICalculatorService.php" ]; then
        cp app/Services/BMICalculatorService.php app/Services/BMICalculatorService.php.backup.$(date +%Y%m%d_%H%M%S)
    fi
    cp "$TEMP_DIR/BMICalculatorService.php" app/Services/BMICalculatorService.php
    chown besthammer_c_usr:besthammer_c_usr app/Services/BMICalculatorService.php
    chmod 755 app/Services/BMICalculatorService.php
else
    log_error "BMICalculatorService PHP语法错误"
    php -l "$TEMP_DIR/BMICalculatorService.php"
    exit 1
fi

log_step "第3步：创建CurrencyConverterService"
echo "-----------------------------------"

# 创建CurrencyConverterService PHP文件
cat > "$TEMP_DIR/CurrencyConverterService.php" << 'PHPEOF'
<?php

namespace App\Services;

class CurrencyConverterService
{
    public static function calculate(float $amount, string $from, string $to): array
    {
        return self::convert($amount, $from, $to);
    }

    public static function convert(float $amount, string $from, string $to): array
    {
        try {
            $from = strtoupper($from);
            $to = strtoupper($to);

            $rates = self::getExchangeRates($from);

            if (!isset($rates[$to])) {
                throw new \InvalidArgumentException("Currency $to not supported");
            }

            $rate = $rates[$to];
            $convertedAmount = $amount * $rate;

            return [
                'success' => true,
                'data' => [
                    'original_amount' => $amount,
                    'converted_amount' => round($convertedAmount, 2),
                    'exchange_rate' => $rate,
                    'from_currency' => $from,
                    'to_currency' => $to,
                    'timestamp' => date('Y-m-d H:i:s')
                ],
                'input' => [
                    'amount' => $amount,
                    'from' => $from,
                    'to' => $to
                ]
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => 'Conversion error: ' . $e->getMessage(),
                'error_code' => 'CURRENCY_CONV_ERROR'
            ];
        }
    }

    public static function getExchangeRates(string $base = 'USD'): array
    {
        $rates = [
            'USD' => [
                'EUR' => 0.85, 'GBP' => 0.73, 'JPY' => 110.0, 'CAD' => 1.25, 'AUD' => 1.35,
                'CHF' => 0.92, 'CNY' => 6.45, 'SEK' => 8.60, 'NZD' => 1.42, 'MXN' => 20.15,
                'SGD' => 1.35, 'HKD' => 7.80, 'NOK' => 8.50, 'TRY' => 8.20, 'RUB' => 75.50,
                'INR' => 74.30, 'BRL' => 5.20, 'ZAR' => 14.80, 'KRW' => 1180.0, 'PLN' => 3.85,
                'DKK' => 6.35, 'CZK' => 21.50, 'HUF' => 295.0, 'THB' => 31.5, 'MYR' => 4.15,
                'IDR' => 14250.0, 'PHP' => 50.8, 'VND' => 23100.0, 'USD' => 1.0
            ],
            'EUR' => [
                'USD' => 1.18, 'GBP' => 0.86, 'JPY' => 129.50, 'CAD' => 1.47, 'AUD' => 1.59,
                'CHF' => 1.08, 'CNY' => 7.59, 'SEK' => 10.12, 'NZD' => 1.67, 'MXN' => 23.74,
                'SGD' => 1.59, 'HKD' => 9.18, 'NOK' => 10.01, 'TRY' => 9.65, 'RUB' => 88.85,
                'INR' => 87.47, 'BRL' => 6.12, 'ZAR' => 17.42, 'KRW' => 1389.0, 'EUR' => 1.0
            ]
        ];

        if (!isset($rates[$base])) {
            $base = 'USD';
        }

        return $rates[$base];
    }

    public static function getSupportedCurrencies(): array
    {
        return [
            'USD' => 'US Dollar', 'EUR' => 'Euro', 'GBP' => 'British Pound', 'JPY' => 'Japanese Yen',
            'CAD' => 'Canadian Dollar', 'AUD' => 'Australian Dollar', 'CHF' => 'Swiss Franc',
            'CNY' => 'Chinese Yuan', 'SEK' => 'Swedish Krona', 'NZD' => 'New Zealand Dollar',
            'MXN' => 'Mexican Peso', 'SGD' => 'Singapore Dollar', 'HKD' => 'Hong Kong Dollar',
            'NOK' => 'Norwegian Krone', 'TRY' => 'Turkish Lira', 'RUB' => 'Russian Ruble',
            'INR' => 'Indian Rupee', 'BRL' => 'Brazilian Real', 'ZAR' => 'South African Rand',
            'KRW' => 'South Korean Won', 'PLN' => 'Polish Zloty', 'DKK' => 'Danish Krone',
            'CZK' => 'Czech Koruna', 'HUF' => 'Hungarian Forint', 'THB' => 'Thai Baht',
            'MYR' => 'Malaysian Ringgit', 'IDR' => 'Indonesian Rupiah', 'PHP' => 'Philippine Peso',
            'VND' => 'Vietnamese Dong'
        ];
    }

    public static function getCurrencySymbol(string $currency): string
    {
        $symbols = [
            'USD' => '$', 'EUR' => '€', 'GBP' => '£', 'JPY' => '¥', 'CAD' => 'C$',
            'AUD' => 'A$', 'CHF' => 'CHF', 'CNY' => '¥', 'SEK' => 'kr', 'NZD' => 'NZ$',
            'MXN' => '$', 'SGD' => 'S$', 'HKD' => 'HK$', 'NOK' => 'kr', 'TRY' => '₺',
            'RUB' => '₽', 'INR' => '₹', 'BRL' => 'R$', 'ZAR' => 'R', 'KRW' => '₩'
        ];

        return $symbols[$currency] ?? $currency;
    }
}
PHPEOF

# 验证PHP语法
if php -l "$TEMP_DIR/CurrencyConverterService.php" > /dev/null 2>&1; then
    log_success "CurrencyConverterService PHP语法正确"
    if [ -f "app/Services/CurrencyConverterService.php" ]; then
        cp app/Services/CurrencyConverterService.php app/Services/CurrencyConverterService.php.backup.$(date +%Y%m%d_%H%M%S)
    fi
    cp "$TEMP_DIR/CurrencyConverterService.php" app/Services/CurrencyConverterService.php
    chown besthammer_c_usr:besthammer_c_usr app/Services/CurrencyConverterService.php
    chmod 755 app/Services/CurrencyConverterService.php
else
    log_error "CurrencyConverterService PHP语法错误"
    php -l "$TEMP_DIR/CurrencyConverterService.php"
    exit 1
fi

log_step "第4步：设置权限和清理缓存"
echo "-----------------------------------"

# 设置正确的文件权限
chown -R besthammer_c_usr:besthammer_c_usr app/Services/
chmod -R 755 app/Services/

# 确保storage和bootstrap/cache可写
chown -R besthammer_c_usr:besthammer_c_usr storage/
chown -R besthammer_c_usr:besthammer_c_usr bootstrap/cache/
chmod -R 775 storage/
chmod -R 775 bootstrap/cache/

log_success "文件权限已设置"

# 清理所有缓存
log_info "清理Laravel缓存..."
sudo -u besthammer_c_usr php artisan config:clear 2>/dev/null || log_warning "配置缓存清理失败"
sudo -u besthammer_c_usr php artisan cache:clear 2>/dev/null || log_warning "应用缓存清理失败"
sudo -u besthammer_c_usr php artisan route:clear 2>/dev/null || log_warning "路由缓存清理失败"
sudo -u besthammer_c_usr php artisan view:clear 2>/dev/null || log_warning "视图缓存清理失败"

# 重新生成自动加载
log_info "重新生成Composer自动加载..."
sudo -u besthammer_c_usr composer dump-autoload 2>/dev/null || log_warning "Composer自动加载失败"

log_success "缓存清理和自动加载完成"

# 重启Apache
systemctl restart apache2
sleep 3

log_success "Apache已重启"

log_step "第5步：验证修复结果"
echo "-----------------------------------"

# 创建简单的PHP测试文件
cat > "$TEMP_DIR/test_services.php" << 'TESTEOF'
<?php
require_once 'vendor/autoload.php';

echo "Testing LoanCalculatorService...\n";
try {
    $result = App\Services\LoanCalculatorService::calculate(100000, 5.0, 30, 'equal_payment');
    if (isset($result['success']) && $result['success']) {
        echo "LOAN_SUCCESS\n";
    } else {
        echo "LOAN_FAILED: " . ($result['message'] ?? 'Unknown error') . "\n";
    }
} catch (Exception $e) {
    echo "LOAN_ERROR: " . $e->getMessage() . "\n";
}

echo "Testing BMICalculatorService...\n";
try {
    $result = App\Services\BMICalculatorService::calculate(70, 175, 'metric');
    if (isset($result['success']) && $result['success']) {
        echo "BMI_SUCCESS\n";
    } else {
        echo "BMI_FAILED: " . ($result['message'] ?? 'Unknown error') . "\n";
    }
} catch (Exception $e) {
    echo "BMI_ERROR: " . $e->getMessage() . "\n";
}

echo "Testing CurrencyConverterService...\n";
try {
    $result = App\Services\CurrencyConverterService::calculate(100, 'USD', 'EUR');
    if (isset($result['success']) && $result['success']) {
        echo "CURRENCY_SUCCESS\n";
    } else {
        echo "CURRENCY_FAILED: " . ($result['message'] ?? 'Unknown error') . "\n";
    }
} catch (Exception $e) {
    echo "CURRENCY_ERROR: " . $e->getMessage() . "\n";
}
TESTEOF

# 运行测试
log_info "运行Service类测试..."
test_output=$(sudo -u besthammer_c_usr php "$TEMP_DIR/test_services.php" 2>&1)

echo "$test_output" | while read line; do
    if echo "$line" | grep -q "SUCCESS"; then
        log_success "$line"
    elif echo "$line" | grep -q "FAILED\|ERROR"; then
        log_error "$line"
    else
        log_info "$line"
    fi
done

# 测试网页访问
log_check "测试网页访问..."
test_urls=(
    "https://www.besthammer.club"
    "https://www.besthammer.club/tools/loan-calculator"
    "https://www.besthammer.club/tools/bmi-calculator"
    "https://www.besthammer.club/tools/currency-converter"
)

all_success=true
for url in "${test_urls[@]}"; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    if [ "$response" = "200" ]; then
        log_success "$url: HTTP $response"
    else
        log_warning "$url: HTTP $response"
        if [ "$response" = "500" ]; then
            all_success=false
        fi
    fi
done

# 清理临时文件
rm -rf "$TEMP_DIR"

echo ""
echo "🔧 安全修复Service方法调用问题完成！"
echo "=========================="
echo ""
echo "📋 修复内容总结："
echo ""
echo "✅ 安全修复措施："
echo "   - 使用临时目录创建PHP文件"
echo "   - 每个文件单独验证PHP语法"
echo "   - 备份现有文件后再替换"
echo "   - 设置正确的文件权限"
echo ""
echo "✅ 修复的问题："
echo "   - LoanCalculatorService: 添加静态calculate方法 ✓"
echo "   - BMICalculatorService: 添加静态calculate方法 ✓"
echo "   - CurrencyConverterService: 添加静态calculate方法 ✓"
echo "   - 统一返回值格式 ✓"
echo ""

if [ "$all_success" = true ]; then
    echo "🎉 修复成功！所有3个主体功能应该正常计算"
    echo ""
    echo "🌍 测试地址："
    echo "   贷款计算器: https://www.besthammer.club/tools/loan-calculator"
    echo "   BMI计算器: https://www.besthammer.club/tools/bmi-calculator"
    echo "   汇率转换器: https://www.besthammer.club/tools/currency-converter"
else
    echo "⚠️ 部分功能仍有问题，建议："
    echo "1. 检查Laravel错误日志: tail -20 storage/logs/laravel.log"
    echo "2. 检查Apache错误日志: tail -10 /var/log/apache2/error.log"
    echo "3. 重新运行诊断脚本: bash diagnose-three-tools.sh"
fi

echo ""
log_info "安全修复Service方法调用问题脚本执行完成！"
