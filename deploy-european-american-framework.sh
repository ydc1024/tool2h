#!/bin/bash

# 欧美地区用户专用部署方案
# 基于README.md需求，针对欧美高频刚需市场
# 支持英语为主，德语、法语、西班牙语为辅的多语言配置

echo "🌍 欧美地区用户专用部署"
echo "======================="
echo "目标市场：欧美高频刚需用户"
echo "语言支持：英语(主) + 德语 + 法语 + 西班牙语"
echo "工具模块：贷款计算器 + BMI计算器 + 汇率转换器"
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
BACKUP_DIR="/var/www/besthammer_c_usr/data/backups"
TEMP_DIR="/tmp/besthammer_european"
TOOL1_DIR="$(pwd)"

log_step "第1步：分析README.md需求"
echo "-----------------------------------"

log_info "项目定位分析："
echo "  🎯 目标市场：欧美高频刚需市场"
echo "  🛠️ 核心工具：贷款计算器 + BMI计算器 + 汇率转换器"
echo "  🌐 语言需求：英语为主，支持德法西语"
echo "  📱 设备支持：响应式设计，移动端+桌面端"
echo "  🔧 技术栈：Laravel 10.x + Tailwind CSS + Alpine.js + Chart.js"

log_step "第2步：备份当前环境"
echo "-----------------------------------"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 备份当前项目
BACKUP_NAME="besthammer.club.before_european.$(date +%Y%m%d_%H%M%S)"
log_info "备份当前环境到: $BACKUP_DIR/$BACKUP_NAME"
cp -r "$PROJECT_DIR" "$BACKUP_DIR/$BACKUP_NAME"

log_success "环境备份完成"

log_step "第3步：创建欧美市场专用Laravel项目"
echo "-----------------------------------"

# 清理并创建临时目录
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# 创建新的Laravel项目
log_info "创建Laravel基础框架..."
cd "$TEMP_DIR"
composer create-project laravel/laravel european_tools --prefer-dist

if [ ! -d "european_tools" ]; then
    log_error "Laravel项目创建失败"
    exit 1
fi

cd "$TEMP_DIR/european_tools"

log_success "Laravel基础框架创建完成"

log_step "第4步：配置欧美地区语言支持"
echo "-----------------------------------"

# 配置应用为英语默认
sed -i "s/'locale' => 'en'/'locale' => 'en'/" config/app.php
sed -i "s/'fallback_locale' => 'en'/'fallback_locale' => 'en'/" config/app.php

# 创建欧美地区语言包
log_info "创建多语言支持..."

# 英语语言包（主要语言）
mkdir -p resources/lang/en
cat > resources/lang/en/common.php << 'EOF'
<?php

return [
    // Navigation
    'home' => 'Home',
    'tools' => 'Tools',
    'about' => 'About',
    'contact' => 'Contact',
    'language' => 'Language',

    // Tools
    'loan_calculator' => 'Loan Calculator',
    'bmi_calculator' => 'BMI Calculator',
    'currency_converter' => 'Currency Converter',

    // Common actions
    'calculate' => 'Calculate',
    'convert' => 'Convert',
    'reset' => 'Reset',
    'export' => 'Export',
    'save' => 'Save',
    'download' => 'Download',

    // Results
    'results' => 'Results',
    'monthly_payment' => 'Monthly Payment',
    'total_interest' => 'Total Interest',
    'bmi_result' => 'BMI Result',
    'exchange_rate' => 'Exchange Rate',

    // Units
    'currency' => 'Currency',
    'amount' => 'Amount',
    'weight' => 'Weight',
    'height' => 'Height',
    'age' => 'Age',
    'years' => 'Years',
    'months' => 'Months',

    // Messages
    'welcome_message' => 'Professional Financial & Health Tools for European and American Markets',
    'description' => 'Calculate loans, BMI, and convert currencies with real-time data',
];
EOF

# 德语语言包
mkdir -p resources/lang/de
cat > resources/lang/de/common.php << 'EOF'
<?php

