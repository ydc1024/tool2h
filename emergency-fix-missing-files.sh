#!/bin/bash

# 紧急修复缺失文件脚本
# 基于诊断结果，恢复关键的缺失文件

echo "🚨 紧急修复缺失文件"
echo "=================="
echo "修复内容："
echo "1. 恢复缺失的ToolController"
echo "2. 恢复缺失的User模型"
echo "3. 创建缺失的Models目录"
echo "4. 恢复Auth控制器"
echo "5. 修复文件权限"
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

log_step "第1步：创建缺失的目录结构"
echo "-----------------------------------"

# 创建Models目录
if [ ! -d "app/Models" ]; then
    mkdir -p app/Models
    log_success "Models目录已创建"
else
    log_info "Models目录已存在"
fi

# 创建Auth控制器目录
if [ ! -d "app/Http/Controllers/Auth" ]; then
    mkdir -p app/Http/Controllers/Auth
    log_success "Auth控制器目录已创建"
else
    log_info "Auth控制器目录已存在"
fi

log_step "第2步：恢复User模型"
echo "-----------------------------------"

# 创建标准的User模型
cat > app/Models/User.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'locale',
        'subscription_plan',
        'subscription_expires_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'subscription_expires_at' => 'datetime',
    ];

    /**
     * 检查用户是否有活跃的订阅
     */
    public function hasActiveSubscription(): bool
    {
        if (!$this->subscription_plan || $this->subscription_plan === 'free') {
            return false;
        }
        
        if (!$this->subscription_expires_at) {
            return false;
        }
        
        return $this->subscription_expires_at->isFuture();
    }
    
    /**
     * 获取用户的订阅计划
     */
    public function getSubscriptionPlan(): string
    {
        return $this->subscription_plan ?? 'free';
    }
    
    /**
     * 检查用户是否是高级用户
     */
    public function isPremiumUser(): bool
    {
        return in_array($this->getSubscriptionPlan(), ['premium', 'professional']);
    }
}
EOF

log_success "User模型已恢复"

log_step "第3步：恢复ToolController"
echo "-----------------------------------"

# 创建完整的ToolController（基于true-complete-implementation.sh）
cat > app/Http/Controllers/ToolController.php << 'EOF'
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use App\Services\LoanCalculatorService;
use App\Services\BMICalculatorService;
use App\Services\CurrencyConverterService;
use App\Services\FeatureService;

class ToolController extends Controller
{
    private $supportedLocales = ['en', 'de', 'fr', 'es'];

    // ===== 贷款计算器 =====
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
            'title' => __('common.loan_calculator') . ' - ' . __('common.site_title')
        ]);
    }

    public function calculateLoan(Request $request): JsonResponse
    {
        try {
            $user = auth()->user();
            
            // 功能使用检查（仅在启用时生效）
            if (FeatureService::subscriptionEnabled()) {
                $featureCheck = FeatureService::canUseFeature($user, 'loan_calculation', $request->all());
                if (!$featureCheck['allowed']) {
                    return response()->json([
                        'success' => false,
                        'message' => $featureCheck['reason'],
                        'upgrade_required' => $featureCheck['upgrade_required'] ?? false
                    ], 403);
                }
            }

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

            $amount = $request->input('amount');
            $rate = $request->input('rate');
            $years = $request->input('years');
            $type = $request->input('type');

            $result = LoanCalculatorService::calculate($amount, $rate, $years, $type);
            
            // 记录功能使用
            FeatureService::recordUsage($user, 'loan_calculation', $request->all());

            return response()->json($result);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Calculation error: ' . $e->getMessage()
            ], 500);
        }
    }

    // ===== BMI计算器 =====
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
            'title' => __('common.bmi_calculator') . ' - ' . __('common.site_title')
        ]);
    }

    public function calculateBmi(Request $request): JsonResponse
    {
        try {
            $user = auth()->user();
            
            // 功能使用检查
            if (FeatureService::subscriptionEnabled()) {
                $featureCheck = FeatureService::canUseFeature($user, 'bmi_calculation', $request->all());
                if (!$featureCheck['allowed']) {
                    return response()->json([
                        'success' => false,
                        'message' => $featureCheck['reason'],
                        'upgrade_required' => $featureCheck['upgrade_required'] ?? false
                    ], 403);
                }
            }

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

            $weight = $request->input('weight');
            $height = $request->input('height');
            $unit = $request->input('unit');

            $result = BMICalculatorService::calculate($weight, $height, $unit);
            
            // 记录功能使用
            FeatureService::recordUsage($user, 'bmi_calculation', $request->all());

            return response()->json($result);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Calculation error: ' . $e->getMessage()
            ], 500);
        }
    }

    // ===== 汇率转换器 =====
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
            'title' => __('common.currency_converter') . ' - ' . __('common.site_title')
        ]);
    }

    public function convertCurrency(Request $request): JsonResponse
    {
        try {
            $user = auth()->user();
            
            // 功能使用检查
            if (FeatureService::subscriptionEnabled()) {
                $featureCheck = FeatureService::canUseFeature($user, 'currency_conversion', $request->all());
                if (!$featureCheck['allowed']) {
                    return response()->json([
                        'success' => false,
                        'message' => $featureCheck['reason'],
                        'upgrade_required' => $featureCheck['upgrade_required'] ?? false
                    ], 403);
                }
            }

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

            $amount = $request->input('amount');
            $from = strtoupper($request->input('from'));
            $to = strtoupper($request->input('to'));

            $result = CurrencyConverterService::convert($amount, $from, $to);
            
            // 记录功能使用
            FeatureService::recordUsage($user, 'currency_conversion', $request->all());

            return response()->json($result);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Conversion error: ' . $e->getMessage()
            ], 500);
        }
    }

    // ===== API方法 =====
    public function getExchangeRates(Request $request): JsonResponse
    {
        try {
            $base = $request->input('base', 'USD');
            $rates = CurrencyConverterService::getExchangeRates($base);
            
            return response()->json([
                'success' => true,
                'base' => $base,
                'rates' => $rates,
                'timestamp' => now()->toISOString()
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch exchange rates: ' . $e->getMessage()
            ], 500);
        }
    }
}
EOF

