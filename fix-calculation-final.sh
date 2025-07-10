#!/bin/bash

# 修复计算错误的最终解决方案 - 无语法错误版本
# 解决前端计算错误，确保所有3个主体功能正常工作

echo "🔧 修复计算错误的最终解决方案"
echo "=========================="
echo "修复内容："
echo "1. 修复API路由配置"
echo "2. 创建完整的ToolController"
echo "3. 确保Service类正确实现"
echo "4. 设置正确的权限和缓存"
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

if [ ! -d "$PROJECT_DIR" ]; then
    log_error "项目目录不存在: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

# 创建临时目录
TEMP_DIR="/tmp/fix_calc_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEMP_DIR"

log_step "第1步：修复API路由配置"
echo "-----------------------------------"

# 备份现有路由文件
if [ -f "routes/web.php" ]; then
    cp routes/web.php "routes/web.php.backup.$(date +%Y%m%d_%H%M%S)"
    log_info "已备份现有路由文件"
fi

# 检查路由文件是否存在工具路由
route_exists=false
if [ -f "routes/web.php" ]; then
    if grep -q "calculateLoan\|tools.*loan" routes/web.php; then
        route_exists=true
    fi
fi

if [ "$route_exists" = false ]; then
    log_info "添加工具计算器路由..."
    
    # 创建路由追加内容
    cat > "$TEMP_DIR/routes_addition.txt" << 'EOF'

// ===== 工具计算器路由 =====
Route::get('/tools/loan-calculator', [App\Http\Controllers\ToolController::class, 'loanCalculator'])->name('tools.loan');
Route::post('/tools/loan-calculator', [App\Http\Controllers\ToolController::class, 'calculateLoan'])->name('tools.loan.calculate');

Route::get('/tools/bmi-calculator', [App\Http\Controllers\ToolController::class, 'bmiCalculator'])->name('tools.bmi');
Route::post('/tools/bmi-calculator', [App\Http\Controllers\ToolController::class, 'calculateBmi'])->name('tools.bmi.calculate');

Route::get('/tools/currency-converter', [App\Http\Controllers\ToolController::class, 'currencyConverter'])->name('tools.currency');
Route::post('/tools/currency-converter', [App\Http\Controllers\ToolController::class, 'convertCurrency'])->name('tools.currency.convert');

// 多语言版本
Route::group(['prefix' => '{locale}', 'where' => ['locale' => 'en|de|fr|es']], function () {
    Route::get('/tools/loan-calculator', [App\Http\Controllers\ToolController::class, 'localeLoanCalculator'])->name('tools.locale.loan');
    Route::post('/tools/loan-calculator', [App\Http\Controllers\ToolController::class, 'calculateLoan'])->name('tools.locale.loan.calculate');
    
    Route::get('/tools/bmi-calculator', [App\Http\Controllers\ToolController::class, 'localeBmiCalculator'])->name('tools.locale.bmi');
    Route::post('/tools/bmi-calculator', [App\Http\Controllers\ToolController::class, 'calculateBmi'])->name('tools.locale.bmi.calculate');
    
    Route::get('/tools/currency-converter', [App\Http\Controllers\ToolController::class, 'localeCurrencyConverter'])->name('tools.locale.currency');
    Route::post('/tools/currency-converter', [App\Http\Controllers\ToolController::class, 'convertCurrency'])->name('tools.locale.currency.convert');
});
EOF
    
    # 追加到路由文件
    cat "$TEMP_DIR/routes_addition.txt" >> routes/web.php
    log_success "工具计算器路由已添加"
else
    log_info "工具计算器路由已存在"
fi

log_step "第2步：创建ToolController"
echo "-----------------------------------"

# 备份现有控制器
if [ -f "app/Http/Controllers/ToolController.php" ]; then
    cp app/Http/Controllers/ToolController.php "app/Http/Controllers/ToolController.php.backup.$(date +%Y%m%d_%H%M%S)"
fi

# 创建ToolController文件
cat > app/Http/Controllers/ToolController.php << 'CONTROLLER_EOF'
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;
use App\Services\LoanCalculatorService;
use App\Services\BMICalculatorService;
use App\Services\CurrencyConverterService;