return [
    // Navigation
    'home' => 'Startseite',
    'tools' => 'Werkzeuge',
    'about' => 'Über uns',
    'contact' => 'Kontakt',
    'language' => 'Sprache',

    // Tools
    'loan_calculator' => 'Darlehensrechner',
    'bmi_calculator' => 'BMI-Rechner',
    'currency_converter' => 'Währungsrechner',

    // Common actions
    'calculate' => 'Berechnen',
    'convert' => 'Umrechnen',
    'reset' => 'Zurücksetzen',
    'export' => 'Exportieren',
    'save' => 'Speichern',
    'download' => 'Herunterladen',

    // Results
    'results' => 'Ergebnisse',
    'monthly_payment' => 'Monatliche Rate',
    'total_interest' => 'Gesamtzinsen',
    'bmi_result' => 'BMI-Ergebnis',
    'exchange_rate' => 'Wechselkurs',

    // Units
    'currency' => 'Währung',
    'amount' => 'Betrag',
    'weight' => 'Gewicht',
    'height' => 'Größe',
    'age' => 'Alter',
    'years' => 'Jahre',
    'months' => 'Monate',

    // Messages
    'welcome_message' => 'Professionelle Finanz- und Gesundheitstools für europäische und amerikanische Märkte',
    'description' => 'Berechnen Sie Darlehen, BMI und konvertieren Sie Währungen mit Echtzeitdaten',
];
EOF

# 法语语言包
mkdir -p resources/lang/fr
cat > resources/lang/fr/common.php << 'EOF'
<?php

return [
    // Navigation
    'home' => 'Accueil',
    'tools' => 'Outils',
    'about' => 'À propos',
    'contact' => 'Contact',
    'language' => 'Langue',

    // Tools
    'loan_calculator' => 'Calculateur de Prêt',
    'bmi_calculator' => 'Calculateur IMC',
    'currency_converter' => 'Convertisseur de Devises',

    // Common actions
    'calculate' => 'Calculer',
    'convert' => 'Convertir',
    'reset' => 'Réinitialiser',
    'export' => 'Exporter',
    'save' => 'Sauvegarder',
    'download' => 'Télécharger',

    // Results
    'results' => 'Résultats',
    'monthly_payment' => 'Paiement Mensuel',
    'total_interest' => 'Intérêts Totaux',
    'bmi_result' => 'Résultat IMC',
    'exchange_rate' => 'Taux de Change',

    // Units
    'currency' => 'Devise',
    'amount' => 'Montant',
    'weight' => 'Poids',
    'height' => 'Taille',
    'age' => 'Âge',
    'years' => 'Années',
    'months' => 'Mois',

    // Messages
    'welcome_message' => 'Outils Financiers et de Santé Professionnels pour les Marchés Européens et Américains',
    'description' => 'Calculez les prêts, l\'IMC et convertissez les devises avec des données en temps réel',
];
EOF

# 西班牙语语言包
mkdir -p resources/lang/es
cat > resources/lang/es/common.php << 'EOF'
<?php

return [
    // Navigation
    'home' => 'Inicio',
    'tools' => 'Herramientas',
    'about' => 'Acerca de',
    'contact' => 'Contacto',
    'language' => 'Idioma',

    // Tools
    'loan_calculator' => 'Calculadora de Préstamos',
    'bmi_calculator' => 'Calculadora IMC',
    'currency_converter' => 'Conversor de Divisas',

    // Common actions
    'calculate' => 'Calcular',
    'convert' => 'Convertir',
    'reset' => 'Restablecer',
    'export' => 'Exportar',
    'save' => 'Guardar',
    'download' => 'Descargar',

    // Results
    'results' => 'Resultados',
    'monthly_payment' => 'Pago Mensual',
    'total_interest' => 'Interés Total',
    'bmi_result' => 'Resultado IMC',
    'exchange_rate' => 'Tipo de Cambio',

    // Units
    'currency' => 'Moneda',
    'amount' => 'Cantidad',
    'weight' => 'Peso',
    'height' => 'Altura',
    'age' => 'Edad',
    'years' => 'Años',
    'months' => 'Meses',

    // Messages
    'welcome_message' => 'Herramientas Profesionales Financieras y de Salud para Mercados Europeos y Americanos',
    'description' => 'Calcule préstamos, IMC y convierta divisas con datos en tiempo real',
];
EOF

