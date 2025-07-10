#!/bin/bash

# 修复路由语法错误导致的500错误
# 解决 array_merge() 参数类型错误问题

echo "🔧 修复路由语法错误"
echo "=================="
echo "修复内容："
echo "1. 修复路由组where约束语法错误"
echo "2. 使用兼容的路由配置语法"
echo "3. 恢复网站正常访问"
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

log_step "第1步：备份当前错误的路由文件"
echo "-----------------------------------"

# 备份错误的路由文件
if [ -f "routes/web.php" ]; then
    cp routes/web.php "routes/web.php.error.$(date +%Y%m%d_%H%M%S)"
    log_success "已备份错误的路由文件"
fi

log_step "第2步：创建修复后的路由文件"
echo "-----------------------------------"

# 创建修复后的路由配置（使用兼容语法）
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

// 关于页面（英语默认）
Route::get('/about', function () {
    return view('about');
})->name('about');

// 多语言路由 - 德语
Route::prefix('de')->group(function () {
    Route::get('/', function () {
        app()->setLocale('de');
        return view('welcome', ['locale' => 'de']);
    })->name('home.locale.de');
    
    Route::get('/tools/loan-calculator', function () {
        app()->setLocale('de');
        return app(ToolController::class)->localeLoanCalculator('de');
    })->name('tools.locale.loan.de');
    
    Route::get('/tools/bmi-calculator', function () {
        app()->setLocale('de');
        return app(ToolController::class)->localeBmiCalculator('de');
    })->name('tools.locale.bmi.de');
    
    Route::get('/tools/currency-converter', function () {
        app()->setLocale('de');
        return app(ToolController::class)->localeCurrencyConverter('de');
    })->name('tools.locale.currency.de');
    
    Route::get('/about', function () {
        app()->setLocale('de');
        return view('about', ['locale' => 'de']);
    })->name('about.locale.de');
});

// 多语言路由 - 法语
Route::prefix('fr')->group(function () {
    Route::get('/', function () {
        app()->setLocale('fr');
        return view('welcome', ['locale' => 'fr']);
    })->name('home.locale.fr');
    
    Route::get('/tools/loan-calculator', function () {
        app()->setLocale('fr');
        return app(ToolController::class)->localeLoanCalculator('fr');
    })->name('tools.locale.loan.fr');
    
    Route::get('/tools/bmi-calculator', function () {
        app()->setLocale('fr');
        return app(ToolController::class)->localeBmiCalculator('fr');
    })->name('tools.locale.bmi.fr');
    
    Route::get('/tools/currency-converter', function () {
        app()->setLocale('fr');
        return app(ToolController::class)->localeCurrencyConverter('fr');
    })->name('tools.locale.currency.fr');
    
    Route::get('/about', function () {
        app()->setLocale('fr');
        return view('about', ['locale' => 'fr']);
    })->name('about.locale.fr');
});

// 多语言路由 - 西班牙语
Route::prefix('es')->group(function () {
    Route::get('/', function () {
        app()->setLocale('es');
        return view('welcome', ['locale' => 'es']);
    })->name('home.locale.es');
    
    Route::get('/tools/loan-calculator', function () {
        app()->setLocale('es');
        return app(ToolController::class)->localeLoanCalculator('es');
    })->name('tools.locale.loan.es');
    
    Route::get('/tools/bmi-calculator', function () {
        app()->setLocale('es');
        return app(ToolController::class)->localeBmiCalculator('es');
    })->name('tools.locale.bmi.es');
    
    Route::get('/tools/currency-converter', function () {
        app()->setLocale('es');
        return app(ToolController::class)->localeCurrencyConverter('es');
    })->name('tools.locale.currency.es');
    
    Route::get('/about', function () {
        app()->setLocale('es');
        return view('about', ['locale' => 'es']);
    })->name('about.locale.es');
});

// 通用多语言路由（用于switchLanguage函数）
Route::get('/{locale}', function ($locale) {
    if (in_array($locale, ['en', 'de', 'fr', 'es'])) {
        if ($locale === 'en') {
            return redirect()->route('home');
        } else {
            return redirect()->route('home.locale.' . $locale);
        }
    }
    abort(404);
})->where('locale', '[a-z]{2}');

Route::get('/{locale}/tools/loan-calculator', function ($locale) {
    if (in_array($locale, ['en', 'de', 'fr', 'es'])) {
        if ($locale === 'en') {
            return redirect()->route('tools.loan');
        } else {
            return redirect()->route('tools.locale.loan.' . $locale);
        }
    }
    abort(404);
})->where('locale', '[a-z]{2}');

Route::get('/{locale}/tools/bmi-calculator', function ($locale) {
    if (in_array($locale, ['en', 'de', 'fr', 'es'])) {
        if ($locale === 'en') {
            return redirect()->route('tools.bmi');
        } else {
            return redirect()->route('tools.locale.bmi.' . $locale);
        }
    }
    abort(404);
})->where('locale', '[a-z]{2}');