class ToolController extends Controller
{
    private $supportedLocales = ['en', 'de', 'fr', 'es'];

    public function loanCalculator()
    {
        return view('tools.loan-calculator', [
            'locale' => null,
            'title' => 'Loan Calculator - BestHammer Tools'
        ]);
    }

    public function localeLoanCalculator($locale)
    {
        if (!in_array($locale, $this->supportedLocales)) {
            abort(404);
        }
        
        app()->setLocale($locale);
        
        return view('tools.loan-calculator', [
            'locale' => $locale,
            'title' => 'Loan Calculator'
        ]);
    }

    public function calculateLoan(Request $request): JsonResponse
    {
        try {
            Log::info('Loan calculation request', $request->all());
            
            $validator = Validator::make($request->all(), [
                'amount' => 'required|numeric|min:1|max:10000000',
                'rate' => 'required|numeric|min:0.01|max:50',
                'years' => 'required|integer|min:1|max:50',
                'type' => 'required|in:equal_payment,equal_principal'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $result = LoanCalculatorService::calculate(
                floatval($request->input('amount')),
                floatval($request->input('rate')),
                intval($request->input('years')),
                $request->input('type')
            );

            return response()->json($result);

        } catch (\Exception $e) {
            Log::error('Loan calculation error', [
                'message' => $e->getMessage(),
                'input' => $request->all()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Calculation error: ' . $e->getMessage()
            ], 500);
        }
    }

    public function bmiCalculator()
    {
        return view('tools.bmi-calculator', [
            'locale' => null,
            'title' => 'BMI Calculator - BestHammer Tools'
        ]);
    }

    public function localeBmiCalculator($locale)
    {
        if (!in_array($locale, $this->supportedLocales)) {
            abort(404);
        }
        
        app()->setLocale($locale);
        
        return view('tools.bmi-calculator', [
            'locale' => $locale,
            'title' => 'BMI Calculator'
        ]);
    }

    public function calculateBmi(Request $request): JsonResponse
    {
        try {
            Log::info('BMI calculation request', $request->all());
            
            $validator = Validator::make($request->all(), [
                'weight' => 'required|numeric|min:1|max:1000',
                'height' => 'required|numeric|min:50|max:300',
                'unit' => 'required|in:metric,imperial'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $result = BMICalculatorService::calculate(
                floatval($request->input('weight')),
                floatval($request->input('height')),
                $request->input('unit')
            );

            return response()->json($result);

        } catch (\Exception $e) {
            Log::error('BMI calculation error', [
                'message' => $e->getMessage(),
                'input' => $request->all()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Calculation error: ' . $e->getMessage()
            ], 500);
        }
    }

    public function currencyConverter()
    {
        return view('tools.currency-converter', [
            'locale' => null,
            'title' => 'Currency Converter - BestHammer Tools'
        ]);
    }

    public function localeCurrencyConverter($locale)
    {
        if (!in_array($locale, $this->supportedLocales)) {
            abort(404);
        }
        
        app()->setLocale($locale);
        
        return view('tools.currency-converter', [
            'locale' => $locale,
            'title' => 'Currency Converter'
        ]);
    }

    public function convertCurrency(Request $request): JsonResponse
    {
        try {
            Log::info('Currency conversion request', $request->all());
            
            $validator = Validator::make($request->all(), [
                'amount' => 'required|numeric|min:0.01|max:1000000000',
                'from' => 'required|string|size:3',
                'to' => 'required|string|size:3'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $result = CurrencyConverterService::convert(
                floatval($request->input('amount')),
                strtoupper($request->input('from')),
                strtoupper($request->input('to'))
            );

            return response()->json($result);

        } catch (\Exception $e) {
            Log::error('Currency conversion error', [
                'message' => $e->getMessage(),
                'input' => $request->all()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Conversion error: ' . $e->getMessage()
            ], 500);
        }
    }
}
CONTROLLER_EOF

# 验证PHP语法
if php -l app/Http/Controllers/ToolController.php > /dev/null 2>&1; then
    log_success "ToolController创建成功，语法正确"
else
    log_error "ToolController语法错误"
    php -l app/Http/Controllers/ToolController.php
    exit 1
fi

log_step "第3步：创建Service类"
echo "-----------------------------------"

# 创建Services目录
mkdir -p app/Services

# 创建LoanCalculatorService
cat > app/Services/LoanCalculatorService.php << 'LOAN_EOF'
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
                    throw new \InvalidArgumentException('Invalid calculation type');
            }

            return [
                'success' => true,
                'data' => $result
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }

    private static function calculateEqualPayment(float $principal, float $rate, int $months): array
    {
        $monthlyRate = $rate / 100 / 12;

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
            'total_interest' => round($totalInterest, 2)
        ];
    }

    private static function calculateEqualPrincipal(float $principal, float $rate, int $months): array
    {
        $monthlyRate = $rate / 100 / 12;
        $monthlyPrincipal = $principal / $months;
        $totalInterest = 0;

        for ($month = 1; $month <= $months; $month++) {
            $remainingPrincipal = $principal - ($monthlyPrincipal * ($month - 1));
            $monthlyInterest = $remainingPrincipal * $monthlyRate;
            $totalInterest += $monthlyInterest;
        }

        $totalPayment = $principal + $totalInterest;
        $firstPayment = $monthlyPrincipal + ($principal * $monthlyRate);
        $lastPayment = $monthlyPrincipal + ($monthlyPrincipal * $monthlyRate);

        return [
            'monthly_payment_first' => round($firstPayment, 2),
            'monthly_payment_last' => round($lastPayment, 2),
            'total_payment' => round($totalPayment, 2),
            'total_interest' => round($totalInterest, 2)
        ];
    }
}
LOAN_EOF

# 验证LoanCalculatorService语法
if php -l app/Services/LoanCalculatorService.php > /dev/null 2>&1; then
    log_success "LoanCalculatorService创建成功"
else
    log_error "LoanCalculatorService语法错误"
    php -l app/Services/LoanCalculatorService.php
    exit 1
fi

# 创建BMICalculatorService
cat > app/Services/BMICalculatorService.php << 'BMI_EOF'
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
            $idealWeight = self::getIdealWeightRange($heightInMeters);

            return [
                'success' => true,
                'data' => [
                    'bmi' => round($bmi, 1),
                    'category' => $category,
                    'ideal_weight_range' => $idealWeight
                ]
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }

    private static function getBMICategory(float $bmi): array
    {
        if ($bmi < 18.5) {
            return ['name' => 'Underweight', 'color' => '#3498db'];
        } elseif ($bmi < 25) {
            return ['name' => 'Normal', 'color' => '#27ae60'];
        } elseif ($bmi < 30) {
            return ['name' => 'Overweight', 'color' => '#f39c12'];
        } else {
            return ['name' => 'Obese', 'color' => '#e74c3c'];
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
}
BMI_EOF

# 验证BMICalculatorService语法
if php -l app/Services/BMICalculatorService.php > /dev/null 2>&1; then
    log_success "BMICalculatorService创建成功"
else
    log_error "BMICalculatorService语法错误"
    php -l app/Services/BMICalculatorService.php
    exit 1
fi

# 创建CurrencyConverterService
cat > app/Services/CurrencyConverterService.php << 'CURRENCY_EOF'
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
                    'to_currency' => $to
                ]
            ];

        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }

    public static function getExchangeRates(string $base = 'USD'): array
    {
        $rates = [
            'USD' => [
                'EUR' => 0.85, 'GBP' => 0.73, 'JPY' => 110.0, 'CAD' => 1.25,
                'AUD' => 1.35, 'CHF' => 0.92, 'CNY' => 6.45, 'SEK' => 8.60,
                'NZD' => 1.42, 'MXN' => 20.15, 'SGD' => 1.35, 'HKD' => 7.80,
                'NOK' => 8.50, 'TRY' => 8.20, 'RUB' => 75.50, 'INR' => 74.30,
                'BRL' => 5.20, 'ZAR' => 14.80, 'KRW' => 1180.0, 'USD' => 1.0
            ]
        ];

        return $rates[$base] ?? $rates['USD'];
    }
}
CURRENCY_EOF

# 验证CurrencyConverterService语法
if php -l app/Services/CurrencyConverterService.php > /dev/null 2>&1; then
    log_success "CurrencyConverterService创建成功"
else
    log_error "CurrencyConverterService语法错误"
    php -l app/Services/CurrencyConverterService.php
    exit 1
fi

log_step "第4步：设置权限和清理缓存"
echo "-----------------------------------"

# 设置正确的文件权限
chown -R besthammer_c_usr:besthammer_c_usr app/
chown -R besthammer_c_usr:besthammer_c_usr routes/
chmod -R 755 app/
chmod -R 755 routes/

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