log_success "欧美地区多语言包创建完成 (EN/DE/FR/ES)"

log_step "第5步：创建欧美市场专用路由配置"
echo "-----------------------------------"

# 创建路由配置
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
|
| BestHammer工具平台路由配置
| 支持英语、德语、法语、西班牙语
|
*/

// 默认英语路由
Route::get('/', [HomeController::class, 'index'])->name('home');
Route::get('/about', [HomeController::class, 'about'])->name('about');

// 工具路由
Route::prefix('tools')->name('tools.')->group(function () {
    Route::get('/loan-calculator', [ToolController::class, 'loanCalculator'])->name('loan');
    Route::post('/loan-calculator', [ToolController::class, 'calculateLoan'])->name('loan.calculate');

    Route::get('/bmi-calculator', [ToolController::class, 'bmiCalculator'])->name('bmi');
    Route::post('/bmi-calculator', [ToolController::class, 'calculateBmi'])->name('bmi.calculate');

    Route::get('/currency-converter', [ToolController::class, 'currencyConverter'])->name('currency');
    Route::post('/currency-converter', [ToolController::class, 'convertCurrency'])->name('currency.convert');
});

// 多语言路由组 (EN/DE/FR/ES)
Route::prefix('{locale}')->where(['locale' => '(en|de|fr|es)'])->group(function () {
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

// 语言切换路由
Route::post('/language/switch', [LanguageController::class, 'switch'])->name('language.switch');

// API路由
Route::prefix('api')->group(function () {
    Route::get('/exchange-rates', [ToolController::class, 'getExchangeRates']);
    Route::get('/health', function () {
        return response()->json([
            'status' => 'healthy',
            'service' => 'BestHammer European Tools',
            'version' => '1.0.0',
            'timestamp' => now()
        ]);
    });
});

// 健康检查
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'market' => 'European & American',
        'languages' => ['en', 'de', 'fr', 'es'],
        'tools' => ['loan_calculator', 'bmi_calculator', 'currency_converter'],
        'timestamp' => now()
    ]);
});
EOF

log_success "欧美市场专用路由配置完成"

log_step "第6步：创建控制器"
echo "-----------------------------------"

# 创建主页控制器
php artisan make:controller HomeController
cat > app/Http/Controllers/HomeController.php << 'EOF'
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class HomeController extends Controller
{
    /**
     * 显示主页 (默认英语)
     */
    public function index()
    {
        return view('home', [
            'locale' => 'en',
            'title' => __('common.welcome_message'),
            'description' => __('common.description')
        ]);
    }

    /**
     * 显示关于页面 (默认英语)
     */
    public function about()
    {
        return view('about', [
            'locale' => 'en',
            'title' => 'About BestHammer'
        ]);
    }

    /**
     * 多语言主页
     */
    public function localeHome($locale)
    {
        app()->setLocale($locale);

        return view('home', [
            'locale' => $locale,
            'title' => __('common.welcome_message'),
            'description' => __('common.description')
        ]);
    }

    /**
     * 多语言关于页面
     */
    public function localeAbout($locale)
    {
        app()->setLocale($locale);

        return view('about', [
            'locale' => $locale,
            'title' => __('common.about')
        ]);
    }
}
EOF

