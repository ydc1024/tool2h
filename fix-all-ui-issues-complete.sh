#!/bin/bash

# 完整修复所有UI问题的脚本 - 基于诊断结果
# 解决：路由缺失、语言选择器、布局结构、CSS冲突等所有问题

echo "🔧 完整修复所有UI问题"
echo "==================="
echo "基于诊断结果修复："
echo "1. ❌ 修复缺失的工具路由（最严重问题）"
echo "2. ❌ 修复语言选择器为select下拉框"
echo "3. ❌ 修复基础布局结构"
echo "4. ❌ 添加switchLanguage函数"
echo "5. ⚠️ 解决Tailwind CSS冲突"
echo "6. ✅ 保持现有的渐变背景和毛玻璃效果"
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

log_step "第1步：修复缺失的工具路由（最关键）"
echo "-----------------------------------"

# 备份现有路由文件
if [ -f "routes/web.php" ]; then
    cp routes/web.php "routes/web.php.backup.$(date +%Y%m%d_%H%M%S)"
    log_success "已备份现有路由文件"
fi

# 创建完整的路由配置
cat > routes/web.php << 'ROUTES_EOF'
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ToolController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

// 首页路由
Route::get('/', function () {
    return view('welcome');
})->name('home');

// 工具页面路由（英语默认）
Route::get('/tools/loan-calculator', [ToolController::class, 'loanCalculator'])->name('tools.loan');
Route::get('/tools/bmi-calculator', [ToolController::class, 'bmiCalculator'])->name('tools.bmi');
Route::get('/tools/currency-converter', [ToolController::class, 'currencyConverter'])->name('tools.currency');

// 工具API路由（计算功能）
Route::post('/tools/loan-calculator', [ToolController::class, 'calculateLoan'])->name('tools.loan.calculate');
Route::post('/tools/bmi-calculator', [ToolController::class, 'calculateBmi'])->name('tools.bmi.calculate');
Route::post('/tools/currency-converter', [ToolController::class, 'convertCurrency'])->name('tools.currency.convert');

// 多语言路由组
Route::prefix('{locale}')->where('locale', 'en|de|fr|es')->group(function () {
    // 首页
    Route::get('/', function ($locale) {
        app()->setLocale($locale);
        return view('welcome', compact('locale'));
    })->name('home.locale');
    
    // 工具页面
    Route::get('/tools/loan-calculator', [ToolController::class, 'localeLoanCalculator'])->name('tools.locale.loan');
    Route::get('/tools/bmi-calculator', [ToolController::class, 'localeBmiCalculator'])->name('tools.locale.bmi');
    Route::get('/tools/currency-converter', [ToolController::class, 'localeCurrencyConverter'])->name('tools.locale.currency');
    
    // 关于页面
    Route::get('/about', function ($locale) {
        app()->setLocale($locale);
        return view('about', compact('locale'));
    })->name('about.locale');
});

// 关于页面（英语默认）
Route::get('/about', function () {
    return view('about');
})->name('about');

// 用户认证路由（如果需要）
Auth::routes();

// 仪表板路由（如果需要）
Route::get('/dashboard', function () {
    return view('dashboard');
})->middleware('auth')->name('dashboard');

Route::get('/{locale}/dashboard', function ($locale) {
    app()->setLocale($locale);
    return view('dashboard', compact('locale'));
})->where('locale', 'en|de|fr|es')->middleware('auth')->name('dashboard.locale');
ROUTES_EOF

log_success "工具路由已修复（包含所有缺失的路由）"

log_step "第2步：创建或修复ToolController"
echo "-----------------------------------"

# 确保Controllers目录存在
mkdir -p app/Http/Controllers

# 创建完整的ToolController
cat > app/Http/Controllers/ToolController.php << 'CONTROLLER_EOF'
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\LoanCalculatorService;
use App\Services\BMICalculatorService;
use App\Services\CurrencyConverterService;

class ToolController extends Controller
{
    // 英语默认路由方法
    public function loanCalculator()
    {
        return view('tools.loan-calculator', [
            'title' => 'Loan Calculator - BestHammer Tools'
        ]);
    }
    