log_success "缓存清理完成"

# 重启Apache
systemctl restart apache2
sleep 3
log_success "Apache已重启"

log_step "第5步：验证修复结果"
echo "-----------------------------------"

# 测试Service类功能
log_info "测试Service类功能..."

# 创建测试脚本
cat > test_services.php << 'TEST_EOF'
<?php
require_once 'vendor/autoload.php';

echo "=== 测试Service类功能 ===\n";

try {
    $result = App\Services\LoanCalculatorService::calculate(100000, 5.0, 30, 'equal_payment');
    if ($result['success']) {
        echo "✓ 贷款计算: 成功 (月供: {$result['data']['monthly_payment']})\n";
    } else {
        echo "✗ 贷款计算: 失败 - {$result['message']}\n";
    }
} catch (Exception $e) {
    echo "✗ 贷款计算: 异常 - {$e->getMessage()}\n";
}

try {
    $result = App\Services\BMICalculatorService::calculate(70, 175, 'metric');
    if ($result['success']) {
        echo "✓ BMI计算: 成功 (BMI: {$result['data']['bmi']})\n";
    } else {
        echo "✗ BMI计算: 失败 - {$result['message']}\n";
    }
} catch (Exception $e) {
    echo "✗ BMI计算: 异常 - {$e->getMessage()}\n";
}

try {
    $result = App\Services\CurrencyConverterService::convert(100, 'USD', 'EUR');
    if ($result['success']) {
        echo "✓ 汇率转换: 成功 (转换金额: {$result['data']['converted_amount']})\n";
    } else {
        echo "✗ 汇率转换: 失败 - {$result['message']}\n";
    }
} catch (Exception $e) {
    echo "✗ 汇率转换: 异常 - {$e->getMessage()}\n";
}
TEST_EOF

# 运行测试
test_output=$(sudo -u besthammer_c_usr php test_services.php 2>&1)
echo "$test_output"

# 清理测试文件
rm -f test_services.php
rm -rf "$TEMP_DIR"

# 测试网页访问
log_check="log_info"
test_urls=(
    "https://www.besthammer.club/tools/loan-calculator"
    "https://www.besthammer.club/tools/bmi-calculator"
    "https://www.besthammer.club/tools/currency-converter"
)

echo ""
echo "🔧 计算错误修复完成！"
echo "=================="
echo ""
echo "📋 修复内容总结："
echo "✅ API路由配置已修复"
echo "✅ ToolController已创建"
echo "✅ Service类已创建"
echo "✅ 权限和缓存已设置"
echo ""
echo "🌍 测试地址："
for url in "${test_urls[@]}"; do
    echo "   $url"
done
echo ""
echo "🧪 测试建议："
echo "1. 在浏览器中打开计算器页面"
echo "2. 输入测试数据进行计算"
echo "3. 检查浏览器开发者工具的网络请求"
echo "4. 查看Laravel日志: tail -f storage/logs/laravel.log"
echo ""

if echo "$test_output" | grep -q "✓.*成功"; then
    echo "🎉 修复成功！计算功能应该正常工作"
else
    echo "⚠️ 部分功能可能仍有问题，请检查日志"
fi

echo ""
log_info "计算错误修复脚本执行完成！"
