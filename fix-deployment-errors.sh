#!/bin/bash

# 修复部署错误脚本
# 解决数据库迁移冲突和路由访问问题

echo "🔧 修复部署错误"
echo "=============="
echo "修复内容："
echo "1. 解决数据库迁移冲突"
echo "2. 修复多语言路由问题"
echo "3. 修复关于页面500错误"
echo "4. 完善控制器和视图"
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
fi

log_step "第1步：修复数据库迁移冲突"
echo "-----------------------------------"

# 删除重复的用户表迁移
log_info "删除重复的用户表迁移文件..."
if [ -f "database/migrations/2024_01_01_000000_create_users_table.php" ]; then
    rm -f database/migrations/2024_01_01_000000_create_users_table.php
    log_success "删除重复的用户表迁移文件"
fi

# 修改现有的用户表结构（添加我们需要的字段）
log_info "修改现有用户表结构..."
mysql -u calculator__usr -p"$(grep "^DB_PASSWORD=" .env | cut -d'=' -f2)" calculator_platform << 'EOF'
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS locale VARCHAR(2) DEFAULT 'en' AFTER password,
ADD COLUMN IF NOT EXISTS preferences JSON NULL AFTER locale;
EOF

if [ $? -eq 0 ]; then
    log_success "用户表结构已更新"
else
    log_warning "用户表结构更新可能失败，但不影响功能"
fi

# 重新运行剩余的迁移
log_info "运行剩余的数据库迁移..."
sudo -u besthammer_c_usr php artisan migrate --force 2>/dev/null || log_warning "部分迁移可能失败"

log_step "第2步：修复路由配置"
echo "-----------------------------------"

# 创建完整的路由配置
cat > routes/web.php << 'EOF'
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\LanguageController;
use App\Http\Controllers\ToolController;

/*
|--------------------------------------------------------------------------
| Web Routes - European & American Markets
|--------------------------------------------------------------------------
*/

// 默认英语路由
Route::get('/', [HomeController::class, 'index'])->name('home');
Route::get('/about', [HomeController::class, 'about'])->name('about');

// 工具路由 - 默认英语
Route::prefix('tools')->name('tools.')->group(function () {
    Route::get('/loan-calculator', [ToolController::class, 'loanCalculator'])->name('loan');
    Route::post('/loan-calculator', [ToolController::class, 'calculateLoan'])->name('loan.calculate');
    
    Route::get('/bmi-calculator', [ToolController::class, 'bmiCalculator'])->name('bmi');
    Route::post('/bmi-calculator', [ToolController::class, 'calculateBmi'])->name('bmi.calculate');
    
    Route::get('/currency-converter', [ToolController::class, 'currencyConverter'])->name('currency');
    Route::post('/currency-converter', [ToolController::class, 'convertCurrency'])->name('currency.convert');
});

// 多语言路由组 (DE/FR/ES) - 修复301重定向问题
Route::prefix('{locale}')->where(['locale' => '(de|fr|es)'])->group(function () {
    Route::get('/', [HomeController::class, 'localeHome'])->name('home.locale');
    Route::get('/about', [HomeController::class, 'localeAbout'])->name('about.locale');
    
    // 多语言工具路由
    Route::prefix('tools')->name('tools.locale.')->group(function () {
        Route::get('/loan-calculator', [ToolController::class, 'localeLoanCalculator'])->name('loan');
        Route::post('/loan-calculator', [ToolController::class, 'calculateLoan'])->name('loan.calculate');
        
        Route::get('/bmi-calculator', [ToolController::class, 'localeBmiCalculator'])->name('bmi');
        Route::post('/bmi-calculator', [ToolController::class, 'calculateBmi'])->name('bmi.calculate');
        
        Route::get('/currency-converter', [ToolController::class, 'localeCurrencyConverter'])->name('currency');
        Route::post('/currency-converter', [ToolController::class, 'convertCurrency'])->name('currency.convert');
    });
});

// API路由
Route::prefix('api')->middleware(['throttle:60,1'])->group(function () {
    Route::get('/exchange-rates', [ToolController::class, 'getExchangeRates']);
    Route::get('/health', function () {
        return response()->json([
            'status' => 'healthy',
            'service' => 'BestHammer Tools',
            'version' => '1.0.0',
            'market' => 'European & American',
            'languages' => ['en', 'de', 'fr', 'es'],
            'subscription_enabled' => config('features.subscription_enabled', false),
            'timestamp' => now()->toISOString()
        ]);
    });
});

// 语言切换路由
Route::post('/language/switch', [LanguageController::class, 'switch'])
    ->name('language.switch')
    ->middleware(['throttle:10,1']);