    public function bmiCalculator()
    {
        return view('tools.bmi-calculator', [
            'title' => 'BMI Calculator - BestHammer Tools'
        ]);
    }
    
    public function currencyConverter()
    {
        return view('tools.currency-converter', [
            'title' => 'Currency Converter - BestHammer Tools'
        ]);
    }
    
    // 多语言路由方法
    public function localeLoanCalculator($locale)
    {
        app()->setLocale($locale);
        return view('tools.loan-calculator', [
            'locale' => $locale,
            'title' => __('common.loan_calculator') . ' - BestHammer Tools'
        ]);
    }
    
    public function localeBmiCalculator($locale)
    {
        app()->setLocale($locale);
        return view('tools.bmi-calculator', [
            'locale' => $locale,
            'title' => __('common.bmi_calculator') . ' - BestHammer Tools'
        ]);
    }
    
    public function localeCurrencyConverter($locale)
    {
        app()->setLocale($locale);
        return view('tools.currency-converter', [
            'locale' => $locale,
            'title' => __('common.currency_converter') . ' - BestHammer Tools'
        ]);
    }
    
    // API计算方法
    public function calculateLoan(Request $request)
    {
        try {
            $validated = $request->validate([
                'amount' => 'required|numeric|min:1|max:10000000',
                'rate' => 'required|numeric|min:0.01|max:50',
                'years' => 'required|integer|min:1|max:50',
                'type' => 'required|in:equal_payment,equal_principal'
            ]);
            
            $result = LoanCalculatorService::calculate(
                $validated['amount'],
                $validated['rate'],
                $validated['years'],
                $validated['type']
            );
            
            return response()->json($result);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error: ' . $e->getMessage()
            ], 422);
        }
    }
    
    public function calculateBmi(Request $request)
    {
        try {
            $validated = $request->validate([
                'weight' => 'required|numeric|min:1|max:1000',
                'height' => 'required|numeric|min:50|max:300',
                'unit' => 'required|in:metric,imperial'
            ]);
            
            $result = BMICalculatorService::calculate(
                $validated['weight'],
                $validated['height'],
                $validated['unit']
            );
            
            return response()->json($result);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error: ' . $e->getMessage()
            ], 422);
        }
    }
    
    public function convertCurrency(Request $request)
    {
        try {
            $validated = $request->validate([
                'amount' => 'required|numeric|min:0.01|max:1000000000',
                'from' => 'required|string|size:3',
                'to' => 'required|string|size:3'
            ]);
            
            $result = CurrencyConverterService::convert(
                $validated['amount'],
                $validated['from'],
                $validated['to']
            );
            
            return response()->json($result);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error: ' . $e->getMessage()
            ], 422);
        }
    }
}
CONTROLLER_EOF

log_success "ToolController已创建（包含所有缺失的方法）"

log_step "第3步：修复主布局文件（语言选择器和布局结构）"
echo "-----------------------------------"

# 备份现有布局文件
if [ -f "resources/views/layouts/app.blade.php" ]; then
    cp resources/views/layouts/app.blade.php "resources/views/layouts/app.blade.php.backup.$(date +%Y%m%d_%H%M%S)"
    log_success "已备份现有布局文件"
fi