Route::get('/{locale}/tools/currency-converter', function ($locale) {
    if (in_array($locale, ['en', 'de', 'fr', 'es'])) {
        if ($locale === 'en') {
            return redirect()->route('tools.currency');
        } else {
            return redirect()->route('tools.locale.currency.' . $locale);
        }
    }
    abort(404);
})->where('locale', '[a-z]{2}');

Route::get('/{locale}/about', function ($locale) {
    if (in_array($locale, ['en', 'de', 'fr', 'es'])) {
        if ($locale === 'en') {
            return redirect()->route('about');
        } else {
            return redirect()->route('about.locale.' . $locale);
        }
    }
    abort(404);
})->where('locale', '[a-z]{2}');

// 用户认证路由（如果需要）
// Auth::routes();

// 仪表板路由（如果需要）
/*
Route::get('/dashboard', function () {
    return view('dashboard');
})->middleware('auth')->name('dashboard');

Route::get('/{locale}/dashboard', function ($locale) {
    if (in_array($locale, ['en', 'de', 'fr', 'es'])) {
        app()->setLocale($locale);
        return view('dashboard', compact('locale'));
    }
    abort(404);
})->where('locale', '[a-z]{2}')->middleware('auth')->name('dashboard.locale');
*/
ROUTES_EOF

log_success "修复后的路由文件已创建（使用兼容语法）"

log_step "第3步：修复主布局文件中的路由引用"
echo "-----------------------------------"

# 修复主布局文件中的路由名称引用
if [ -f "resources/views/layouts/app.blade.php" ]; then
    # 备份布局文件
    cp resources/views/layouts/app.blade.php "resources/views/layouts/app.blade.php.backup.$(date +%Y%m%d_%H%M%S)"
    
    # 修复路由名称引用
    sed -i 's/route("tools\.locale\.loan", $locale)/route("tools.locale.loan." . $locale)/g' resources/views/layouts/app.blade.php
    sed -i 's/route("tools\.locale\.bmi", $locale)/route("tools.locale.bmi." . $locale)/g' resources/views/layouts/app.blade.php
    sed -i 's/route("tools\.locale\.currency", $locale)/route("tools.locale.currency." . $locale)/g' resources/views/layouts/app.blade.php
    sed -i 's/route("home\.locale", $locale)/route("home.locale." . $locale)/g' resources/views/layouts/app.blade.php
    sed -i 's/route("about\.locale", $locale)/route("about.locale." . $locale)/g' resources/views/layouts/app.blade.php
    sed -i 's/route("dashboard\.locale", $locale)/route("dashboard.locale." . $locale)/g' resources/views/layouts/app.blade.php
    
    log_success "主布局文件中的路由引用已修复"
else
    log_warning "主布局文件不存在，跳过路由引用修复"
fi

log_step "第4步：清理缓存和重启服务"
echo "-----------------------------------"

# 设置正确的文件权限
chown -R besthammer_c_usr:besthammer_c_usr routes/
chmod -R 755 routes/

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

# 测试路由是否正常
log_info "测试路由配置..."
route_test=$(sudo -u besthammer_c_usr php artisan route:list 2>&1)
if echo "$route_test" | grep -q "tools.loan"; then
    log_success "路由配置测试通过"
else
    log_error "路由配置仍有问题"
    echo "路由测试输出:"
    echo "$route_test"
fi

echo ""
echo "🔧 路由语法错误修复完成！"
echo "========================"
echo ""
echo "📋 修复内容总结："
echo "✅ 1. 修复了路由组where约束语法错误"
echo "✅ 2. 使用了兼容的路由配置语法"
echo "✅ 3. 分别定义了每种语言的路由组"
echo "✅ 4. 修复了主布局文件中的路由引用"
echo "✅ 5. 清理了所有Laravel缓存"
echo ""
echo "🌍 测试地址："
echo "   https://www.besthammer.club/"
echo "   https://www.besthammer.club/tools/loan-calculator"
echo "   https://www.besthammer.club/de/tools/loan-calculator"
echo "   https://www.besthammer.club/fr/tools/loan-calculator"
echo "   https://www.besthammer.club/es/tools/loan-calculator"
echo ""
echo "🎯 主要修复："
echo "   ❌ 之前：Route::prefix('{locale}')->where('locale', 'en|de|fr|es')"
echo "   ✅ 现在：Route::prefix('de')->group() 分别定义"
echo ""
echo "💡 如果仍有500错误："
echo "1. 检查Laravel错误日志: tail -20 storage/logs/laravel.log"
echo "2. 检查Apache错误日志: tail -10 /var/log/apache2/error.log"
echo "3. 验证路由列表: php artisan route:list"
echo "4. 检查ToolController是否存在: ls -la app/Http/Controllers/"
echo ""

log_info "路由语法错误修复脚本执行完成！"