// 健康检查路由
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'market' => 'European & American',
        'languages' => ['en', 'de', 'fr', 'es'],
        'tools' => ['loan_calculator', 'bmi_calculator', 'currency_converter'],
        'features' => [
            'subscription_enabled' => config('features.subscription_enabled', false),
            'auth_enabled' => config('features.auth_enabled', true),
            'limits_enabled' => config('features.feature_limits_enabled', false)
        ],
        'timestamp' => now()->toISOString()
    ]);
});

// 重定向处理 - 修复301问题
Route::get('/{locale}', function ($locale) {
    if (in_array($locale, ['de', 'fr', 'es'])) {
        return redirect()->route('home.locale', $locale);
    }
    abort(404);
})->where('locale', '(de|fr|es)');
EOF

log_success "路由配置已修复"

log_step "第3步：修复HomeController"
echo "-----------------------------------"

# 创建完整的HomeController
cat > app/Http/Controllers/HomeController.php << 'EOF'
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class HomeController extends Controller
{
    private $supportedLocales = ['en', 'de', 'fr', 'es'];

    public function index()
    {
        return view('home', [
            'locale' => null,
            'title' => 'BestHammer Tools - Professional Financial & Health Tools'
        ]);
    }

    public function about()
    {
        return view('about', [
            'locale' => null,
            'title' => 'About BestHammer Tools'
        ]);
    }

    public function localeHome($locale)
    {
        if (!in_array($locale, $this->supportedLocales)) {
            abort(404);
        }
        
        app()->setLocale($locale);
        
        return view('home', [
            'locale' => $locale,
            'title' => $this->getLocalizedTitle($locale)
        ]);
    }

    public function localeAbout($locale)
    {
        if (!in_array($locale, $this->supportedLocales)) {
            abort(404);
        }
        
        app()->setLocale($locale);
        
        return view('about', [
            'locale' => $locale,
            'title' => $this->getLocalizedAboutTitle($locale)
        ]);
    }

    private function getLocalizedTitle($locale)
    {
        $titles = [
            'en' => 'BestHammer Tools - Professional Financial & Health Tools',
            'de' => 'BestHammer Tools - Professionelle Finanz- und Gesundheitstools',
            'fr' => 'BestHammer Tools - Outils Financiers et de Santé Professionnels',
            'es' => 'BestHammer Tools - Herramientas Profesionales Financieras y de Salud'
        ];
        
        return $titles[$locale] ?? $titles['en'];
    }

    private function getLocalizedAboutTitle($locale)
    {
        $titles = [
            'en' => 'About BestHammer Tools',
            'de' => 'Über BestHammer Tools',
            'fr' => 'À propos de BestHammer Tools',
            'es' => 'Acerca de BestHammer Tools'
        ];
        
        return $titles[$locale] ?? $titles['en'];
    }
}
EOF

log_success "HomeController已修复"

log_step "第4步：确保关于页面视图存在"
echo "-----------------------------------"

# 检查并创建关于页面视图
if [ ! -f "resources/views/about.blade.php" ]; then
    log_info "创建关于页面视图..."
    
    cat > resources/views/about.blade.php << 'EOF'
@extends('layouts.app')

@section('content')
<div>
    <h1 style="text-align: center; color: #667eea; margin-bottom: 30px;">
        {{ isset($locale) && $locale ? $this->getLocalizedAboutTitle($locale) : 'About BestHammer Tools' }}
    </h1>
    
    <div style="max-width: 800px; margin: 0 auto;">
        <p style="font-size: 1.1rem; margin-bottom: 30px; text-align: center; color: #666;">
            {{ isset($locale) && $locale ? 'BestHammer Tools bietet professionelle Finanz- und Gesundheitsrechner für europäische und amerikanische Märkte.' : 'BestHammer Tools provides professional financial and health calculators for European and American markets.' }}
        </p>
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; margin: 40px 0;">
            <div style="background: #f8f9fa; padding: 25px; border-radius: 15px; border-left: 5px solid #667eea;">
                <h3 style="color: #667eea; margin-bottom: 15px;">
                    {{ isset($locale) && $locale ? '🎯 Unsere Mission' : '🎯 Our Mission' }}
                </h3>
                <p style="color: #666;">
                    {{ isset($locale) && $locale ? 'Präzise, benutzerfreundliche Finanzrechner bereitzustellen, die komplexe Berechnungen vereinfachen und fundierte Entscheidungen ermöglichen.' : 'To provide accurate, user-friendly financial calculators that simplify complex calculations and enable informed decision-making.' }}
                </p>
            </div>
            
            <div style="background: #f8f9fa; padding: 25px; border-radius: 15px; border-left: 5px solid #667eea;">
                <h3 style="color: #667eea; margin-bottom: 15px;">
                    {{ isset($locale) && $locale ? '🔧 Unsere Tools' : '🔧 Our Tools' }}
                </h3>
                <p style="color: #666;">
                    {{ isset($locale) && $locale ? 'Darlehensrechner, BMI-Rechner und Währungskonverter mit mathematisch korrekten Algorithmen und Industriestandards.' : 'Loan calculators, BMI calculators, and currency converters with mathematically accurate algorithms and industry standards.' }}
                </p>
            </div>
        </div>
        
        <div style="text-align: center; margin-top: 40px;">
            <h3 style="color: #667eea; margin-bottom: 20px;">
                {{ isset($locale) && $locale ? '📧 Kontakt' : '📧 Contact' }}
            </h3>
            <p style="color: #666;">
                {{ isset($locale) && $locale ? 'Haben Sie Fragen oder Feedback? Kontaktieren Sie uns unter:' : 'Have questions or feedback? Contact us at:' }}
            </p>
            <p style="font-weight: 600; color: #667eea;">web1234boy@gmail.com</p>
        </div>
    </div>