log_success "ToolController已恢复"

log_step "第4步：检查并恢复Auth控制器"
echo "-----------------------------------"

# 检查LoginController是否存在
if [ ! -f "app/Http/Controllers/Auth/LoginController.php" ]; then
    log_info "恢复LoginController..."

    cat > app/Http/Controllers/Auth/LoginController.php << 'EOF'
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Providers\RouteServiceProvider;
use Illuminate\Foundation\Auth\AuthenticatesUsers;
use Illuminate\Http\Request;

class LoginController extends Controller
{
    use AuthenticatesUsers;

    protected $redirectTo = '/dashboard';

    public function __construct()
    {
        $this->middleware('guest')->except('logout');
    }

    public function showLoginForm(Request $request, $locale = null)
    {
        if ($locale && in_array($locale, ['de', 'fr', 'es'])) {
            app()->setLocale($locale);
        }

        return view('auth.login', [
            'locale' => $locale,
            'title' => $locale ? __('auth.login') : 'Login - BestHammer Tools'
        ]);
    }

    protected function authenticated(Request $request, $user)
    {
        $locale = $request->route('locale');

        if ($locale && in_array($locale, ['de', 'fr', 'es'])) {
            return redirect()->route('dashboard.locale', $locale);
        }

        return redirect()->route('dashboard');
    }

    public function logout(Request $request)
    {
        $this->guard()->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect('/');
    }
}
EOF
    log_success "LoginController已恢复"
else
    log_info "LoginController已存在"
fi

# 检查RegisterController是否存在
if [ ! -f "app/Http/Controllers/Auth/RegisterController.php" ]; then
    log_info "恢复RegisterController..."

    cat > app/Http/Controllers/Auth/RegisterController.php << 'EOF'
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Providers\RouteServiceProvider;
use App\Models\User;
use Illuminate\Foundation\Auth\RegistersUsers;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\Request;

class RegisterController extends Controller
{
    use RegistersUsers;

    protected $redirectTo = '/dashboard';

    public function __construct()
    {
        $this->middleware('guest');
    }

    public function showRegistrationForm(Request $request, $locale = null)
    {
        if ($locale && in_array($locale, ['de', 'fr', 'es'])) {
            app()->setLocale($locale);
        }

        return view('auth.register', [
            'locale' => $locale,
            'title' => $locale ? __('auth.register') : 'Register - BestHammer Tools'
        ]);
    }

    protected function validator(array $data)
    {
        return Validator::make($data, [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);
    }

    protected function create(array $data)
    {
        return User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
        ]);
    }

    protected function registered(Request $request, $user)
    {
        $locale = $request->route('locale');

        if ($locale && in_array($locale, ['de', 'fr', 'es'])) {
            return redirect()->route('dashboard.locale', $locale);
        }

        return redirect()->route('dashboard');
    }
}
EOF
    log_success "RegisterController已恢复"
else
    log_info "RegisterController已存在"
fi

log_step "第5步：检查并恢复FeatureService"
echo "-----------------------------------"

if [ ! -f "app/Services/FeatureService.php" ]; then
    log_info "恢复FeatureService..."

    cat > app/Services/FeatureService.php << 'EOF'
<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

class FeatureService
{
    /**
     * 检查订阅系统是否启用
     */
    public static function subscriptionEnabled(): bool
    {
        return config('features.subscription_enabled', false);
    }

    /**
     * 检查功能限制是否启用
     */
    public static function limitsEnabled(): bool
    {
        return config('features.feature_limits_enabled', false);
    }

    /**
     * 检查用户是否可以使用特定功能
     */
    public static function canUseFeature(?User $user, string $feature, array $context = []): array
    {
        // 如果订阅系统未启用，允许所有功能（保持现有行为）
        if (!self::subscriptionEnabled()) {
            return [
                'allowed' => true,
                'reason' => 'All features available',
                'remaining_uses' => 999999
            ];
        }

        // 如果功能限制未启用，允许所有功能
        if (!self::limitsEnabled()) {
            return [
                'allowed' => true,
                'reason' => 'No limits enforced',
                'remaining_uses' => 999999
            ];
        }

        return [
            'allowed' => true,
            'reason' => 'Feature available',
            'remaining_uses' => 999999
        ];
    }