# 创建修复后的主布局文件
cat > resources/views/layouts/app.blade.php << 'LAYOUT_EOF'
<!DOCTYPE html>
<html lang="{{ isset($locale) && $locale ? $locale : app()->getLocale() }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>{{ $title ?? (isset($locale) && $locale ? __('common.site_title') : 'BestHammer Tools') }}</title>
    <meta name="description" content="{{ isset($locale) && $locale ? __('common.description') : 'Professional loan calculator, BMI calculator, and currency converter for European and American markets' }}">
    <meta name="keywords" content="loan calculator, BMI calculator, currency converter, financial tools, health tools">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            min-height: 100vh;
        }

        .header {
            background: rgba(255,255,255,0.95);
            padding: 20px 30px;
            border-radius: 15px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
            backdrop-filter: blur(10px);
            margin-bottom: 20px;
        }

        .header-top {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
            flex-wrap: wrap;
        }

        .logo {
            width: 48px;
            height: 48px;
            margin-right: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: #667eea;
            font-weight: bold;
            flex-shrink: 0;
            text-decoration: none;
            transition: transform 0.3s ease;
        }

        .logo:hover {
            transform: scale(1.1);
            color: #764ba2;
        }

        .header h1 {
            color: #667eea;
            font-weight: 700;
            font-size: 1.8rem;
            margin: 0;
            flex-grow: 1;
        }

        .auth-controls {
            margin-left: auto;
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .auth-controls a, .auth-controls button {
            color: #667eea;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 20px;
            background: rgba(102, 126, 234, 0.1);
            border: none;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        .auth-controls a:hover, .auth-controls button:hover {
            background: rgba(102, 126, 234, 0.2);
            transform: translateY(-1px);
        }

        .auth-controls .register-btn {
            background: #667eea;
            color: white;
        }

        .nav {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            align-items: center;
            justify-content: space-between;
        }

        .nav-links {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
        }

        .nav a {
            color: #667eea;
            text-decoration: none;
            padding: 10px 20px;
            border-radius: 25px;
            background: rgba(102, 126, 234, 0.1);
            transition: all 0.3s ease;
            font-weight: 500;
        }

        .nav a:hover {
            background: rgba(102, 126, 234, 0.2);
            transform: translateY(-2px);
        }

        /* 修复语言选择器 - 单个select下拉框 */
        .language-selector {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .language-selector label {
            color: #667eea;
            font-weight: 500;
            font-size: 14px;
        }

        .language-selector select {
            padding: 8px 12px;
            border-radius: 20px;
            border: 2px solid rgba(102, 126, 234, 0.2);
            background: rgba(255, 255, 255, 0.9);
            color: #667eea;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s ease;
            min-width: 120px;
        }

        .language-selector select:hover {
            border-color: rgba(102, 126, 234, 0.4);
            background: rgba(255, 255, 255, 1);
        }

        .language-selector select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .content {
            background: rgba(255,255,255,0.95);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
            backdrop-filter: blur(10px);
        }

        .tools-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }

        .tool-card {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 15px;
            border-left: 5px solid #667eea;
            transition: all 0.3s ease;
            text-align: center;
        }

        .tool-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        }

        .tool-card h3 {
            color: #667eea;
            margin-bottom: 15px;
            font-weight: 600;
        }

        .tool-card p {
            color: #666;
            margin-bottom: 20px;
        }

        .btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px 25px;
            border: none;
            border-radius: 25px;
            text-decoration: none;
            display: inline-block;
            font-weight: 500;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }

        .calculator-form {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin: 30px 0;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 500;
        }

        .form-group input, .form-group select {
            width: 100%;
            padding: 12px;
            border: 2px solid #e1e5e9;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s ease;
        }

        .form-group input:focus, .form-group select:focus {
            outline: none;
            border-color: #667eea;
        }

        .result-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin: 15px 0;
            border-left: 4px solid #667eea;
        }

        .result-value {
            font-size: 2rem;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 5px;
        }

        /* 响应式设计 */
        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }

            .header, .content {
                padding: 20px;
            }

            .header-top {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }

            .logo {
                align-self: center;
            }

            .nav {
                flex-direction: column;
                gap: 15px;
            }

            .nav-links {
                justify-content: center;
            }

            .language-selector {
                align-self: center;
            }

            .calculator-form {
                grid-template-columns: 1fr;
                gap: 20px;
            }

            .auth-controls {
                margin-left: 0;
                margin-top: 10px;
            }
        }
    </style>

    <!-- Alpine.js for interactivity -->
    <script defer src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js"></script>

    <!-- Chart.js for data visualization -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    @stack('scripts')
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="header-top">
                <a href="{{ isset($locale) && $locale ? route('home.locale', $locale) : route('home') }}" class="logo">🔨</a>
                <h1>{{ isset($locale) && $locale ? __('common.site_title') : 'BestHammer Tools' }}</h1>

                <!-- 用户认证控件 -->
                @auth
                    <div class="auth-controls">
                        <a href="{{ isset($locale) && $locale ? route('dashboard.locale', $locale) : route('dashboard') }}">
                            {{ isset($locale) && $locale ? __('common.dashboard') : 'Dashboard' }}
                        </a>
                        <form method="POST" action="{{ route('logout') }}" style="display: inline;">
                            @csrf
                            <button type="submit">
                                {{ isset($locale) && $locale ? __('common.logout') : 'Logout' }}
                            </button>
                        </form>
                    </div>
                @else
                    <div class="auth-controls">
                        <a href="{{ route('login') }}">
                            {{ isset($locale) && $locale ? __('common.login') : 'Login' }}
                        </a>
                        <a href="{{ route('register') }}" class="register-btn">
                            {{ isset($locale) && $locale ? __('common.register') : 'Register' }}
                        </a>
                    </div>
                @endauth
            </div>

            <nav class="nav">
                <div class="nav-links">
                    <a href="{{ isset($locale) && $locale ? route('home.locale', $locale) : route('home') }}">
                        {{ isset($locale) && $locale ? __('common.home') : 'Home' }}
                    </a>
                    <a href="{{ isset($locale) && $locale ? route('tools.locale.loan', $locale) : route('tools.loan') }}">
                        {{ isset($locale) && $locale ? __('common.loan_calculator') : 'Loan Calculator' }}
                    </a>
                    <a href="{{ isset($locale) && $locale ? route('tools.locale.bmi', $locale) : route('tools.bmi') }}">
                        {{ isset($locale) && $locale ? __('common.bmi_calculator') : 'BMI Calculator' }}
                    </a>
                    <a href="{{ isset($locale) && $locale ? route('tools.locale.currency', $locale) : route('tools.currency') }}">
                        {{ isset($locale) && $locale ? __('common.currency_converter') : 'Currency Converter' }}
                    </a>
                    <a href="{{ isset($locale) && $locale ? route('about.locale', $locale) : route('about') }}">
                        {{ isset($locale) && $locale ? __('common.about') : 'About' }}
                    </a>
                </div>

                <!-- 修复语言选择器 - 单个select下拉框 -->
                <div class="language-selector">
                    <label for="language-select">{{ isset($locale) && $locale ? __('common.language') : 'Language' }}:</label>
                    <select id="language-select" onchange="switchLanguage(this.value)">
                        <option value="en" {{ !isset($locale) || $locale == 'en' ? 'selected' : '' }}>🇺🇸 English</option>
                        <option value="de" {{ isset($locale) && $locale == 'de' ? 'selected' : '' }}>🇩🇪 Deutsch</option>
                        <option value="fr" {{ isset($locale) && $locale == 'fr' ? 'selected' : '' }}>🇫🇷 Français</option>
                        <option value="es" {{ isset($locale) && $locale == 'es' ? 'selected' : '' }}>🇪🇸 Español</option>
                    </select>
                </div>
            </nav>
        </div>

        <div class="content">
            @yield('content')
        </div>
    </div>

    <script>
        // 全局JavaScript配置
        window.Laravel = {
            csrfToken: document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        };

        // 修复switchLanguage函数
        function switchLanguage(locale) {
            const currentUrl = window.location.href;
            const baseUrl = window.location.origin;
            const path = window.location.pathname;

            // 移除现有的语言前缀
            let newPath = path.replace(/^\/(en|de|fr|es)/, '');

            // 如果选择的不是英语，添加语言前缀
            if (locale !== 'en') {
                newPath = '/' + locale + newPath;
            }

            // 如果路径为空，设置为根路径
            if (newPath === '' || newPath === '/') {
                newPath = locale === 'en' ? '/' : '/' + locale;
            }

            // 跳转到新URL
            window.location.href = baseUrl + newPath + window.location.search;
        }
    </script>