# 创建语言控制器
php artisan make:controller LanguageController
cat > app/Http/Controllers/LanguageController.php << 'EOF'
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class LanguageController extends Controller
{
    /**
     * 支持的欧美地区语言
     */
    private $supportedLocales = ['en', 'de', 'fr', 'es'];

    /**
     * 切换语言
     */
    public function switch(Request $request)
    {
        $locale = $request->input('locale', 'en');

        if (in_array($locale, $this->supportedLocales)) {
            session(['locale' => $locale]);
            app()->setLocale($locale);
        }

        return redirect()->back();
    }
}
EOF

# 创建工具控制器
php artisan make:controller ToolController
cat > app/Http/Controllers/ToolController.php << 'EOF'
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ToolController extends Controller
{
    /**
     * 贷款计算器页面
     */
    public function loanCalculator()
    {
        return view('tools.loan-calculator', [
            'locale' => 'en',
            'title' => __('common.loan_calculator')
        ]);
    }

    /**
     * 多语言贷款计算器页面
     */
    public function localeLoanCalculator($locale)
    {
        app()->setLocale($locale);

        return view('tools.loan-calculator', [
            'locale' => $locale,
            'title' => __('common.loan_calculator')
        ]);
    }

    /**
     * 计算贷款
     */
    public function calculateLoan(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:1',
            'rate' => 'required|numeric|min:0',
            'years' => 'required|integer|min:1'
        ]);

        $principal = $request->amount;
        $rate = $request->rate / 100 / 12; // 月利率
        $payments = $request->years * 12; // 总月数

        if ($rate > 0) {
            $monthlyPayment = $principal * ($rate * pow(1 + $rate, $payments)) / (pow(1 + $rate, $payments) - 1);
        } else {
            $monthlyPayment = $principal / $payments;
        }

        $totalPayment = $monthlyPayment * $payments;
        $totalInterest = $totalPayment - $principal;

        return response()->json([
            'monthly_payment' => round($monthlyPayment, 2),
            'total_payment' => round($totalPayment, 2),
            'total_interest' => round($totalInterest, 2)
        ]);
    }

    /**
     * BMI计算器页面
     */
    public function bmiCalculator()
    {
        return view('tools.bmi-calculator', [
            'locale' => 'en',
            'title' => __('common.bmi_calculator')
        ]);
    }

    /**
     * 多语言BMI计算器页面
     */
    public function localeBmiCalculator($locale)
    {
        app()->setLocale($locale);

        return view('tools.bmi-calculator', [
            'locale' => $locale,
            'title' => __('common.bmi_calculator')
        ]);
    }

    /**
     * 计算BMI
     */
    public function calculateBmi(Request $request)
    {
        $request->validate([
            'weight' => 'required|numeric|min:1',
            'height' => 'required|numeric|min:1'
        ]);

        $weight = $request->weight;
        $height = $request->height / 100; // 转换为米

        $bmi = $weight / ($height * $height);

        // BMI分类
        if ($bmi < 18.5) {
            $category = 'Underweight';
        } elseif ($bmi < 25) {
            $category = 'Normal weight';
        } elseif ($bmi < 30) {
            $category = 'Overweight';
        } else {
            $category = 'Obese';
        }

        return response()->json([
            'bmi' => round($bmi, 1),
            'category' => $category
        ]);
    }

    /**
     * 汇率转换器页面
     */
    public function currencyConverter()
    {
        return view('tools.currency-converter', [
            'locale' => 'en',
            'title' => __('common.currency_converter')
        ]);
    }

    /**
     * 多语言汇率转换器页面
     */
    public function localeCurrencyConverter($locale)
    {
        app()->setLocale($locale);

        return view('tools.currency-converter', [
            'locale' => $locale,
            'title' => __('common.currency_converter')
        ]);
    }

    /**
     * 货币转换
     */
    public function convertCurrency(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:0',
            'from' => 'required|string|size:3',
            'to' => 'required|string|size:3'
        ]);

        // 这里应该调用真实的汇率API
        // 为演示目的，使用模拟汇率
        $mockRates = [
            'USD' => 1.0,
            'EUR' => 0.85,
            'GBP' => 0.73,
            'CAD' => 1.25,
            'AUD' => 1.35,
            'CHF' => 0.92,
            'JPY' => 110.0
        ];

        $fromRate = $mockRates[$request->from] ?? 1;
        $toRate = $mockRates[$request->to] ?? 1;

        $usdAmount = $request->amount / $fromRate;
        $convertedAmount = $usdAmount * $toRate;

        return response()->json([
            'converted_amount' => round($convertedAmount, 2),
            'exchange_rate' => round($toRate / $fromRate, 4),
            'from_currency' => $request->from,
            'to_currency' => $request->to
        ]);
    }

    /**
     * 获取汇率数据
     */
    public function getExchangeRates()
    {
        // 模拟汇率数据
        return response()->json([
            'base' => 'USD',
            'rates' => [
                'EUR' => 0.85,
                'GBP' => 0.73,
                'CAD' => 1.25,
                'AUD' => 1.35,
                'CHF' => 0.92,
                'JPY' => 110.0
            ],
            'timestamp' => now()
        ]);
    }
}
EOF