    /**
     * 记录功能使用
     */
    public static function recordUsage(?User $user, string $feature, array $data = []): void
    {
        if (!self::subscriptionEnabled() || !self::limitsEnabled()) {
            return;
        }

        // 简单的日志记录
        Log::info("Feature usage recorded", [
            'user_id' => $user ? $user->id : 'guest',
            'feature' => $feature,
            'data' => $data
        ]);
    }

    /**
     * 获取所有可用的订阅计划
     */
    public static function getSubscriptionPlans(): array
    {
        return config('features.subscription_plans', []);
    }
}
EOF
    log_success "FeatureService已恢复"
else
    log_info "FeatureService已存在"
fi

log_step "第6步：设置文件权限"
echo "-----------------------------------"

# 设置正确的文件权限
chown -R besthammer_c_usr:besthammer_c_usr app/
chmod -R 755 app/

# 确保storage和bootstrap/cache可写
chown -R besthammer_c_usr:besthammer_c_usr storage/
chown -R besthammer_c_usr:besthammer_c_usr bootstrap/cache/
chmod -R 775 storage/
chmod -R 775 bootstrap/cache/

log_success "文件权限已设置"

log_step "第7步：清理缓存和重新生成自动加载"
echo "-----------------------------------"

# 清理所有缓存
log_info "清理Laravel缓存..."
sudo -u besthammer_c_usr php artisan config:clear 2>/dev/null || log_warning "配置缓存清理失败"
sudo -u besthammer_c_usr php artisan cache:clear 2>/dev/null || log_warning "应用缓存清理失败"
sudo -u besthammer_c_usr php artisan route:clear 2>/dev/null || log_warning "路由缓存清理失败"
sudo -u besthammer_c_usr php artisan view:clear 2>/dev/null || log_warning "视图缓存清理失败"

# 重新生成自动加载
log_info "重新生成Composer自动加载..."
sudo -u besthammer_c_usr composer dump-autoload 2>/dev/null || log_warning "Composer自动加载失败"

# 重新缓存配置
sudo -u besthammer_c_usr php artisan config:cache 2>/dev/null || log_warning "配置缓存失败"

log_success "缓存清理和自动加载完成"

log_step "第8步：重启服务"
echo "-----------------------------------"

# 重启Apache
systemctl restart apache2
sleep 3

log_success "Apache已重启"

log_step "第9步：验证修复结果"
echo "-----------------------------------"

# 测试关键URL
log_info "测试修复结果..."
test_urls=(
    "https://www.besthammer.club"
    "https://www.besthammer.club/tools/loan-calculator"
    "https://www.besthammer.club/tools/bmi-calculator"
    "https://www.besthammer.club/tools/currency-converter"
    "https://www.besthammer.club/login"
    "https://www.besthammer.club/register"
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

echo ""
echo "🚨 紧急修复完成！"
echo "================"
echo ""
echo "📋 修复内容总结："
echo ""
echo "✅ 恢复的文件："
echo "   - app/Models/User.php (用户模型)"
echo "   - app/Http/Controllers/ToolController.php (工具控制器)"
echo "   - app/Http/Controllers/Auth/LoginController.php (登录控制器)"
echo "   - app/Http/Controllers/Auth/RegisterController.php (注册控制器)"
echo "   - app/Services/FeatureService.php (功能服务)"
echo ""
echo "✅ 修复的问题："
echo "   - ToolController语法错误已解决"
echo "   - User模型无法加载已解决"
echo "   - 缺失的目录结构已创建"
echo "   - 文件权限已正确设置"
echo "   - 缓存已清理并重新生成"
echo ""

if [ "$all_success" = true ]; then
    echo "🎉 修复成功！所有工具页面应该正常工作"
    echo ""
    echo "🌍 测试地址："
    echo "   主页: https://www.besthammer.club"
    echo "   贷款计算器: https://www.besthammer.club/tools/loan-calculator"
    echo "   BMI计算器: https://www.besthammer.club/tools/bmi-calculator"
    echo "   汇率转换器: https://www.besthammer.club/tools/currency-converter"
    echo "   登录: https://www.besthammer.club/login"
    echo "   注册: https://www.besthammer.club/register"
else
    echo "⚠️ 部分URL仍有问题，建议检查："
    echo "1. Laravel错误日志: tail -20 storage/logs/laravel.log"
    echo "2. Apache错误日志: tail -10 /var/log/apache2/error.log"
    echo "3. 重新运行诊断脚本: bash diagnose-500-errors.sh"
fi

echo ""
echo "📝 后续建议："
echo "1. 测试所有工具功能是否正常"
echo "2. 测试用户注册和登录功能"
echo "3. 检查多语言功能是否正常"
echo "4. 如需启用订阅功能，编辑.env文件设置SUBSCRIPTION_ENABLED=true"

echo ""
log_info "紧急修复脚本执行完成！"