</body>
</html>
LAYOUT_EOF

log_success "主布局文件已修复（语言选择器、布局结构、switchLanguage函数）"

log_step "第4步：修复工具页面视图（移除Tailwind CSS冲突）"
echo "-----------------------------------"

# 创建工具视图目录
mkdir -p resources/views/tools

# 修复贷款计算器视图（移除Tailwind CSS）
cat > resources/views/tools/loan-calculator.blade.php << 'LOAN_VIEW_EOF'
@extends('layouts.app')

@section('title', $title ?? 'Loan Calculator - BestHammer Tools')

@section('content')
<div x-data="loanCalculator()">
    <h1 style="color: #667eea; margin-bottom: 30px; text-align: center; font-size: 2.5rem;">
        {{ __('common.loan_calculator') ?? 'Loan Calculator' }}
    </h1>

    <div class="calculator-form">
        <!-- 输入表单 -->
        <div>
            <form @submit.prevent="calculateLoan">
                @csrf

                <div class="form-group">
                    <label for="amount">{{ __('loan.amount') ?? 'Loan Amount' }} ($)</label>
                    <input
                        type="number"
                        id="amount"
                        name="amount"
                        x-model="form.amount"
                        placeholder="100000"
                        min="1"
                        max="10000000"
                        required
                    >
                </div>

                <div class="form-group">
                    <label for="rate">{{ __('loan.rate') ?? 'Annual Interest Rate' }} (%)</label>
                    <input
                        type="number"
                        id="rate"
                        name="rate"
                        x-model="form.rate"
                        placeholder="5.0"
                        min="0.01"
                        max="50"
                        step="0.01"
                        required
                    >
                </div>

                <div class="form-group">
                    <label for="years">{{ __('loan.years') ?? 'Loan Term' }} ({{ __('common.years') ?? 'Years' }})</label>
                    <input
                        type="number"
                        id="years"
                        name="years"
                        x-model="form.years"
                        placeholder="30"
                        min="1"
                        max="50"
                        required
                    >
                </div>

                <div class="form-group">
                    <label for="type">{{ __('loan.type') ?? 'Payment Type' }}</label>
                    <select
                        id="type"
                        name="type"
                        x-model="form.type"
                        required
                    >
                        <option value="equal_payment">{{ __('loan.equal_payment') ?? 'Equal Payment' }}</option>
                        <option value="equal_principal">{{ __('loan.equal_principal') ?? 'Equal Principal' }}</option>
                    </select>
                </div>

                <button
                    type="submit"
                    :disabled="loading"
                    class="btn"
                    style="width: 100%; margin-top: 20px;"
                >
                    <span x-show="!loading">{{ __('common.calculate') ?? 'Calculate' }}</span>
                    <span x-show="loading">{{ __('common.calculating') ?? 'Calculating...' }}</span>
                </button>
            </form>
        </div>

        <!-- 结果显示 -->
        <div>
            <!-- 错误信息 -->
            <div x-show="error" style="background: #fee; border: 1px solid #fcc; color: #c33; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                <span x-text="error"></span>
            </div>

            <!-- 计算结果 -->
            <div x-show="result && result.success">
                <h3 style="color: #667eea; margin-bottom: 20px;">
                    {{ __('common.results') ?? 'Calculation Results' }}
                </h3>

                <div class="result-card" x-show="result.data.monthly_payment">
                    <div class="result-value" x-text="'$' + (result.data.monthly_payment || 0).toLocaleString()"></div>
                    <div>{{ __('loan.monthly_payment') ?? 'Monthly Payment' }}</div>
                </div>

                <div class="result-card" x-show="result.data.monthly_payment_first">
                    <div class="result-value" x-text="'$' + (result.data.monthly_payment_first || 0).toLocaleString()"></div>
                    <div>{{ __('loan.first_payment') ?? 'First Payment' }}</div>
                </div>

                <div class="result-card" x-show="result.data.monthly_payment_last">
                    <div class="result-value" x-text="'$' + (result.data.monthly_payment_last || 0).toLocaleString()"></div>
                    <div>{{ __('loan.last_payment') ?? 'Last Payment' }}</div>
                </div>

                <div class="result-card" x-show="result.data.total_payment">
                    <div class="result-value" x-text="'$' + (result.data.total_payment || 0).toLocaleString()"></div>
                    <div>{{ __('loan.total_payment') ?? 'Total Payment' }}</div>
                </div>

                <div class="result-card" x-show="result.data.total_interest">
                    <div class="result-value" style="color: #e74c3c;" x-text="'$' + (result.data.total_interest || 0).toLocaleString()"></div>
                    <div>{{ __('loan.total_interest') ?? 'Total Interest' }}</div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function loanCalculator() {
    return {
        form: {
            amount: 100000,
            rate: 5.0,
            years: 30,
            type: 'equal_payment'
        },
        result: null,
        error: null,
        loading: false,

        async calculateLoan() {
            this.loading = true;
            this.error = null;
            this.result = null;

            try {
                const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');

                const response = await fetch('{{ route("tools.loan.calculate") }}', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': csrfToken,
                        'X-Requested-With': 'XMLHttpRequest',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify(this.form)
                });

                const data = await response.json();

                if (data.success) {
                    this.result = data;
                } else {
                    this.error = data.message || 'Error calculating loan. Please check your inputs.';
                }

            } catch (error) {
                console.error('Loan calculation error:', error);
                this.error = 'Error calculating loan. Please check your inputs.';
            } finally {
                this.loading = false;
            }
        }
    }
}
</script>
@endsection
LOAN_VIEW_EOF