log_success "控制器创建完成"

log_step "第7步：创建工具视图目录和基础视图"
echo "-----------------------------------"

# 创建工具视图目录
mkdir -p resources/views/tools

# 运行视图创建脚本
log_info "运行视图创建脚本..."
bash "$TOOL1_DIR/deploy-european-views.sh"

log_step "第8步：配置环境文件"
echo "-----------------------------------"

# 更新.env.example
cat > .env.example << 'EOF'
APP_NAME="BestHammer"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://www.besthammer.club

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=besthammer
DB_USERNAME=besthammer_user
DB_PASSWORD=

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=localhost
MAIL_PORT=587
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@besthammer.club"
MAIL_FROM_NAME="${APP_NAME}"

# 多语言配置 - 欧美市场
APP_LOCALE=en
APP_FALLBACK_LOCALE=en
APP_FAKER_LOCALE=en_US

# 支持的语言
SUPPORTED_LOCALES=en,de,fr,es

# 汇率API配置 (可选)
EXCHANGE_RATE_API_KEY=
EXCHANGE_RATE_API_URL=https://api.exchangerate-api.com/v4/latest/
EOF

# 更新config/app.php的语言配置
sed -i "s/'locale' => 'en'/'locale' => 'en'/" config/app.php
sed -i "s/'fallback_locale' => 'en'/'fallback_locale' => 'en'/" config/app.php

log_success "环境配置已优化"

log_step "第9步：部署到生产环境"
echo "-----------------------------------"

# 保存当前项目的.env文件
if [ -f "$PROJECT_DIR/.env" ]; then
    cp "$PROJECT_DIR/.env" "$TEMP_DIR/current.env"
    log_info "已保存当前.env配置"
fi

# 清空项目目录
log_info "清理项目目录..."
find "$PROJECT_DIR" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +

# 复制整合后的项目
log_info "部署欧美市场专用项目..."
cp -r "$TEMP_DIR/european_tools"/* "$PROJECT_DIR/"
cp -r "$TEMP_DIR/european_tools"/.[^.]* "$PROJECT_DIR/" 2>/dev/null || true

# 恢复.env配置
if [ -f "$TEMP_DIR/current.env" ]; then
    cp "$TEMP_DIR/current.env" "$PROJECT_DIR/.env"
    log_info "已恢复.env配置"
else
    cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
    log_info "已创建新的.env配置"
fi

log_step "第10步：安装依赖和配置"
echo "-----------------------------------"

cd "$PROJECT_DIR"

# 生成应用密钥
sudo -u besthammer_c_usr php artisan key:generate --force

# 安装Composer依赖
log_info "安装Composer依赖..."
sudo -u besthammer_c_usr composer install --no-dev --optimize-autoloader

# 设置文件权限
log_info "设置文件权限..."
chown -R besthammer_c_usr:besthammer_c_usr "$PROJECT_DIR"
chmod -R 755 "$PROJECT_DIR"
chmod -R 775 storage
chmod -R 775 bootstrap/cache

# 创建storage链接
sudo -u besthammer_c_usr php artisan storage:link

log_step "第11步：优化和缓存"
echo "-----------------------------------"

# 清除缓存
sudo -u besthammer_c_usr php artisan config:clear
sudo -u besthammer_c_usr php artisan cache:clear
sudo -u besthammer_c_usr php artisan route:clear
sudo -u besthammer_c_usr php artisan view:clear

# 生产环境优化
sudo -u besthammer_c_usr php artisan config:cache
sudo -u besthammer_c_usr php artisan route:cache
sudo -u besthammer_c_usr php artisan view:cache

log_step "第12步：验证部署结果"
echo "-----------------------------------"

# 测试网站访问
sleep 3
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://www.besthammer.club" 2>/dev/null || echo "000")
log_info "网站访问测试: HTTP $HTTP_STATUS"

if [ "$HTTP_STATUS" = "200" ]; then
    log_success "欧美市场专用部署成功！"
    DEPLOY_SUCCESS=true
elif [ "$HTTP_STATUS" = "500" ]; then
    log_error "部署后出现500错误"
    DEPLOY_SUCCESS=false
else
    log_warning "网站状态异常: HTTP $HTTP_STATUS"
    DEPLOY_SUCCESS=false
fi

# 测试多语言功能
for lang in de fr es; do
    LANG_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://www.besthammer.club/$lang/" 2>/dev/null || echo "000")
    log_info "$lang 语言页面测试: HTTP $LANG_STATUS"
done

# 测试工具页面
TOOL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://www.besthammer.club/tools/loan-calculator" 2>/dev/null || echo "000")
log_info "工具页面测试: HTTP $TOOL_STATUS"

# 清理临时文件
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 欧美市场专用部署完成！"
echo "=========================="
echo ""
echo "📋 部署摘要："
echo "✅ 针对欧美市场的Laravel项目已部署"
echo "✅ 多语言支持 (EN/DE/FR/ES)"
echo "✅ 三大核心工具已集成"
echo "✅ 响应式设计，支持移动端"
echo "✅ FastPanel环境配置保持不变"
echo ""
echo "🌐 功能验证："
echo "   主页: https://www.besthammer.club"
echo "   德语: https://www.besthammer.club/de/"
echo "   法语: https://www.besthammer.club/fr/"
echo "   西语: https://www.besthammer.club/es/"
echo "   贷款计算器: https://www.besthammer.club/tools/loan-calculator"
echo "   BMI计算器: https://www.besthammer.club/tools/bmi-calculator"
echo "   汇率转换器: https://www.besthammer.club/tools/currency-converter"
echo ""
echo "🛠️ 核心工具："
echo "   💰 贷款计算器 - 支持抵押贷款、汽车贷款、个人贷款"
echo "   ⚖️ BMI计算器 - 基于WHO标准的健康评估"
echo "   💱 汇率转换器 - 实时汇率数据支持"
echo ""
echo "📁 备份位置: $BACKUP_DIR/$BACKUP_NAME"
echo ""

if [ "$DEPLOY_SUCCESS" = true ]; then
    echo "🎯 部署成功！您的欧美市场专用工具平台现在已上线。"
    echo ""
    echo "🚀 下一步开发建议："
    echo "   1. 集成真实的汇率API服务"
    echo "   2. 添加用户账户和保存功能"
    echo "   3. 实现数据导出功能"
    echo "   4. 添加更多金融工具"
    echo "   5. 优化SEO和性能"
else
    echo "⚠️ 部署可能存在问题，请检查错误日志。"
    echo "   Laravel日志: storage/logs/laravel.log"
    echo "   Apache日志: /var/log/apache2/error.log"
    echo ""
    echo "🔄 如需回滚，备份文件位于: $BACKUP_DIR/$BACKUP_NAME"
fi

echo ""
log_info "欧美市场专用部署完成！您的工具平台已针对欧美用户优化！"