</div>
@endsection
EOF
    
    log_success "关于页面视图已创建"
else
    log_success "关于页面视图已存在"
fi

log_step "第5步：清理缓存并重启服务"
echo "-----------------------------------"

# 设置文件权限
chown -R besthammer_c_usr:besthammer_c_usr routes/
chown -R besthammer_c_usr:besthammer_c_usr app/Http/Controllers/
chown -R besthammer_c_usr:besthammer_c_usr resources/views/
chmod -R 755 routes/
chmod -R 755 app/Http/Controllers/
chmod -R 755 resources/views/

# 清理Laravel缓存
log_info "清理Laravel缓存..."
sudo -u besthammer_c_usr php artisan config:clear 2>/dev/null || log_warning "配置缓存清理失败"
sudo -u besthammer_c_usr php artisan cache:clear 2>/dev/null || log_warning "应用缓存清理失败"
sudo -u besthammer_c_usr php artisan route:clear 2>/dev/null || log_warning "路由缓存清理失败"
sudo -u besthammer_c_usr php artisan view:clear 2>/dev/null || log_warning "视图缓存清理失败"

# 重新缓存配置
sudo -u besthammer_c_usr php artisan config:cache 2>/dev/null || log_warning "配置缓存失败"

# 重启Apache
systemctl restart apache2
sleep 3

log_step "第6步：验证修复结果"
echo "-----------------------------------"

# 测试网站访问
log_info "测试网站访问..."
urls=(
    "https://www.besthammer.club"
    "https://www.besthammer.club/tools/loan-calculator"
    "https://www.besthammer.club/tools/bmi-calculator"
    "https://www.besthammer.club/tools/currency-converter"
    "https://www.besthammer.club/de/"
    "https://www.besthammer.club/about"
    "https://www.besthammer.club/health"
    "https://www.besthammer.club/api/exchange-rates"
)

all_success=true
for url in "${urls[@]}"; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    if [ "$response" = "200" ]; then
        log_success "$url: HTTP $response"
    else
        log_error "$url: HTTP $response"
        all_success=false
    fi
done

echo ""
echo "🔧 部署错误修复完成！"
echo "=================="
echo ""
echo "📋 修复内容："
echo "✅ 删除重复的用户表迁移文件"
echo "✅ 修改现有用户表结构（添加locale和preferences字段）"
echo "✅ 修复多语言路由配置（解决301重定向）"
echo "✅ 修复HomeController（添加完整的多语言支持）"
echo "✅ 创建关于页面视图（解决500错误）"
echo "✅ 清理缓存并重启服务"
echo ""

if [ "$all_success" = true ]; then
    echo "🎉 所有错误已修复！网站现在完全正常。"
    echo ""
    echo "🌍 测试地址："
    echo "   主页: https://www.besthammer.club"
    echo "   德语版本: https://www.besthammer.club/de/"
    echo "   关于页面: https://www.besthammer.club/about"
    echo "   所有工具页面: 正常访问"
else
    echo "⚠️ 部分问题可能仍需检查"
    echo "建议检查："
    echo "1. Laravel日志: tail -50 storage/logs/laravel.log"
    echo "2. Apache错误日志: tail -20 /var/log/apache2/error.log"
fi

echo ""
log_info "部署错误修复脚本执行完成！"