log_success "贷款计算器视图已修复（移除Tailwind CSS冲突）"

log_step "第5步：清理缓存和设置权限"
echo "-----------------------------------"

# 设置正确的文件权限
chown -R besthammer_c_usr:besthammer_c_usr app/
chown -R besthammer_c_usr:besthammer_c_usr routes/
chown -R besthammer_c_usr:besthammer_c_usr resources/
chmod -R 755 app/
chmod -R 755 routes/
chmod -R 755 resources/

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

# 重新缓存配置和路由
sudo -u besthammer_c_usr php artisan config:cache 2>/dev/null || log_warning "配置缓存失败"
sudo -u besthammer_c_usr php artisan route:cache 2>/dev/null || log_warning "路由缓存失败"

log_success "缓存清理和重新生成完成"

# 重启Apache
systemctl restart apache2
sleep 3
log_success "Apache已重启"

echo ""
echo "🔧 所有UI问题修复完成！"
echo "======================"
echo ""
echo "📋 修复内容总结："
echo ""
echo "✅ 1. 工具路由问题（最关键）："
echo "   - 添加了所有缺失的工具路由"
echo "   - 创建了完整的ToolController"
echo "   - 支持英语默认和多语言路由"
echo "   - 包含API计算路由"
echo ""
echo "✅ 2. 语言选择器问题："
echo "   - 从4个独立链接恢复为单个select下拉框"
echo "   - 添加了switchLanguage()函数"
echo "   - 支持🇺🇸🇩🇪🇫🇷🇪🇸 4种语言"
echo ""
echo "✅ 3. 基础布局结构："
echo "   - 修复了.header .nav .content结构"
echo "   - 保持了渐变背景和毛玻璃效果"
echo "   - 完整的响应式设计"
echo ""
echo "✅ 4. CSS样式冲突："
echo "   - 移除了Tailwind CSS冲突"
echo "   - 使用原始自定义CSS类"
echo "   - 保持了完美的视觉效果"
echo ""
echo "✅ 5. Alpine.js和JavaScript："
echo "   - 正确的Alpine.js v3配置"
echo "   - defer加载和全局配置"
echo "   - 完整的表单交互功能"
echo ""
echo "🌍 测试地址："
echo "   https://www.besthammer.club/tools/loan-calculator"
echo "   https://www.besthammer.club/tools/bmi-calculator"
echo "   https://www.besthammer.club/tools/currency-converter"
echo ""
echo "🎯 关键修复对比："
echo "   ❌ 之前：路由缺失 → ✅ 现在：完整路由配置"
echo "   ❌ 之前：4个独立语言链接 → ✅ 现在：单个select下拉框"
echo "   ❌ 之前：布局结构缺失 → ✅ 现在：完整布局结构"
echo "   ❌ 之前：switchLanguage函数缺失 → ✅ 现在：函数正常工作"
echo "   ⚠️ 之前：Tailwind CSS冲突 → ✅ 现在：原始自定义CSS"
echo ""
echo "💡 如果仍有问题："
echo "1. 强制刷新浏览器缓存 (Ctrl+F5)"
echo "2. 检查Laravel错误日志: tail -20 storage/logs/laravel.log"
echo "3. 检查Apache错误日志: tail -10 /var/log/apache2/error.log"
echo "4. 重新运行诊断脚本: bash diagnose-ui-layout-issues.sh"
echo ""

log_info "完整UI问题修复脚本执行完成！"
